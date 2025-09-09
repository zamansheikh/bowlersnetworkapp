# Bowlers Network App

A Flutter application built with Clean Architecture, featuring state management with Bloc pattern, navigation with Go Router, functional programming with Either, and dependency injection with GetIt.

## 🏗️ Architecture

This project follows **Clean Architecture** principles with three main layers:

### 📁 Project Structure
```
lib/
├── core/                          # Core functionality
│   ├── constants/                 # App constants
│   │   ├── colors.dart           # Brand colors (#8BC342)
│   │   ├── constants.dart        # General constants
│   │   └── strings.dart          # String constants
│   ├── di/                       # Dependency Injection
│   │   └── injection.dart        # GetIt configuration
│   ├── error/                    # Error handling
│   │   ├── exceptions.dart       # Custom exceptions
│   │   └── failures.dart         # Failure classes
│   ├── network/                  # Network layer
│   │   ├── network_info.dart     # Network connectivity
│   │   └── network_module.dart   # Dio configuration
│   ├── router/                   # Navigation
│   │   └── app_router.dart       # Go Router configuration
│   ├── theme/                    # App theming
│   │   └── app_theme.dart        # Material 3 theme
│   └── utils/                    # Utilities
│       └── usecase.dart          # Base use case
└── features/                     # Feature modules
    └── home/
        ├── data/                 # Data layer
        │   ├── datasources/      # Remote/local data sources
        │   ├── models/           # Data models
        │   └── repositories/     # Repository implementations
        ├── domain/               # Domain layer
        │   ├── entities/         # Business entities
        │   ├── repositories/     # Repository contracts
        │   └── usecases/         # Business logic
        └── presentation/         # Presentation layer
            ├── bloc/             # State management
            ├── pages/            # UI pages
            └── widgets/          # Reusable widgets
```

## 🎨 Brand Colors

- **Primary**: #8BC342 (Lime Green)
- **Black**: #000000
- **White**: #FFFFFF

## 🛠️ Technologies Used

- **Flutter**: UI framework
- **Dart**: Programming language
- **flutter_bloc**: State management
- **get_it + injectable**: Dependency injection
- **go_router**: Navigation
- **dartz**: Functional programming (Either)
- **dio**: HTTP client
- **equatable**: Value equality
- **json_annotation**: JSON serialization

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.9.0)
- Dart SDK

### Installation

1. **Clone the repository**
   ```bash
   git clone [your-repo-url]
   cd bowlersnetworkapp
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   dart run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📋 Key Features

### Clean Architecture Implementation

- **Separation of Concerns**: Each layer has its specific responsibility
- **Dependency Inversion**: Dependencies point inward toward the domain
- **Testability**: Easy to unit test with mock dependencies

### State Management (Bloc)

- **Predictable State**: Uses the Bloc pattern for state management
- **Event-Driven**: UI events trigger business logic
- **Reactive Programming**: UI rebuilds based on state changes

### Dependency Injection (GetIt + Injectable)

- **Singleton Management**: Centralized dependency management
- **Code Generation**: Automatic DI code generation
- **Modular**: Easy to swap implementations

### Navigation (Go Router)

- **Declarative Routing**: Type-safe navigation
- **Deep Linking**: Support for web and mobile deep links
- **Guard Routes**: Authentication and permission checking

### Functional Programming (Dartz)

- **Either Type**: Handle success/failure scenarios elegantly
- **Immutability**: Reduces bugs with immutable data structures
- **Composability**: Chain operations safely

## 🧪 Testing

Run tests with:
```bash
flutter test
```

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS  
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🔧 Build Commands

### Development
```bash
flutter run --debug
```

### Production
```bash
flutter build apk --release          # Android APK
flutter build appbundle --release    # Android Bundle
flutter build ios --release          # iOS
flutter build web --release          # Web
```

## 📚 Project Conventions

### Naming Conventions
- **Files**: snake_case (e.g., `user_repository.dart`)
- **Classes**: PascalCase (e.g., `UserRepository`)
- **Variables**: camelCase (e.g., `userName`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `API_BASE_URL`)

### Code Organization
- Group related functionality in features
- Keep business logic in the domain layer
- UI components should be stateless when possible
- Use Bloc for complex state management

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Team

Built with ❤️ for the Bowlers Network community.
khokan512@gmail.com