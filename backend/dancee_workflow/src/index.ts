import * as http2 from "http2";
import * as restate from "@restatedev/restate-sdk";
import { initSentry, validateConfig } from "./core/config";
import { config } from "./core/config";
import { apiService } from "./services/api";
import { eventWorkflow } from "./services/workflow";
import { batchService } from "./services/batch";

validateConfig();
initSentry();

const restateHandler = restate
  .endpoint()
  .bind(apiService)
  .bind(eventWorkflow)
  .bind(batchService)
  .http2Handler();

const allowedOrigins = config.corsOrigins === "*"
  ? null
  : config.corsOrigins.split(",").map((o) => o.trim());

const server = http2.createServer(
  (req: http2.Http2ServerRequest, res: http2.Http2ServerResponse) => {
    const origin = req.headers["origin"] as string | undefined;

    if (origin) {
      if (allowedOrigins === null || allowedOrigins.includes(origin)) {
        res.setHeader("Access-Control-Allow-Origin", origin);
      }
    } else if (allowedOrigins === null) {
      res.setHeader("Access-Control-Allow-Origin", "*");
    }

    res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
    res.setHeader(
      "Access-Control-Allow-Headers",
      "Content-Type, Authorization",
    );
    res.setHeader("Access-Control-Max-Age", "86400");

    if (req.method === "OPTIONS") {
      res.writeHead(204);
      res.end();
      return;
    }

    // Map /api/* paths to Restate service handler paths (Requirement 13)
    const apiRoutes: Record<string, string> = {
      "/api/event": "/ApiService/processEvent",
      "/api/events/process": "/ApiService/processBatch",
      "/api/events/list": "/ApiService/listEvents",
    };
    const fullUrl = req.url ?? "";
    const qIndex = fullUrl.indexOf("?");
    const pathname = qIndex >= 0 ? fullUrl.slice(0, qIndex) : fullUrl;
    const queryString = qIndex >= 0 ? fullUrl.slice(qIndex + 1) : "";
    const mappedPath = apiRoutes[pathname];
    if (mappedPath) {
      req.url = queryString ? `${mappedPath}?${queryString}` : mappedPath;

      // For listEvents, parse the filter query param and forward it as a custom
      // header so the Restate handler can read it (GET bodies are non-standard).
      if (pathname === "/api/events/list" && queryString) {
        const params = new URLSearchParams(queryString);
        const filterParam = params.get("filter");
        if (filterParam) {
          (req.headers as Record<string, string | string[] | undefined>)[
            "x-dancee-filter"
          ] = filterParam;
        }
      }
    }

    restateHandler(req, res);
  },
);

server.listen(config.appPort, () => {
  console.log(`Restate endpoint listening on port ${config.appPort}`);
});
