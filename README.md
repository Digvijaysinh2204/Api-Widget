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

## Features

- 🚀 Simple and intuitive API request handling
- 📱 Built-in loading overlay with customizable widget
- 🔄 Automatic retry mechanism for failed requests
- 🎨 Customizable error handling and messages
- 🔒 Secure header management with token support
- 📤 Multipart form data support
- 📝 Detailed request/response logging
- ⚡ Timeout handling
- 🔍 Debug mode with curl command generation

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  api_widget: ^0.0.1
```

## Usage

### Basic Setup

First, configure the API widget with your settings:

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
      // Show toast message
    },
    handleResponseStatus: (context, response) {
      // Handle specific status codes
    },
  );
  
  runApp(MyApp());
}
```

### Making API Requests

```dart
// GET request
final apiWidget = ApiWidget(
  url: 'https://api.example.com/data',
  method: HttpMethod.get,
  context: context,
);

final response = await apiWidget.sendRequest();

// POST request with body
final apiWidget = ApiWidget(
  url: 'https://api.example.com/create',
  method: HttpMethod.post,
  context: context,
  body: jsonEncode({'name': 'John'}),
);

final response = await apiWidget.sendRequest();

// Multipart request with file upload
final file = await ApiWidget.createMultipartFile('file', 'path/to/file.jpg');
final apiWidget = ApiWidget(
  url: 'https://api.example.com/upload',
  method: HttpMethod.multipart,
  context: context,
  files: {'file': file},
  fields: {'description': 'My file'},
);

final response = await apiWidget.sendRequest();
```

### Custom Headers

You can set custom headers globally or per request:

```dart
// Global headers
ApiConfig.instance.customHeader = {
  'X-Custom-Header': 'value',
  'Accept': 'application/json',
};

// Per-request headers
final apiWidget = ApiWidget(
  url: 'https://api.example.com/data',
  method: HttpMethod.get,
  context: context,
  customHeaders: {
    'X-Request-Specific': 'value',
  },
);
```

### Error Handling

The widget automatically handles common errors and provides retry mechanisms:

```dart
try {
  final response = await apiWidget.sendRequest();
  // Handle successful response
} on TimeoutException {
  // Handle timeout
} on http.ClientException {
  // Handle network errors
} catch (e) {
  // Handle other errors
}
```

## API Reference

### ApiConfig

| Property | Type | Description |
|----------|------|-------------|
| accessToken | String | Bearer token for authentication |
| timeoutDuration | Duration | Request timeout duration |
| retryDelay | Duration | Delay between retry attempts |
| loaderWidget | Widget Function | Custom loading widget |
| handleResponseStatus | Function | Custom response status handler |
| customHeader | Map<String, String> | Global custom headers |
| createCurl | bool | Enable curl command generation in debug mode |

### ApiWidget

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| url | String | Yes | API endpoint URL |
| method | HttpMethod | Yes | HTTP method (get, post, put, delete, multipart) |
| context | BuildContext | Yes | Build context for showing overlays |
| body | dynamic | No | Request body for POST/PUT |
| showLoader | bool | No | Show loading overlay (default: true) |
| fields | Map<String, String> | No | Form fields for multipart request |
| files | Map<String, MultipartFile> | No | Files for multipart request |

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
