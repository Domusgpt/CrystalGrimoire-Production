#!/usr/bin/env python3
"""
Crystal Grimoire Beta0.2 - Demo Backend with Mock APIs (Port 8081)
Full working backend for demonstration with all features mocked
"""

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import json
import uuid
from datetime import datetime, timedelta
import random

# Demo data and responses
DEMO_CRYSTALS = [
    {
        "name": "Amethyst",
        "type": "Quartz",
        "color": "Purple",
        "chakra": "Crown",
        "properties": ["Spiritual protection", "Enhanced intuition", "Stress relief"],
        "zodiac_compatibility": ["Pisces", "Virgo", "Aquarius"],
        "description": "A powerful protective stone that transforms negative energy into love."
    },
    {
        "name": "Rose Quartz",
        "type": "Quartz",
        "color": "Pink",
        "chakra": "Heart",
        "properties": ["Unconditional love", "Emotional healing", "Self-compassion"],
        "zodiac_compatibility": ["Taurus", "Libra"],
        "description": "The stone of unconditional love, promoting deep inner healing."
    },
    {
        "name": "Clear Quartz",
        "type": "Quartz", 
        "color": "Clear",
        "chakra": "Crown",
        "properties": ["Amplification", "Clarity", "Energy cleansing"],
        "zodiac_compatibility": ["All signs"],
        "description": "The master healer that amplifies energy and brings clarity."
    }
]

DEMO_HOROSCOPES = {
    "aries": "Today brings fiery energy perfect for new beginnings. Your ruling planet Mars encourages bold action.",
    "taurus": "Venus blesses you with harmony and beauty today. Focus on material stability and sensual pleasures.",
    "gemini": "Mercury enhances your communication skills. It's a perfect day for learning and social connections.",
    "cancer": "The Moon illuminates your emotional depths. Trust your intuition and nurture those you love.",
    "leo": "The Sun radiates through you today. Step into your power and let your creativity shine brightly.",
    "virgo": "Earth energy grounds you in practical matters. Pay attention to details and health routines.",
    "libra": "Venus brings balance to relationships. Seek harmony and beauty in all your interactions.",
    "scorpio": "Pluto stirs transformative energies. Embrace change and dive deep into mysteries.",
    "sagittarius": "Jupiter expands your horizons. Adventure and higher learning call to your spirit.",
    "capricorn": "Saturn supports your ambitions. Structure and discipline lead to lasting achievements.",
    "aquarius": "Uranus sparks innovation. Think outside the box and embrace your unique perspective.",
    "pisces": "Neptune enhances your psychic abilities. Dreams and intuition guide your way forward."
}

DEMO_GUIDANCE_RESPONSES = [
    "Based on your spiritual profile, I sense you're entering a period of deep transformation. The crystals in your collection, particularly amethyst, are perfectly aligned with your current energy. Consider placing amethyst under your pillow tonight to enhance dream clarity.",
    "Your birth chart shows strong water element influence, which resonates beautifully with rose quartz energy. This is an excellent time for heart chakra healing work. Try holding rose quartz during meditation and focus on self-love affirmations.",
    "The current lunar phase supports releasing old patterns. Clear quartz would be perfect for this work - it will amplify your intentions while cleansing stagnant energy. Create a simple crystal grid with your clear quartz at the center.",
    "I notice Scorpio influence in your chart, suggesting you're naturally drawn to transformation work. Black tourmaline would be a powerful addition to your collection for protection during this deep spiritual work."
]

# Models
class CrystalIdentificationRequest(BaseModel):
    image_base64: Optional[str] = None
    description: str
    user_context: Optional[Dict[str, Any]] = {}

class PersonalizedGuidanceRequest(BaseModel):
    query: str
    guidance_type: str = "general"
    user_context: Optional[Dict[str, Any]] = {}

class UserProfile(BaseModel):
    name: str = "Crystal Seeker"
    zodiac_sign: str = "pisces"
    subscription_tier: str = "free"
    owned_crystals: List[str] = []

# FastAPI App
app = FastAPI(title="Crystal Grimoire Demo API", version="2.0.0")

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "🔮 Crystal Grimoire Beta0.2 Demo API",
        "version": "2.0.0",
        "status": "running",
        "docs": "/docs",
        "health": "/health"
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "version": "2.0.0",
        "mode": "demo",
        "services": {
            "crystal_ai": True,
            "horoscope": True,
            "guidance": True,
            "payment": True
        }
    }

@app.post("/api/crystal/identify")
async def identify_crystal(request: CrystalIdentificationRequest):
    """Demo crystal identification with AI-like responses"""
    
    # Find best match based on description
    description_lower = request.description.lower()
    best_match = DEMO_CRYSTALS[0]  # Default to amethyst
    
    for crystal in DEMO_CRYSTALS:
        if crystal["name"].lower() in description_lower or crystal["color"].lower() in description_lower:
            best_match = crystal
            break
    
    # Generate personalized response
    user_zodiac = request.user_context.get("zodiac_sign", "unknown")
    zodiac_match = user_zodiac.title() in best_match["zodiac_compatibility"]
    
    response = {
        "success": True,
        "crystal": best_match,
        "confidence": round(random.uniform(0.85, 0.98), 2),
        "personalized_insights": {
            "zodiac_compatibility": zodiac_match,
            "chakra_alignment": f"This crystal resonates with your {best_match['chakra']} chakra",
            "recommendation": f"Perfect for {user_zodiac} energy!" if zodiac_match else f"A wonderful complement to {user_zodiac} energy",
            "usage_suggestion": f"Try placing {best_match['name']} on your {best_match['chakra'].lower()} chakra during meditation"
        },
        "usage_remaining": 4,
        "tier_benefits": {
            "current": "free",
            "upgrade_message": "Upgrade to Premium for unlimited identifications and detailed crystal histories!"
        }
    }
    
    return response

@app.post("/api/guidance/personalized")
async def get_personalized_guidance(request: PersonalizedGuidanceRequest):
    """Demo personalized metaphysical guidance"""
    
    # Select response based on query keywords
    query_lower = request.query.lower()
    
    if "anxious" in query_lower or "stress" in query_lower:
        guidance = DEMO_GUIDANCE_RESPONSES[0] + " For anxiety relief, try amethyst or rose quartz in a calming meditation."
    elif "love" in query_lower or "relationship" in query_lower:
        guidance = DEMO_GUIDANCE_RESPONSES[1] + " Rose quartz is your ally in matters of the heart."
    elif "transformation" in query_lower or "change" in query_lower:
        guidance = DEMO_GUIDANCE_RESPONSES[2] + " Clear quartz will amplify your transformational work."
    else:
        guidance = random.choice(DEMO_GUIDANCE_RESPONSES)
    
    user_context = request.user_context
    
    return {
        "success": True,
        "guidance": guidance,
        "context_used": {
            "zodiac_sign": user_context.get("zodiac_sign", "Unknown"),
            "owned_crystals": user_context.get("owned_crystals", []),
            "moon_phase": "Waxing Crescent",
            "guidance_type": request.guidance_type
        },
        "follow_up_suggestions": [
            "Journal about any insights that come up",
            "Create a crystal grid with your guidance crystals",
            "Set intentions during tonight's moon phase"
        ],
        "tier_info": {
            "current": "demo",
            "available_features": ["Basic guidance", "Crystal recommendations"],
            "premium_features": ["Deep astrological analysis", "Personalized rituals", "Dream interpretation"]
        }
    }

@app.get("/api/horoscope/{zodiac_sign}")
async def get_horoscope(zodiac_sign: str):
    """Demo horoscope with crystal recommendations"""
    
    sign = zodiac_sign.lower()
    if sign not in DEMO_HOROSCOPES:
        raise HTTPException(status_code=400, detail="Invalid zodiac sign")
    
    # Find compatible crystals
    compatible_crystals = []
    for crystal in DEMO_CRYSTALS:
        if sign.title() in crystal["zodiac_compatibility"] or "All signs" in crystal["zodiac_compatibility"]:
            compatible_crystals.append(crystal["name"])
    
    return {
        "success": True,
        "zodiac_sign": sign.title(),
        "date": datetime.now().strftime("%Y-%m-%d"),
        "horoscope": DEMO_HOROSCOPES[sign],
        "daily_crystal": random.choice(compatible_crystals) if compatible_crystals else "Clear Quartz",
        "lucky_numbers": [random.randint(1, 50) for _ in range(3)],
        "moon_phase": "Waxing Crescent",
        "planetary_influences": {
            "dominant": "Venus",
            "supporting": "Moon",
            "aspect": "Harmonious"
        },
        "compatible_crystals": compatible_crystals,
        "spiritual_advice": f"Today's energy supports {sign} in manifestation work. Focus on your heart's desires."
    }

@app.get("/api/crystals/database")
async def get_crystal_database():
    """Demo crystal database"""
    return {
        "success": True,
        "crystals": DEMO_CRYSTALS,
        "total_count": len(DEMO_CRYSTALS),
        "categories": {
            "chakras": ["Crown", "Heart", "Throat", "Solar Plexus", "Sacral", "Root"],
            "colors": ["Purple", "Pink", "Clear", "Blue", "Yellow", "Orange", "Red"],
            "purposes": ["Protection", "Love", "Healing", "Manifestation", "Clarity"]
        }
    }

if __name__ == "__main__":
    import uvicorn
    print("🔮 Starting Crystal Grimoire Demo Backend...")
    print("🌟 Backend will be available at: http://localhost:8081")
    print("📖 API Documentation: http://localhost:8081/docs")
    uvicorn.run(app, host="0.0.0.0", port=8081, log_level="info")