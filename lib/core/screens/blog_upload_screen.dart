import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:zarity/core/provider/blog_provider.dart';
import 'package:zarity/model/blog_post.dart' as model;

class BlogUploadScreen extends ConsumerStatefulWidget {
  const BlogUploadScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BlogUploadScreen> createState() => _BlogUploadScreenState();
}

class _BlogUploadScreenState extends ConsumerState<BlogUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageURLController = TextEditingController();
  final _deeplinkController = TextEditingController();
  
  bool _isLoading = false;
  
  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _imageURLController.dispose();
    _deeplinkController.dispose();
    super.dispose();
  }
  
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Format the deeplink properly for zarity.example.com domain
        String deeplink = _deeplinkController.text.trim();
        
        // If it's just a number or simple string, format it as a post path
        if (deeplink.contains('://')) {
          // Extract just the last part if it's a full URL
          final uri = Uri.parse(deeplink);
          if (uri.pathSegments.length > 1 && uri.pathSegments[0] == 'post') {
            deeplink = 'https://zarity.example.com/post/${uri.pathSegments[1]}';
          }
        } else if (!deeplink.startsWith('https://')) {
          // If it doesn't have a protocol, assume it's just the ID
          deeplink = 'https://zarity.example.com/post/$deeplink';
        }

        // Create a new blog post
        final blogPost = model.BlogPost(
          id: const Uuid().v1(),
          title: _titleController.text.trim(),
          summary: _summaryController.text.trim(),
          content: _contentController.text.trim(),
          imageURL: _imageURLController.text.trim(),
          deeplink: deeplink,
        );
        
        // Save the blog post to Firestore
        await ref.read(createBlogPostProvider(blogPost).future);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Blog post created successfully with ID: ${blogPost.id}'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Clear the form
          _titleController.clear();
          _summaryController.clear();
          _contentController.clear();
          _imageURLController.clear();
          _deeplinkController.clear();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating blog post: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Blog Post'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Summary
                    TextFormField(
                      controller: _summaryController,
                      decoration: const InputDecoration(
                        labelText: 'Summary',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.short_text),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a summary';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Content
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'Content',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.article),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 10,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter content';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Image URL
                    TextFormField(
                      controller: _imageURLController,
                      decoration: const InputDecoration(
                        labelText: 'Image URL',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.image),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an image URL';
                        }
                        if (!Uri.tryParse(value)!.isAbsolute) {
                          return 'Please enter a valid URL';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Image Preview
                    if (_imageURLController.text.isNotEmpty && Uri.tryParse(_imageURLController.text)!.isAbsolute)
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _imageURLController.text,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.error, color: Colors.red, size: 50),
                              );
                            },
                          ),
                        ),
                      ),
                    if (_imageURLController.text.isNotEmpty && Uri.tryParse(_imageURLController.text)!.isAbsolute)
                      const SizedBox(height: 16),
                    
                    // Deeplink
                    TextFormField(
                      controller: _deeplinkController,
                      decoration: const InputDecoration(
                        labelText: 'Deeplink (post ID or full path)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                        hintText: 'Enter a number (like "2") or full URL',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a deeplink value';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Examples: "2" or "https://zarity.example.com/post/2"',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Submit Button
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Upload Blog Post',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 