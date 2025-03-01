import 'package:cloud_firestore/cloud_firestore.dart';

class BlogPost {
  final String id;
  final String imageURL;
  final String title;
  final String summary;
  final String content;
  final String deeplink;

  BlogPost({
    required this.id,
    required this.imageURL,
    required this.title,
    required this.summary,
    required this.content,
    required this.deeplink,
  }) ;

  static BlogPost fromsnap(DocumentSnapshot snap){
    var map = snap.data() as Map<String ,dynamic>;
    return BlogPost(
      id: map['id'],
      imageURL: map['imageURL'] ,
      title: map['title'] ,
      summary: map['summary'] ,
      content: map['content'] ,
      deeplink: map['deeplink'] ,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':id,
      'imageURL': imageURL,
      'title': title,
      'summary': summary,
      'content': content,
      'deeplink': deeplink,
    };
  }
} 