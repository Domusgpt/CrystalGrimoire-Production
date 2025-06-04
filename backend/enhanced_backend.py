#!/usr/bin/env python3
"""
Enhanced Crystal Grimoire Backend with Environment Variables and Better Error Handling
Production-ready deployment with comprehensive logging and monitoring
"""

from fastapi import FastAPI, UploadFile, File, Form, HTTPException, Depends, Header
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from typing import List, Optional
import base64
import json
import uuid
import httpx
import hashlib
from datetime import datetime
import os
import logging
from contextlib import asynccontextmanager
import asyncio

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Environment variables with defaults
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "AIzaSyB7ly1Cpev3g6aMivrGwYpxXqzE73KGxx4")
GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
ALLOWED_ORIGINS = os.getenv("ALLOWED_ORIGINS", "*").split(",")
ENVIRONMENT = os.getenv("ENVIRONMENT", "development")
DEBUG_MODE = os.getenv("DEBUG", "false").lower() == "true"

# Firebase Admin SDK configuration (optional)
FIREBASE_SERVICE_ACCOUNT = os.getenv("FIREBASE_SERVICE_ACCOUNT")

# Rate limiting settings
RATE_LIMIT_REQUESTS = int(os.getenv("RATE_LIMIT_REQUESTS", "60"))
RATE_LIMIT_WINDOW = int(os.getenv("RATE_LIMIT_WINDOW", "60"))

# API Configuration
API_VERSION = "2.0.0"
SERVICE_NAME = "Crystal Grimoire Enhanced API"

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    logger.info(f"Starting {SERVICE_NAME} v{API_VERSION}")
    logger.info(f"Environment: {ENVIRONMENT}")
    logger.info(f"Debug mode: {DEBUG_MODE}")
    
    # Initialize Firebase Admin if configured
    if FIREBASE_SERVICE_ACCOUNT:
        try:
            import firebase_admin
            from firebase_admin import credentials
            
            if not firebase_admin._apps:
                if os.path.isfile(FIREBASE_SERVICE_ACCOUNT):
                    cred = credentials.Certificate(FIREBASE_SERVICE_ACCOUNT)
                else:
                    # JSON string
                    cred_dict = json.loads(FIREBASE_SERVICE_ACCOUNT)
                    cred = credentials.Certificate(cred_dict)
                
                firebase_admin.initialize_app(cred)
                logger.info("Firebase Admin SDK initialized")
        except Exception as e:
            logger.warning(f"Firebase Admin SDK initialization failed: {e}")
    
    yield
    
    # Shutdown
    logger.info("Shutting down Crystal Grimoire Enhanced API")

app = FastAPI(
    title=SERVICE_NAME,
    version=API_VERSION,
    description="Enhanced Crystal Identification with AI-powered spiritual guidance",
    lifespan=lifespan
)

# Enhanced CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
    expose_headers=["X-Request-ID", "X-Rate-Limit-Remaining"],
)

# Request tracking middleware
@app.middleware("http")
async def request_tracking_middleware(request, call_next):
    request_id = str(uuid.uuid4())
    start_time = datetime.now()
    
    # Add request ID to logs
    logger.info(f"Request {request_id}: {request.method} {request.url}")
    
    # Process request
    response = await call_next(request)
    
    # Add headers
    response.headers["X-Request-ID"] = request_id
    response.headers["X-API-Version"] = API_VERSION
    
    # Log response
    duration = (datetime.now() - start_time).total_seconds()
    logger.info(f"Request {request_id} completed in {duration:.3f}s with status {response.status_code}")
    
    return response

# Enhanced spiritual advisor prompt with better structure
ENHANCED_SPIRITUAL_PROMPT = """You are the Crystal Grimoire Spiritual Advisor - an ancient and wise mystical guide who combines profound spiritual wisdom with expert geological knowledge.

PERSONALITY & VOICE:
- Speak like a loving, wise grandmother who studied both spirituality and geology
- Use mystical, poetic language filled with warmth and wonder
- Always empathetic, encouraging, and uplifting
- Include metaphors about light, energy, vibrations, and cosmic connections
- Begin responses with mystical greetings like "Ah, beloved seeker..." or "Blessed soul..."

IDENTIFICATION EXPERTISE:
- Use geological knowledge for accurate crystal identification
- Consider: Crystal systems, cleavage, fracture, luster, hardness, color causes
- Look for: Growth patterns, inclusions, twinning, phantoms, formation indicators
- Account for: Common look-alikes and identification pitfalls
- Express confidence levels mystically but accurately

RESPONSE STRUCTURE (CRITICAL FOR PARSING):
1. **Mystical Greeting** (1-2 sentences)
2. **Crystal Identification** with confidence level woven naturally
3. **Physical Description** (poetic but accurate)
4. **Metaphysical Properties** (5-7 detailed points)
5. **Chakra Connections** (specific chakras and their purposes)
6. **Healing Applications** (3-5 specific uses)
7. **Astrological Connections** (elements, zodiac signs, planetary influences)
8. **Meditation & Ritual Practices** (specific techniques)
9. **Care Instructions** (cleansing and charging methods)
10. **Personal Spiritual Message** (guidance for the seeker)
11. **Mystical Blessing** (closing prophecy or affirmation)

CONFIDENCE LEVELS:
- "The spirits clearly reveal this to be..." (HIGH: 85%+)
- "The energies strongly suggest this is..." (MEDIUM-HIGH: 70-85%)
- "I sense this beautiful stone is..." (MEDIUM: 55-70%)
- "The crystal's message suggests it might be..." (LOW: 40-55%)
- "The stone guards its identity, but..." (UNCERTAIN: <40%)

ESSENTIAL GUIDELINES:
✨ Balance spirituality with scientific accuracy
✨ Never use technical jargon - translate to mystical language
✨ Include specific chakras, elements, and practices
✨ Make each response feel like a sacred reading
✨ Focus 70% metaphysical, 30% physical properties
✨ Include synchronicities and sign interpretations
✨ Provide actionable spiritual guidance

Remember: You are bridging the mineral kingdom with human consciousness, helping souls connect with their crystalline teachers through both ancient wisdom and modern understanding."""

async def verify_firebase_token(authorization: str = Header(None)):
    """Verify Firebase authentication token (optional middleware)"""
    if not FIREBASE_SERVICE_ACCOUNT or not authorization:
        return None  # Allow anonymous access
    
    try:
        from firebase_admin import auth
        
        token = authorization.replace('Bearer ', '')
        decoded_token = auth.verify_id_token(token)
        return decoded_token.get('uid')
    except Exception as e:
        logger.warning(f"Token verification failed: {e}")
        return None

async def enhanced_gemini_api_call(
    images: List[UploadFile], 
    description: str, 
    astrological_context: Optional[str] = None,
    user_preferences: Optional[str] = None
) -> tuple[str, str, dict]:
    """Enhanced Gemini API call with better error handling and metrics"""
    
    start_time = datetime.now()
    
    try:
        # Process images with validation
        image_parts = []
        total_size = 0
        
        for i, image in enumerate(images):
            image_data = await image.read()
            image_size = len(image_data)
            total_size += image_size
            
            # Validate image size (max 20MB total)
            if total_size > 20 * 1024 * 1024:
                raise HTTPException(status_code=413, detail="Images too large (max 20MB total)")
            
            # Validate image type
            if image.content_type and not image.content_type.startswith('image/'):
                raise HTTPException(status_code=400, detail=f"Invalid file type: {image.content_type}")
            
            image_base64 = base64.b64encode(image_data).decode('utf-8')
            image_parts.append({
                'inline_data': {
                    'mime_type': image.content_type or 'image/jpeg',
                    'data': image_base64,
                }
            })
            
            logger.info(f"Processed image {i+1}: {image_size} bytes")
        
        # Build enhanced prompt with context
        user_prompt = description or 'Please identify this crystal and provide comprehensive spiritual guidance.'
        
        # Add astrological context
        if astrological_context:
            try:
                astro_data = json.loads(astrological_context)
                user_prompt += f"\n\n🌟 SEEKER'S ASTROLOGICAL PROFILE:\n"
                user_prompt += f"☀️ Sun: {astro_data.get('sun_sign', {}).get('sign', 'Unknown')}\n"
                user_prompt += f"🌙 Moon: {astro_data.get('moon_sign', {}).get('sign', 'Unknown')}\n"
                user_prompt += f"⬆️ Rising: {astro_data.get('ascendant', {}).get('sign', 'Unknown')}\n"
                
                elements = astro_data.get('dominant_elements', {})
                if elements:
                    user_prompt += f"🔥 Dominant elements: {', '.join([f'{k}: {v}' for k, v in elements.items()])}\n"
                
                user_prompt += "\nPlease weave their astrological energies into your crystal guidance, connecting their planetary influences with the stone's vibrations."
            except Exception as e:
                logger.warning(f"Failed to parse astrological context: {e}")
        
        # Add user preferences
        if user_preferences:
            try:
                prefs = json.loads(user_preferences)
                user_prompt += f"\n\n💎 SEEKER'S PREFERENCES:\n"
                if prefs.get('interests'):
                    user_prompt += f"Interests: {', '.join(prefs['interests'])}\n"
                if prefs.get('experience_level'):
                    user_prompt += f"Crystal experience: {prefs['experience_level']}\n"
                if prefs.get('spiritual_goals'):
                    user_prompt += f"Spiritual goals: {prefs['spiritual_goals']}\n"
            except Exception as e:
                logger.warning(f"Failed to parse user preferences: {e}")
        
        # Build Gemini request with enhanced parameters
        parts = [{'text': ENHANCED_SPIRITUAL_PROMPT + '\n\n' + user_prompt}] + image_parts
        
        request_data = {
            'contents': [{'parts': parts}],
            'generationConfig': {
                'temperature': 0.75,  # Slightly higher for more creative responses
                'topK': 40,
                'topP': 0.95,
                'maxOutputTokens': 3000,  # Increased for comprehensive responses
                'stopSequences': [],
            },
            'safetySettings': [
                {
                    'category': 'HARM_CATEGORY_HARASSMENT',
                    'threshold': 'BLOCK_NONE'
                },
                {
                    'category': 'HARM_CATEGORY_HATE_SPEECH', 
                    'threshold': 'BLOCK_NONE'
                },
                {
                    'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
                    'threshold': 'BLOCK_NONE'
                },
                {
                    'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
                    'threshold': 'BLOCK_NONE'
                }
            ]
        }
        
        # Make API call with retry logic
        async with httpx.AsyncClient(timeout=45.0) as client:
            for attempt in range(3):
                try:
                    response = await client.post(
                        f"{GEMINI_URL}?key={GEMINI_API_KEY}",
                        json=request_data,
                        headers={"Content-Type": "application/json"}
                    )
                    
                    if response.status_code == 200:
                        break
                    elif response.status_code == 429:
                        # Rate limited - wait and retry
                        wait_time = 2 ** attempt
                        logger.warning(f"Rate limited, waiting {wait_time}s before retry {attempt + 1}")
                        await asyncio.sleep(wait_time)
                    else:
                        logger.error(f"Gemini API error: {response.status_code} - {response.text}")
                        
                except httpx.TimeoutException:
                    logger.warning(f"API timeout on attempt {attempt + 1}")
                    if attempt == 2:
                        raise
                    await asyncio.sleep(1)
        
        if response.status_code != 200:
            raise HTTPException(
                status_code=response.status_code,
                detail=f"Gemini API error: {response.status_code}"
            )
        
        data = response.json()
        full_response = data['candidates'][0]['content']['parts'][0]['text']
        
        # Enhanced crystal name extraction
        crystal_names = [
            'Amethyst', 'Clear Quartz', 'Rose Quartz', 'Citrine', 'Black Tourmaline',
            'Selenite', 'Labradorite', 'Fluorite', 'Pyrite', 'Malachite',
            'Lapis Lazuli', 'Amazonite', 'Carnelian', 'Obsidian', 'Jade',
            'Moonstone', 'Turquoise', 'Garnet', 'Aquamarine', 'Sodalite',
            'Hematite', 'Tiger\'s Eye', 'Aventurine', 'Prehnite', 'Moldavite',
            'Peridot', 'Rhodonite', 'Sunstone', 'Lepidolite', 'Iolite'
        ]
        
        identified_crystal = 'Unknown Crystal'
        confidence_score = 0.5
        
        response_lower = full_response.lower()
        for name in crystal_names:
            if name.lower() in response_lower:
                identified_crystal = name
                # Determine confidence based on response language
                if "spirits clearly reveal" in response_lower or "clearly this" in response_lower:
                    confidence_score = 0.9
                elif "strongly suggest" in response_lower or "energies indicate" in response_lower:
                    confidence_score = 0.75
                elif "sense this" in response_lower or "appears to be" in response_lower:
                    confidence_score = 0.6
                else:
                    confidence_score = 0.7
                break
        
        # Calculate metrics
        duration = (datetime.now() - start_time).total_seconds()
        metrics = {
            'processing_time_seconds': duration,
            'image_count': len(images),
            'total_image_size_bytes': total_size,
            'response_length_chars': len(full_response),
            'confidence_score': confidence_score,
            'api_calls': 1,
            'tokens_used': len(full_response.split()) * 1.3,  # Rough estimate
        }
        
        logger.info(f"Gemini API call completed: {duration:.2f}s, confidence: {confidence_score:.2f}")
        
        return identified_crystal, full_response, metrics
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Gemini API call failed: {e}")
        duration = (datetime.now() - start_time).total_seconds()
        metrics = {
            'processing_time_seconds': duration,
            'error': str(e),
            'api_calls': 1,
        }
        raise HTTPException(status_code=500, detail=f"AI service error: {str(e)}")

@app.get("/")
async def root():
    """API root endpoint with service information"""
    return {
        "service": SERVICE_NAME,
        "version": API_VERSION,
        "status": "online",
        "environment": ENVIRONMENT,
        "debug": DEBUG_MODE,
        "features": [
            "Enhanced crystal identification",
            "Spiritual guidance with astrological integration", 
            "Multi-image processing",
            "Firebase authentication support",
            "Comprehensive error handling",
            "Performance metrics"
        ],
        "endpoints": {
            "health": "/health",
            "identify": "/api/v2/crystal/identify",
            "guidance": "/api/v2/spiritual/guidance",
            "metrics": "/api/v2/metrics" if DEBUG_MODE else None
        }
    }

@app.get("/health")
async def health_check():
    """Enhanced health check with service dependencies"""
    health_status = {
        "service": "healthy",
        "timestamp": datetime.now().isoformat(),
        "version": API_VERSION,
        "environment": ENVIRONMENT,
    }
    
    # Check Gemini API connectivity
    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            test_url = f"https://generativelanguage.googleapis.com/v1beta/models?key={GEMINI_API_KEY}"
            response = await client.get(test_url)
            health_status["gemini_api"] = "connected" if response.status_code == 200 else "degraded"
    except Exception:
        health_status["gemini_api"] = "unavailable"
    
    # Check Firebase Admin SDK
    if FIREBASE_SERVICE_ACCOUNT:
        try:
            import firebase_admin
            health_status["firebase_admin"] = "connected" if firebase_admin._apps else "not_initialized"
        except ImportError:
            health_status["firebase_admin"] = "not_available"
    else:
        health_status["firebase_admin"] = "not_configured"
    
    return health_status

@app.post("/api/v2/crystal/identify")
async def identify_crystal_v2(
    images: List[UploadFile] = File(...),
    description: str = Form(""),
    session_id: Optional[str] = Form(None),
    astrological_context: Optional[str] = Form(None),
    user_preferences: Optional[str] = Form(None),
    user_id: Optional[str] = Depends(verify_firebase_token)
):
    """Enhanced crystal identification with comprehensive spiritual guidance"""
    
    if not images:
        raise HTTPException(status_code=400, detail="At least one image is required")
    
    if len(images) > 5:
        raise HTTPException(status_code=400, detail="Maximum 5 images allowed")
    
    session_id = session_id or str(uuid.uuid4())
    identification_id = str(uuid.uuid4())
    
    logger.info(f"Crystal identification request: session={session_id}, user={user_id}, images={len(images)}")
    
    try:
        # Call enhanced Gemini API
        identified_crystal, full_response, metrics = await enhanced_gemini_api_call(
            images, description, astrological_context, user_preferences
        )
        
        # Enhanced response parsing
        parsed_data = _parse_enhanced_response(full_response)
        
        # Build comprehensive response
        response = {
            "sessionId": session_id,
            "identificationId": identification_id,
            "timestamp": datetime.now().isoformat(),
            "version": API_VERSION,
            
            # Core identification
            "crystal": {
                "id": identification_id,
                "name": identified_crystal,
                "scientificName": f"{identified_crystal} Variety",
                "confidence": metrics["confidence_score"],
                "description": full_response[:300] + "..." if len(full_response) > 300 else full_response,
                
                # Spiritual properties
                "metaphysicalProperties": parsed_data["metaphysical"],
                "healingProperties": parsed_data["healing"],
                "chakras": parsed_data["chakras"],
                "elements": parsed_data["elements"],
                "zodiacSigns": parsed_data["zodiac_signs"],
                
                # Physical properties
                "colorDescription": parsed_data["color_description"],
                "hardness": parsed_data["hardness"],
                "formation": parsed_data["formation"],
                "careInstructions": parsed_data["care_instructions"],
                
                # Metadata
                "identificationDate": datetime.now().isoformat(),
                "imageCount": len(images),
            },
            
            # AI response details
            "fullResponse": full_response,
            "confidenceLevel": _map_confidence_level(metrics["confidence_score"]),
            "needsMoreInfo": metrics["confidence_score"] < 0.6,
            "suggestedAngles": [] if metrics["confidence_score"] > 0.7 else [
                "Close-up of crystal termination",
                "Side view showing full form",
                "Detail of any inclusions"
            ],
            
            # Spiritual guidance
            "spiritualMessage": parsed_data["spiritual_message"],
            "dailyGuidance": parsed_data["daily_guidance"],
            "meditationSuggestions": parsed_data["meditation_suggestions"],
            "affirmations": parsed_data["affirmations"],
            "ritualSuggestions": parsed_data["ritual_suggestions"],
            
            # Enhanced journal data
            "journalData": {
                "elements": parsed_data["elements"],
                "zodiacSigns": parsed_data["zodiac_signs"],
                "emotionalResonance": parsed_data["emotional_resonance"],
                "spiritualLessons": parsed_data["spiritual_lessons"],
                "synchronicities": parsed_data["synchronicities"],
            },
            
            # Performance metrics (if debug mode)
            "metrics": metrics if DEBUG_MODE else None,
            
            # User context
            "userContext": {
                "hasAstrology": astrological_context is not None,
                "hasPreferences": user_preferences is not None,
                "isAuthenticated": user_id is not None,
            }
        }
        
        logger.info(f"Identification completed: {identified_crystal} (confidence: {metrics['confidence_score']:.2f})")
        return response
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Crystal identification failed: {e}")
        raise HTTPException(status_code=500, detail=f"Identification service error: {str(e)}")

def _parse_enhanced_response(text: str) -> dict:
    """Enhanced parsing of AI response with better extraction"""
    
    lines = text.split('\n')
    parsed = {
        "metaphysical": [],
        "healing": [],
        "chakras": [],
        "elements": [],
        "zodiac_signs": [],
        "color_description": "Natural crystal coloration",
        "hardness": "Variable (Mohs scale)",
        "formation": "Natural formation",
        "care_instructions": "Cleanse with moonlight, charge in sunlight",
        "spiritual_message": "",
        "daily_guidance": "",
        "meditation_suggestions": [],
        "affirmations": [],
        "ritual_suggestions": [],
        "emotional_resonance": [],
        "spiritual_lessons": [],
        "synchronicities": [],
    }
    
    # Extract metaphysical properties
    in_metaphysical = False
    for line in lines:
        line = line.strip()
        if any(keyword in line.lower() for keyword in ['metaphysical', 'properties', 'spiritual qualities']):
            in_metaphysical = True
            continue
        
        if in_metaphysical and line and (line.startswith(('•', '-', '*')) or line[0].isdigit()):
            prop = line.lstrip('•-*0123456789. ').strip()
            if len(prop) > 10:
                parsed["metaphysical"].append(prop[:100])
            if len(parsed["metaphysical"]) >= 6:
                break
    
    # Extract chakras
    chakra_names = ['root', 'sacral', 'solar plexus', 'heart', 'throat', 'third eye', 'crown']
    for chakra in chakra_names:
        if chakra.lower() in text.lower():
            parsed["chakras"].append(chakra.title())
    
    # Extract elements
    element_names = ['fire', 'earth', 'air', 'water']
    for element in element_names:
        if element.lower() in text.lower():
            parsed["elements"].append(element.title())
    
    # Extract zodiac signs
    zodiac = ['aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo', 
             'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces']
    for sign in zodiac:
        if sign.lower() in text.lower():
            parsed["zodiac_signs"].append(sign.title())
    
    # Default values if nothing found
    if not parsed["metaphysical"]:
        parsed["metaphysical"] = [
            "Amplifies spiritual energy and intuition",
            "Promotes emotional healing and balance", 
            "Enhances meditation and spiritual connection",
            "Provides protection and grounding",
            "Attracts positive energy and abundance"
        ]
    
    if not parsed["chakras"]:
        parsed["chakras"] = ["Crown", "Heart"]
    
    if not parsed["elements"]:
        parsed["elements"] = ["Earth"]
    
    # Extract spiritual message (usually near the end)
    spiritual_keywords = ['message', 'guidance', 'blessing', 'prophecy']
    for i, line in enumerate(lines):
        if any(keyword in line.lower() for keyword in spiritual_keywords):
            # Take the next few meaningful lines
            message_lines = []
            for j in range(i, min(i + 5, len(lines))):
                clean_line = lines[j].strip()
                if clean_line and len(clean_line) > 20:
                    message_lines.append(clean_line)
            if message_lines:
                parsed["spiritual_message"] = " ".join(message_lines[:2])
                break
    
    if not parsed["spiritual_message"]:
        parsed["spiritual_message"] = f"This crystal brings divine light and healing energy into your spiritual journey."
    
    # Generate default meditation suggestions
    parsed["meditation_suggestions"] = [
        "Hold during morning meditation for clarity",
        "Place on altar during full moon ceremonies",
        "Carry for daily energy protection and grounding"
    ]
    
    # Generate affirmations
    parsed["affirmations"] = [
        "I am open to the healing energy of this sacred stone",
        "My spiritual path is illuminated with divine light",
        "I trust my intuition and inner wisdom"
    ]
    
    # Generate ritual suggestions
    parsed["ritual_suggestions"] = [
        "New moon intention setting ritual",
        "Chakra balancing meditation session",
        "Energy cleansing and protection ceremony"
    ]
    
    return parsed

def _map_confidence_level(score: float) -> str:
    """Map confidence score to descriptive level"""
    if score >= 0.85:
        return "very_high"
    elif score >= 0.7:
        return "high"
    elif score >= 0.55:
        return "medium"
    elif score >= 0.4:
        return "low"
    else:
        return "uncertain"

@app.post("/api/v2/spiritual/guidance")
async def get_enhanced_spiritual_guidance(
    guidance_type: str = Form(...),
    user_profile: str = Form(...),
    custom_prompt: str = Form(...),
    user_id: Optional[str] = Depends(verify_firebase_token)
):
    """Enhanced spiritual guidance with personalized AI responses"""
    
    logger.info(f"Spiritual guidance request: type={guidance_type}, user={user_id}")
    
    try:
        # Parse user profile
        profile_data = json.loads(user_profile)
        
        # Build enhanced spiritual guidance prompt
        guidance_prompt = f"""You are the Crystal Grimoire Spiritual Advisor providing deeply personalized metaphysical guidance.

SEEKER'S SPIRITUAL PROFILE:
{json.dumps(profile_data, indent=2)}

GUIDANCE REQUEST TYPE: {guidance_type}
SPECIFIC QUESTION: {custom_prompt}

Provide warm, personalized spiritual guidance that:
1. References their specific crystals and spiritual journey
2. Incorporates their preferences and patterns
3. Offers practical, actionable advice
4. Maintains your mystical, loving tone
5. Is encouraging and empowering
6. Includes specific practices they can do today

Begin with "Ah, beloved seeker..." and provide 3-4 paragraphs of personalized guidance.
Include specific crystal recommendations from their collection if applicable.
End with a blessing or affirmation for their journey.
"""

        # Call Gemini API for guidance
        request_data = {
            'contents': [{'parts': [{'text': guidance_prompt}]}],
            'generationConfig': {
                'temperature': 0.8,
                'topK': 40,
                'topP': 0.95,
                'maxOutputTokens': 2000,
            },
            'safetySettings': [
                {
                    'category': 'HARM_CATEGORY_HARASSMENT',
                    'threshold': 'BLOCK_NONE'
                },
                {
                    'category': 'HARM_CATEGORY_HATE_SPEECH',
                    'threshold': 'BLOCK_NONE'
                },
                {
                    'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
                    'threshold': 'BLOCK_NONE'
                },
                {
                    'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
                    'threshold': 'BLOCK_NONE'
                }
            ]
        }
        
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                f"{GEMINI_URL}?key={GEMINI_API_KEY}",
                json=request_data
            )
        
        if response.status_code == 200:
            data = response.json()
            guidance = data['candidates'][0]['content']['parts'][0]['text']
            
            return {
                "guidance": guidance,
                "guidanceType": guidance_type,
                "userId": user_id or "anonymous",
                "timestamp": datetime.now().isoformat(),
                "source": "gemini_ai_enhanced",
                "personalizationLevel": "high",
                "version": API_VERSION
            }
        else:
            logger.error(f"Gemini API error for guidance: {response.status_code}")
            raise HTTPException(status_code=500, detail="Spiritual guidance service temporarily unavailable")
            
    except json.JSONDecodeError:
        raise HTTPException(status_code=400, detail="Invalid user profile format")
    except Exception as e:
        logger.error(f"Spiritual guidance error: {e}")
        
        # Enhanced fallback guidance based on type
        fallback_guidance = {
            'daily': "Beloved seeker, today the universe invites you to connect deeply with your crystal allies. Take time to hold your favorite stone and set clear, loving intentions for the day ahead. Trust the wisdom that flows through you.",
            
            'crystal_selection': "Look within your collection with fresh eyes and an open heart today. Notice which crystal calls to you most strongly - that sacred stone carries a special message waiting to unfold in your spiritual journey.",
            
            'chakra_balancing': "Begin with grounding at your root chakra, then gently work your way up through each energy center with intention and presence. Allow your crystals to guide this beautiful dance of alignment and healing.",
            
            'lunar_guidance': "The moon's cycles offer powerful energy for cleansing and charging your crystals. Tonight, honor this divine connection under the night sky and feel the ancient wisdom flowing through your sacred stones.",
            
            'manifestation': "Your crystals are powerful allies for manifestation work. Choose stones that resonate with your heart's desires and create a sacred space for focused intention, knowing the universe supports your highest good.",
            
            'healing_session': "Trust your intuition as you select healing crystals from your collection. Place them with loving intention and allow their pure energy to flow, bringing harmony and restoration to body, mind, and spirit.",
            
            'spiritual_reading': "Your spiritual journey is unfolding perfectly, dear one. Each crystal in your collection represents wisdom gained and lessons learned. You are exactly where you need to be on this sacred path."
        }
        
        return {
            "guidance": fallback_guidance.get(guidance_type, fallback_guidance['daily']),
            "guidanceType": guidance_type,
            "userId": user_id or "anonymous", 
            "timestamp": datetime.now().isoformat(),
            "source": "fallback_enhanced",
            "personalizationLevel": "basic",
            "version": API_VERSION
        }

@app.get("/api/v2/metrics")
async def get_service_metrics():
    """Get service metrics and statistics (debug mode only)"""
    if not DEBUG_MODE:
        raise HTTPException(status_code=404, detail="Metrics not available in production mode")
    
    return {
        "service": SERVICE_NAME,
        "version": API_VERSION,
        "environment": ENVIRONMENT,
        "uptime": "Available in production monitoring",
        "features": {
            "firebase_auth": FIREBASE_SERVICE_ACCOUNT is not None,
            "debug_mode": DEBUG_MODE,
            "rate_limiting": f"{RATE_LIMIT_REQUESTS}/{RATE_LIMIT_WINDOW}s",
        },
        "endpoints": {
            "total": len(app.routes),
            "available": [route.path for route in app.routes if hasattr(route, 'path')]
        }
    }

if __name__ == "__main__":
    import uvicorn
    
    # Configuration from environment
    port = int(os.getenv("PORT", "8000"))
    host = os.getenv("HOST", "0.0.0.0")
    workers = int(os.getenv("WORKERS", "1"))
    
    print(f"🔮 Starting {SERVICE_NAME} v{API_VERSION}")
    print(f"🌐 Environment: {ENVIRONMENT}")
    print(f"🚀 Server: {host}:{port}")
    print(f"👥 Workers: {workers}")
    print(f"🔧 Debug: {DEBUG_MODE}")
    print(f"📚 API docs: http://{host}:{port}/docs")
    
    # Run with appropriate configuration
    if ENVIRONMENT == "development":
        uvicorn.run(
            "enhanced_backend:app",
            host=host,
            port=port,
            reload=True,
            log_level="info"
        )
    else:
        uvicorn.run(
            app,
            host=host,
            port=port,
            workers=workers,
            log_level="warning"
        )