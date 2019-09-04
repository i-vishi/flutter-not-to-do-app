import 'package:flutter/material.dart';
import 'package:not_to_do_flutter_app/models/nottodo_item.dart';

import 'database_client.dart';
import 'date_formatter.dart';

class NotToDoScreen extends StatefulWidget {
  @override
  _NotToDoScreenState createState() => _NotToDoScreenState();
}

class _NotToDoScreenState extends State<NotToDoScreen> {

  final TextEditingController _textEditingController = new TextEditingController();
  var db = new DatabaseHelper();


  final List<NotToDoItem> _itemList = <NotToDoItem>[];


  @override
  void initState() {
    super.initState();
    _readNotToDoList();
  }


  void _handleSubmit(String text) async {
    _textEditingController.clear();

    NotToDoItem item = new NotToDoItem(text, dateFormatted());
    
    int savedItemId = await db.saveItem(item);

    NotToDoItem addedItem = await db.getItem(savedItemId);


    setState(() {
      _itemList.insert(0, addedItem);
    });
  }

  @override
  void _showFormDialog() {
    var alert = new AlertDialog(
      content: new Row(
        children: <Widget>[
          new Expanded(
            child: TextField(
              controller: _textEditingController,
              autofocus: true,
              decoration: new InputDecoration(
                labelText: "Item",
                hintText: "eg., Don't try stunts at Home",
                icon: new Icon(Icons.note_add)
              ),
            ),
          )
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            _handleSubmit(_textEditingController.text);
            _textEditingController.clear();
            Navigator.pop(context);
          },
          child: Text("Save"),
        ),


        new FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel")
        )
      ],
    );

    showDialog(context: context,
    builder: (_) {
      return alert;
    });
  }
  
  
  _deleteNotToDo(int id, int index) async {

    await db.deleteItem(id);
    setState(() {
      _itemList.removeAt(index);
    });
  }


  _updateItem(NotToDoItem item, int index) async {
    var alert = new AlertDialog(
      title: new Text("Update Item"),
      content: new Row(
        children: <Widget>[
          new Expanded(
            child: new TextField(
              controller: _textEditingController,
              autofocus: true,

              decoration: new InputDecoration(
                labelText: "Item",
                hintText: "eg. Do not murder",
                icon: new Icon(Icons.update)
              ),
            ),
          )
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () async {
            NotToDoItem newitem = NotToDoItem.fromMap(
              {
                "itemName": _textEditingController.text,
                "dateCreated": dateFormatted(),
                "id": item.id
              }
            );

            _handleSubmitUpdate(index, item);
            _textEditingController.clear();

            await db.updateItem(newitem);

            setState(() {
              _readNotToDoList();
            });

            Navigator.pop(context);
          },
          child: new Text("Update"),
        ),
        new FlatButton(
          onPressed: () => Navigator.pop(context),
          child: new Text("Cancel"),
        )
      ],
    );
    
    
    showDialog(
      context: context,builder: (_) {
        return alert;
      }
      );
  }


  _readNotToDoList() async {
    List items = await db.getItems();
    items.forEach((item) {
//      NotToDoItem notToDoItem = NotToDoItem.fromMap(item);
      
      setState(() {
        _itemList.add(NotToDoItem.map(item));
      });
      
//      print("Db Items: ${notToDoItem.itemName}");
    });
  }


  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        children: <Widget>[
          new Flexible(
            child: new ListView.builder(
              padding: new EdgeInsets.all(8.0),
              reverse: false,
              itemCount: _itemList.length,
              itemBuilder: (_, int index) {
                return Card(
                  color: Colors.white10,
                  child: new ListTile(
                    title: _itemList[index],
                    onLongPress: () => _updateItem(_itemList[index], index),
                    trailing: new Listener(
                      key: new Key(_itemList[index].itemName),
                      child: new Icon(Icons.remove_circle, color: Colors.red,),
                      onPointerDown: (pointerEvent) => _deleteNotToDo(_itemList[index].id, index),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),





      floatingActionButton: new FloatingActionButton(
        onPressed: _showFormDialog,
        tooltip: "Add Item",
        backgroundColor: Colors.blue,
        child: new ListTile(
          title: new Icon(Icons.add),
        ),
      ),
    );
  }

  void _handleSubmitUpdate(int index, NotToDoItem item) {
    setState(() {
      _itemList.removeWhere((element) {
        _itemList[index].itemName == item.itemName;
      });
    });
  }
}
