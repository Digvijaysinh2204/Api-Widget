/// A powerful and flexible Flutter widget for handling API requests.
///
/// This package provides a convenient way to make HTTP requests in Flutter applications
/// with built-in loading states, error handling, and retry mechanisms. It supports all
/// major HTTP methods and includes features like:
///
/// - Loading overlay with customizable widget
/// - Automatic retry mechanism for failed requests
/// - Customizable error handling and messages
/// - Secure header management with token support
/// - Multipart form data support
/// - Detailed request/response logging
/// - Timeout handling
/// - Debug mode with curl command generation
///
/// To use this package, first configure the API widget with your settings:
///
/// ```dart
/// void main() {
///   ApiConfig.initialize(
///     accessToken: 'your_access_token',
///     timeoutDuration: const Duration(seconds: 30),
///     loaderWidget: () => const CircularProgressIndicator(),
///     onLogoutMethod: () {
///       // Handle logout
///     },
///     toastWidget: (context, message) {
///       // Show toast message
///     },
///     handleResponseStatus: (context, response) {
///       // Handle specific status codes
///     },
///   );
///
///   runApp(MyApp());
/// }
/// ```
///
/// Then use the ApiWidget to make requests:
///
/// ```dart
/// final apiWidget = ApiWidget(
///   url: 'https://api.example.com/data',
///   method: HttpMethod.get,
///   context: context,
/// );
///
/// final response = await apiWidget.sendRequest();
/// ```
///
/// For more information and examples, see the [README](https://github.com/yourusername/api_widget).

export 'src/api_widget_base.dart';
export 'src/api_config.dart';

// TODO: Export any libraries intended for clients of this package.
