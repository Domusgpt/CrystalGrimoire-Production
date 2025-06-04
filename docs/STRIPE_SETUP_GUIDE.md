# 💳 Stripe Payment Integration Setup Guide

## Overview
This guide walks through setting up Stripe for Crystal Grimoire's subscription tiers and marketplace payments.

## Prerequisites
- A Stripe account (create at [dashboard.stripe.com/register](https://dashboard.stripe.com/register))
- Business information ready (name, address, bank account for payouts)

## Step 1: Create Stripe Account

1. Go to [dashboard.stripe.com/register](https://dashboard.stripe.com/register)
2. Enter your email and create a password
3. Verify your email address
4. Complete business profile:
   - Business name: "Crystal Grimoire" (or your business entity)
   - Business type: "Individual" or "Company"
   - Industry: "Software"
   - Website: `https://domusgpt.github.io/CrystalGrimoireBeta2/`

## Step 2: Configure Products & Pricing

### Create Subscription Products

1. Navigate to **Products** in Stripe Dashboard
2. Click **"+ Add product"**

#### Premium Tier ($9.99/month)
```
Name: Crystal Grimoire Premium
Description: 30 daily IDs, unlimited crystal collection, marketplace access
Price: $9.99
Billing: Monthly recurring
Product ID: Save this for .env file
```

#### Pro Tier ($19.99/month)
```
Name: Crystal Grimoire Pro  
Description: Unlimited IDs, priority marketplace, advanced AI features
Price: $19.99
Billing: Monthly recurring
Product ID: Save this for .env file
```

#### Founders Edition (One-time $199)
```
Name: Crystal Grimoire Founders Edition
Description: Lifetime access, exclusive features, early access
Price: $199.00
Billing: One-time payment
Product ID: Save this for .env file
```

## Step 3: Set Up Webhooks

1. Go to **Developers → Webhooks**
2. Click **"Add endpoint"**
3. Endpoint URL: `https://your-backend-url.com/api/webhook/stripe`
4. Select events to listen for:
   - `checkout.session.completed`
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
5. Save the **Webhook signing secret** for your .env file

## Step 4: Get API Keys

1. Go to **Developers → API keys**
2. Copy your keys:
   - **Publishable key** (starts with `pk_test_` or `pk_live_`)
   - **Secret key** (starts with `sk_test_` or `sk_live_`)

⚠️ **IMPORTANT**: Use test keys for development, live keys for production!

## Step 5: Configure Customer Portal

1. Go to **Settings → Billing → Customer portal**
2. Enable the customer portal
3. Configure features:
   - ✅ Allow customers to update payment methods
   - ✅ Allow customers to cancel subscriptions
   - ✅ Allow customers to switch plans
4. Set cancellation policy:
   - Cancellation effective: "At end of billing period"
5. Save settings

## Step 6: Test Mode Setup

### Create Test Customers
Use these test card numbers in test mode:
- Success: `4242 4242 4242 4242`
- Decline: `4000 0000 0000 0002`
- Requires authentication: `4000 0025 0000 3155`

### Test Subscription Flow
1. Create a test subscription using the checkout
2. Verify webhook receives events
3. Check customer appears in Stripe Dashboard
4. Test cancellation flow

## Step 7: Update Environment Variables

Add to your `.env` file:
```bash
# Stripe Keys (Test Mode)
STRIPE_PUBLISHABLE_KEY=pk_test_your_key_here
STRIPE_SECRET_KEY=sk_test_your_key_here
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret

# Stripe Product/Price IDs
STRIPE_PREMIUM_PRICE_ID=price_premium_id_here
STRIPE_PRO_PRICE_ID=price_pro_id_here
STRIPE_FOUNDERS_PRICE_ID=price_founders_id_here

# For production, update to live keys:
# STRIPE_PUBLISHABLE_KEY=pk_live_your_key_here
# STRIPE_SECRET_KEY=sk_live_your_key_here
```

## Step 8: Frontend Integration

### Install Stripe Flutter SDK
```yaml
# pubspec.yaml
dependencies:
  flutter_stripe: ^9.5.0
```

### Initialize Stripe in Flutter
```dart
// main.dart
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Stripe
  Stripe.publishableKey = const String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');
  await Stripe.instance.applySettings();
  
  runApp(MyApp());
}
```

## Step 9: Backend Webhook Handler

The webhook handler is already implemented in `backend/unified_backend.py`. Key features:
- Verifies webhook signatures
- Updates user subscription status in Firebase
- Handles payment failures and retries
- Sends confirmation emails (if configured)

## Step 10: Production Checklist

Before going live:
- [ ] Complete Stripe account verification
- [ ] Add bank account for payouts
- [ ] Set up proper business information
- [ ] Configure tax settings if needed
- [ ] Review and accept Stripe's terms of service
- [ ] Switch from test to live API keys
- [ ] Update webhook endpoint to production URL
- [ ] Test live payment flow with small amount
- [ ] Set up proper error monitoring
- [ ] Configure fraud prevention rules

## Marketplace Payment Handling

For the Crystal Marketplace feature:

### Payment Flow
1. Buyer selects crystal and clicks "Buy"
2. Create payment intent with platform fee:
   ```python
   payment_intent = stripe.PaymentIntent.create(
       amount=1000,  # $10.00
       currency='usd',
       application_fee_amount=50,  # 5% platform fee
       transfer_data={
           'destination': seller_stripe_account_id,
       },
   )
   ```
3. Complete payment on frontend
4. On success, create order record and notify seller

### Seller Onboarding
Use Stripe Connect for marketplace sellers:
1. Sellers create Connected accounts
2. Complete identity verification
3. Add bank account for payouts
4. Platform takes 5% commission on sales

## Troubleshooting

### Common Issues

**"No such price" error**
- Ensure you're using the correct price ID from Stripe Dashboard
- Check if using test vs live keys consistently

**Webhook failures**
- Verify endpoint URL is publicly accessible
- Check webhook signing secret is correct
- Ensure backend handles all selected events

**Subscription not updating**
- Check Firebase rules allow subscription updates
- Verify webhook is processing successfully
- Check logs for any errors

## Support Resources

- [Stripe Documentation](https://stripe.com/docs)
- [Flutter Stripe SDK](https://pub.dev/packages/flutter_stripe)
- [Stripe Support](https://support.stripe.com)
- [Testing Documentation](https://stripe.com/docs/testing)

---

💎 Remember: Always test thoroughly in test mode before switching to live payments!