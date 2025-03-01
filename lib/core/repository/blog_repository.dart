import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zarity/model/blog_post.dart';

class BlogRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'blogPosts';

  // Get all blog posts
  Stream<List<BlogPost>> getBlogPosts() {
    return _firestore
        .collection(_collection)
        .orderBy('title')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc)  => BlogPost.fromsnap(doc)).toList());
  }


  // Get a blog post by deeplink
  Future<BlogPost?> getBlogPostByDeeplink(String deeplink) async {
    // Clean up the input deeplink for easier matching
    String searchDeeplink = deeplink.trim();
    String searchPostId = '';


    // Extract the post ID if it's in the format "post/123"
    if (searchDeeplink.startsWith('post/')) {
      searchPostId = searchDeeplink.substring('post/'.length);
    }

    // Format for full URL comparison
    if (!searchDeeplink.startsWith('http')) {
      searchDeeplink = 'https://zarity.example.com/$searchDeeplink';
    }


    // First try an exact match on the deeplink field
    var querySnapshot = await _firestore
        .collection(_collection)
        .where('deeplink', isEqualTo: searchDeeplink)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return BlogPost.fromsnap(querySnapshot.docs.first);
    }

    // If we extracted a post ID, try looking for deeplinks ending with that ID
    if (searchPostId.isNotEmpty) {
      final allPosts = await _firestore.collection(_collection).get();

      for (var doc in allPosts.docs) {
        final storedDeeplink = doc.data()['deeplink'] as String? ?? '';

        if (storedDeeplink.endsWith('/post/$searchPostId') ||
            storedDeeplink.endsWith('/$searchPostId')) {
          return BlogPost.fromsnap(doc);
        }
      }
    }

    // If still not found, check if any deeplink contains our search string
    final allPosts = await _firestore.collection(_collection).get();
    for (var doc in allPosts.docs) {
      final storedDeeplink = doc.data()['deeplink'] as String? ?? '';

      // Check for partial matches
      if (storedDeeplink.contains(searchDeeplink) ||
          searchDeeplink.contains(storedDeeplink)) {
        return BlogPost.fromsnap(doc);
      }
    }

    print('No matching blog post found for deeplink: $searchDeeplink');
    return null;
  }
  
  // Create a new blog post
  Future<void> createBlogPost(BlogPost blogPost) async {
    try {
      await _firestore.collection(_collection).doc(blogPost.id).set(blogPost.toMap());
    } catch (e) {
      throw Exception('Failed to create blog post: $e');
    }
  }

} 