# Phone Guardian

A comprehensive iOS app for device monitoring, performance optimization, and system management.

## 📱 Features

### Core Features
- **Device Information**: Detailed device specs, capabilities, and model mapping
- **Performance Monitoring**: CPU, RAM, and battery usage tracking with charts
- **Storage Management**: Storage analysis, cache clearing, and duplicate file detection
- **Network Monitoring**: Network speed tests, data usage tracking, and connectivity analysis
- **Health Checks**: System health monitoring and diagnostics
- **Sensor Information**: Access to device sensors and their data

### Premium Features (Gold)
- **AI-Powered Tools**: Photo enhancement, smart file recommendations, duplicate finder
- **Cloud Integration**: Cloud storage management and media synchronization
- **Privacy Protection**: App activity monitoring, firewall protection, privacy audits
- **Advanced Storage Tools**: Photo compression, redundant backup checking, smart organization
- **Network Tools**: Advanced network testing, speed optimization, and diagnostics

### Watch App
- Companion Apple Watch app for quick device monitoring
- Real-time performance metrics
- Quick access to essential features

## 🏗️ Project Structure

```
Phone Guardian/
├── App/                          # Main app entry point and core files
│   ├── AppDelegate.swift
│   ├── ContentView.swift
│   ├── PhoneGuardianApp.swift
│   ├── PGEnvironment.swift
│   └── PersistenceController.swift
│
├── Core/                         # Core functionality and managers
│   ├── Managers/                 # App-wide managers and controllers
│   │   ├── AppNotificationManager.swift
│   │   ├── IAPManager.swift
│   │   ├── LogManager.swift
│   │   ├── ModuleManager.swift
│   │   ├── PermissionsManager.swift
│   │   └── TrackingPermissionHelper.swift
│   ├── Models/                   # Data models and view models
│   │   ├── InfoRow.swift
│   │   ├── Item.swift
│   │   ├── Module.swift
│   │   └── ModuleListView.swift
│   └── Utilities/                # Utility classes and helpers
│
├── Features/                     # Feature modules organized by functionality
│   ├── Camera/                   # Camera functionality
│   ├── Dashboard/                # Main dashboard and overview
│   ├── DeviceInfo/               # Device information and capabilities
│   │   ├── DetailedDeviceInfo/   # Detailed device views by platform
│   │   ├── ModelMapping/         # Device model mapping and identification
│   │   └── TemperatureManager.swift
│   ├── Display/                  # Display information and settings
│   ├── Health/                   # System health monitoring
│   ├── Network/                  # Network monitoring and tools
│   ├── Performance/              # Performance monitoring
│   │   ├── Battery/              # Battery monitoring and charts
│   │   ├── CPU/                  # CPU monitoring and analysis
│   │   └── RAM/                  # RAM monitoring and optimization
│   ├── Sensors/                  # Sensor data and information
│   ├── Settings/                 # App settings and configuration
│   │   └── Referral/             # Referral system and sharing
│   └── Storage/                  # Storage management tools
│       └── DuplicateScanner EXT/ # Duplicate file detection
│
├── Premium/                      # Premium features and add-ons
│   ├── Add On View/              # Premium feature presentation
│   ├── AI/                       # AI-powered features
│   │   └── Ai+/
│   ├── Cloud/                    # Cloud integration features
│   │   └── Cloud+/
│   ├── Gold/                     # Gold tier features
│   │   ├── Gold/
│   │   └── Upcoming features/
│   ├── Privacy/                  # Privacy protection features
│   │   └── Privacy/
│   ├── Storage/                  # Premium storage tools
│   │   └── Storage+/
│   └── Tools/                    # Premium utility tools
│       ├── DailyChallenges/      # Gamification features
│       └── Tools/                # Various utility tools
│           ├── Doc Conversions/  # Document conversion tools
│           ├── Network Tests/    # Advanced network testing
│           └── Not Added yet/    # Features in development
│
├── Resources/                    # App resources and assets
│   └── Assets.xcassets/          # App icons and visual assets
│
└── UI/                          # Reusable UI components
    ├── Charts/                   # Data visualization components
    ├── Components/               # Reusable UI components
    │   ├── Ads/                  # Advertisement components
    │   └── Definitions/          # Help and definition views
    └── Views/                    # Shared view components
```

## 🚀 Getting Started

### Prerequisites
- Xcode 14.0 or later
- iOS 16.0 or later
- Swift 5.7 or later

### Installation
1. Clone the repository
2. Open `Phone Guardian.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run the project

### Watch App
The project includes a companion Apple Watch app located in the `PhoneGuardian Watch` directory.

## 🛠️ Development

### Architecture
The app follows a modular architecture with clear separation of concerns:
- **Core**: Contains managers, models, and utilities used throughout the app
- **Features**: Organized by functionality with each feature in its own directory
- **Premium**: Premium features separated from core functionality
- **UI**: Reusable components and views

### Key Components
- **ModuleManager**: Manages feature modules and their states
- **IAPManager**: Handles in-app purchases and premium features
- **PermissionsManager**: Manages app permissions and user consent
- **LogManager**: Handles logging and debugging

## 📄 License

This project is proprietary software. All rights reserved.

## 🤝 Contributing

This is a private project. For questions or support, please contact the development team.

## 📞 Support

For technical support or feature requests, please reach out through the app's support channels. 