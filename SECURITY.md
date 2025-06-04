# 🔐 Security Configuration for Crystal Grimoire

## ⚠️ CRITICAL: API Key Management

### **NEVER commit API keys to source code**

All API keys must be managed through environment variables or GitHub Secrets.

## 🔑 Setting Up GitHub Secrets

### 1. Add Secrets to Repository
Go to: https://github.com/domusgpt/CrystalGrimoire-Production/settings/secrets/actions

Add these secrets:
```
GEMINI_API_KEY=AIzaSyC__1EHCjv9pCRJzQoRQiKVxTfaPMXFXAs
FIREBASE_API_KEY=(when you get it)
STRIPE_PUBLISHABLE_KEY=(when you get it)
```

### 2. Local Development
Copy `.env.example` to `.env` and add your keys:
```bash
cp .env.example .env
# Edit .env with your API keys
```

The `.env` file is in `.gitignore` and will never be committed.

## 🛡️ Security Best Practices

### Environment Variables
```dart
// ✅ CORRECT - Use environment variables
static const String _geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

// ❌ WRONG - Never hardcode keys
static const String _geminiApiKey = 'AIzaSy...'; // NEVER DO THIS
```

### Build Configuration
```bash
# Production build with secrets
flutter build web --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY
```

### GitHub Actions
```yaml
# Secrets are automatically secured in GitHub Actions
env:
  GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
```

## 🔒 API Key Rotation

If an API key is compromised:

1. **Immediately revoke** the old key in the provider console
2. **Generate** a new key
3. **Update** GitHub Secrets and local `.env`
4. **Test** the application with new keys

## 📋 Security Checklist

- [ ] All API keys removed from source code
- [ ] GitHub Secrets configured
- [ ] Local `.env` file created (not committed)
- [ ] Old compromised keys revoked
- [ ] New keys tested and working

## 🚨 Incident Response

If API keys are exposed:
1. Revoke exposed keys immediately
2. Generate new keys
3. Update all environments
4. Check for unauthorized usage
5. Document the incident

## 🔍 Security Scanning

This repository uses:
- GitGuardian for secret detection
- GitHub security scanning
- Automated dependency updates

Never ignore security alerts - fix them immediately.