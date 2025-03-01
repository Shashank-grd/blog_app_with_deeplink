import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zarity/core/helper/blogpostcard.dart';
import 'package:zarity/core/provider/blog_provider.dart';
import 'package:zarity/core/screens/blog_detail_screen.dart';
import 'package:zarity/core/screens/blog_upload_screen.dart';
import 'package:zarity/model/blog_post.dart';

class BlogListScreen extends ConsumerStatefulWidget {
  final String? highlightDeeplink;
  
  const BlogListScreen({Key? key, this.highlightDeeplink}) : super(key: key);

  @override
  ConsumerState<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends ConsumerState<BlogListScreen> {
  final ScrollController _scrollController = ScrollController();
  BlogPost? _blogPostToHighlight;
  bool _hasScrolledToHighlighted = false;
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.highlightDeeplink != null) {
      _loadAndHighlightBlogPost(widget.highlightDeeplink!);
    }
  }
  
  @override
  void didUpdateWidget(BlogListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlightDeeplink != oldWidget.highlightDeeplink && 
        widget.highlightDeeplink != null) {
      _loadAndHighlightBlogPost(widget.highlightDeeplink!);
    }
  }
  
  Future<void> _loadAndHighlightBlogPost(String deeplink) async {
    setState(() {
      _isSearching = true;
    });
    
    debugPrint('Loading and highlighting post with deeplink: $deeplink');
    
    try {
      final highlightedPost = await ref.read(blogRepositoryProvider).getBlogPostByDeeplink(deeplink);
      
      if (highlightedPost != null) {
        debugPrint('Successfully found post: ${highlightedPost.id} - ${highlightedPost.title}');
        
        setState(() {
          _blogPostToHighlight = highlightedPost;
          _hasScrolledToHighlighted = false;
        });
        
        // Set the selected blog post ID in the provider
        ref.read(selectedBlogPostIdProvider.notifier).state = highlightedPost.id;
        
        // Show a snackbar to confirm we found the post
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Found post: ${highlightedPost.title}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        debugPrint('No post found for deeplink: $deeplink');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No post found for: $deeplink'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error finding post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error finding post: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }
  
  void _scrollToHighlightedPost(List<BlogPost> blogPosts) {
    if (_blogPostToHighlight != null && !_hasScrolledToHighlighted) {
      final index = blogPosts.indexWhere((post) => post.id == _blogPostToHighlight!.id);
      if (index != -1) {
        // Use a small delay to ensure the ListView is fully built
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              index * 350.0, // Approximate height of each blog card
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
            setState(() {
              _hasScrolledToHighlighted = true;
            });
          }
        });
      }
    }
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blogPostsAsyncValue = ref.watch(blogPostsProvider);
    final selectedBlogPostId = ref.watch(selectedBlogPostIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isSearching ? 'Finding Post...' : 'Blog Posts',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(blogPostsProvider);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.blue.shade50,
                ],
              ),
            ),
            child: blogPostsAsyncValue.when(
              data: (blogPosts) {
                if (_blogPostToHighlight != null) {
                  _scrollToHighlightedPost(blogPosts);
                }
                
                if (blogPosts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No blog posts available',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const BlogUploadScreen()));
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add a Blog Post'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: blogPosts.length,
                  itemBuilder: (context, index) {
                    final blogPost = blogPosts[index];
                    final isSelected = blogPost.id == selectedBlogPostId;
                    
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      margin: EdgeInsets.symmetric(
                        vertical: isSelected ? 8.0 : 4.0,
                        horizontal: isSelected ? 4.0 : 0.0,
                      ),
                      decoration: BoxDecoration(
                        boxShadow: isSelected 
                            ? [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ] 
                            : [],
                      ),
                      child: BlogPostCard(
                        blogPost: blogPost,
                        isSelected: isSelected,
                        onTap: () {
                          // Set the selected blog post ID
                          ref.read(selectedBlogPostIdProvider.notifier).state = blogPost.id;
                          
                          // Navigate to the blog detail screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlogDetailScreen(blogPost: blogPost),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => _buildLoadingShimmer(),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${error.toString()}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.refresh(blogPostsProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Show loading indicator when searching for a post
          if (_isSearching)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Card(
                  elevation: 8,
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Finding blog post...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingShimmer() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          itemCount: 5,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 24,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 16,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    height: 36,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

