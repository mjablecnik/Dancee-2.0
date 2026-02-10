# Swagger Security - Quick Reference Card

**⚡ Keep this handy for quick access to common commands and information**

## 🚀 Quick Setup (30 seconds)

```bash
export NODE_ENV=production
export SWAGGER_USER=your_username
export SWAGGER_PASSWORD=your_secure_password
task start
```

Access: `http://localhost:3001/api` (enter credentials when prompted)

## 📋 Environment Variables

```bash
NODE_ENV=production              # Required for security
SWAGGER_USER=your_username       # Your custom username
SWAGGER_PASSWORD=your_password   # Your secure password
```

## 🔧 Common Commands

### Development (No Auth)
```bash
export NODE_ENV=development
task dev
# Access: http://localhost:3001/api (no password)
```

### Production (With Auth)
```bash
export NODE_ENV=production
export SWAGGER_USER=admin
export SWAGGER_PASSWORD=myPass123!
task start
# Access: http://localhost:3001/api (password required)
```

### Test Authentication
```bash
# Should return 401
curl -I http://localhost:3001/api

# Should return 200
curl -u username:password -I http://localhost:3001/api
```

## 🔐 Generate Strong Password

```bash
# Using openssl
openssl rand -base64 32

# Using Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

## 📚 Documentation Links

| Document | Purpose | Time |
|----------|---------|------|
| [Quick Start](./docs/SWAGGER_SECURITY_QUICKSTART.md) | Fast setup | 5 min |
| [Index](./docs/SWAGGER_SECURITY_INDEX.md) | Navigation | 2 min |
| [Checklist](./docs/SWAGGER_SECURITY_CHECKLIST.md) | Deployment | 15 min |
| [Complete Guide](./docs/SWAGGER_SECURITY.md) | Full details | 20 min |
| [Examples](./docs/SWAGGER_SECURITY_EXAMPLES.md) | Code samples | 30 min |

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| Can't access Swagger | Check `NODE_ENV=production` |
| Wrong credentials | Verify `SWAGGER_USER` and `SWAGGER_PASSWORD` |
| Browser keeps asking | Clear cache, check credentials |
| Want to disable | Set `NODE_ENV=development` (not recommended) |

## ✅ Pre-Deployment Checklist

- [ ] Set `NODE_ENV=production`
- [ ] Set custom `SWAGGER_USER`
- [ ] Set strong `SWAGGER_PASSWORD`
- [ ] Test authentication
- [ ] Document credentials securely
- [ ] Notify team

## 🔄 Quick Access Methods

### Browser
1. Open `http://localhost:3001/api`
2. Enter username and password
3. Click "Sign In"

### curl
```bash
curl -u username:password http://localhost:3001/api
```

### Postman
1. Authorization → Basic Auth
2. Enter username and password
3. Send request

### JavaScript
```javascript
const credentials = btoa('username:password');
fetch('http://localhost:3001/api', {
  headers: { 'Authorization': `Basic ${credentials}` }
});
```

## 📞 Need Help?

1. **Quick Setup**: [SWAGGER_SECURITY_QUICKSTART.md](./docs/SWAGGER_SECURITY_QUICKSTART.md)
2. **Full Guide**: [SWAGGER_SECURITY.md](./docs/SWAGGER_SECURITY.md)
3. **All Docs**: [SWAGGER_SECURITY_INDEX.md](./docs/SWAGGER_SECURITY_INDEX.md)

## 🎯 Key Points

✅ **Development**: No authentication (easy testing)
🔒 **Production**: Username + password required
📝 **Configuration**: Environment variables only
🔐 **Security**: HTTP Basic Authentication
📚 **Documentation**: 7 comprehensive guides

---

**Print this page and keep it at your desk!**

**Quick Start**: [docs/SWAGGER_SECURITY_QUICKSTART.md](./docs/SWAGGER_SECURITY_QUICKSTART.md)
