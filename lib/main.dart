import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final toDoController = TextEditingController();

  List toDoList = [];

  @override
  void initState() {
    super.initState();
    readData().then((value) {
      setState(() {
        toDoList = json.decode(value);
      });
    });
  }

  void addToDo() {
    setState(() {
      try {
        Map<String, dynamic> newToDo = {};
        newToDo['title'] = toDoController.text;
        toDoController.text = '';
        newToDo['Ok'] = false;
        toDoList.add(newToDo);
        saveData();
      } catch (e) {
        rethrow;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lista de tarefas',
          style: TextStyle(color: Colors.blueAccent),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(17, 1, 7, 1),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: toDoController,
                    decoration: InputDecoration(
                      labelText: 'Insira a tarefa',
                      labelStyle: TextStyle(
                        color: Colors.blueAccent[100],
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: addToDo,
                  child: Text(
                    'Salvar',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 10),
              itemCount: toDoList.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  activeColor: Colors.blueAccent,
                  title: Text(toDoList[index]['title']),
                  value: toDoList[index]['Ok'],
                  secondary: Icon(toDoList[index]['Ok']
                      ? Icons.check
                      : Icons.error_outline),
                  onChanged: (value) {
                    setState(() {
                      toDoList[index]['Ok'] = value;
                      saveData();
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<File> getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/data.json');
  }

  Future<File> saveData() async {
    var data = json.encode(toDoList);
    final file = await getFile();
    return file.writeAsString(data);
  }

  Future<String> readData() async {
    try {
      final file = await getFile();
      return file.readAsString();
    } catch (e) {
      rethrow;
    }
  }
}
