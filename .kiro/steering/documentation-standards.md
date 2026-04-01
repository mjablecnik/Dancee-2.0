---
inclusion: always
---

# Documentation Standards

## Documentation File Placement

**CRITICAL**: All documentation files MUST follow strict organizational rules.

**For ALL backend services (`dancee_api`, `dancee_workflow`, `dancee_cms`):**
- ✅ **All documentation files** MUST be placed in the `docs/` folder
- ✅ **Exception**: Only `README.md` can be in the root directory
- ❌ **Never** place documentation files (`.md`) in the root except `README.md`

## Examples

```
✅ CORRECT:
backend/dancee_api/README.md                 # Root README only
backend/dancee_api/docs/SWAGGER.md           # Documentation in docs/
backend/dancee_api/docs/SETUP.md             # Documentation in docs/
backend/dancee_workflow/README.md             # Root README only
backend/dancee_workflow/docs/SCRIPTS.md       # Documentation in docs/

❌ WRONG:
backend/dancee_api/SWAGGER.md                # Should be in docs/
backend/dancee_workflow/API_GUIDE.md          # Should be in docs/
```

## Documentation Standards

1. **README.md** - Overview, quick start, basic usage (root only)
2. **docs/** folder - All other documentation:
   - Setup guides
   - API documentation
   - Examples and tutorials
   - Troubleshooting guides
   - Architecture documentation
   - Deployment guides

## When Creating New Documentation

1. **Check if it's a README** - If yes, place in root
2. **All other docs** - Place in `docs/` folder
3. **Create docs/ folder** if it doesn't exist
4. **Use descriptive names** - `SWAGGER.md`, `EXAMPLES.md`, `DEPLOYMENT.md`
5. **Link from README** - Reference docs from main README.md
