import 'dart:convert';
import 'dart:io';

import 'package:api_widget_example/model/post_model.dart';
import 'package:flutter/material.dart';
import 'package:api_widget/api_widget.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  ApiConfig.initialize(
    accessToken: 'ABCBCBC',
    timeoutDuration: const Duration(seconds: 30),
    loaderWidget: () => const CircularProgressIndicator(),
    onLogoutMethod: () {},
    toastWidget: (context, message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    },
    handleResponseStatus: (context, response) {
      if (response.statusCode != 200 && response.statusCode != 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    },
    createCurl: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Widget Example',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<PostModel> posts = [];
  bool isLoading = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _fetchPosts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final apiWidget = ApiWidget(
        url: 'https://jsonplaceholder.typicode.com/posts',
        method: HttpMethod.get,
        context: context,
      );

      final response = await apiWidget.sendRequest();
      if (response.statusCode == 200) {
        var decodeData = jsonDecode(response.body) as List;
        setState(() {
          posts = decodeData
              .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _createPost() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final apiWidget = ApiWidget(
        url: 'https://jsonplaceholder.typicode.com/posts',
        method: HttpMethod.post,
        context: context,
        body: jsonEncode({
          'title': _titleController.text,
          'body': _bodyController.text,
          'userId': 1,
        }),
      );

      final response = await apiWidget.sendRequest();
      if (response.statusCode == 201) {
        _titleController.clear();
        _bodyController.clear();
        _fetchPosts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _updatePost(int id) async {
    setState(() {
      isLoading = true;
    });

    try {
      final apiWidget = ApiWidget(
        url: 'https://jsonplaceholder.typicode.com/posts/$id',
        method: HttpMethod.put,
        context: context,
        body: jsonEncode({
          'id': id,
          'title': 'Updated Title',
          'body': 'Updated Body',
          'userId': 1,
        }),
      );

      final response = await apiWidget.sendRequest();
      if (response.statusCode == 200) {
        _fetchPosts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _deletePost(int id) async {
    setState(() {
      isLoading = true;
    });

    try {
      final apiWidget = ApiWidget(
        url: 'https://jsonplaceholder.typicode.com/posts/$id',
        method: HttpMethod.delete,
        context: context,
      );

      final response = await apiWidget.sendRequest();
      if (response.statusCode == 200) {
        _fetchPosts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _uploadImage({context}) async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final apiWidget = ApiWidget(
        url: 'https://api.imgbb.com/1/upload',
        method: HttpMethod.multipart,
        context: context,
        fields: {'key': 'a7c3b1b2b2b2b2b2b2b2b2b2b2b2b2'},
        files: {
          'image': await ApiWidget.createMultipartFile(
            'image',
            _selectedImage!.path,
          ),
        },
      );

      final response = await apiWidget.sendRequest();
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
        } else {
          throw Exception('Failed to upload image');
        }
        setState(() {
          _selectedImage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Methods Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchPosts,
          ),
        ],
      ),
      body: isLoading
          ? const SizedBox()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Create Post Form
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Create New Post',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Title',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _bodyController,
                            decoration: const InputDecoration(
                              labelText: 'Body',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _createPost,
                            child: const Text('Create Post'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Image Upload Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Upload Image',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_selectedImage != null)
                            Image.file(
                              _selectedImage!,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.image),
                                label: const Text('Pick Image'),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _uploadImage(context: context);
                                },
                                icon: const Icon(Icons.upload),
                                label: const Text('Upload'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Posts List
                  const Text(
                    'Posts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'User ID: ${post.userId}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'ID: ${post.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                post.title ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(post.body ?? ''),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _updatePost(post.id!),
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Update'),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _deletePost(post.id!),
                                    icon: const Icon(Icons.delete),
                                    label: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
