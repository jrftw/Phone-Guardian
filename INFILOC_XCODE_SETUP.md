# INFILOC Xcode Project Setup Guide

## 🔧 Bundle Identifier Configuration

### **Issue:** "Embedded binary's bundle identifier is not prefixed with the parent app's bundle identifier"

This error occurs when the Network Extension target's bundle identifier doesn't follow Apple's naming convention.

## 📱 Required Bundle Identifiers

### **Main App Target:**
- **Bundle Identifier:** `Infinitum-Imagery-LLC.Phone-Guardian`
- **Display Name:** Phone Guardian

### **InfiLocTunnel Extension Target:**
- **Bundle Identifier:** `Infinitum-Imagery-LLC.Phone-Guardian.InfiLocTunnel`
- **Display Name:** INFILOC Tunnel

## 🛠️ Xcode Configuration Steps

### **Step 1: Configure Main App Target**
1. Select the **Phone Guardian** target in Xcode
2. Go to **General** tab
3. Under **Identity** section:
   - **Bundle Identifier:** `Infinitum-Imagery-LLC.Phone-Guardian`
   - **Version:** `1.13`
   - **Build:** `1`

### **Step 2: Configure InfiLocTunnel Extension Target**
1. Select the **InfiLocTunnel** target in Xcode
2. Go to **General** tab
3. Under **Identity** section:
   - **Bundle Identifier:** `Infinitum-Imagery-LLC.Phone-Guardian.InfiLocTunnel`
   - **Version:** `1.0`
   - **Build:** `1`
   - **Display Name:** `INFILOC Tunnel`

### **Step 3: Verify Target Dependencies**
1. Select the **Phone Guardian** target
2. Go to **General** tab
3. Under **Frameworks, Libraries, and Embedded Content**:
   - Ensure **InfiLocTunnel** is listed
   - **Embed** should be set to **Do Not Embed**

### **Step 4: Configure App Groups**
1. Select the **Phone Guardian** target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability** and add **App Groups**
4. Add group: `group.Infinitum-Imagery-LLC.Phone-Guardian.infiloc`

5. Select the **InfiLocTunnel** target
6. Go to **Signing & Capabilities** tab
7. Click **+ Capability** and add **App Groups**
8. Add the same group: `group.Infinitum-Imagery-LLC.Phone-Guardian.infiloc`

### **Step 5: Configure Network Extensions**
1. Select the **Phone Guardian** target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability** and add **Network Extensions**
4. Check **Packet Tunnel Provider**

5. Select the **InfiLocTunnel** target
6. Go to **Signing & Capabilities** tab
7. Click **+ Capability** and add **Network Extensions**
8. Check **Packet Tunnel Provider**

## 🔑 Apple Developer Portal Setup

### **Step 1: Configure App ID**
1. Go to [Apple Developer Portal](https://developer.apple.com)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Select **Identifiers** → **App IDs**
4. Find your app ID or create a new one
5. Enable **Network Extensions** capability
6. Enable **App Groups** capability
7. Add App Group: `group.Infinitum-Imagery-LLC.Phone-Guardian.infiloc`

### **Step 2: Create App Group**
1. Go to **Identifiers** → **App Groups**
2. Create new App Group with identifier: `group.Infinitum-Imagery-LLC.Phone-Guardian.infiloc`
3. Add both the main app and extension to this group

### **Step 3: Update Provisioning Profiles**
1. Go to **Profiles**
2. Download updated provisioning profiles for both targets
3. Install the profiles in Xcode

## 📋 Verification Checklist

### **Bundle Identifiers:**
- ✅ Main App: `Infinitum-Imagery-LLC.Phone-Guardian`
- ✅ Extension: `Infinitum-Imagery-LLC.Phone-Guardian.InfiLocTunnel`
- ✅ Extension is prefixed with main app bundle ID

### **Capabilities:**
- ✅ Main App: Network Extensions, App Groups
- ✅ Extension: Network Extensions, App Groups
- ✅ App Group: `group.Infinitum-Imagery-LLC.Phone-Guardian.infiloc`

### **Target Dependencies:**
- ✅ InfiLocTunnel extension is added to main app
- ✅ Extension is set to "Do Not Embed"

### **Code Signing:**
- ✅ Both targets have valid provisioning profiles
- ✅ Both targets are signed with the same team
- ✅ App Groups are properly configured

## 🚨 Common Issues & Solutions

### **Issue 1: Bundle Identifier Error**
```
Embedded binary's bundle identifier is not prefixed with the parent app's bundle identifier
```
**Solution:** Ensure extension bundle ID follows the pattern: `[MainAppBundleID].[ExtensionName]`

### **Issue 2: App Group Not Found**
```
App Group 'group.com.example.PhoneGuardian.infiloc' is not available
```
**Solution:** Create the App Group in Apple Developer Portal and add both targets

### **Issue 3: Network Extension Not Available**
```
Network Extensions capability is not available
```
**Solution:** Enable Network Extensions in your Apple Developer account

### **Issue 4: Provisioning Profile Issues**
```
Provisioning profile doesn't include Network Extensions
```
**Solution:** Download updated provisioning profiles after enabling capabilities

## 🔍 Testing the Configuration

### **Build Test:**
1. Clean build folder (Product → Clean Build Folder)
2. Build the project (⌘+B)
3. Verify no bundle identifier errors

### **Runtime Test:**
1. Run on a real device (not simulator)
2. Navigate to Privacy Control module
3. Tap "Start Monitoring"
4. Approve VPN configuration
5. Verify tunnel starts successfully

## 📞 Support

If you encounter issues:
1. Check the bundle identifiers match exactly
2. Verify all capabilities are enabled
3. Ensure provisioning profiles are up to date
4. Test on a real device (VPN doesn't work in simulator)

**The bundle identifier configuration is critical for the Network Extension to work properly.** 