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

  // Get a single blog post by ID
  Future<BlogPost?> getBlogPostById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists) {
      return BlogPost.fromsnap(doc);
    }
    return null;
  }

  // Get a blog post by deeplink
  Future<BlogPost?> getBlogPostByDeeplink(String deeplink) async {
    // Clean up the input deeplink for easier matching
    String searchDeeplink = deeplink.trim();
    String searchPostId = '';
    
    // Debug the input
    print('Original deeplink search: $searchDeeplink');
    
    // Extract the post ID if it's in the format "post/123"
    if (searchDeeplink.startsWith('post/')) {
      searchPostId = searchDeeplink.substring('post/'.length);
      print('Extracted post ID: $searchPostId');
    }
    
    // Format for full URL comparison
    if (!searchDeeplink.startsWith('http')) {
      searchDeeplink = 'https://zarity.example.com/$searchDeeplink';
    }
    
    print('Searching for blog post with formatted deeplink: $searchDeeplink');
    
    // First try an exact match on the deeplink field
    var querySnapshot = await _firestore
        .collection(_collection)
        .where('deeplink', isEqualTo: searchDeeplink)
        .limit(1)
        .get();
    
    if (querySnapshot.docs.isNotEmpty) {
      print('Found exact match for deeplink');
      return BlogPost.fromsnap(querySnapshot.docs.first);
    }
    
    // If we extracted a post ID, try looking for deeplinks ending with that ID
    if (searchPostId.isNotEmpty) {
      print('Searching for deeplinks ending with ID: $searchPostId');
      final allPosts = await _firestore.collection(_collection).get();
      
      for (var doc in allPosts.docs) {
        final storedDeeplink = doc.data()['deeplink'] as String? ?? '';
        print('Checking against stored deeplink: $storedDeeplink');
        
        if (storedDeeplink.endsWith('/post/$searchPostId') || 
            storedDeeplink.endsWith('/$searchPostId')) {
          print('Found match by ID in deeplink: $storedDeeplink');
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
        print('Found partial match: $storedDeeplink');
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
  
  // Update an existing blog post
  Future<void> updateBlogPost(BlogPost blogPost) async {
    try {
      await _firestore.collection(_collection).doc(blogPost.id).update(blogPost.toMap());
    } catch (e) {
      throw Exception('Failed to update blog post: $e');
    }
  }
  
  // Delete a blog post
  Future<void> deleteBlogPost(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete blog post: $e');
    }
  }
} 