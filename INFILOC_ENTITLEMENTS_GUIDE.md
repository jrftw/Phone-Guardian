# INFILOC Network Extensions Entitlements Guide

## 🔧 Required Entitlements Configuration

INFILOC requires specific entitlements to function properly with Apple's Network Extensions framework. This guide ensures your app is correctly configured.

## 📱 Main App Entitlements

### **File:** `Phone Guardian/App/Phone_Guardian.entitlements`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Network Extensions - REQUIRED for INFILOC -->
    <key>com.apple.developer.networking.networkextension</key>
    <array>
        <string>packet-tunnel-provider</string>
    </array>
    
    <!-- App Groups - REQUIRED for data sharing -->
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.Infinitum-Imagery-LLC.Phone-Guardian.infiloc</string>
    </array>
    
    <!-- Other existing entitlements... -->
</dict>
</plist>
```

## 🔌 Extension Entitlements

### **File:** `InfiLocTunnel/InfiLocTunnel.entitlements`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Network Extensions - REQUIRED for tunnel provider -->
    <key>com.apple.developer.networking.networkextension</key>
    <array>
        <string>packet-tunnel-provider</string>
    </array>
    
    <!-- App Groups - REQUIRED for data sharing -->
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.Infinitum-Imagery-LLC.Phone-Guardian.infiloc</string>
    </array>
</dict>
</plist>
```

## ✅ Current Status

### **Main App Entitlements:** ✅ CONFIGURED
- ✅ Network Extensions with packet-tunnel-provider
- ✅ App Groups for data sharing
- ✅ All required entitlements present

### **Extension Entitlements:** ✅ CONFIGURED
- ✅ Network Extensions with packet-tunnel-provider
- ✅ App Groups for data sharing
- ✅ All required entitlements present

## 🛠️ Xcode Configuration Steps

### **Step 1: Verify Main App Target**
1. Select **Phone Guardian** target in Xcode
2. Go to **Signing & Capabilities** tab
3. Ensure **Network Extensions** capability is added
4. Check **Packet Tunnel Provider** is enabled
5. Verify **App Groups** capability is added with correct group

### **Step 2: Verify Extension Target**
1. Select **InfiLocTunnel** target in Xcode
2. Go to **Signing & Capabilities** tab
3. Ensure **Network Extensions** capability is added
4. Check **Packet Tunnel Provider** is enabled
5. Verify **App Groups** capability is added with correct group

### **Step 3: Apple Developer Portal**
1. Go to [Apple Developer Portal](https://developer.apple.com)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Select **Identifiers** → **App IDs**
4. Find your app ID: `Infinitum-Imagery-LLC.Phone-Guardian`
5. Enable **Network Extensions** capability
6. Enable **App Groups** capability
7. Add App Group: `group.Infinitum-Imagery-LLC.Phone-Guardian.infiloc`

## 🔑 Key Entitlements Explained

### **Network Extensions**
```xml
<key>com.apple.developer.networking.networkextension</key>
<array>
    <string>packet-tunnel-provider</string>
</array>
```
**Purpose:** Allows the app to create and manage VPN tunnels for network monitoring.

### **App Groups**
```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.Infinitum-Imagery-LLC.Phone-Guardian.infiloc</string>
</array>
```
**Purpose:** Enables secure data sharing between the main app and the tunnel extension.

## 🚨 Common Issues & Solutions

### **Issue 1: "Network Extensions capability is not available"**
**Solution:** 
- Ensure you have a paid Apple Developer account
- Network Extensions require paid membership
- Free accounts cannot use this capability

### **Issue 2: "App Group not found"**
**Solution:**
- Create the App Group in Apple Developer Portal
- Add both main app and extension to the group
- Download updated provisioning profiles

### **Issue 3: "Provisioning profile doesn't include Network Extensions"**
**Solution:**
- Enable Network Extensions in your App ID
- Download updated provisioning profiles
- Install the new profiles in Xcode

### **Issue 4: "Bundle identifier mismatch"**
**Solution:**
- Ensure extension bundle ID is prefixed with main app bundle ID
- Main App: `Infinitum-Imagery-LLC.Phone-Guardian`
- Extension: `Infinitum-Imagery-LLC.Phone-Guardian.InfiLocTunnel`

## 📋 Verification Checklist

### **Entitlements Files:**
- ✅ Main app entitlements file exists
- ✅ Extension entitlements file exists
- ✅ Network Extensions configured in both
- ✅ App Groups configured in both
- ✅ Correct App Group identifier used

### **Xcode Capabilities:**
- ✅ Network Extensions added to main app
- ✅ Network Extensions added to extension
- ✅ Packet Tunnel Provider enabled
- ✅ App Groups added to both targets
- ✅ Correct App Group selected

### **Apple Developer Portal:**
- ✅ Network Extensions enabled for App ID
- ✅ App Group created and configured
- ✅ Both targets added to App Group
- ✅ Updated provisioning profiles downloaded

### **Bundle Identifiers:**
- ✅ Main app: `Infinitum-Imagery-LLC.Phone-Guardian`
- ✅ Extension: `Infinitum-Imagery-LLC.Phone-Guardian.InfiLocTunnel`
- ✅ Extension properly prefixed

## 🔍 Testing Entitlements

### **Build Test:**
1. Clean build folder (Product → Clean Build Folder)
2. Build project (⌘+B)
3. Verify no entitlement errors

### **Runtime Test:**
1. Run on real device (not simulator)
2. Navigate to Privacy Control module
3. Tap "Start Monitoring"
4. Verify VPN configuration is accepted
5. Check that tunnel starts successfully

## 📞 Support

If you encounter entitlement issues:
1. Verify all entitlements are correctly configured
2. Ensure Apple Developer Portal settings match
3. Download and install updated provisioning profiles
4. Test on a real device (VPN doesn't work in simulator)

**The entitlements configuration is critical for Network Extensions to work properly.** 