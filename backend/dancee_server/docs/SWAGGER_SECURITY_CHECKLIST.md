# Swagger Security - Deployment Checklist

Use this checklist before deploying to production to ensure Swagger documentation is properly secured.

## Pre-Deployment Checklist

### 1. Environment Configuration

- [ ] Set `NODE_ENV=production`
- [ ] Set `SWAGGER_USER` to a custom username (not 'admin')
- [ ] Set `SWAGGER_PASSWORD` to a strong password
- [ ] Verify environment variables are loaded correctly
- [ ] Ensure `.env` file is in `.gitignore`

**Verify:**
```bash
echo $NODE_ENV
echo $SWAGGER_USER
# Don't echo password in production!
```

### 2. Password Security

- [ ] Password is at least 16 characters long
- [ ] Password contains uppercase letters
- [ ] Password contains lowercase letters
- [ ] Password contains numbers
- [ ] Password contains special characters
- [ ] Password is NOT a dictionary word
- [ ] Password is NOT reused from other services
- [ ] Password is stored in secure location (password manager)

**Generate strong password:**
```bash
openssl rand -base64 32
```

### 3. Testing

- [ ] Test Swagger access without credentials (should fail)
- [ ] Test Swagger access with wrong credentials (should fail)
- [ ] Test Swagger access with correct credentials (should succeed)
- [ ] Test from different browsers
- [ ] Test from different devices
- [ ] Verify 401 response includes WWW-Authenticate header

**Test commands:**
```bash
# Should return 401
curl -I http://localhost:3001/api

# Should return 200
curl -u username:password -I http://localhost:3001/api
```

### 4. Documentation

- [ ] Document credentials in secure location
- [ ] Share credentials only with authorized team members
- [ ] Document credential rotation schedule
- [ ] Update team documentation with access instructions
- [ ] Inform team about authentication requirement

### 5. Security Review

- [ ] HTTPS is enabled (not HTTP)
- [ ] Firewall rules are configured
- [ ] Server is not publicly accessible (if not needed)
- [ ] Logging is enabled for authentication attempts
- [ ] Monitoring is set up for failed login attempts
- [ ] Backup access method is documented

### 6. Code Review

- [ ] Middleware is properly registered in `app.module.ts`
- [ ] Routes `/api` and `/api-json` are protected
- [ ] No credentials are hardcoded in source code
- [ ] No credentials are committed to version control
- [ ] Unit tests are passing
- [ ] Integration tests are passing

### 7. Deployment

- [ ] Environment variables are set in deployment environment
- [ ] Deployment scripts include security configuration
- [ ] CI/CD pipeline uses secrets management
- [ ] Production deployment is tested
- [ ] Rollback plan is documented

## Post-Deployment Checklist

### 1. Verification

- [ ] Access Swagger UI in production
- [ ] Verify authentication prompt appears
- [ ] Test with correct credentials
- [ ] Test with incorrect credentials
- [ ] Verify all team members can access
- [ ] Check server logs for authentication events

### 2. Monitoring

- [ ] Set up alerts for failed authentication attempts
- [ ] Monitor access logs regularly
- [ ] Track who has access to credentials
- [ ] Document any access issues
- [ ] Review security logs weekly

### 3. Maintenance

- [ ] Schedule credential rotation (recommended: every 90 days)
- [ ] Document credential changes
- [ ] Update team when credentials change
- [ ] Review access list quarterly
- [ ] Update security documentation as needed

## Security Incident Response

If credentials are compromised:

- [ ] Immediately change SWAGGER_USER and SWAGGER_PASSWORD
- [ ] Restart the server
- [ ] Notify all team members
- [ ] Review access logs for unauthorized access
- [ ] Document the incident
- [ ] Update security procedures

## Credential Rotation Checklist

Perform every 90 days:

- [ ] Generate new strong password
- [ ] Update environment variables
- [ ] Restart server
- [ ] Test new credentials
- [ ] Notify team members
- [ ] Update password manager
- [ ] Document rotation date
- [ ] Schedule next rotation

## Team Onboarding Checklist

When adding new team member:

- [ ] Provide Swagger URL
- [ ] Share credentials securely (not via email/chat)
- [ ] Explain authentication requirement
- [ ] Show how to access Swagger
- [ ] Provide documentation links
- [ ] Add to access list
- [ ] Document access grant date

## Team Offboarding Checklist

When removing team member:

- [ ] Rotate credentials immediately
- [ ] Update all team members with new credentials
- [ ] Remove from access list
- [ ] Document access revocation date
- [ ] Review recent access logs

## Compliance Checklist

- [ ] Security policy is documented
- [ ] Access control is implemented
- [ ] Audit logging is enabled
- [ ] Credentials are encrypted at rest
- [ ] Credentials are encrypted in transit (HTTPS)
- [ ] Regular security reviews are scheduled
- [ ] Incident response plan is documented

## Quick Reference

### Environment Variables Template

```bash
# Production Environment
NODE_ENV=production
SWAGGER_USER=your_custom_username
SWAGGER_PASSWORD=your_secure_password_here
```

### Test Commands

```bash
# Test without auth (should fail)
curl -I https://your-domain.com/api

# Test with auth (should succeed)
curl -u username:password -I https://your-domain.com/api
```

### Emergency Access

If locked out:

1. SSH into server
2. Set `NODE_ENV=development` temporarily
3. Access Swagger without auth
4. Reset credentials
5. Set `NODE_ENV=production`
6. Restart server

## Documentation Links

- [Quick Start Guide](./SWAGGER_SECURITY_QUICKSTART.md)
- [Complete Security Guide](./SWAGGER_SECURITY.md)
- [Usage Examples](./SWAGGER_SECURITY_EXAMPLES.md)
- [Visual Diagrams](./SWAGGER_SECURITY_DIAGRAM.md)
- [Implementation Summary](./SWAGGER_SECURITY_SUMMARY.md)

## Sign-Off

### Pre-Deployment

- [ ] Developer: _________________ Date: _______
- [ ] Security Review: _________________ Date: _______
- [ ] Team Lead: _________________ Date: _______

### Post-Deployment

- [ ] Deployment Verified: _________________ Date: _______
- [ ] Team Notified: _________________ Date: _______
- [ ] Documentation Updated: _________________ Date: _______

---

**Remember**: Security is an ongoing process, not a one-time task. Review this checklist regularly and update as needed.

**Next Rotation Date**: _________________
