import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zarity/core/repository/blog_repository.dart';
import 'package:zarity/model/blog_post.dart';

// Provider for the blog repository
final blogRepositoryProvider = Provider<BlogRepository>((ref) {
  return BlogRepository();
});

// Provider for the stream of blog posts
final blogPostsProvider = StreamProvider<List<BlogPost>>((ref) {
  final repository = ref.watch(blogRepositoryProvider);
  return repository.getBlogPosts();
});

// Provider for a single blog post by ID
final blogPostByIdProvider = FutureProvider.family<BlogPost?, String>((ref, id) async {
  final repository = ref.watch(blogRepositoryProvider);
  return repository.getBlogPostById(id);
});

// Provider for a blog post by deeplink
final blogPostByDeeplinkProvider = FutureProvider.family<BlogPost?, String>((ref, deeplink) async {
  final repository = ref.watch(blogRepositoryProvider);
  return repository.getBlogPostByDeeplink(deeplink);
});

// Provider to store the currently selected blog post ID
final selectedBlogPostIdProvider = StateProvider<String?>((ref) => null);

// Provider for creating a blog post
final createBlogPostProvider = FutureProvider.family<void, BlogPost>((ref, blogPost) async {
  final repository = ref.watch(blogRepositoryProvider);
  return repository.createBlogPost(blogPost);
});

// Provider for updating a blog post
final updateBlogPostProvider = FutureProvider.family<void, BlogPost>((ref, blogPost) async {
  final repository = ref.watch(blogRepositoryProvider);
  return repository.updateBlogPost(blogPost);
});

// Provider for deleting a blog post
final deleteBlogPostProvider = FutureProvider.family<void, String>((ref, id) async {
  final repository = ref.watch(blogRepositoryProvider);
  return repository.deleteBlogPost(id);
});

// Provider to store the deeplink that should be highlighted
final deeplinkToHighlightProvider = StateProvider<String?>((ref) => null); 