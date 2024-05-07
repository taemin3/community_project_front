import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import '/write.dart';
import 'api_url.dart';

class PostDto {
  final int id;
  final String title;
  final String content;
  final String memberName;
  final int goodCount;
  final int commentCount;

  PostDto({required this.id,required this.title, required this.content,required this.memberName, required this.goodCount,required this.commentCount});

  factory PostDto.fromJson(Map<String, dynamic> json) {
    return PostDto(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      memberName: json['memberName'],
      goodCount: json['goodCount'],
      commentCount: json['commentCount'],

    );
  }
}

class PostListScreen extends StatefulWidget {

  final String boardName;
  final int boardId;

  PostListScreen(this.boardName,this.boardId);
  @override
  _PostListScreenState createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {

  late ScrollController _scrollController;
  late List<PostDto> posts = [];
  bool isFavorite = false;
  int page = 0;
  int pageSize = 10;
  bool isLoading = false;
  Color iconColor = Colors.grey;

  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
      iconColor = isFavorite ? Colors.red : Colors.grey;
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    fetchPosts();
  }
  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the controller when not needed
    super.dispose();
  }

  Future<void> fetchPosts() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse('${ApiUrl.baseUrl}/api/post?page=$page&pageSize=$pageSize&boardId=${widget.boardId}'));
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      setState(() {
        posts.addAll(jsonData.map((data) => PostDto.fromJson(data)).toList());
        page++;
      });
    } else {
      throw Exception('Failed to load posts');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (posts == null) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Loading...'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.boardName),
      ),
      body: ListView.builder(
        itemCount: posts.length + (isLoading ? 1 : 0),
        itemBuilder: (BuildContext context, int index) {
          if(index < posts.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(
                    posts[index].title,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    posts[index].content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.favorite, color: iconColor),
                    onPressed: () {
                      toggleFavorite();
                      // 버튼을 눌렀을 때 수행할 작업을 추가할 수 있습니다.
                    },
                  ),
                  onTap: () {
                    // 게시글을 눌렀을 때의 동작을 추가할 수 있습니다.
                  },
                ),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

        },
        controller: _scrollController,

      ),
      floatingActionButton: FloatingActionButton(

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WriteScreen(widget.boardId,widget.boardName)),
          );
          // 버튼을 눌렀을 때 수행할 작업을 추가할 수 있습니다.
        },
        child: SvgPicture.asset(
            'assets/icons/pencil.svg',
          width: 35,
          color: Colors.white,
        ),

      ),

    );
  }
  void _scrollListener() {
    if (isLoading) return;

    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      fetchPosts();
    }
  }
}