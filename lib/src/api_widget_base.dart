import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'api_config.dart';

/// HTTP methods supported by the API widget
enum HttpMethod {
  /// GET request method
  get,

  /// POST request method
  post,

  /// PUT request method
  put,

  /// DELETE request method
  delete,

  /// Multipart form data request method
  multipart,
}

/// A class that handles API requests with loading state and error handling.
///
/// This widget provides a convenient way to make HTTP requests with built-in
/// loading states, error handling, and retry mechanisms. It supports all major
/// HTTP methods and includes features like:
///
/// - Loading overlay with customizable widget
/// - Automatic retry mechanism for failed requests
/// - Customizable error handling and messages
/// - Secure header management with token support
/// - Multipart form data support
/// - Detailed request/response logging
/// - Timeout handling
/// - Debug mode with curl command generation
class ApiWidget {
  /// The URL endpoint for the API request
  final String url;

  /// The HTTP method to use for the request
  final HttpMethod method;

  /// The request body (for POST/PUT requests)
  final dynamic body;

  /// Whether to show the loading overlay
  final bool showLoader;

  /// Form fields for multipart requests
  final Map<String, String>? fields;

  /// Files to upload in multipart requests
  final Map<String, http.MultipartFile>? files;

  /// The build context for showing overlays
  final BuildContext context;

  /// Optional HTTP client for testing or custom implementations
  final http.Client? _client;

  /// The overlay entry for the loading indicator
  OverlayEntry? _loaderOverlay;

  /// Creates a new instance of [ApiWidget].
  ///
  /// [url] is the endpoint URL for the API request.
  /// [method] specifies the HTTP method to use.
  /// [context] is required for showing overlays and messages.
  /// [body] is optional and used for POST/PUT requests.
  /// [showLoader] determines whether to show the loading overlay.
  /// [fields] and [files] are used for multipart requests.
  /// [client] is optional and used for testing or custom HTTP client implementations.
  ApiWidget({
    required this.url,
    required this.method,
    required this.context,
    this.body,
    this.showLoader = true,
    this.fields,
    this.files,
    http.Client? client,
  }) : _client = client;

  /// Creates a [MultipartFile] from a file path.
  ///
  /// [fieldName] is the name of the form field.
  /// [filePath] is the path to the file on disk.
  /// Returns a [Future<MultipartFile>] that can be used in multipart requests.
  static Future<http.MultipartFile> createMultipartFile(
      String fieldName, String filePath) async {
    return await http.MultipartFile.fromPath(fieldName, filePath);
  }

  /// Creates a [MultipartFile] from bytes.
  ///
  /// [fieldName] is the name of the form field.
  /// [bytes] is the file content as a list of bytes.
  /// [filename] is optional and specifies the name of the file.
  /// Returns a [MultipartFile] that can be used in multipart requests.
  static http.MultipartFile createMultipartFileFromBytes(
      String fieldName, List<int> bytes,
      {String? filename}) {
    return http.MultipartFile.fromBytes(fieldName, bytes, filename: filename);
  }

  /// Sends the API request and handles the response.
  ///
  /// This method:
  /// 1. Shows the loading overlay if enabled
  /// 2. Prepares the request headers
  /// 3. Sends the request based on the HTTP method
  /// 4. Handles the response and any errors
  /// 5. Removes the loading overlay
  ///
  /// Returns a [Future<http.Response>] containing the API response.
  /// Throws [TimeoutException] if the request times out.
  /// Throws [http.ClientException] for network errors.
  Future<http.Response> sendRequest() async {
    DateTime startTime = DateTime.now();
    if (showLoader && ApiConfig.instance.loaderWidget != null) {
      _showLoader();
    }

    final Map<String, String> header = {
      if (ApiConfig.instance.customHeader != null)
        ...ApiConfig.instance.customHeader!,
      if (ApiConfig.instance.customHeader == null &&
          ApiConfig.instance.accessToken.isNotEmpty)
        'Authorization': 'Bearer ${ApiConfig.instance.accessToken}',
      if (method == HttpMethod.multipart)
        'Content-Type': 'multipart/form-data'
      else
        'Content-Type': 'application/json',
    };

    try {
      http.Response response;
      final client = _client ?? http.Client();

      switch (method) {
        case HttpMethod.multipart:
          if (fields == null && files == null) {
            throw Exception(
                'Fields or files are required for multipart request');
          }

          var request = http.MultipartRequest(
            'POST',
            Uri.parse(url),
          );

          // Add headers
          header.forEach((key, value) {
            request.headers[key] = value;
          });

          // Add fields
          if (fields != null) {
            request.fields.addAll(fields!);
          }

          // Add files
          if (files != null) {
            request.files.addAll(files!.values);
          }

          // Send request and get response
          var streamedResponse = await request.send();
          response = await http.Response.fromStream(streamedResponse);
          break;

        case HttpMethod.get:
          response = await client
              .get(Uri.parse(url), headers: header)
              .timeout(ApiConfig.instance.timeoutDuration);
          break;

        case HttpMethod.post:
          response = await client
              .post(Uri.parse(url), headers: header, body: body)
              .timeout(ApiConfig.instance.timeoutDuration);
          break;

        case HttpMethod.put:
          response = await client
              .put(Uri.parse(url), headers: header, body: body)
              .timeout(ApiConfig.instance.timeoutDuration);
          break;

        case HttpMethod.delete:
          response = await client
              .delete(Uri.parse(url), headers: header)
              .timeout(ApiConfig.instance.timeoutDuration);
          break;
      }

      _logResponse(response, startTime);

      if (showLoader && ApiConfig.instance.loaderWidget != null) {
        _removeLoader();
      }

      if (ApiConfig.instance.handleResponseStatus != null) {
        ApiConfig.instance.handleResponseStatus!(context, response);
      }

      return response;
    } on TimeoutException {
      if (showLoader && ApiConfig.instance.loaderWidget != null) {
        _removeLoader();
      }
      if (ApiConfig.instance.retryDelay != null) {
        await Future.delayed(ApiConfig.instance.retryDelay!);
        return sendRequest();
      }
      rethrow;
    } on http.ClientException catch (e) {
      if (showLoader && ApiConfig.instance.loaderWidget != null) {
        _removeLoader();
      }
      if (ApiConfig.instance.retryDelay != null) {
        await Future.delayed(ApiConfig.instance.retryDelay!);
        return sendRequest();
      }
      _showMessage("Network error: ${e.message}");
      rethrow;
    } catch (e) {
      if (showLoader && ApiConfig.instance.loaderWidget != null) {
        _removeLoader();
      }
      _showMessage("An error occurred: $e");
      rethrow;
    }
  }

  /// Shows the loading overlay with the configured loader widget.
  ///
  /// This method creates and inserts an overlay entry with the loading widget
  /// centered on the screen with a semi-transparent black background.
  void _showLoader() {
    if (ApiConfig.instance.loaderWidget == null) return;

    _loaderOverlay = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withAlpha(128),
        child: Center(
          child: ApiConfig.instance.loaderWidget!(),
        ),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_loaderOverlay != null) {
        Overlay.of(context).insert(_loaderOverlay!);
      }
    });
  }

  /// Removes the loading overlay.
  ///
  /// This method safely removes the loading overlay and cleans up the overlay entry.
  void _removeLoader() {
    if (_loaderOverlay != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loaderOverlay?.remove();
        _loaderOverlay = null;
      });
    }
  }

  /// Logs a message in debug mode.
  ///
  /// [content] is the message to log.
  /// [title] is an optional title for the log entry.
  void kLog({required dynamic content, String title = ''}) {
    if (kDebugMode) {
      log(content.toString(), name: title.toString());
    }
  }

  /// Generates a curl command for debugging purposes.
  ///
  /// [url] is the request URL.
  /// [method] is the HTTP method.
  /// [headers] are the request headers.
  /// [body] is the request body.
  /// [fields] are the form fields for multipart requests.
  /// Returns a formatted curl command string.
  String _generateCurlCommand(String url, String method,
      Map<String, String> headers, dynamic body, Map<String, String>? fields) {
    final StringBuffer curl = StringBuffer();
    curl.write('curl --request $method \\\n');
    curl.write('  --url $url \\\n');

    // Add headers
    headers.forEach((key, value) {
      curl.write("  --header '$key: $value' \\\n");
    });

    // Add body or form data
    if (method == 'POST' || method == 'PUT') {
      if (fields != null) {
        // Handle multipart form data
        fields.forEach((key, value) {
          curl.write("  --form '$key=$value' \\\n");
        });
      } else if (body != null) {
        // Handle JSON body
        curl.write("  --data '${body.toString()}'");
      }
    }

    return curl.toString().trimRight();
  }

  /// Logs the API response details.
  ///
  /// [response] is the HTTP response.
  /// [startTime] is the time when the request started.
  void _logResponse(http.Response response, DateTime startTime) {
    DateTime endTime = DateTime.now();
    Duration duration = endTime.difference(startTime);

    kLog(content: url, title: 'URL');
    kLog(content: method.name.toUpperCase(), title: 'METHOD');
    kLog(content: response.request?.headers, title: 'HEADERS');
    kLog(content: response.statusCode, title: 'STATUS CODE');
    kLog(content: '${duration.inMilliseconds} ms', title: 'RESPONSE TIME');

    if (ApiConfig.instance.createCurl) {
      final curlCommand = _generateCurlCommand(
        url,
        method.name.toUpperCase(),
        response.request?.headers ?? {},
        body,
        fields,
      );
      kLog(content: curlCommand, title: 'CURL COMMAND');
    }

    if (response.statusCode != 500) {
      kLog(content: response.body, title: 'RESPONSE BODY');
    }
  }

  /// Shows a message using the configured toast widget.
  ///
  /// [message] is the message to display.
  void _showMessage(String message) {
    ApiConfig.instance.toastWidget(context, message);
  }
}
