import 'package:flutter/material.dart';
import 'package:not_to_do_flutter_app/utils/nottodo_screen.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text('NotToDo'),
        backgroundColor: Colors.black54,
      ),
      body: new NotToDoScreen(),
    );
  }
}
