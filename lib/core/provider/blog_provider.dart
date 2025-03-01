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


// Provider to store the currently selected blog post ID
final selectedBlogPostIdProvider = StateProvider<String?>((ref) => null);

// Provider for creating a blog post
final createBlogPostProvider = FutureProvider.family<void, BlogPost>((ref, blogPost) async {
  final repository = ref.watch(blogRepositoryProvider);
  return repository.createBlogPost(blogPost);
});

// Provider to store the deeplink that should be highlighted
final deeplinkToHighlightProvider = StateProvider<String?>((ref) => null); 