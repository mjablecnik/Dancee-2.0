import { config } from "../core/config";
import { getOpenAI } from "../core/openai";
import { getImageGenerationPrompt } from "../core/prompts";
import { uploadFile, findExpiredEventWithImage } from "../clients/directus-client";
import { log } from "../core/logger";

export interface ImageProcessResult {
  fileId: string | null;
  source: "facebook" | "ai_generated" | null;
}

/**
 * Downloads an image from a URL and returns the buffer, MIME type, and filename.
 * Throws on HTTP errors or timeouts.
 */
export async function downloadImage(
  url: string,
): Promise<{ buffer: Buffer; mimeType: string; filename: string }> {
  const response = await fetch(url, {
    signal: AbortSignal.timeout(30000),
  });
  if (!response.ok) {
    throw new Error(`Failed to download image from ${url}: HTTP ${response.status}`);
  }
  const contentType = response.headers.get("content-type") ?? "image/jpeg";
  const mimeType = contentType.split(";")[0].trim();
  const arrayBuffer = await response.arrayBuffer();
  const buffer = Buffer.from(arrayBuffer);
  const ext = mimeType === "image/png" ? "png" : mimeType === "image/webp" ? "webp" : "jpg";
  const filename = `event-image.${ext}`;
  return { buffer, mimeType, filename };
}

/**
 * Generates an AI image via OpenRouter using the configured image generation model.
 * OpenRouter returns images in a non-standard `images` field on the message object
 * (not in `content`), with structure: images[].image_url.url = "data:image/png;base64,..."
 * Returns the image as a Buffer.
 */
export async function generateAiImage(
  title: string,
  primaryDance: string,
  eventType: string,
): Promise<Buffer> {
  const prompt = getImageGenerationPrompt(title, primaryDance, eventType);
  const openai = getOpenAI();
  const response = await openai.chat.completions.create({
    model: config.imageGenerationModel,
    messages: [{ role: "user", content: prompt }],
    // @ts-expect-error — OpenRouter extension: request image output modality
    modalities: ["image"],
  }) as any;

  const message = response.choices?.[0]?.message;

  // OpenRouter returns images in a separate `images` array on the message object
  if (Array.isArray(message?.images)) {
    for (const img of message.images) {
      if (img?.type === "image_url" && img?.image_url?.url) {
        const match = img.image_url.url.match(/data:image\/[^;]+;base64,(.+)/s);
        if (match) {
          return Buffer.from(match[1], "base64");
        }
      }
    }
  }

  // Fallback: check content as string (some models may use this)
  if (typeof message?.content === "string" && message.content.length > 0) {
    const match = message.content.match(/data:image\/[^;]+;base64,(.+)/s);
    if (match) {
      return Buffer.from(match[1], "base64");
    }
  }

  // Fallback: check content as array
  if (Array.isArray(message?.content)) {
    for (const part of message.content) {
      if (part?.type === "image_url" && part?.image_url?.url) {
        const match = part.image_url.url.match(/data:image\/[^;]+;base64,(.+)/s);
        if (match) {
          return Buffer.from(match[1], "base64");
        }
      }
    }
  }

  throw new Error("AI image generation returned no valid image data");
}

/**
 * Processes an event/course image using the fallback chain:
 * 1. Download from Facebook URL (if provided)
 * 2. Reuse an AI-generated image from an expired event with matching dance/type
 * 3. Generate a new AI image via OpenRouter
 * 4. Return null if all steps fail
 */
export async function processEventImage(
  imageUrl: string | null | undefined,
  primaryDance: string,
  eventType: string,
  title: string,
): Promise<ImageProcessResult> {
  // Step 1: Download from Facebook URL
  if (imageUrl) {
    try {
      const { buffer, mimeType, filename } = await downloadImage(imageUrl);
      const fileId = await uploadFile(buffer, filename, mimeType);
      return { fileId, source: "facebook" };
    } catch (err) {
      log({ level: "warn", message: "Failed to download Facebook image, falling back", reason: err instanceof Error ? err.message : String(err) });
    }
  }

  // Step 2: Reuse AI-generated image from an expired event
  try {
    const reusableFileId = await findExpiredEventWithImage(primaryDance, eventType);
    if (reusableFileId) {
      return { fileId: reusableFileId, source: "ai_generated" };
    }
  } catch (err) {
    log({ level: "warn", message: "Failed to find reusable image, falling back to AI generation", reason: err instanceof Error ? err.message : String(err) });
  }

  // Step 3: Generate a new AI image
  try {
    const buffer = await generateAiImage(title, primaryDance, eventType);
    const fileId = await uploadFile(buffer, "ai-generated-event-image.png", "image/png");
    return { fileId, source: "ai_generated" };
  } catch (err) {
    log({ level: "warn", message: "Failed to generate AI image, storing null", reason: err instanceof Error ? err.message : String(err) });
  }

  // Step 4: All fallbacks failed
  return { fileId: null, source: null };
}
