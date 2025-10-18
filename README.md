# Water Buddy iOS App

A comprehensive water buddy iOS application built with UIKit following MVVM + Clean Architecture principles. The app helps users monitor their daily water intake, set hydration goals, receive smart reminders, and track progress over time.

## 🌟 Features

### Core Features (ALL Implemented)
- ✅ **Auto Layout** - Responsive design across all iPhone sizes
- ✅ **UINavigationController** - Navigation flow between main screens
- ✅ **UITabBarController** - 5 tabs: Home, Stats, Add Water, History, Settings
- ✅ **Modal Presentation** - Quick water intake, achievements, and settings
- ✅ **UITableView** - Hydration history log, reminder list, daily entries
- ✅ **UICollectionView** - Water container options and achievement badges grid
- ✅ **Alamofire Integration** - Weather API for temperature-based recommendations
- ✅ **UserDefaults Persistence** - User preferences, goals, and water entries
- ✅ **Custom Fonts** - Programmatic font configuration for water amounts

### Enhanced Features (5/5 Implemented)
- ✅ **Charts Library (SPM)** - Statistical visualizations and progress tracking
- ✅ **Localization** - English and Thai language support
- ✅ **Local Notifications** - Hourly hydration reminders with smart scheduling
- ✅ **Animations** - Water filling effects, splash animations, goal celebrations
- ✅ **TextField Validation** - Input validation for water amounts and settings

### Special Features (2/2 Implemented)
- ✅ **MVVM + Clean Architecture** - Domain, Data, and Presentation layers
- ✅ **Home Screen Quick Actions** - 3D Touch shortcuts for quick water logging

## 🏗️ Architecture

The app follows **MVVM + Clean Architecture** principles with clear separation of concerns:

```
WaterBuddy/
├── Application/           # App lifecycle, DI container, coordinators
├── Domain/               # Business logic, entities, use cases
│   ├── Entities/         # Core data models
│   ├── UseCases/         # Business logic operations
│   └── Repositories/     # Data access interfaces
├── Data/                 # Data layer implementation
│   ├── Repositories/     # Repository implementations
│   ├── DataSources/      # Local and remote data sources
│   └── Network/          # API clients and networking
├── Presentation/         # UI layer
│   ├── ViewModels/       # MVVM view models
│   ├── Views/           # View controllers and custom views
│   └── Coordinators/    # Navigation coordination
├── Core/                # Shared utilities and extensions
└── Resources/           # Localization and assets
```

## 🎯 Key Screens

### 1. Home Dashboard
- **Circular animated progress indicator** showing daily intake
- **Quick add buttons** (100ml, 250ml, 500ml, custom)
- **Weather-based recommendations** with temperature integration
- **Streak counter** for consecutive goal achievements
- **Mini chart** displaying last 7 days progress
- **Motivational messages** based on progress

### 2. Add Water Screen (Modal)
- **UICollectionView** with container type selection
- **Custom amount input** with real-time validation
- **Recent amounts** for quick access
- **Animated feedback** for successful additions

### 3. Statistics Screen
- **Charts library integration** for beautiful visualizations
- **Multiple time periods**: Today, Week, Month, Year
- **Progress trends** and achievement analytics
- **Goal completion tracking**

### 4. History Screen
- **UITableView** with daily water entry logs
- **Date picker** for viewing specific days
- **Swipe actions** for editing and deleting entries
- **Search and filter** functionality

### 5. Settings Screen
- **User profile management** with daily goal setting
- **Unit preferences** (ml/oz) with automatic conversion
- **Language selection** (English/Thai)
- **Smart reminder configuration** with time range settings
- **Achievement badge collection**

## 🚀 Quick Actions (3D Touch)

The app supports **Home Screen Quick Actions** for instant water logging:

- **Add 250ml** - Quick log small glass
- **Add 500ml** - Quick log bottle
- **View Progress** - Jump to statistics screen
- **Quick Reminder** - Set reminder for 1 hour

## 🌍 Localization

Full localization support for:
- ✅ **English** (default)
- ✅ **Thai** (ภาษาไทย)

All UI text, number formatting, and date displays are localized.

## 💾 Data Architecture

### Clean Architecture Layers

**Domain Layer** (Business Logic)
- `WaterEntry`, `User`, `HydrationStatistics` entities
- Use cases: `AddWaterUseCase`, `GetStatisticsUseCase`, etc.
- Repository protocols for data access

**Data Layer** (Data Management)
- Repository implementations with local/remote data sources
- UserDefaults for persistence
- Weather API integration with Alamofire
- Automatic data synchronization

**Presentation Layer** (UI)
- MVVM ViewModels with Combine for reactive updates
- UIKit view controllers with proper separation of concerns
- Navigation coordinators for flow management

## 🧪 Testing

Unit tests included for:
- ✅ **ViewModels** - Business logic and state management
- ✅ **Use Cases** - Core functionality testing
- ✅ **Mock implementations** for dependency injection

## 📱 Technical Requirements

- **iOS 15.0+**
- **Swift 5.0+**
- **UIKit** (converted from SwiftUI for full navigation control)
- **Combine** for reactive programming
- **Swift Package Manager** dependencies

## 🎨 Design Features

- **Custom animations** - Water filling, splash effects, celebrations
- **Smooth transitions** between screens and states
- **Haptic feedback** for user interactions
- **Accessibility support** with proper labels and hints
- **Dark mode compatibility**

## 🔔 Smart Notifications

- **Hourly reminders** during active hours
- **Goal completion alerts**
- **Weather-based hydration suggestions**
- **Customizable reminder schedules**

## ⚡ Performance Optimizations

- **Efficient data loading** with async/await patterns
- **Memory management** with proper cleanup
- **Smooth animations** with optimized view updates
- **Background processing** for data synchronization

## 🏆 Achievements System

Track progress with:
- **Daily goal streaks**
- **Weekly consistency badges**
- **Monthly milestones**
- **Special weather challenges**

## 🔧 Setup Instructions

1. **Clone the repository**
2. **Add SPM dependencies**:
   - Charts: `https://github.com/danielgindi/Charts`
   - Alamofire: `https://github.com/Alamofire/Alamofire`
3. **Configure weather API key** in `APIClient.swift`
4. **Build and run** on iOS Simulator or device

## 🎯 Future Enhancements

- **Apple Health integration** for comprehensive health tracking
- **Social features** for sharing achievements
- **Advanced analytics** with ML-powered insights
- **Widget support** for home screen quick access
- **Apple Watch companion app**

---

**Built with ❤️ using MVVM + Clean Architecture and modern iOS development practices.**