import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './style.dart' as style;

void main() {
  runApp(MaterialApp(theme: style.theme, home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var tab = 0;
  var data = [];
  var userImage;
  var userContent;

  setUserContent(a) {
    setState(() {
      userContent = a;
    });
  }

  addMyData() {
    var myData = {
      'id': data.length,
      'image': userImage,
      'likes': 5,
      'date': DateTime.now().toString(),
      'content': userContent,
      'liked': false,
      'user': 'John Kim'
    };

    setState(() {
      data.insert(0, myData);
    });
  }

  saveData() async {
    var storage = await SharedPreferences.getInstance();
    // storage.setString('map', jsonEncode(map));
    storage.getString('name');
  }

  fetchMoreData(a) {
    setState(() {
      data.add(a);
    });
  }

  getMoreData() async {
    var result = await http
        .get(Uri.parse('https://codingapple1.github.io/app/data.json'));

    setState(() {
      data = jsonDecode(result.body);
    });
  }

  @override
  void initState() {
    super.initState();
    try {
      getMoreData();
    } catch (error) {
      print(error);
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Instagram'), actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add_box_outlined),
              onPressed: () async {
                var picker = ImagePicker();
                var image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    userImage = File(image.path);
                  });
                }

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UploadPage(
                            userImage: userImage,
                            setUserContent: setUserContent,
                            addMyData: addMyData)));
              }),
        ]),
        bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag_outlined), label: 'Shopping'),
            ],
            onTap: (i) {
              setState(() {
                tab = i;
              });
            },
            currentIndex: 0,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed),
        body: [Home(data: data, fetchMoreData: fetchMoreData), Text('샵')][tab]);
  }
}

class Home extends StatefulWidget {
  const Home({Key? key, this.data, this.fetchMoreData}) : super(key: key);
  final data;
  final fetchMoreData;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var scroll = ScrollController();

  getMoreData() async {
    var result = await http
        .get(Uri.parse('https://codingapple1.github.io/app/more1.json'));

    print(jsonDecode(result.body));
    widget.fetchMoreData(jsonDecode(result.body));
  }

  @override
  void initState() {
    super.initState();
    scroll.addListener(() {
      if (scroll.position.pixels == scroll.position.maxScrollExtent) {
        getMoreData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isNotEmpty) {
      return ListView.builder(
          itemCount: widget.data.length,
          controller: scroll,
          itemBuilder: (c, i) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.data[i]['image'].runtimeType == String
                      ? Image.network(widget.data[i]['image'])
                      : Image.file(widget.data[i]['image']),
                  Text('좋아요 ${widget.data[i]['likes']}개'),
                  Text(widget.data[i]['date']),
                  Text(widget.data[i]['content']),
                ]);
          });
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}

class UploadPage extends StatelessWidget {
  const UploadPage(
      {super.key, this.userImage, this.setUserContent, this.addMyData});

  final userImage;
  final setUserContent;
  final addMyData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Upload'),
          actions: [
            IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  addMyData();
                  Navigator.pop(context);
                })
          ],
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_outlined, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Image.file(userImage, width: 100, height: 100),
          TextField(
            decoration: InputDecoration(
              hintText: '내용을 입력하세요',
              border: InputBorder.none,
            ),
            onChanged: (text) {
              setUserContent(text);
            },
          )
        ]));
  }
}
