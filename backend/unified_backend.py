#!/usr/bin/env python3
"""
Crystal Grimoire Beta0.2 - Unified Backend Service
Complete backend with Firebase, Stripe, LLM, and Horoscope integrations
"""

from fastapi import FastAPI, HTTPException, Depends, Header, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
import os
import logging
import httpx
import json
from datetime import datetime, timedelta
from contextlib import asynccontextmanager
import stripe
import firebase_admin
from firebase_admin import credentials, firestore, auth
from enum import Enum
import hashlib
import base64

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Load environment variables
from dotenv import load_dotenv
load_dotenv()

# ===== CONFIGURATION =====
class Config:
    # Firebase
    FIREBASE_CREDENTIALS_PATH = os.getenv("FIREBASE_CREDENTIALS_PATH", "firebase-credentials.json")
    
    # Stripe
    STRIPE_SECRET_KEY = os.getenv("STRIPE_SECRET_KEY")
    STRIPE_WEBHOOK_SECRET = os.getenv("STRIPE_WEBHOOK_SECRET")
    STRIPE_PREMIUM_PRICE_ID = os.getenv("STRIPE_PREMIUM_PRICE_ID")
    STRIPE_PRO_PRICE_ID = os.getenv("STRIPE_PRO_PRICE_ID")
    
    # LLM APIs
    OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
    ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY")
    GOOGLE_AI_API_KEY = os.getenv("GOOGLE_AI_API_KEY")
    
    # Horoscope API
    HOROSCOPE_API_KEY = os.getenv("HOROSCOPE_API_KEY")
    HOROSCOPE_API_URL = os.getenv("HOROSCOPE_API_URL")
    HOROSCOPE_API_HOST = os.getenv("HOROSCOPE_API_HOST")
    
    # App Configuration
    ALLOWED_ORIGINS = os.getenv("ALLOWED_ORIGINS", "*").split(",")
    ENVIRONMENT = os.getenv("ENVIRONMENT", "development")
    API_BASE_URL = os.getenv("API_BASE_URL", "http://localhost:8080")
    
    # Subscription Limits
    FREE_DAILY_LIMIT = int(os.getenv("FREE_TIER_DAILY_IDENTIFICATIONS", "5"))
    PREMIUM_DAILY_LIMIT = int(os.getenv("PREMIUM_TIER_DAILY_IDENTIFICATIONS", "30"))
    PRO_DAILY_LIMIT = int(os.getenv("PRO_TIER_DAILY_IDENTIFICATIONS", "999"))

# ===== ENUMS =====
class SubscriptionTier(str, Enum):
    FREE = "free"
    PREMIUM = "premium"
    PRO = "pro"
    FOUNDERS = "founders"

class LLMProvider(str, Enum):
    OPENAI = "openai"
    ANTHROPIC = "anthropic"
    GOOGLE = "google"

# ===== MODELS =====
class UserProfile(BaseModel):
    id: str
    name: str
    email: str
    birth_date: Optional[datetime] = None
    birth_time: Optional[str] = None
    birth_location: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    subscription_tier: SubscriptionTier = SubscriptionTier.FREE
    stripe_customer_id: Optional[str] = None
    spiritual_preferences: Dict[str, Any] = {}
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

class CrystalIdentificationRequest(BaseModel):
    image_base64: Optional[str] = None
    description: str
    user_context: Optional[Dict[str, Any]] = None

class PersonalizedGuidanceRequest(BaseModel):
    query: str
    guidance_type: str = "general"
    include_crystals: bool = True
    include_astrology: bool = True

class HoroscopeRequest(BaseModel):
    zodiac_sign: str
    horoscope_type: str = "daily"  # daily, weekly, monthly

# ===== SERVICES =====
class FirebaseService:
    """Handles all Firebase operations"""
    def __init__(self):
        try:
            if not firebase_admin._apps:
                cred = credentials.Certificate(Config.FIREBASE_CREDENTIALS_PATH)
                firebase_admin.initialize_app(cred)
            self.db = firestore.client()
            logger.info("Firebase initialized successfully")
        except Exception as e:
            logger.error(f"Firebase initialization failed: {e}")
            self.db = None
    
    async def get_user_profile(self, user_id: str) -> Optional[UserProfile]:
        """Fetch user profile from Firestore"""
        if not self.db:
            return None
        
        try:
            doc = self.db.collection('users').document(user_id).get()
            if doc.exists:
                return UserProfile(**doc.to_dict())
            return None
        except Exception as e:
            logger.error(f"Error fetching user profile: {e}")
            return None
    
    async def update_user_usage(self, user_id: str, usage_type: str):
        """Update user's daily usage counters"""
        if not self.db:
            return
        
        try:
            today = datetime.utcnow().strftime("%Y-%m-%d")
            usage_ref = self.db.collection('users').document(user_id).collection('usage').document(today)
            
            usage_ref.set({
                usage_type: firestore.Increment(1),
                'last_updated': datetime.utcnow()
            }, merge=True)
        except Exception as e:
            logger.error(f"Error updating usage: {e}")

class LLMService:
    """Unified LLM service supporting multiple providers"""
    def __init__(self):
        self.openai_available = bool(Config.OPENAI_API_KEY)
        self.anthropic_available = bool(Config.ANTHROPIC_API_KEY)
        self.google_available = bool(Config.GOOGLE_AI_API_KEY)
    
    async def generate_response(self, prompt: str, tier: SubscriptionTier, provider: Optional[LLMProvider] = None) -> str:
        """Generate AI response based on user tier and provider preference"""
        
        # Select provider based on tier if not specified
        if not provider:
            if tier == SubscriptionTier.PRO and self.anthropic_available:
                provider = LLMProvider.ANTHROPIC
            elif tier == SubscriptionTier.PREMIUM and self.openai_available:
                provider = LLMProvider.OPENAI
            else:
                provider = LLMProvider.GOOGLE if self.google_available else None
        
        if not provider:
            raise HTTPException(status_code=503, detail="No LLM provider available")
        
        try:
            if provider == LLMProvider.OPENAI:
                return await self._generate_openai(prompt, tier)
            elif provider == LLMProvider.ANTHROPIC:
                return await self._generate_anthropic(prompt, tier)
            elif provider == LLMProvider.GOOGLE:
                return await self._generate_google(prompt)
            else:
                raise HTTPException(status_code=400, detail="Invalid LLM provider")
        except Exception as e:
            logger.error(f"LLM generation error: {e}")
            raise HTTPException(status_code=500, detail=f"AI generation failed: {str(e)}")
    
    async def _generate_openai(self, prompt: str, tier: SubscriptionTier) -> str:
        """Generate response using OpenAI"""
        model = "gpt-4-turbo-preview" if tier in [SubscriptionTier.PRO, SubscriptionTier.FOUNDERS] else "gpt-3.5-turbo"
        
        async with httpx.AsyncClient() as client:
            response = await client.post(
                "https://api.openai.com/v1/chat/completions",
                headers={
                    "Authorization": f"Bearer {Config.OPENAI_API_KEY}",
                    "Content-Type": "application/json"
                },
                json={
                    "model": model,
                    "messages": [{"role": "user", "content": prompt}],
                    "temperature": 0.7,
                    "max_tokens": 1000
                }
            )
            response.raise_for_status()
            return response.json()["choices"][0]["message"]["content"]
    
    async def _generate_anthropic(self, prompt: str, tier: SubscriptionTier) -> str:
        """Generate response using Anthropic Claude"""
        model = "claude-3-opus-20240229" if tier == SubscriptionTier.FOUNDERS else "claude-3-sonnet-20240229"
        
        async with httpx.AsyncClient() as client:
            response = await client.post(
                "https://api.anthropic.com/v1/messages",
                headers={
                    "x-api-key": Config.ANTHROPIC_API_KEY,
                    "anthropic-version": "2023-06-01",
                    "Content-Type": "application/json"
                },
                json={
                    "model": model,
                    "messages": [{"role": "user", "content": prompt}],
                    "max_tokens": 1000
                }
            )
            response.raise_for_status()
            return response.json()["content"][0]["text"]
    
    async def _generate_google(self, prompt: str) -> str:
        """Generate response using Google Gemini"""
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={Config.GOOGLE_AI_API_KEY}",
                json={
                    "contents": [{"parts": [{"text": prompt}]}],
                    "generationConfig": {
                        "temperature": 0.7,
                        "maxOutputTokens": 1000
                    }
                }
            )
            response.raise_for_status()
            return response.json()["candidates"][0]["content"]["parts"][0]["text"]

class HoroscopeService:
    """Handles horoscope and astrology data"""
    async def get_daily_horoscope(self, zodiac_sign: str) -> Dict[str, Any]:
        """Fetch daily horoscope from API"""
        if not Config.HOROSCOPE_API_KEY:
            # Fallback to AI-generated horoscope
            return await self._generate_ai_horoscope(zodiac_sign)
        
        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(
                    f"{Config.HOROSCOPE_API_URL}/daily",
                    params={"sign": zodiac_sign},
                    headers={
                        "X-RapidAPI-Key": Config.HOROSCOPE_API_KEY,
                        "X-RapidAPI-Host": Config.HOROSCOPE_API_HOST
                    }
                )
                response.raise_for_status()
                return response.json()
        except Exception as e:
            logger.error(f"Horoscope API error: {e}")
            return await self._generate_ai_horoscope(zodiac_sign)
    
    async def _generate_ai_horoscope(self, zodiac_sign: str) -> Dict[str, Any]:
        """Generate horoscope using AI as fallback"""
        llm_service = LLMService()
        prompt = f"""Generate a personalized daily horoscope for {zodiac_sign}.
        Include:
        - General outlook
        - Love and relationships
        - Career and money
        - Health and wellness
        - Lucky crystal for today
        - Lucky numbers
        Format as JSON with these keys."""
        
        try:
            response = await llm_service.generate_response(prompt, SubscriptionTier.FREE)
            return json.loads(response)
        except:
            return {
                "sign": zodiac_sign,
                "date": datetime.utcnow().strftime("%Y-%m-%d"),
                "horoscope": f"Today brings new opportunities for {zodiac_sign}. Trust your intuition.",
                "lucky_crystal": "Clear Quartz",
                "lucky_numbers": [7, 14, 21]
            }

class StripeService:
    """Handles payment processing"""
    def __init__(self):
        if Config.STRIPE_SECRET_KEY:
            stripe.api_key = Config.STRIPE_SECRET_KEY
    
    async def create_checkout_session(self, user_id: str, price_id: str, success_url: str, cancel_url: str):
        """Create Stripe checkout session"""
        try:
            session = stripe.checkout.Session.create(
                payment_method_types=['card'],
                line_items=[{
                    'price': price_id,
                    'quantity': 1,
                }],
                mode='subscription',
                success_url=success_url,
                cancel_url=cancel_url,
                metadata={'user_id': user_id}
            )
            return session
        except Exception as e:
            logger.error(f"Stripe error: {e}")
            raise HTTPException(status_code=400, detail=str(e))

# ===== INITIALIZE SERVICES =====
firebase_service = FirebaseService()
llm_service = LLMService()
horoscope_service = HoroscopeService()
stripe_service = StripeService()

# ===== FASTAPI APP =====
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    logger.info("Starting Crystal Grimoire Unified Backend v2.0")
    yield
    # Shutdown
    logger.info("Shutting down Crystal Grimoire Backend")

app = FastAPI(
    title="Crystal Grimoire Unified API",
    version="2.0.0",
    lifespan=lifespan
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=Config.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ===== AUTH DEPENDENCIES =====
async def get_current_user(authorization: str = Header(None)) -> UserProfile:
    """Verify Firebase auth token and return user profile"""
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")
    
    token = authorization.split(" ")[1]
    
    try:
        # Verify Firebase token
        decoded_token = auth.verify_id_token(token)
        user_id = decoded_token['uid']
        
        # Get user profile
        user_profile = await firebase_service.get_user_profile(user_id)
        if not user_profile:
            # Create new user profile
            user_profile = UserProfile(
                id=user_id,
                email=decoded_token.get('email', ''),
                name=decoded_token.get('name', 'Crystal Seeker')
            )
            # Save to Firestore
            await firebase_service.db.collection('users').document(user_id).set(user_profile.dict())
        
        return user_profile
    except Exception as e:
        logger.error(f"Auth error: {e}")
        raise HTTPException(status_code=401, detail="Invalid token")

# ===== ENDPOINTS =====
@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "version": "2.0.0",
        "services": {
            "firebase": firebase_service.db is not None,
            "openai": llm_service.openai_available,
            "anthropic": llm_service.anthropic_available,
            "google": llm_service.google_available,
            "stripe": bool(Config.STRIPE_SECRET_KEY),
            "horoscope": bool(Config.HOROSCOPE_API_KEY)
        }
    }

@app.post("/api/crystal/identify")
async def identify_crystal(
    request: CrystalIdentificationRequest,
    user: UserProfile = Depends(get_current_user)
):
    """Identify crystal from image and/or description"""
    # Check daily usage limit
    # TODO: Implement usage checking
    
    # Build personalized prompt
    prompt = f"""
    User Context:
    - Name: {user.name}
    - Zodiac Sign: {user.spiritual_preferences.get('zodiac_sign', 'Unknown')}
    - Subscription: {user.subscription_tier}
    
    Crystal Identification Request:
    Description: {request.description}
    
    Please identify this crystal and provide:
    1. Crystal name and type
    2. Metaphysical properties
    3. Chakra associations
    4. How it aligns with the user's zodiac sign
    5. Suggested uses based on their profile
    """
    
    if request.image_base64:
        # TODO: Add image processing
        prompt += "\n[Image data provided]"
    
    # Generate response
    response = await llm_service.generate_response(prompt, user.subscription_tier)
    
    # Update usage
    await firebase_service.update_user_usage(user.id, "crystal_identifications")
    
    return {
        "success": True,
        "identification": response,
        "usage_remaining": _calculate_remaining_usage(user.subscription_tier)
    }

@app.post("/api/guidance/personalized")
async def get_personalized_guidance(
    request: PersonalizedGuidanceRequest,
    user: UserProfile = Depends(get_current_user)
):
    """Get personalized metaphysical guidance"""
    # Build context-rich prompt
    context = {
        "user_name": user.name,
        "birth_date": user.birth_date,
        "zodiac_info": user.spiritual_preferences.get('zodiac_info', {}),
        "owned_crystals": [],  # TODO: Fetch from collection
        "recent_mood": "neutral",  # TODO: Fetch from journal
        "subscription_tier": user.subscription_tier
    }
    
    prompt = f"""
    PERSONALIZED GUIDANCE REQUEST
    
    User Profile:
    - Name: {context['user_name']}
    - Astrological Info: {context['zodiac_info']}
    - Subscription Level: {context['subscription_tier']}
    
    Query: {request.query}
    Guidance Type: {request.guidance_type}
    
    Please provide deeply personalized guidance that:
    1. Addresses their specific question
    2. Incorporates their astrological profile
    3. Suggests crystals they might benefit from
    4. Offers actionable spiritual practices
    5. Feels like advice from a trusted spiritual mentor
    """
    
    response = await llm_service.generate_response(prompt, user.subscription_tier)
    
    return {
        "success": True,
        "guidance": response,
        "context_used": context
    }

@app.get("/api/horoscope/{zodiac_sign}")
async def get_horoscope(
    zodiac_sign: str,
    user: UserProfile = Depends(get_current_user)
):
    """Get daily horoscope with crystal recommendations"""
    horoscope_data = await horoscope_service.get_daily_horoscope(zodiac_sign)
    
    # Enhance with crystal recommendations based on user's collection
    # TODO: Add personalized crystal suggestions
    
    return {
        "success": True,
        "horoscope": horoscope_data,
        "personalized_for": user.name
    }

@app.post("/api/subscription/checkout")
async def create_subscription_checkout(
    tier: str,
    user: UserProfile = Depends(get_current_user)
):
    """Create Stripe checkout session for subscription"""
    price_id_map = {
        "premium": Config.STRIPE_PREMIUM_PRICE_ID,
        "pro": Config.STRIPE_PRO_PRICE_ID
    }
    
    if tier not in price_id_map:
        raise HTTPException(status_code=400, detail="Invalid subscription tier")
    
    session = await stripe_service.create_checkout_session(
        user_id=user.id,
        price_id=price_id_map[tier],
        success_url=f"{Config.API_BASE_URL}/subscription/success?session_id={{CHECKOUT_SESSION_ID}}",
        cancel_url=f"{Config.API_BASE_URL}/subscription/cancel"
    )
    
    return {
        "success": True,
        "checkout_url": session.url,
        "session_id": session.id
    }

@app.post("/api/webhook/stripe")
async def stripe_webhook(request: dict):
    """Handle Stripe webhook events"""
    # TODO: Implement webhook signature verification
    # TODO: Handle subscription events
    return {"received": True}

# ===== HELPER FUNCTIONS =====
def _calculate_remaining_usage(tier: SubscriptionTier) -> int:
    """Calculate remaining daily usage based on tier"""
    limits = {
        SubscriptionTier.FREE: Config.FREE_DAILY_LIMIT,
        SubscriptionTier.PREMIUM: Config.PREMIUM_DAILY_LIMIT,
        SubscriptionTier.PRO: Config.PRO_DAILY_LIMIT,
        SubscriptionTier.FOUNDERS: 9999
    }
    # TODO: Implement actual usage calculation
    return limits.get(tier, 0)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)