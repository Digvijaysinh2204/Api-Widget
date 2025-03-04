<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages). 
-->

# API Widget

A powerful and flexible Flutter widget for handling API requests with built-in loading states, error handling, and retry mechanisms.

[![pub package](https://img.shields.io/pub/v/api_widget.svg)](https://pub.dev/packages/api_widget)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub issues](https://img.shields.io/github/issues/Digvijaysinh2204/Api-Widget)](https://github.com/Digvijaysinh2204/Api-Widget/issues)
[![GitHub pull requests](https://img.shields.io/github/issues-pr/Digvijaysinh2204/Api-Widget)](https://github.com/Digvijaysinh2204/Api-Widget/pulls)

## Links

- [Pub.dev Package](https://pub.dev/packages/api_widget)
- [GitHub Repository](https://github.com/Digvijaysinh2204/Api-Widget)
- [Issue Tracker](https://github.com/Digvijaysinh2204/Api-Widget/issues)
- [Changelog](CHANGELOG.md)
- [License](LICENSE)

## Features

- 🚀 Support for all HTTP methods (GET, POST, PUT, DELETE, PATCH, MULTIPART)
- 🔄 Built-in loading states and error handling
- 🎨 Customizable UI components
- 🔒 Automatic token management with refresh support
- 🔁 Retry mechanism for failed requests
- 🐛 Debug features (curl command generation)
- 📱 Platform support for iOS, Android, Web, Windows, macOS, and Linux
- 📦 Zero dependencies (except http package)
- ✅ Comprehensive test coverage
- 📚 Detailed documentation and examples

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  api_widget: ^1.0.1
```

## Getting Started

### Basic Usage

1. Initialize the API configuration:

```dart
void main() {
  ApiConfig.initialize(
    accessToken: 'your_access_token',
    timeoutDuration: const Duration(seconds: 30),
    loaderWidget: () => const CircularProgressIndicator(),
    onLogoutMethod: () {
      // Handle logout
    },
    toastWidget: (context, message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    },
    handleResponseStatus: (context, response) {
      // Handle specific status codes
    },
  );
  runApp(MyApp());
}
```

2. Use the API widget in your code:

```dart
final apiWidget = ApiWidget(
  url: 'https://api.example.com/data',
  method: HttpMethod.get,
  context: context,
);

final response = await apiWidget.sendRequest();
```

### Token Management

The package includes built-in token management with support for runtime token updates:

```dart
// Update the access token at runtime
ApiConfig.updateAccessToken("new_token_here");
```

This is particularly useful for:
- Token refresh scenarios
- User re-authentication
- Switching between different user sessions

### Advanced Features

#### Multipart Requests

```dart
final apiWidget = ApiWidget(
  url: 'https://api.example.com/upload',
  method: HttpMethod.multipart,
  context: context,
  fields: {'key': 'value'},
  files: {
    'file': await ApiWidget.createMultipartFile(
      'file',
      filePath,
    ),
  },
);
```

#### Custom Headers

```dart
final apiWidget = ApiWidget(
  url: 'https://api.example.com/data',
  method: HttpMethod.get,
  context: context,
  headers: {'Custom-Header': 'value'},
);
```

#### Retry Mechanism

```dart
final apiWidget = ApiWidget(
  url: 'https://api.example.com/data',
  method: HttpMethod.get,
  context: context,
  retryCount: 3,
  retryDelay: const Duration(seconds: 2),
);
```

## API Reference

### ApiConfig

The main configuration class for the API widget.

#### Methods

- `initialize()`: Initialize the API configuration
- `updateAccessToken()`: Update the access token at runtime

### ApiWidget

The main widget for making API requests.

#### Constructor Parameters

- `url`: The API endpoint URL
- `method`: The HTTP method to use
- `context`: The BuildContext
- `body`: Optional request body
- `headers`: Optional custom headers
- `files`: Optional files for multipart requests
- `fields`: Optional fields for multipart requests
- `retryCount`: Number of retry attempts
- `retryDelay`: Delay between retry attempts

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

- **DIGVIJAYSINH CHAUHAN**
  - GitHub: [@Digvijaysinh2204](https://github.com/Digvijaysinh2204)
  - Email: [digvijaysinh2204@gmail.com]

## Acknowledgments

- Thanks to the Flutter team for the amazing framework
- Thanks to the http package team for the HTTP client implementation
