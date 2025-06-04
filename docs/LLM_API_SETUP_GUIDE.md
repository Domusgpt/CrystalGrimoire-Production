# 🤖 LLM API Integration Setup Guide

## Overview
Crystal Grimoire uses multiple LLM providers to deliver tier-appropriate AI features:
- **Free Tier**: Google Gemini (cost-effective)
- **Premium Tier**: OpenAI GPT-4 (balanced quality)
- **Pro/Founders Tier**: Anthropic Claude Opus (highest quality)

## Option A: OpenAI Setup (Recommended)

### 1. Create OpenAI Account
1. Go to [platform.openai.com/signup](https://platform.openai.com/signup)
2. Sign up with email or Google account
3. Verify your email address

### 2. Add Payment Method
1. Navigate to [platform.openai.com/account/billing](https://platform.openai.com/account/billing)
2. Click "Add payment method"
3. Enter credit card details
4. Set usage limit: $100/month recommended

### 3. Generate API Key
1. Go to [platform.openai.com/api-keys](https://platform.openai.com/api-keys)
2. Click "Create new secret key"
3. Name it: "Crystal Grimoire Production"
4. Copy the key immediately (you won't see it again!)
5. Add to `.env`: `OPENAI_API_KEY=sk-...`

### 4. Configure Organization (Optional)
1. Go to Settings → Organization
2. Copy Organization ID
3. Add to `.env`: `OPENAI_ORG_ID=org-...`

### 5. Model Selection & Pricing
```
Free Tier: gpt-3.5-turbo
- Input: $0.0005 / 1K tokens
- Output: $0.0015 / 1K tokens
- Good for basic queries

Premium Tier: gpt-4-turbo-preview  
- Input: $0.01 / 1K tokens
- Output: $0.03 / 1K tokens
- Best balance of quality and cost

Pro Tier: gpt-4-32k
- Input: $0.06 / 1K tokens
- Output: $0.12 / 1K tokens
- Extended context for complex guidance
```

## Option B: Anthropic Claude Setup

### 1. Create Anthropic Account
1. Go to [console.anthropic.com](https://console.anthropic.com)
2. Sign up for access (may have waitlist)
3. Complete onboarding

### 2. Generate API Key
1. Navigate to API Keys section
2. Create new key: "Crystal Grimoire"
3. Copy key
4. Add to `.env`: `ANTHROPIC_API_KEY=sk-ant-...`

### 3. Model Selection
```
Premium: claude-3-sonnet
- Balanced performance
- ~$0.003 / 1K tokens

Pro/Founders: claude-3-opus
- Highest quality responses
- ~$0.015 / 1K tokens
```

## Option C: Google Gemini Setup (Budget Option)

### 1. Create Google Cloud Project
1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. Create new project: "crystal-grimoire"
3. Enable billing (has free tier)

### 2. Enable Gemini API
1. Go to APIs & Services → Library
2. Search for "Generative Language API"
3. Click Enable

### 3. Create API Key
1. Go to APIs & Services → Credentials
2. Create credentials → API Key
3. Restrict key to Gemini API
4. Copy key
5. Add to `.env`: `GOOGLE_AI_API_KEY=AIza...`

### 4. Model Options
```
Free Tier: gemini-pro
- 60 requests per minute free
- Good for basic features

Paid: gemini-pro-vision
- Includes image analysis
- ~$0.00025 / 1K characters
```

## Implementing Tier-Based AI

### System Prompts by Tier

#### Free Tier Prompt Template
```python
FREE_TIER_PROMPT = """
You are a helpful crystal guide assistant. Provide basic information about crystals 
and their properties. Keep responses concise (under 200 words).

User: {query}
Response:
"""
```

#### Premium Tier Prompt Template
```python
PREMIUM_TIER_PROMPT = """
You are an experienced crystal healing practitioner and spiritual guide. 
You have deep knowledge of:
- Crystal properties and metaphysical uses
- Chakra healing and energy work
- Astrological correspondences
- Meditation and ritual practices

User Profile:
- Name: {user_name}
- Zodiac: {zodiac_sign}
- Owned Crystals: {crystal_collection}
- Recent Mood: {recent_mood}

Query: {query}

Provide personalized, detailed guidance that references their specific situation.
Include practical steps they can take with their crystals.
"""
```

#### Pro/Founders Tier Prompt Template
```python
PRO_TIER_PROMPT = """
You are a master metaphysical counselor with decades of experience in:
- Crystal healing and programming
- Jungian psychology and shadow work
- Vedic and Western astrology
- Sacred geometry and energy grids
- Quantum consciousness principles

User Deep Profile:
- Full Name: {user_name}
- Birth Chart: {birth_chart_data}
- Crystal Collection: {detailed_collection}
- Journal History: {journal_summary}
- Spiritual Goals: {spiritual_preferences}
- Recent Rituals: {ritual_history}
- Current Transits: {astrological_transits}

Query: {query}

Provide transformative guidance that:
1. Addresses their query at multiple levels (practical, emotional, spiritual)
2. Integrates their complete metaphysical profile
3. Suggests specific crystal combinations and sacred geometry layouts
4. Includes timing based on lunar and astrological cycles
5. Offers both immediate actions and long-term spiritual practices
6. References relevant esoteric traditions and modern consciousness research

Your response should feel like consulting with a wise spiritual mentor who deeply 
understands their unique journey.
"""
```

## Cost Optimization Strategies

### 1. Token Usage Monitoring
```python
def estimate_token_cost(text: str, model: str) -> float:
    # Rough estimate: 1 token ≈ 4 characters
    tokens = len(text) / 4
    
    costs = {
        "gpt-3.5-turbo": 0.002,
        "gpt-4-turbo": 0.03,
        "claude-opus": 0.015,
        "gemini-pro": 0.0001
    }
    
    return tokens * costs.get(model, 0.01) / 1000
```

### 2. Response Caching
```python
# Cache common queries for 24 hours
CACHED_RESPONSES = {
    "amethyst_properties": "cached_response_here",
    "chakra_basics": "cached_response_here"
}

# Check cache before API call
if query_type in CACHED_RESPONSES:
    return CACHED_RESPONSES[query_type]
```

### 3. Batch Processing
- Group similar requests
- Use bulk endpoints where available
- Process during off-peak hours

## Error Handling & Fallbacks

### Graceful Degradation
```python
async def get_ai_response(prompt: str, tier: str) -> str:
    try:
        # Try primary provider
        return await primary_llm.generate(prompt)
    except RateLimitError:
        # Fall back to secondary
        return await backup_llm.generate(prompt)
    except Exception as e:
        # Ultimate fallback
        return get_static_response(prompt)
```

### Rate Limit Management
```python
# Implement exponential backoff
import time

def retry_with_backoff(func, max_retries=3):
    for i in range(max_retries):
        try:
            return func()
        except RateLimitError:
            time.sleep(2 ** i)
    raise Exception("Max retries exceeded")
```

## Testing Your Integration

### 1. Test Prompts
```python
# Test basic functionality
test_prompts = [
    "What are the properties of amethyst?",
    "I'm feeling anxious, which crystal should I use?",
    "Create a crystal grid for abundance"
]

# Test personalization
personalized_test = {
    "query": "What crystal should I work with today?",
    "user_data": {
        "zodiac": "Pisces",
        "mood": "creative",
        "owned_crystals": ["amethyst", "moonstone"]
    }
}
```

### 2. Monitor Usage
- Set up usage alerts in provider dashboards
- Track cost per user tier
- Monitor response times
- Log token usage

## Production Best Practices

### 1. Security
- Never expose API keys in frontend code
- Use environment variables
- Implement request signing
- Rate limit by user

### 2. Performance
- Cache frequent queries
- Use streaming for long responses
- Implement timeout handling
- Batch similar requests

### 3. Quality Control
- Log all prompts and responses
- Implement content filtering
- Monitor for harmful outputs
- Collect user feedback

## Monthly Cost Projections

Based on 1000 active users:

### Conservative Usage (5 queries/user/day)
```
Free Tier (70%): 
- 3,500 users × 5 queries × 30 days = 525,000 queries
- Using Gemini: ~$50/month

Premium Tier (25%):
- 250 users × 10 queries × 30 days = 75,000 queries  
- Using GPT-4-turbo: ~$225/month

Pro Tier (5%):
- 50 users × 20 queries × 30 days = 30,000 queries
- Using Claude Opus: ~$150/month

Total: ~$425/month
```

## Troubleshooting

### "Invalid API Key"
- Check for extra spaces in .env file
- Ensure using correct key (test vs production)
- Verify key hasn't been revoked

### "Rate Limit Exceeded"  
- Implement exponential backoff
- Upgrade to higher tier
- Distribute requests over time

### "Context Length Exceeded"
- Truncate user history
- Summarize long contexts
- Use model with larger context window

## Horoscope API Integration

### Option 1: RapidAPI Horoscope
1. Sign up at [rapidapi.com](https://rapidapi.com)
2. Subscribe to "Horoscope Astrology" API
3. Get API key from dashboard
4. Add to `.env`:
   ```
   HOROSCOPE_API_KEY=your_key
   HOROSCOPE_API_URL=https://horoscope-astrology.p.rapidapi.com
   HOROSCOPE_API_HOST=horoscope-astrology.p.rapidapi.com
   ```

### Option 2: AI-Generated Horoscopes
If no horoscope API available, use LLM:
```python
prompt = f"""
Generate a daily horoscope for {zodiac_sign} on {date}.
Include:
- General fortune
- Love outlook  
- Career advice
- Health tips
- Lucky crystal
- Lucky numbers
Format as JSON.
"""
```

---

💡 **Pro Tip**: Start with Google Gemini for development, upgrade to OpenAI for production!