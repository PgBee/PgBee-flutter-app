# PgBee Flutter App - Architecture Documentation

## Overview
This document provides a comprehensive overview of the PgBee Flutter application architecture, including project structure, design patterns, state management, and integration details.

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── config/
│   └── locator.dart                   # Dependency injection setup
├── core/
│   ├── constants/                     # App constants
│   ├── controllers/                   # Business logic controllers
│   ├── routing/                       # Navigation and routing
│   │   └── route.dart
│   ├── theme/                         # App theming
│   │   └── app_theme.dart
│   └── utils/                         # Utility functions
├── controllers/
│   └── auth_controller.dart           # Authentication controller
├── models/                            # Data models
│   ├── auth_model.dart
│   ├── enquiry_model.dart
│   ├── hostel_model.dart
│   └── ...
├── providers/                         # State management providers
│   ├── auth_provider.dart
│   ├── enquiry_provider.dart
│   ├── hostel_provider_new.dart
│   └── screens_provider.dart
├── services/                          # API and business services
│   ├── service_manager.dart           # Centralized service manager
│   ├── auth_service.dart
│   ├── enquiry_service.dart
│   ├── hostel_service.dart
│   ├── amenities_service.dart
│   ├── owner_service.dart
│   └── review_service.dart
└── views/                             # UI components
    └── screens/                       # App screens
        ├── auth_screen.dart
        ├── home_screen.dart
        ├── inbox_screen.dart
        ├── pg_details_screen.dart
        └── ...
```

## Architecture Patterns

### 1. Clean Architecture
The app follows clean architecture principles with clear separation of concerns:

- **Presentation Layer**: UI components (Views/Screens)
- **Business Layer**: Controllers and Providers
- **Data Layer**: Services and Models

### 2. Provider Pattern
State management is handled using the Provider pattern:

- **ChangeNotifier**: For reactive state management
- **Consumer**: For UI updates based on state changes
- **Provider.of**: For accessing providers without listening

### 3. Service Layer Pattern
All API interactions are centralized through service classes:

- **ServiceManager**: Centralized service coordination
- **Individual Services**: Specific domain services (Auth, Hostel, etc.)
- **Token Management**: Automatic token handling across services

## Core Components

### 1. ServiceManager
Central hub for all services with token management:

```dart
class ServiceManager {
  static final ServiceManager _instance = ServiceManager._internal();
  factory ServiceManager() => _instance;
  
  // Services
  final AuthService authService = AuthService();
  final HostelService hostelService = HostelService();
  final EnquiryService enquiryService = EnquiryService();
  // ... other services
  
  // Token management
  void setAuthTokens({required String accessToken, ...}) {
    // Propagate tokens to all services
  }
}
```

### 2. Providers
State management for different app features:

#### AuthProvider
- User authentication state
- Login/logout functionality
- User role management

#### HostelProvider
- Hostel data management
- CRUD operations for hostels
- Image upload functionality

#### EnquiryProvider
- Enquiry management for owners
- Accept/deny enquiry actions
- Real-time enquiry updates

### 3. Services
API communication layer:

#### AuthService
- User authentication endpoints
- Google OAuth integration
- Token refresh management

#### HostelService
- Hostel CRUD operations
- Owner hostel management
- Hostel search functionality

#### EnquiryService
- Enquiry creation and management
- Status updates (accept/deny)
- Statistics and analytics

## Data Flow

### 1. User Authentication Flow
```
UI (AuthScreen) → AuthProvider → AuthController → ServiceManager → AuthService → Backend API
                      ↓
              Update UI State ← Token Storage ← Response Processing
```

### 2. Hostel Management Flow
```
UI (PgDetailsScreen) → HostelProvider → ServiceManager → HostelService → Backend API
                           ↓
                   Update Local State ← Data Processing ← API Response
```

### 3. Enquiry Management Flow
```
UI (InboxScreen) → EnquiryProvider → ServiceManager → EnquiryService → Backend API
                       ↓
               Update Enquiry List ← Status Update ← API Response
```

## State Management

### Provider Pattern Implementation

```dart
// Provider registration in main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => HostelProvider()),
    ChangeNotifierProvider(create: (_) => EnquiryProvider()),
  ],
  child: PgBee(),
)

// Provider usage in widgets
Consumer<HostelProvider>(
  builder: (context, hostelProvider, child) {
    if (hostelProvider.isLoading) {
      return CircularProgressIndicator();
    }
    return HostelDetails(hostel: hostelProvider.hostel);
  },
)
```

### State Lifecycle
1. **Initial State**: Loading indicators
2. **Loading State**: Progress indicators
3. **Success State**: Display data
4. **Error State**: Error handling and retry options

## Error Handling

### 1. Service Level Error Handling
```dart
try {
  final response = await _dio.post('/endpoint', data: data);
  return {'success': true, 'data': response.data};
} catch (e) {
  if (e is DioException) {
    return {'success': false, 'error': e.response?.data['message']};
  }
  return {'success': false, 'error': 'Network error'};
}
```

### 2. Provider Level Error Handling
```dart
Future<void> loadData() async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    final result = await _service.getData();
    if (result['success']) {
      _data = result['data'];
    } else {
      _errorMessage = result['error'];
    }
  } catch (e) {
    _errorMessage = 'Failed to load data';
  }

  _isLoading = false;
  notifyListeners();
}
```

### 3. UI Level Error Handling
```dart
if (provider.errorMessage != null) {
  return ErrorWidget(
    message: provider.errorMessage!,
    onRetry: () => provider.retry(),
  );
}
```

## Navigation and Routing

### Route Configuration
```dart
class AppRoute {
  static Map<String, Widget Function(BuildContext)> appRoute = {
    '/': (context) => AuthScreen(),
    '/home': (context) => HomeScreen(),
    '/inbox': (context) => InboxScreen(),
    '/pg-details': (context) => PgDetailsScreen(),
  };
}
```

### Navigation Management
- Declarative routing using named routes
- Route guards for authentication
- Deep linking support

## API Integration

### 1. Base Configuration
```dart
class BaseService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://server.pgbee.in',
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
  ));
  
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
}
```

### 2. Request/Response Interceptors
- Automatic token injection
- Request/response logging
- Error response handling
- Token refresh on 401 errors

### 3. Mock Data Support
All services include mock data fallbacks for development and testing:

```dart
// Return mock data when API fails
catch (e) {
  print('API Error: $e');
  return {
    'success': true,
    'data': getMockData(),
  };
}
```

## Authentication System

### 1. JWT Token Management
- Access tokens for API requests
- Refresh tokens for token renewal
- Automatic token refresh
- Secure token storage

### 2. Google OAuth Integration
- Google Sign-In SDK integration
- Server-side token validation
- User profile synchronization

### 3. Role-Based Access Control
- Owner role: Hostel management, enquiry handling
- Student role: Hostel browsing, enquiry creation
- Admin role: System management

## File Upload System

### 1. Image Upload Flow
```dart
Future<bool> uploadImages(List<String> imagePaths) async {
  // 1. Select images using ImagePicker
  // 2. Compress and optimize images
  // 3. Upload to backend/cloud storage
  // 4. Update hostel data with image URLs
}
```

### 2. Image Management
- Multiple image selection
- Image compression
- Progress indicators
- Error handling for failed uploads

## Performance Optimizations

### 1. Lazy Loading
- Providers loaded on-demand
- Images loaded progressively
- Pagination for large data sets

### 2. Caching Strategy
- Service-level response caching
- Image caching with cached_network_image
- Local storage for user preferences

### 3. Memory Management
- Proper disposal of controllers
- Provider lifecycle management
- Image memory optimization

## Testing Strategy

### 1. Unit Tests
- Service layer testing
- Provider testing
- Model validation testing

### 2. Widget Tests
- UI component testing
- User interaction testing
- State change validation

### 3. Integration Tests
- End-to-end flow testing
- API integration testing
- Authentication flow testing

## Build and Deployment

### 1. Build Configuration
```yaml
# pubspec.yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/fonts/
  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Regular.ttf
```

### 2. Environment Configuration
- Development environment setup
- Production build configuration
- Environment-specific constants

### 3. Platform-Specific Configurations
- Android: Gradle configuration, permissions
- iOS: Info.plist configuration, capabilities

## Security Considerations

### 1. Data Security
- Secure token storage using flutter_secure_storage
- Input validation and sanitization
- SQL injection prevention

### 2. Network Security
- HTTPS enforcement
- Certificate pinning
- Request encryption

### 3. Authentication Security
- Token expiration handling
- Secure logout implementation
- Session management

## Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5           # State management
  dio: ^5.3.2               # HTTP client
  get_it: ^7.6.4            # Dependency injection
  google_sign_in: ^6.1.5    # Google OAuth
  image_picker: ^1.0.4      # Image selection
  cached_network_image: ^3.3.0  # Image caching
```

### Development Dependencies
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
  mockito: ^5.4.2           # Mocking for tests
  build_runner: ^2.4.7      # Code generation
```

## Future Enhancements

### 1. Planned Features
- Real-time notifications using WebSockets
- Offline data synchronization
- Advanced search and filtering
- Payment integration
- Multi-language support

### 2. Technical Improvements
- GraphQL integration
- State persistence
- Advanced caching strategies
- Performance monitoring
- Crash reporting

### 3. UI/UX Enhancements
- Dark mode support
- Accessibility improvements
- Animation and micro-interactions
- Responsive design for tablets

## Development Guidelines

### 1. Code Standards
- Follow Dart/Flutter style guide
- Use meaningful variable names
- Add comprehensive comments
- Implement proper error handling

### 2. Git Workflow
- Feature branch development
- Code review requirements
- Commit message conventions
- Automated testing on CI/CD

### 3. Documentation Requirements
- API documentation updates
- Code documentation
- Architecture decision records
- User guide updates

## Troubleshooting Guide

### Common Issues
1. **Provider Not Found**: Ensure provider is registered in main.dart
2. **Network Errors**: Check backend connectivity and endpoints
3. **Authentication Failures**: Verify token management and refresh logic
4. **Build Issues**: Clean build cache and update dependencies

### Debugging Tools
- Flutter Inspector for UI debugging
- Network logging for API issues
- Provider debugging for state issues
- Performance profiling for optimization

---

**Last Updated**: July 30, 2025
**Architecture Version**: 2.0
**Flutter Version**: 3.x
**Dart Version**: 3.x
