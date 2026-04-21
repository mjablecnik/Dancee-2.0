import { describe, it, expect, vi, beforeEach } from "vitest";

vi.mock("../../core/config", () => ({
  config: {
    openRouterApiKey: "test-key",
    openRouterModel: "test-model",
    imageGenerationModel: "test-image-model",
    directusBaseUrl: "http://localhost:8055",
    directusAccessToken: "test-token",
    directusTimeoutMs: 30000,
  },
}));

const { mockUploadFile, mockFindExpiredEventWithImage } = vi.hoisted(() => ({
  mockUploadFile: vi.fn(),
  mockFindExpiredEventWithImage: vi.fn(),
}));

vi.mock("../../clients/directus-client", () => ({
  uploadFile: mockUploadFile,
  findExpiredEventWithImage: mockFindExpiredEventWithImage,
}));

const { mockImagesGenerate } = vi.hoisted(() => ({
  mockImagesGenerate: vi.fn(),
}));

vi.mock("openai", () => ({
  default: vi.fn().mockImplementation(() => ({
    images: {
      generate: mockImagesGenerate,
    },
  })),
}));

// Mock global fetch for image downloads
const mockFetch = vi.fn();
vi.stubGlobal("fetch", mockFetch);

import { processEventImage, downloadImage, generateAiImage } from "../../services/image-processor";

beforeEach(() => {
  vi.clearAllMocks();
});

describe("downloadImage", () => {
  it("returns buffer, mimeType, and filename on successful download", async () => {
    const fakeBuffer = Buffer.from("fake image data");
    mockFetch.mockResolvedValue({
      ok: true,
      headers: { get: () => "image/jpeg" },
      arrayBuffer: () => Promise.resolve(fakeBuffer.buffer),
    });

    const result = await downloadImage("https://example.com/image.jpg");
    expect(result.buffer).toBeInstanceOf(Buffer);
    expect(result.mimeType).toBe("image/jpeg");
    expect(result.filename).toBe("event-image.jpg");
  });

  it("uses png extension for image/png content type", async () => {
    const fakeBuffer = Buffer.from("png data");
    mockFetch.mockResolvedValue({
      ok: true,
      headers: { get: () => "image/png" },
      arrayBuffer: () => Promise.resolve(fakeBuffer.buffer),
    });

    const result = await downloadImage("https://example.com/image.png");
    expect(result.filename).toBe("event-image.png");
    expect(result.mimeType).toBe("image/png");
  });

  it("throws on HTTP error response", async () => {
    mockFetch.mockResolvedValue({
      ok: false,
      status: 404,
    });

    await expect(downloadImage("https://example.com/missing.jpg")).rejects.toThrow(
      "Failed to download image from https://example.com/missing.jpg: HTTP 404",
    );
  });
});

describe("generateAiImage", () => {
  it("returns a Buffer from base64 response", async () => {
    const fakeB64 = Buffer.from("fake image").toString("base64");
    mockImagesGenerate.mockResolvedValue({
      data: [{ b64_json: fakeB64 }],
    });

    const result = await generateAiImage("Salsa Night", "salsa", "party");
    expect(result).toBeInstanceOf(Buffer);
    expect(result.toString()).toBe("fake image");
  });

  it("throws when response contains no image data", async () => {
    mockImagesGenerate.mockResolvedValue({ data: [] });

    await expect(generateAiImage("Test Event", "bachata", "workshop")).rejects.toThrow(
      "AI image generation returned no image data",
    );
  });

  it("throws when b64_json is missing from response", async () => {
    mockImagesGenerate.mockResolvedValue({ data: [{}] });

    await expect(generateAiImage("Test Event", "kizomba", "party")).rejects.toThrow(
      "AI image generation returned no image data",
    );
  });
});

describe("processEventImage fallback chain", () => {
  it("step 1: downloads and uploads Facebook image when URL is provided and download succeeds", async () => {
    const fakeBuffer = Buffer.from("facebook image");
    mockFetch.mockResolvedValue({
      ok: true,
      headers: { get: () => "image/jpeg" },
      arrayBuffer: () => Promise.resolve(fakeBuffer.buffer),
    });
    mockUploadFile.mockResolvedValue("file-id-123");

    const result = await processEventImage("https://fb.com/photo.jpg", "salsa", "party", "Salsa Night");

    expect(result).toEqual({ fileId: "file-id-123", source: "facebook" });
    expect(mockUploadFile).toHaveBeenCalledOnce();
    expect(mockFindExpiredEventWithImage).not.toHaveBeenCalled();
  });

  it("step 2: falls back to reusing expired event image when Facebook download fails", async () => {
    mockFetch.mockResolvedValue({ ok: false, status: 500 });
    mockFindExpiredEventWithImage.mockResolvedValue("reused-file-id");

    const result = await processEventImage("https://fb.com/photo.jpg", "bachata", "party", "Bachata Party");

    expect(result).toEqual({ fileId: "reused-file-id", source: "ai_generated" });
    expect(mockFindExpiredEventWithImage).toHaveBeenCalledWith("bachata", "party");
  });

  it("step 2: falls back to reuse when no Facebook imageUrl is provided", async () => {
    mockFindExpiredEventWithImage.mockResolvedValue("reused-file-id");

    const result = await processEventImage(null, "salsa", "workshop", "Salsa Workshop");

    expect(result).toEqual({ fileId: "reused-file-id", source: "ai_generated" });
    expect(mockFetch).not.toHaveBeenCalled();
  });

  it("step 3: falls back to AI generation when no reusable image exists and download fails", async () => {
    mockFetch
      .mockResolvedValueOnce({ ok: false, status: 404 }) // download fails
      .mockResolvedValue(undefined); // not called again for download
    mockFindExpiredEventWithImage.mockResolvedValue(null);

    const fakeB64 = Buffer.from("ai image data").toString("base64");
    mockImagesGenerate.mockResolvedValue({ data: [{ b64_json: fakeB64 }] });
    mockUploadFile.mockResolvedValue("ai-file-id");

    const result = await processEventImage("https://fb.com/photo.jpg", "kizomba", "party", "Kizomba Night");

    expect(result).toEqual({ fileId: "ai-file-id", source: "ai_generated" });
    expect(mockImagesGenerate).toHaveBeenCalledOnce();
    expect(mockUploadFile).toHaveBeenCalledWith(expect.any(Buffer), "ai-generated-event-image.jpg", "image/jpeg");
  });

  it("step 3: generates AI image when no URL provided and no reusable image", async () => {
    mockFindExpiredEventWithImage.mockResolvedValue(null);
    const fakeB64 = Buffer.from("generated").toString("base64");
    mockImagesGenerate.mockResolvedValue({ data: [{ b64_json: fakeB64 }] });
    mockUploadFile.mockResolvedValue("ai-file-id-456");

    const result = await processEventImage(undefined, "zouk", "workshop", "Zouk Workshop");

    expect(result).toEqual({ fileId: "ai-file-id-456", source: "ai_generated" });
  });

  it("step 4: returns null when all fallback steps fail", async () => {
    mockFetch.mockResolvedValue({ ok: false, status: 503 });
    mockFindExpiredEventWithImage.mockRejectedValue(new Error("Directus unavailable"));
    mockImagesGenerate.mockRejectedValue(new Error("OpenRouter error"));

    const result = await processEventImage("https://fb.com/photo.jpg", "tango", "party", "Tango Night");

    expect(result).toEqual({ fileId: null, source: null });
  });

  it("returns null when no URL, reuse fails, and AI generation fails", async () => {
    mockFindExpiredEventWithImage.mockResolvedValue(null);
    mockImagesGenerate.mockRejectedValue(new Error("API error"));

    const result = await processEventImage(null, "swing", "festival", "Swing Festival");

    expect(result).toEqual({ fileId: null, source: null });
  });

  it("handles fetch throwing (e.g. timeout) and falls through to reuse", async () => {
    mockFetch.mockRejectedValue(new Error("network timeout"));
    mockFindExpiredEventWithImage.mockResolvedValue("reused-id");

    const result = await processEventImage("https://fb.com/photo.jpg", "salsa", "party", "Event");

    expect(result).toEqual({ fileId: "reused-id", source: "ai_generated" });
  });
});
