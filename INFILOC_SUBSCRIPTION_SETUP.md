# INFILOC Subscription Setup Guide

## Overview
This guide provides step-by-step instructions for setting up the INFILOC subscription system in App Store Connect and configuring the necessary product identifiers in your app.

## App Store Connect Setup

### 1. Create Subscription Group
1. Log into [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to your app
3. Go to **Features** → **In-App Purchases**
4. Click **+** to create a new subscription group
5. Name it: `com.infinitumimagery.phoneguardian.infiloc.subscriptiongroup`
6. Set the reference name: `INFILOC Privacy Monitor`

### 2. Create Subscription Products

#### Weekly Subscription ($1.99/week)
1. Click **+** to add a new subscription
2. **Product ID**: `com.infinitumimagery.phoneguardian.infiloc.weekly`
3. **Reference Name**: `INFILOC Weekly`
4. **Subscription Duration**: 1 Week
5. **Price**: $1.99 USD
6. **Localization**:
   - **Display Name**: `INFILOC Weekly`
   - **Description**: `Weekly access to INFILOC privacy monitoring features`
   - **Promotional Image**: Upload appropriate icon

#### Monthly Subscription ($3.99/month)
1. Click **+** to add a new subscription
2. **Product ID**: `com.infinitumimagery.phoneguardian.infiloc.monthly`
3. **Reference Name**: `INFILOC Monthly`
4. **Subscription Duration**: 1 Month
5. **Price**: $3.99 USD
6. **Localization**:
   - **Display Name**: `INFILOC Monthly`
   - **Description**: `Monthly access to INFILOC privacy monitoring features`
   - **Promotional Image**: Upload appropriate icon

#### Yearly Subscription ($44.99/year)
1. Click **+** to add a new subscription
2. **Product ID**: `com.infinitumimagery.phoneguardian.infiloc.yearly`
3. **Reference Name**: `INFILOC Yearly`
4. **Subscription Duration**: 1 Year
5. **Price**: $44.99 USD
6. **Localization**:
   - **Display Name**: `INFILOC Yearly`
   - **Description**: `Annual access to INFILOC privacy monitoring features (Save 40%)`
   - **Promotional Image**: Upload appropriate icon

### 3. Configure Subscription Group Settings
1. **Subscription Group Name**: `INFILOC Privacy Monitor`
2. **Review Information**:
   - **Review Notes**: "INFILOC provides advanced privacy monitoring for location access detection. All processing is done locally on the user's device with no data transmission to external servers."
   - **Review Screenshots**: Upload screenshots showing the subscription interface

### 4. Set Up Pricing
1. **Base Territory**: United States
2. **Pricing**: Use automatic pricing for other territories
3. **Availability**: Make available in all territories where your app is available

## Xcode Configuration

### 1. Add StoreKit Configuration (for Testing)
1. In Xcode, go to **File** → **New** → **File**
2. Select **StoreKit Configuration File**
3. Name it: `INFILOC_StoreKit_Config.storekit`
4. Add the following products:

```json
{
  "identifier" : "INFILOC_StoreKit_Config",
  "nonRenewingSubscriptions" : [

  ],
  "products" : [

  ],
  "settings" : {
    "_applicationInternalID" : "1234567890",
    "_developerTeamID" : "YOUR_TEAM_ID",
    "_failTransactionsEnabled" : false,
    "_lastSynchronizedDate" : 1234567890.0,
    "_locale" : "en_US",
    "_storefront" : "USA",
    "_storeKitErrors" : [
      {
        "current" : null,
        "enabled" : false,
        "name" : "Load Products"
      },
      {
        "current" : null,
        "enabled" : false,
        "name" : "Purchase"
      },
      {
        "current" : null,
        "enabled" : false,
        "name" : "Verification"
      }
    ]
  },
        "subscriptionGroups" : [
        {
          "id" : "com.infinitumimagery.phoneguardian.infiloc.subscriptiongroup",
          "localizations" : [
            {
              "description" : "Advanced privacy monitoring for location access detection",
              "displayName" : "INFILOC Privacy Monitor",
              "locale" : "en_US"
            }
          ],
          "name" : "INFILOC Privacy Monitor",
          "subscriptions" : [
            {
              "adHocOffers" : [

              ],
              "codeOffers" : [

              ],
              "displayPrice" : "1.99",
              "familyShareable" : false,
              "groupNumber" : 1,
              "internalID" : "1234567890",
              "introductoryOffer" : null,
              "localizations" : [
                {
                  "description" : "Weekly access to INFILOC privacy monitoring features",
                  "displayName" : "INFILOC Weekly",
                  "locale" : "en_US"
                }
              ],
              "productID" : "com.infinitumimagery.phoneguardian.infiloc.weekly",
              "recurringSubscriptionPeriod" : "P1W",
              "referenceName" : "INFILOC Weekly",
              "subscriptionGroupID" : "com.infinitumimagery.phoneguardian.infiloc.subscriptiongroup",
              "type" : "RecurringSubscription"
            },
            {
              "adHocOffers" : [

              ],
              "codeOffers" : [

              ],
              "displayPrice" : "3.99",
              "familyShareable" : false,
              "groupNumber" : 2,
              "internalID" : "1234567891",
              "introductoryOffer" : null,
              "localizations" : [
                {
                  "description" : "Monthly access to INFILOC privacy monitoring features",
                  "displayName" : "INFILOC Monthly",
                  "locale" : "en_US"
                }
              ],
              "productID" : "com.infinitumimagery.phoneguardian.infiloc.monthly",
              "recurringSubscriptionPeriod" : "P1M",
              "referenceName" : "INFILOC Monthly",
              "subscriptionGroupID" : "com.infinitumimagery.phoneguardian.infiloc.subscriptiongroup",
              "type" : "RecurringSubscription"
            },
            {
              "adHocOffers" : [

              ],
              "codeOffers" : [

              ],
              "displayPrice" : "44.99",
              "familyShareable" : false,
              "groupNumber" : 3,
              "internalID" : "1234567892",
              "introductoryOffer" : null,
              "localizations" : [
                {
                  "description" : "Annual access to INFILOC privacy monitoring features (Save 40%)",
                  "displayName" : "INFILOC Yearly",
                  "locale" : "en_US"
                }
              ],
              "productID" : "com.infinitumimagery.phoneguardian.infiloc.yearly",
              "recurringSubscriptionPeriod" : "P1Y",
              "referenceName" : "INFILOC Yearly",
              "subscriptionGroupID" : "com.infinitumimagery.phoneguardian.infiloc.subscriptiongroup",
              "type" : "RecurringSubscription"
            }
          ]
        }
      ],
  "version" : {
    "major" : 3,
    "minor" : 0
  }
}
```

### 2. Configure StoreKit Testing
1. In Xcode, go to **Product** → **Scheme** → **Edit Scheme**
2. Select **Run** → **Options**
3. Set **StoreKit Configuration** to your configuration file
4. Enable **Ask on Launch** for testing

### 3. Add StoreKit Framework
1. In your Xcode project, go to **Targets** → **Phone Guardian**
2. Select **General** → **Frameworks, Libraries, and Embedded Content**
3. Click **+** and add **StoreKit.framework**

## Testing the Subscription System

### 1. Sandbox Testing
1. Create a sandbox tester account in App Store Connect
2. Sign out of your regular Apple ID on the test device
3. Sign in with the sandbox tester account
4. Build and run the app
5. Test subscription purchase flow

### 2. StoreKit Testing
1. Use the StoreKit configuration file for local testing
2. Test all subscription options
3. Test restore purchases functionality
4. Test subscription management

### 3. Test Scenarios
- **New Subscription**: Purchase each subscription type
- **Restore Purchases**: Test restore functionality
- **Subscription Management**: Test managing subscriptions
- **Error Handling**: Test network errors and invalid states
- **Legal Compliance**: Verify disclaimers are displayed

## Legal Compliance

### 1. Required Disclaimers
Ensure the following disclaimers are prominently displayed:

1. **Detection Accuracy Disclaimer**: "INFILOC location detection is not 100% accurate and may not catch all location access attempts."

2. **Service Limitations**: Clear explanation of what the service can and cannot do

3. **Privacy Information**: How user data is handled (locally only)

4. **Subscription Terms**: Clear pricing and renewal information

### 2. App Store Guidelines Compliance
- Follow [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- Ensure subscription descriptions are accurate
- Provide clear value proposition
- Include proper legal disclaimers

## Production Deployment

### 1. App Store Connect
1. Submit subscription products for review
2. Ensure all localizations are complete
3. Upload promotional images
4. Set up pricing for all territories

### 2. App Submission
1. Include subscription products in app submission
2. Provide clear description of INFILOC features
3. Include screenshots showing subscription interface
4. Ensure legal disclaimers are visible

### 3. Review Process
1. Apple will review both the app and subscription products
2. Ensure compliance with all guidelines
3. Be prepared to provide additional information if requested

## Monitoring and Analytics

### 1. App Store Connect Analytics
- Monitor subscription conversion rates
- Track revenue and subscriber retention
- Analyze user behavior and preferences

### 2. App Analytics
- Track subscription flow completion rates
- Monitor error rates and user feedback
- Analyze feature usage patterns

## Troubleshooting

### Common Issues
1. **Product IDs Not Found**: Ensure product IDs match exactly between App Store Connect and code
2. **Sandbox Testing Issues**: Verify sandbox tester account is properly configured
3. **Restore Purchases Not Working**: Check transaction verification logic
4. **Legal Compliance Rejection**: Ensure all required disclaimers are present

### Support Resources
- [StoreKit Documentation](https://developer.apple.com/documentation/storekit)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

---

*This guide should be updated as Apple's policies and StoreKit framework evolve.* 