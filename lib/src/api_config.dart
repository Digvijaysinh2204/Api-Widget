import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Configuration class for the API widget that manages global settings and behaviors.
///
/// This class uses the singleton pattern to provide a single source of configuration
/// for all API requests. It includes settings for:
///
/// - Authentication (access token)
/// - Request timeouts and retries
/// - Custom UI components (loader, toast messages)
/// - Response handling
/// - Custom headers
/// - Debug features (curl command generation)
class ApiConfig {
  /// The access token used for API authentication.
  /// This token will be automatically added to request headers as a Bearer token.
  final String accessToken;

  /// Callback function to handle user logout.
  /// This is typically called when authentication errors are detected.
  final VoidCallback onLogoutMethod;

  /// The default timeout duration for API requests.
  /// If a request takes longer than this duration, it will be cancelled.
  final Duration timeoutDuration;

  /// Optional delay duration between retry attempts for failed requests.
  /// If set, failed requests will be retried after this delay.
  final Duration? retryDelay;

  /// Custom widget function for displaying toast messages.
  /// This is used to show error messages and other notifications.
  final void Function(BuildContext context, String message) toastWidget;

  /// Optional callback function to handle specific HTTP response status codes.
  /// This can be used to implement custom error handling or status-specific behaviors.
  final void Function(BuildContext context, http.Response response)?
      handleResponseStatus;

  /// Optional map of custom headers to be added to all API requests.
  /// These headers will be merged with the default headers.
  final Map<String, String>? customHeader;

  /// Optional custom widget function for the loading overlay.
  /// This widget will be shown during API requests if showLoader is true.
  final Widget Function()? loaderWidget;

  /// Whether to generate and log curl commands for requests in debug mode.
  /// This is useful for debugging and testing API requests.
  final bool createCurl;

  /// Creates a new instance of [ApiConfig].
  ///
  /// [accessToken] is required for API authentication.
  /// [onLogoutMethod] is called when authentication errors occur.
  /// [toastWidget] is used to display messages to the user.
  /// [timeoutDuration] defaults to 60 seconds if not specified.
  /// [retryDelay] is optional and used for retrying failed requests.
  /// [handleResponseStatus] is optional and used for custom status handling.
  /// [loaderWidget] is optional and used for the loading overlay.
  /// [customHeader] is optional and adds custom headers to requests.
  /// [createCurl] enables curl command generation in debug mode.
  const ApiConfig({
    required this.accessToken,
    required this.onLogoutMethod,
    required this.toastWidget,
    this.timeoutDuration = const Duration(seconds: 60),
    this.retryDelay,
    this.handleResponseStatus,
    this.loaderWidget,
    this.customHeader,
    this.createCurl = false,
  });

  /// The singleton instance of [ApiConfig].
  static ApiConfig? _instance;

  /// Gets the current instance of [ApiConfig].
  ///
  /// Throws an exception if [initialize] has not been called.
  static ApiConfig get instance {
    if (_instance == null) {
      throw Exception(
          'ApiConfig not initialized. Call ApiConfig.initialize() first.');
    }
    return _instance!;
  }

  /// Initializes the [ApiConfig] singleton with the provided settings.
  ///
  /// This method must be called before using the API widget.
  ///
  /// [accessToken] is required for API authentication.
  /// [timeoutDuration] is the default request timeout.
  /// [loaderWidget] is the widget shown during loading.
  /// [onLogoutMethod] is called on authentication errors.
  /// [toastWidget] is used to display messages.
  /// [handleResponseStatus] handles specific status codes.
  /// [customHeader] adds custom headers to requests.
  /// [createCurl] enables curl command generation.
  static void initialize({
    required String accessToken,
    required Duration timeoutDuration,
    required Widget Function() loaderWidget,
    required VoidCallback onLogoutMethod,
    required void Function(BuildContext context, String message) toastWidget,
    required void Function(BuildContext context, http.Response response)
        handleResponseStatus,
    Map<String, String>? customHeader,
    bool createCurl = false,
  }) {
    _instance = ApiConfig(
      onLogoutMethod: onLogoutMethod,
      toastWidget: toastWidget,
      accessToken: accessToken,
      timeoutDuration: timeoutDuration,
      loaderWidget: loaderWidget,
      handleResponseStatus: handleResponseStatus,
      customHeader: customHeader,
      createCurl: createCurl,
    );
  }

  /// Gets the current access token.
  static String get token => instance.accessToken;

  /// Gets the current timeout duration.
  static Duration get timeout => instance.timeoutDuration;

  /// Gets the current loader widget function.
  static Widget Function()? get customLoader => instance.loaderWidget;
}
