#!/usr/bin/env python3
"""
Script to create Stripe products and prices for Crystal Grimoire
Run this once to set up your subscription products in Stripe
"""

import requests
import json
from base64 import b64encode

# Your Stripe secret key - SET THIS TO YOUR ACTUAL KEY
STRIPE_SECRET_KEY = "sk_live_YOUR_SECRET_KEY_HERE"

# Stripe API base URL
STRIPE_API_URL = "https://api.stripe.com/v1"

def create_stripe_request(endpoint, data):
    """Make a request to Stripe API"""
    auth_header = b64encode(f"{STRIPE_SECRET_KEY}:".encode()).decode()
    
    response = requests.post(
        f"{STRIPE_API_URL}/{endpoint}",
        headers={
            "Authorization": f"Basic {auth_header}",
            "Content-Type": "application/x-www-form-urlencoded"
        },
        data=data
    )
    
    if response.status_code == 200:
        return response.json()
    else:
        print(f"Error creating {endpoint}: {response.text}")
        return None

def setup_products():
    """Create all subscription products and prices"""
    
    products_to_create = [
        {
            "name": "Crystal Grimoire Premium",
            "description": "Premium subscription with advanced AI and unlimited crystals",
            "price": 999,  # $9.99
            "interval": "month",
            "tier": "premium"
        },
        {
            "name": "Crystal Grimoire Pro", 
            "description": "Pro subscription with Claude AI and priority features",
            "price": 1999,  # $19.99
            "interval": "month",
            "tier": "pro"
        },
        {
            "name": "Crystal Grimoire Founders Edition",
            "description": "Lifetime access with all features and exclusive benefits", 
            "price": 19900,  # $199.00
            "interval": None,  # One-time payment
            "tier": "founders"
        }
    ]
    
    price_ids = {}
    
    for product_info in products_to_create:
        print(f"\nCreating product: {product_info['name']}")
        
        # Create product
        product_data = {
            "name": product_info["name"],
            "description": product_info["description"],
            "type": "service",
            "metadata[tier]": product_info["tier"]
        }
        
        product = create_stripe_request("products", product_data)
        if not product:
            continue
            
        print(f"✅ Product created: {product['id']}")
        
        # Create price
        price_data = {
            "unit_amount": str(product_info["price"]),
            "currency": "usd",
            "product": product["id"],
            "metadata[tier]": product_info["tier"]
        }
        
        if product_info["interval"]:
            price_data["recurring[interval]"] = product_info["interval"]
        
        price = create_stripe_request("prices", price_data)
        if price:
            print(f"✅ Price created: {price['id']}")
            price_ids[product_info["tier"]] = price["id"]
        
    return price_ids

if __name__ == "__main__":
    print("🔮 Setting up Crystal Grimoire Stripe Products...")
    print("=" * 50)
    
    price_ids = setup_products()
    
    print("\n" + "=" * 50)
    print("✨ Setup Complete! Add these Price IDs to your environment:")
    print("=" * 50)
    
    for tier, price_id in price_ids.items():
        env_var = f"STRIPE_{tier.upper()}_PRICE_ID"
        print(f"{env_var}={price_id}")
    
    print("\n🔧 Next steps:")
    print("1. Add these Price IDs to your .env file")
    print("2. Add them as GitHub Secrets")
    print("3. Update the StripeService price mapping")
    print("4. Test your subscription flow!")