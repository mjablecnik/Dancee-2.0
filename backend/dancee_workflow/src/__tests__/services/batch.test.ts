import { describe, it, expect, vi, beforeEach } from "vitest";

// Mock config before importing anything that uses it
vi.mock("../../core/config", () => ({
  config: {
    directusBaseUrl: "http://directus-test",
    directusAccessToken: "test-token",
  },
  captureError: vi.fn(),
}));

// Mock restate SDK so service() returns the definition object directly
vi.mock("@restatedev/restate-sdk", () => ({
  service: (def: { name: string; handlers: Record<string, unknown> }) => def,
}));

const mockGetGroups = vi.fn();
const mockUpdateGroupTimestamp = vi.fn();
const mockFindEventByOriginalUrl = vi.fn();
const mockFindSkippedEventByUrl = vi.fn();
const mockCreateError = vi.fn();
const mockScrapeEventList = vi.fn();

vi.mock("../../clients/directus-client", () => ({
  getGroupsOrderedByUpdatedAt: (...args: unknown[]) => mockGetGroups(...args),
  updateGroupTimestamp: (...args: unknown[]) => mockUpdateGroupTimestamp(...args),
  findEventByOriginalUrl: (...args: unknown[]) => mockFindEventByOriginalUrl(...args),
  findSkippedEventByUrl: (...args: unknown[]) => mockFindSkippedEventByUrl(...args),
  createError: (...args: unknown[]) => mockCreateError(...args),
  clearDanceStyleCodesCache: vi.fn(),
}));

vi.mock("../../clients/scraper-client", () => ({
  scrapeEventList: (...args: unknown[]) => mockScrapeEventList(...args),
  buildFacebookEventUrl: (eventId: string) => `https://www.facebook.com/events/${eventId}`,
}));

import { batchService } from "../../services/batch";

// Access the raw handler (works because we mocked restate.service)
const batchDef = batchService as unknown as {
  handlers: { processAll: (ctx: ReturnType<typeof makeMockCtx>) => Promise<unknown> };
};
const processAll = batchDef.handlers.processAll;

// Minimal mock Restate Context
function makeMockCtx() {
  let uuidCounter = 0;
  const workflowSendMock = vi.fn().mockReturnValue({ run: vi.fn() });
  return {
    run: vi.fn((_name: string, fn: () => unknown) => fn()),
    rand: { uuidv4: vi.fn(() => `uuid-${++uuidCounter}`) },
    workflowSendClient: workflowSendMock,
    _workflowSendMock: workflowSendMock,
  };
}

function makeGroup(overrides: Record<string, unknown> = {}) {
  return {
    id: 1,
    url: "https://facebook.com/groups/dance1",
    type: "facebook",
    updated_at: null,
    ...overrides,
  };
}

function makeEvent(overrides: Record<string, unknown> = {}) {
  return {
    id: "evt123",
    url: "https://facebook.com/events/evt123",
    name: "Test Event",
    startTimestamp: 1700000000,
    ...overrides,
  };
}

beforeEach(() => {
  vi.clearAllMocks();
  mockUpdateGroupTimestamp.mockResolvedValue({ id: 1, url: "https://facebook.com/groups/dance1", updated_at: new Date().toISOString() });
  mockCreateError.mockResolvedValue({ id: 99, url: "", message: "", datetime: new Date().toISOString() });
  mockFindSkippedEventByUrl.mockResolvedValue(null);
});

describe("BatchService.processAll: empty groups list", () => {
  it("returns { groups: 0, eventsScheduled: 0, schedulingErrors: 0 } when no groups", async () => {
    mockGetGroups.mockResolvedValue([]);
    const ctx = makeMockCtx();

    const result = await processAll(ctx);

    expect(result).toEqual({ groups: 0, eventsScheduled: 0, schedulingErrors: 0 });
    expect(ctx.workflowSendClient).not.toHaveBeenCalled();
  });
});

describe("BatchService.processAll: groups with no new events (all duplicates)", () => {
  it("does not schedule workflows when all events already exist", async () => {
    const group = makeGroup();
    const event = makeEvent();
    mockGetGroups.mockResolvedValue([group]);
    mockScrapeEventList.mockResolvedValue([event]);
    // Event already exists in Directus
    mockFindEventByOriginalUrl.mockResolvedValue({
      id: 1,
      original_url: event.url,
      original_description: "",
      organizer: "",
      start_time: "2025-01-01T00:00:00Z",
      timezone: "UTC",
      parts: [],
      info: [],
      dances: [],
    });

    const ctx = makeMockCtx();
    const result = await processAll(ctx);

    expect(result).toEqual({ groups: 1, eventsScheduled: 0, schedulingErrors: 0 });
    expect(ctx.workflowSendClient).not.toHaveBeenCalled();
  });
});

describe("BatchService.processAll: groups with new events", () => {
  it("schedules a workflow for each new event", async () => {
    const group = makeGroup();
    const event1 = makeEvent({ id: "evt1", url: "https://facebook.com/events/evt1" });
    const event2 = makeEvent({ id: "evt2", url: "https://facebook.com/events/evt2" });
    mockGetGroups.mockResolvedValue([group]);
    mockScrapeEventList.mockResolvedValue([event1, event2]);
    // Neither event exists yet
    mockFindEventByOriginalUrl.mockResolvedValue(null);

    const ctx = makeMockCtx();
    const result = await processAll(ctx);

    expect(result).toEqual({ groups: 1, eventsScheduled: 2, schedulingErrors: 0 });
    expect(ctx.workflowSendClient).toHaveBeenCalledTimes(2);
  });

  it("uses event.url as the workflow input when available", async () => {
    const group = makeGroup();
    const event = makeEvent({ id: "evt1", url: "https://facebook.com/events/evt1" });
    mockGetGroups.mockResolvedValue([group]);
    mockScrapeEventList.mockResolvedValue([event]);
    mockFindEventByOriginalUrl.mockResolvedValue(null);

    const ctx = makeMockCtx();
    await processAll(ctx);

    // workflowSendClient().run should be called with the event URL
    const runMock = ctx._workflowSendMock.mock.results[0]?.value?.run as ReturnType<typeof vi.fn>;
    expect(runMock).toHaveBeenCalledWith(event.url);
  });

  it("constructs fallback Facebook URL when event.url is missing", async () => {
    const group = makeGroup();
    const event = makeEvent({ id: "evt999", url: undefined });
    mockGetGroups.mockResolvedValue([group]);
    mockScrapeEventList.mockResolvedValue([event]);
    mockFindEventByOriginalUrl.mockResolvedValue(null);

    const ctx = makeMockCtx();
    await processAll(ctx);

    const runMock = ctx._workflowSendMock.mock.results[0]?.value?.run as ReturnType<typeof vi.fn>;
    expect(runMock).toHaveBeenCalledWith("https://www.facebook.com/events/evt999");
  });
});

describe("BatchService.processAll: scheduling errors", () => {
  it("increments schedulingErrors and calls createError when scheduling fails", async () => {
    const group = makeGroup();
    const event = makeEvent();
    mockGetGroups.mockResolvedValue([group]);
    mockScrapeEventList.mockResolvedValue([event]);
    mockFindEventByOriginalUrl.mockResolvedValue(null);

    const ctx = makeMockCtx();
    // Make workflowSendClient().run throw a scheduling error
    ctx._workflowSendMock.mockReturnValue({
      run: vi.fn(() => { throw new Error("Restate unavailable"); }),
    });

    const result = await processAll(ctx);

    expect(result).toEqual({ groups: 1, eventsScheduled: 0, schedulingErrors: 1 });
    expect(mockCreateError).toHaveBeenCalledWith(
      expect.objectContaining({
        url: event.url,
        message: "Restate unavailable",
      })
    );
  });

  it("continues processing remaining events after a scheduling error", async () => {
    const group = makeGroup();
    const event1 = makeEvent({ id: "evt1", url: "https://facebook.com/events/evt1" });
    const event2 = makeEvent({ id: "evt2", url: "https://facebook.com/events/evt2" });
    mockGetGroups.mockResolvedValue([group]);
    mockScrapeEventList.mockResolvedValue([event1, event2]);
    mockFindEventByOriginalUrl.mockResolvedValue(null);

    const ctx = makeMockCtx();
    let callCount = 0;
    ctx._workflowSendMock.mockReturnValue({
      run: vi.fn(() => {
        if (callCount++ === 0) throw new Error("First scheduling failed");
        // Second succeeds (no throw)
      }),
    });

    const result = await processAll(ctx);

    // One failed, one succeeded
    expect(result).toEqual({ groups: 1, eventsScheduled: 1, schedulingErrors: 1 });
  });
});

describe("BatchService.processAll: group timestamp update", () => {
  it("updates group timestamp after processing", async () => {
    const group = makeGroup({ id: 42 });
    mockGetGroups.mockResolvedValue([group]);
    mockScrapeEventList.mockResolvedValue([]);

    const ctx = makeMockCtx();
    await processAll(ctx);

    expect(mockUpdateGroupTimestamp).toHaveBeenCalledWith(42, expect.any(String));
  });

  it("skips timestamp update when group has no id", async () => {
    const group = makeGroup({ id: undefined });
    mockGetGroups.mockResolvedValue([group]);
    mockScrapeEventList.mockResolvedValue([]);

    const ctx = makeMockCtx();
    const warnSpy = vi.spyOn(console, "warn").mockImplementation(() => {});

    await processAll(ctx);

    expect(mockUpdateGroupTimestamp).not.toHaveBeenCalled();
    expect(warnSpy).toHaveBeenCalledWith(expect.stringContaining("Skipping timestamp update"));
    warnSpy.mockRestore();
  });

  it("processes multiple groups and updates each timestamp", async () => {
    const group1 = makeGroup({ id: 1, url: "https://facebook.com/groups/dance1" });
    const group2 = makeGroup({ id: 2, url: "https://facebook.com/groups/dance2" });
    mockGetGroups.mockResolvedValue([group1, group2]);
    mockScrapeEventList.mockResolvedValue([]);

    const ctx = makeMockCtx();
    const result = await processAll(ctx);

    expect(result).toEqual({ groups: 2, eventsScheduled: 0, schedulingErrors: 0 });
    expect(mockUpdateGroupTimestamp).toHaveBeenCalledTimes(2);
  });
});

describe("BatchService.processAll: group-level scraping failure creates error record", () => {
  it("calls createError when scrapeEventList throws for a group", async () => {
    const group = makeGroup({ id: 5, url: "https://facebook.com/groups/broken" });
    mockGetGroups.mockResolvedValue([group]);
    mockScrapeEventList.mockRejectedValue(new Error("Scraper unavailable"));

    const ctx = makeMockCtx();
    await processAll(ctx);

    expect(mockCreateError).toHaveBeenCalledWith(
      expect.objectContaining({
        url: group.url,
        message: expect.stringContaining("Scraper unavailable"),
      })
    );
  });

  it("continues processing remaining groups after one fails", async () => {
    const group1 = makeGroup({ id: 1, url: "https://facebook.com/groups/broken" });
    const group2 = makeGroup({ id: 2, url: "https://facebook.com/groups/ok" });
    mockGetGroups.mockResolvedValue([group1, group2]);
    mockScrapeEventList
      .mockRejectedValueOnce(new Error("Scraper unavailable"))
      .mockResolvedValueOnce([]);

    const ctx = makeMockCtx();
    const result = await processAll(ctx);

    expect(result).toEqual({ groups: 2, eventsScheduled: 0, schedulingErrors: 0 });
    expect(mockCreateError).toHaveBeenCalledTimes(1);
    expect(mockUpdateGroupTimestamp).toHaveBeenCalledTimes(1);
  });
});
