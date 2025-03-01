import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zarity/core/provider/blog_provider.dart';
import 'package:zarity/core/screens/blog_list_screen.dart';
import 'package:zarity/core/screens/blog_upload_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final String? initialDeeplink;
  
  const HomeScreen({Key? key, this.initialDeeplink}) : super(key: key);
  
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    if (widget.initialDeeplink != null) {

      setState(() {
        _currentIndex = 0;
      });
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(deeplinkToHighlightProvider.notifier).state = widget.initialDeeplink;
      });
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialDeeplink != null 
              ? 'Post: ${widget.initialDeeplink}' 
              : 'Blog App',
        ),
      ),
      body: Column(
        children: [
          
          // Main content
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                BlogListScreen(
                  highlightDeeplink: widget.initialDeeplink ?? 
                      ref.watch(deeplinkToHighlightProvider),
                ),
                const BlogUploadScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Blog Posts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Upload',
          ),
        ],
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}