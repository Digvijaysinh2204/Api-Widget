import 'dart:async';
import 'dart:io';

import 'package:api_widget/api_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([http.Client])
import 'api_widget_test.mocks.dart';

void main() {
  late MockClient mockClient;
  late BuildContext mockContext;
  late File testFile;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    mockClient = MockClient();
    mockContext = MockBuildContext();

    // Create a temporary test file
    final tempDir = await Directory.systemTemp.createTemp();
    testFile = File('${tempDir.path}/test.txt');
    await testFile.writeAsString('test content');

    // Initialize ApiConfig with test values
    ApiConfig.initialize(
      accessToken: 'test_token',
      timeoutDuration: const Duration(seconds: 30),
      loaderWidget: () => const CircularProgressIndicator(),
      onLogoutMethod: () {},
      toastWidget: (context, message) {},
      handleResponseStatus: (context, response) {},
    );
  });

  tearDown(() async {
    // Clean up the temporary file
    if (await testFile.exists()) {
      await testFile.delete();
    }
  });

  group('ApiWidget Tests', () {
    test('should create MultipartFile from file path', () async {
      final multipartFile = await ApiWidget.createMultipartFile(
        'file',
        testFile.path,
      );
      expect(multipartFile.field, 'file');
    });

    test('should create MultipartFile from bytes', () {
      final bytes = [1, 2, 3];
      final multipartFile = ApiWidget.createMultipartFileFromBytes(
        'file',
        bytes,
        filename: 'test.txt',
      );
      expect(multipartFile.field, 'file');
      expect(multipartFile.filename, 'test.txt');
    });

    test('should handle GET request successfully', () async {
      final response = http.Response('{"data": "test"}', 200);
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => response);

      final apiWidget = ApiWidget(
        url: 'https://api.example.com/test',
        method: HttpMethod.get,
        context: mockContext,
        showLoader: false, // Disable loader for testing
        client: mockClient,
      );

      final result = await apiWidget.sendRequest();
      expect(result.statusCode, 200);
      expect(result.body, '{"data": "test"}');
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('should handle POST request successfully', () async {
      final response = http.Response('{"data": "test"}', 201);
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => response);

      final apiWidget = ApiWidget(
        url: 'https://api.example.com/test',
        method: HttpMethod.post,
        context: mockContext,
        body: '{"key": "value"}',
        showLoader: false, // Disable loader for testing
        client: mockClient,
      );

      final result = await apiWidget.sendRequest();
      expect(result.statusCode, 201);
      expect(result.body, '{"data": "test"}');
      verify(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).called(1);
    });

    test('should handle error response', () async {
      final response = http.Response('{"error": "Not found"}', 404);
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => response);

      final apiWidget = ApiWidget(
        url: 'https://api.example.com/test',
        method: HttpMethod.get,
        context: mockContext,
        showLoader: false, // Disable loader for testing
        client: mockClient,
      );

      final result = await apiWidget.sendRequest();
      expect(result.statusCode, 404);
      expect(result.body, '{"error": "Not found"}');
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('should handle timeout exception', () async {
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => throw TimeoutException('Request timed out'));

      final apiWidget = ApiWidget(
        url: 'https://api.example.com/test',
        method: HttpMethod.get,
        context: mockContext,
        showLoader: false, // Disable loader for testing
        client: mockClient,
      );

      expect(
        () => apiWidget.sendRequest(),
        throwsA(isA<TimeoutException>()),
      );
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('should handle network error', () async {
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => throw http.ClientException('Network error'));

      final apiWidget = ApiWidget(
        url: 'https://api.example.com/test',
        method: HttpMethod.get,
        context: mockContext,
        showLoader: false, // Disable loader for testing
        client: mockClient,
      );

      expect(
        () => apiWidget.sendRequest(),
        throwsA(isA<http.ClientException>()),
      );
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });
  });
}

class MockBuildContext extends Mock implements BuildContext {}
