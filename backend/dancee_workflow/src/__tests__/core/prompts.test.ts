import { describe, it, expect } from "vitest";
import {
  getEventInfoExtractionPrompt,
  getEventPartsExtractionPrompt,
  getCourseExtractionPrompt,
  getImageGenerationPrompt,
} from "../../core/prompts";

describe("getEventInfoExtractionPrompt", () => {
  it("mentions dresscode as an extractable type", () => {
    const prompt = getEventInfoExtractionPrompt();
    expect(prompt).toContain("dresscode");
  });

  it("includes all three types: url, price, dresscode", () => {
    const prompt = getEventInfoExtractionPrompt();
    expect(prompt).toContain("url");
    expect(prompt).toContain("price");
    expect(prompt).toContain("dresscode");
  });

  it("includes a dresscode example", () => {
    const prompt = getEventInfoExtractionPrompt();
    expect(prompt.toLowerCase()).toContain("dresscode");
    expect(prompt).toContain("Elegant");
  });
});

describe("getEventPartsExtractionPrompt", () => {
  it("mentions relevance ordering for dances", () => {
    const prompt = getEventPartsExtractionPrompt("Czech", "2024-01-01T18:00:00", null);
    expect(prompt.toLowerCase()).toContain("relevance");
  });

  it("injects dance style codes when provided", () => {
    const codes = ["salsa", "bachata", "kizomba"];
    const prompt = getEventPartsExtractionPrompt("Czech", "2024-01-01T18:00:00", null, codes);
    expect(prompt).toContain("salsa");
    expect(prompt).toContain("bachata");
    expect(prompt).toContain("kizomba");
  });

  it("works without dance style codes (empty array default)", () => {
    const prompt = getEventPartsExtractionPrompt("Czech", "2024-01-01T18:00:00", null);
    expect(prompt).toBeTruthy();
  });

  it("instructs to order dances by relevance (most prominent first)", () => {
    const prompt = getEventPartsExtractionPrompt("Czech", "2024-01-01T18:00:00", null, ["salsa"]);
    expect(prompt).toContain("most prominent");
  });
});

describe("getCourseExtractionPrompt", () => {
  it("is written in English", () => {
    const prompt = getCourseExtractionPrompt("Czech", "2024-01-01T18:00:00", null);
    // The prompt instructions should be in English
    expect(prompt).toContain("Your task is to extract");
    expect(prompt).toContain("Important rules");
  });

  it("instructs LLM to output in the specified language", () => {
    const prompt = getCourseExtractionPrompt("Czech", "2024-01-01T18:00:00", null);
    expect(prompt).toContain("Czech");
  });

  it("includes all required course fields", () => {
    const prompt = getCourseExtractionPrompt("Czech", "2024-01-01T18:00:00", null);
    expect(prompt).toContain("instructor_name");
    expect(prompt).toContain("level");
    expect(prompt).toContain("schedule_day");
    expect(prompt).toContain("schedule_time");
    expect(prompt).toContain("lesson_count");
    expect(prompt).toContain("lesson_duration_minutes");
    expect(prompt).toContain("max_participants");
    expect(prompt).toContain("price");
    expect(prompt).toContain("learning_items");
    expect(prompt).toContain("dances");
  });

  it("injects dance style codes when provided", () => {
    const codes = ["salsa", "bachata"];
    const prompt = getCourseExtractionPrompt("Czech", "2024-01-01T18:00:00", null, codes);
    expect(prompt).toContain("salsa");
    expect(prompt).toContain("bachata");
  });

  it("instructs to order dances by relevance", () => {
    const prompt = getCourseExtractionPrompt("Czech", "2024-01-01T18:00:00", null, ["salsa"]);
    expect(prompt).toContain("relevance");
    expect(prompt).toContain("most prominent");
  });
});

describe("getImageGenerationPrompt", () => {
  it("includes the event title", () => {
    const prompt = getImageGenerationPrompt("Salsa Night 2024", "salsa", "party");
    expect(prompt).toContain("Salsa Night 2024");
  });

  it("includes the primary dance style", () => {
    const prompt = getImageGenerationPrompt("Salsa Night 2024", "salsa", "party");
    expect(prompt).toContain("salsa");
  });

  it("includes the event type", () => {
    const prompt = getImageGenerationPrompt("Salsa Night 2024", "salsa", "party");
    expect(prompt).toContain("party");
  });

  it("works with different dance styles and event types", () => {
    const prompt = getImageGenerationPrompt("Bachata Workshop", "bachata", "workshop");
    expect(prompt).toContain("Bachata Workshop");
    expect(prompt).toContain("bachata");
    expect(prompt).toContain("workshop");
  });
});
