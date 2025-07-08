# INFILOC Testing Guide

## Overview
This guide provides comprehensive testing procedures for the INFILOC VPN implementation to ensure it works correctly and reliably.

## Prerequisites
- iOS 15.6 or later
- Xcode 14.0 or later
- Apple Developer Account (for Network Extensions entitlement)
- Physical iOS device (Network Extensions don't work in simulator)

## Initial Setup Testing

### 1. Build and Install
```bash
# Clean build
xcodebuild clean -project "Phone Guardian.xcodeproj" -scheme "Phone Guardian"

# Build for device
xcodebuild build -project "Phone Guardian.xcodeproj" -scheme "Phone Guardian" -destination "generic/platform=iOS"
```

### 2. Verify Entitlements
- Check that both main app and extension have Network Extensions entitlement
- Verify App Group is configured correctly: `group.Infinitum-Imagery-LLC.Phone-Guardian.infiloc`
- Ensure bundle identifiers are correct:
  - Main app: `Infinitum-Imagery-LLC.Phone-Guardian`
  - Extension: `Infinitum-Imagery-LLC.Phone-Guardian.InfiLocTunnel`

### 3. Install on Device
- Install the app on a physical iOS device
- Grant VPN permissions when prompted
- Grant notification permissions

## Functional Testing

### 1. Basic VPN Connection
1. Open the app and navigate to Privacy Control
2. Tap "Start Monitoring"
3. Verify VPN connection is established
4. Check status shows "Privacy Protected"

**Expected Results:**
- VPN status should show "Connected"
- No error messages
- Tunnel health should show "Active"

### 2. Packet Processing Test
1. With VPN active, open Safari
2. Visit a known location service (e.g., maps.apple.com)
3. Check if detection is recorded

**Expected Results:**
- Detection should appear in the app
- Notification should be shown (if enabled)
- Detection count should increase

### 3. Connection Stability Test
1. Start VPN monitoring
2. Use the device normally for 10-15 minutes
3. Check VPN remains connected
4. Test with different network conditions (WiFi, Cellular)

**Expected Results:**
- VPN should remain stable
- No unexpected disconnections
- Automatic reconnection if needed

## Debug Testing

### 1. Debug Console
1. In Privacy Settings, tap "Debug Console" (DEBUG builds only)
2. Use the following test functions:

#### Test Tunnel Connection
- Tap "Test Tunnel Connection"
- Should return "Tunnel connection test successful"

#### Simulate Detection
- Tap "Simulate Detection"
- Should create a test detection entry

#### Export Debug Log
- Tap "Export Debug Log"
- Should generate comprehensive debug information

### 2. Console Logs
Monitor Xcode console for these log messages:

**Successful Startup:**
```
Starting INFILOC tunnel - Privacy Mode Active
Tunnel settings applied successfully - Privacy Protected
INFILOC VPN started successfully - Privacy Active
```

**Packet Processing:**
```
Location access detected: maps.googleapis.com (Google Maps)
Detection notification sent locally: Google Maps - maps.googleapis.com
```

**Error Messages:**
```
Failed to set tunnel settings: [error description]
Failed to start VPN: [error description]
```

## Troubleshooting

### Common Issues

#### 1. VPN Won't Connect
**Symptoms:** VPN status shows "Configuration Error" or "Invalid"

**Solutions:**
- Check entitlements in Xcode
- Verify bundle identifiers match
- Ensure Network Extensions capability is enabled
- Check Apple Developer account has Network Extensions entitlement

#### 2. No Detections Recorded
**Symptoms:** VPN connects but no detections appear

**Solutions:**
- Check App Group configuration
- Verify packet processing is active
- Test with known location services
- Check console logs for errors

#### 3. App Crashes on VPN Start
**Symptoms:** App crashes when starting VPN

**Solutions:**
- Check Info.plist has required keys
- Verify entitlements are properly configured
- Check for memory issues in PacketTunnelProvider
- Review crash logs in Xcode

#### 4. Notifications Not Working
**Symptoms:** Detections recorded but no notifications

**Solutions:**
- Check notification permissions
- Verify notification settings in app
- Test notification delivery in iOS Settings
- Check notification content configuration

### Debug Steps

#### 1. Enable Verbose Logging
Add to PacketTunnelProvider.swift:
```swift
private let logger = Logger(subsystem: "com.phoneguardian.infiloc.tunnel", category: "PacketTunnel")
logger.logLevel = .debug
```

#### 2. Check App Group Data
```swift
let userDefaults = UserDefaults(suiteName: "group.Infinitum-Imagery-LLC.Phone-Guardian.infiloc")
let detections = userDefaults?.array(forKey: "tunnel_detections")
print("Tunnel detections: \(detections?.count ?? 0)")
```

#### 3. Monitor Network Activity
Use Xcode's Network profiler to verify:
- VPN tunnel is active
- Packets are being processed
- No unexpected network activity

## Performance Testing

### 1. Battery Impact
- Monitor battery usage with VPN active
- Compare with VPN disabled
- Should have minimal impact (<5% additional drain)

### 2. Network Performance
- Test download/upload speeds with VPN active
- Should have minimal impact on network performance
- Check for latency increases

### 3. Memory Usage
- Monitor memory usage during extended use
- Should remain stable without memory leaks
- Check for memory warnings

## Security Testing

### 1. Data Privacy
- Verify no data is transmitted externally
- Check that all processing is local
- Confirm App Group data is device-only

### 2. Packet Analysis
- Verify only headers are analyzed
- Confirm no content decryption
- Check that sensitive data is not logged

### 3. Permissions
- Verify minimal permissions are requested
- Check that permissions are used appropriately
- Confirm no unnecessary data access

## Integration Testing

### 1. App Lifecycle
- Test VPN behavior during app backgrounding
- Verify VPN reconnects after app restart
- Check behavior during device sleep/wake

### 2. Network Changes
- Test VPN behavior when switching WiFi networks
- Verify behavior when switching to cellular
- Check reconnection after network loss

### 3. System Updates
- Test after iOS updates
- Verify compatibility with new iOS versions
- Check behavior with system changes

## Automated Testing

### 1. Unit Tests
Run the test suite:
```bash
xcodebuild test -project "Phone Guardian.xcodeproj" -scheme "Phone Guardian" -destination "platform=iOS Simulator,name=iPhone 14"
```

### 2. UI Tests
- Test VPN connection flow
- Test notification delivery
- Test settings persistence

### 3. Integration Tests
- Test end-to-end detection flow
- Test data persistence
- Test error handling

## Reporting Issues

When reporting issues, include:

1. **Device Information:**
   - iOS version
   - Device model
   - Available storage

2. **App Information:**
   - App version
   - Build number
   - Installation method

3. **Issue Details:**
   - Steps to reproduce
   - Expected vs actual behavior
   - Console logs
   - Debug log export

4. **Environment:**
   - Network conditions
   - Other apps running
   - System settings

## Success Criteria

The INFILOC implementation is working correctly when:

✅ VPN connects reliably and maintains connection
✅ Location access attempts are detected and recorded
✅ Notifications are delivered appropriately
✅ No data is transmitted externally
✅ Battery and performance impact is minimal
✅ App handles errors gracefully
✅ Settings persist correctly
✅ Debug tools provide useful information

## Next Steps

After successful testing:

1. **Performance Optimization:** Fine-tune based on test results
2. **User Experience:** Refine UI based on testing feedback
3. **Documentation:** Update user documentation
4. **App Store Preparation:** Ensure compliance with App Store guidelines
5. **Monitoring:** Set up production monitoring and analytics

---

*This testing guide should be updated as the implementation evolves and new features are added.* 