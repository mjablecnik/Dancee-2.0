---
inclusion: always
---

# API Documentation Synchronization

**CRITICAL**: The `dancee_api` service maintains centralized documentation for ALL API endpoints across all backend services.

## Centralized API Documentation

The `backend/dancee_api` service acts as an API Gateway and maintains the **single source of truth** for all API endpoint documentation using OpenAPI/Swagger specifications.

### Location
- **Path**: `backend/dancee_api/specs/`
- **Format**: OpenAPI YAML files
- **Purpose**: Centralized documentation for all microservices

## Mandatory Synchronization Rule

**When you add, modify, or delete ANY API endpoint in ANY backend service, you MUST update the corresponding OpenAPI specification in `dancee_api`.**

### Affected Services

All backend services must sync their API changes to `dancee_api`:

1. **dancee_workflow** (TypeScript/Restate) → Update `backend/dancee_api/specs/workflow.openapi.yaml`
2. **dancee_cms** (Directus) → Update `backend/dancee_api/specs/cms.openapi.yaml`

The combined spec is maintained at `backend/dancee_api/specs/combined.openapi.yaml`.

## What to Update

When making API changes, update the OpenAPI spec with:

### 1. New Endpoints
```yaml
paths:
  /api/events/{id}:
    get:
      summary: Get event by ID
      tags:
        - Events
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: Event found
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Event'
        '404':
          description: Event not found
```

### 2. Modified Endpoints
- Update parameters
- Update request/response schemas
- Update descriptions
- Update examples

### 3. Deleted Endpoints
- Remove the endpoint definition
- Remove unused schemas if no longer referenced

### 4. Schema Changes
```yaml
components:
  schemas:
    Event:
      type: object
      required:
        - id
        - name
      properties:
        id:
          type: string
          example: "evt_123"
        name:
          type: string
          example: "Summer Dance Party"
        description:
          type: string
          example: "Join us for an amazing night"
```

## Workflow

### When Adding a New Endpoint

1. ✅ **Implement the endpoint** in the backend service
2. ✅ **Test the endpoint** to ensure it works
3. ✅ **Update OpenAPI spec** in `backend/dancee_api/specs/`
4. ✅ **Validate the spec** (use OpenAPI validator if available)
5. ✅ **Commit both changes** together

### When Modifying an Endpoint

1. ✅ **Update the implementation** in the backend service
2. ✅ **Update the OpenAPI spec** in `backend/dancee_api/specs/`
3. ✅ **Ensure backward compatibility** or document breaking changes
4. ✅ **Commit both changes** together

### When Deleting an Endpoint

1. ✅ **Remove the implementation** from the backend service
2. ✅ **Remove from OpenAPI spec** in `backend/dancee_api/specs/`
3. ✅ **Check for dependent schemas** and clean up if unused
4. ✅ **Commit both changes** together

## Why This Matters

- **Single Source of Truth**: Developers know where to find complete API documentation
- **API Gateway**: `dancee_api` routes requests based on this documentation
- **Client Generation**: Frontend can generate API clients from these specs
- **Testing**: Automated tests can validate API contracts
- **Documentation**: Auto-generated API documentation for developers

## API Path Prefix Convention

**CRITICAL**: All backend API endpoints MUST use the `/api` prefix.

✅ Correct: `/api/events/list`, `/api/events/favorites`, `/api/events/{id}`
❌ Wrong: `/events/list`, `/events/favorites`, `/events/{id}`

This applies to:
- Route definitions in all backend services
- OpenAPI spec paths in `dancee_api/specs/`
- Frontend API client calls

Never register routes without the `/api` prefix. Legacy non-prefixed routes have been removed and must not be reintroduced.

## Common Mistakes to Avoid

❌ **Don't register routes without `/api` prefix** — all endpoints must start with `/api/`
❌ **Don't forget to update the spec** after changing an endpoint
❌ **Don't update only the service** without updating `dancee_api` specs
❌ **Don't create inconsistencies** between implementation and documentation
❌ **Don't skip validation** of the OpenAPI spec after changes

## Validation

After updating OpenAPI specs, validate them:

```bash
# Navigate to dancee_api
cd backend/dancee_api

# Validate specs (if validator is available)
task validate-specs

# Or use online validator
# Upload to https://editor.swagger.io/
```

## Example: Adding a New Workflow Endpoint

**Step 1: Implement in `dancee_workflow` service**
```typescript
// backend/dancee_workflow/src/services/api.ts
router.get('/api/workflow/status', async (req, res) => {
  // Implementation...
});
```

**Step 2: Update `backend/dancee_api/specs/workflow.openapi.yaml`**
```yaml
paths:
  /api/workflow/status:
    get:
      summary: Get workflow status
      operationId: getWorkflowStatus
      tags:
        - Workflow
      responses:
        '200':
          description: Success
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/WorkflowStatus'
```

**Step 3: Commit both changes together**
```bash
git add backend/dancee_workflow/src/services/api.ts
git add backend/dancee_api/specs/workflow.openapi.yaml
git commit -m "feat: add GET /api/workflow/status endpoint"
```

## Remember

**Every API change = Two updates:**
1. Backend service implementation
2. `dancee_api` OpenAPI specification

This ensures the API Gateway and documentation stay in sync with actual implementations.
