# INFILOC Privacy Control Setup Guide

## Overview
INFILOC (Passive Location Access Detection System) is a privacy-focused monitoring system that detects when apps or services attempt to access your location without your explicit knowledge. It uses a VPN-based approach to monitor network traffic and identify location-related requests.

## Features
- ✅ Real-time network traffic monitoring
- ✅ Detection of location access attempts from popular services
- ✅ Local notifications when detections occur
- ✅ Comprehensive detection history and logging
- ✅ Export capabilities (JSON/Text)
- ✅ User-configurable settings
- ✅ Privacy-first design (all processing local)

## Supported Services
- **Apple Services:** Find My iPhone, Apple Location Services
- **Social Media:** Snapchat, WhatsApp, Facebook
- **Navigation:** Google Maps, HERE Maps, Mapbox
- **Location Sharing:** Life360, Foursquare, Yelp
- **Ride Sharing:** Uber, Lyft
- **And more...**

## Technical Architecture

### Components
1. **Main App Module:** `PrivacyControlView.swift` - User interface
2. **VPN Manager:** `VPNManager.swift` - VPN tunnel management
3. **Traffic Analyzer:** `TrafficAnalyzer.swift` - Domain analysis
4. **Tunnel Extension:** `InfiLocTunnel` - Network packet inspection
5. **Detection Log:** `DetectionLogView.swift` - History viewer
6. **Settings:** `PrivacySettingsView.swift` - Configuration

### Data Flow
```
Network Traffic → Tunnel Extension → Domain Analysis → Detection → Notification → Log Storage
```

## Setup Instructions

### 1. Xcode Project Configuration

#### A. Add Network Extension Target
1. In Xcode, go to **File > New > Target...**
2. Select **Network Extension** > **Packet Tunnel Extension**
3. Name it `InfiLocTunnel`
4. Ensure it's added to your workspace

#### B. Configure Bundle Identifiers
- Main App: `com.phoneguardian.infiloc`
- Tunnel Extension: `com.phoneguardian.infiloc.tunnel`

#### C. Add Entitlements
**Main App (`Phone_Guardian.entitlements`):**
```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.phoneguardian.infiloc</string>
</array>
<key>com.apple.developer.networking.networkextension</key>
<array>
    <string>packet-tunnel-provider</string>
</array>
```

**Tunnel Extension (`InfiLocTunnel.entitlements`):**
```xml
<key>com.apple.developer.networking.networkextension</key>
<array>
    <string>packet-tunnel-provider</string>
</array>
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.phoneguardian.infiloc</string>
</array>
```

### 2. Apple Developer Account Setup

#### A. Enable Network Extension Capability
1. Go to [Apple Developer Portal](https://developer.apple.com)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Select your App ID
4. Enable **Network Extensions** capability
5. Download and install updated provisioning profiles

#### B. Create App Group
1. In Developer Portal, go to **Identifiers**
2. Create new App Group: `group.com.phoneguardian.infiloc`
3. Add both main app and tunnel extension to this group

### 3. Build and Test

#### A. Device Requirements
- **Real Device Required:** VPN and Network Extensions don't work in simulator
- **iOS 14.0+** (Network Extension framework requirements)

#### B. First Run
1. Build and run on device
2. Navigate to **Privacy Control** module
3. Tap **Start Monitoring**
4. Approve VPN configuration when prompted
5. Grant notification permissions if requested

#### C. Testing Detection
- The system will monitor network traffic in real-time
- Detections are logged and can be viewed in the **Detection History**
- Notifications will appear if enabled in settings

## User Interface

### Main Dashboard
- **Status Card:** Shows monitoring status and VPN connection
- **Control Buttons:** Start/Stop monitoring
- **Statistics:** Total, today, and weekly detection counts
- **Recent Detections:** Last 3 detected events
- **Settings Access:** Configure privacy preferences

### Detection History
- **Search & Filter:** Find specific detections
- **Export Options:** JSON or text format
- **Detailed View:** Tap for more information
- **Clear History:** Remove all stored detections

### Privacy Settings
- **Auto-start:** Begin monitoring when app launches
- **Notifications:** Enable/disable detection alerts
- **Silent Mode:** Monitor without user interaction
- **Log Limits:** Configure maximum stored entries
- **Domain List:** View monitored services

## Configuration Options

### User Preferences
```swift
// Auto-start monitoring
UserDefaults.standard.set(true, forKey: "infiloc_auto_start")

// Show notifications
UserDefaults.standard.set(true, forKey: "infiloc_notifications")

// Silent mode
UserDefaults.standard.set(false, forKey: "infiloc_silent_mode")

// Maximum log entries
UserDefaults.standard.set(100, forKey: "infiloc_max_logs")
```

### Custom Domains
Add custom domains to monitor:
```swift
trafficAnalyzer.addCustomDomain("custom.domain.com", service: "Custom Service")
```

## Troubleshooting

### Common Issues

#### 1. VPN Won't Start
- **Check Entitlements:** Ensure Network Extension capability is enabled
- **Provisioning Profile:** Verify profiles include Network Extension
- **Bundle ID:** Confirm tunnel extension bundle ID matches VPN configuration

#### 2. No Detections
- **VPN Status:** Verify tunnel is connected
- **Domain List:** Check if target domains are in the monitoring list
- **Network Traffic:** Ensure apps are generating location-related requests

#### 3. Notifications Not Working
- **Permissions:** Check notification permissions in iOS Settings
- **App Settings:** Verify notifications are enabled in Privacy Settings
- **Background Mode:** Ensure app can run in background

#### 4. Build Errors
- **Target Dependencies:** Ensure tunnel extension is properly linked
- **Code Signing:** Check both targets have valid provisioning profiles
- **Entitlements:** Verify all required entitlements are present

### Debug Logging
Enable detailed logging:
```swift
// In VPNManager.swift
private let logger = Logger(subsystem: "com.phoneguardian.infiloc", category: "VPNManager")

// In PacketTunnelProvider.swift
private let logger = Logger(subsystem: "com.phoneguardian.infiloc.tunnel", category: "PacketTunnel")
```

## Privacy & Security

### Data Handling
- **Local Processing:** All analysis happens on-device
- **No Cloud Storage:** Detection logs are stored locally only
- **No External Servers:** No data is sent to external services
- **User Control:** Users can clear all data at any time

### Compliance
- **iOS Guidelines:** Follows Apple's privacy guidelines
- **No Decryption:** Does not decrypt or intercept encrypted content
- **Transparent:** Clear about what data is collected and how it's used
- **User Consent:** Requires explicit user permission to start monitoring

## Legal Notice

INFILOC is designed for personal privacy monitoring only. This tool:
- Does not decrypt, inject, or violate user privacy
- Is not intended for surveillance or unauthorized monitoring
- Should only be used on devices you own or have explicit permission to monitor
- May not be compliant with all jurisdictions' laws regarding network monitoring

## Support

For technical support or feature requests:
1. Check the troubleshooting section above
2. Review Apple's Network Extension documentation
3. Ensure all setup steps have been completed
4. Test on a real device (not simulator)

## Version History

### v1.0.0 (Current)
- Initial release with VPN-based monitoring
- Real-time detection of location access attempts
- Comprehensive logging and export capabilities
- User-configurable settings and notifications
- Support for major location services and apps 