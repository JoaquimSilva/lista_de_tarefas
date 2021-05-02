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
  static const String titulo = 'title';
  static const String ok = 'Ok';
  static const String emBranco = '';
  static const String tituloDoApp = 'Lista de tarefas';
  static const String mensagemDoTextFild = 'Insira a tarefa';
  static const String salvar = 'Salvar';

  final toDoController = TextEditingController();

  List toDoList = [];

  Map<String, dynamic> lastRemoved;
  int lastRemovedPosition;

  @override
  void initState() {
    super.initState();
    readData().then((value) {
      setState(() {
        toDoList = json.decode(value);
      });
    });
  }

// Metodo para adicionar a tarefa no lista
  void addToDo() {
    setState(() {
      try {
        Map<String, dynamic> newToDo = {};
        newToDo[titulo] = toDoController.text;
        toDoController.text = emBranco;
        newToDo[ok] = false;
        toDoList.add(newToDo);
        saveData();
      } catch (e) {
        rethrow;
      }
    });
  }

// adiciona atualizador ao puxar a lista para baixo e ordena as tarefas entre marcadas e não marcadas
  Future<void> refresh() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      toDoList.sort((a, b) {
        if (a[ok] && !b[ok])
          return 1;
        else if (!a[ok] && b[ok])
          return -1;
        else
          return 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tituloDoApp, style: TextStyle(color: Colors.blueAccent)),
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
                      labelText: mensagemDoTextFild,
                      labelStyle: TextStyle(
                        color: Colors.blueAccent[100],
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: addToDo,
                  child:
                      Text(salvar, style: TextStyle(color: Colors.blueAccent)),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: refresh,
              child: ListView.builder(
                padding: EdgeInsets.only(top: 10),
                itemCount: toDoList.length,
                itemBuilder: buildItem,
              ),
            ),
          ),
        ],
      ),
    );
  }

// cria o dismiss (gesto de deslizar para deletar) e monta a lista de tarefas
  Widget buildItem(context, index) {
    return Dismissible(
      key: Key(DateTime.now().microsecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: Card(
        child: CheckboxListTile(
          activeColor: Colors.blueAccent,
          title: Text(toDoList[index][titulo]),
          value: toDoList[index][ok],
          secondary:
              Icon(toDoList[index][ok] ? Icons.check : Icons.error_outline),
          onChanged: (value) {
            setState(() {
              toDoList[index][ok] = value;
              saveData();
            });
          },
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          //metodo para remover uma tarefa

          //lista as tarefas com o map
          lastRemoved = Map.from(toDoList[index]);
          //pega a posicao pelo index
          lastRemovedPosition = index;
          //remove da lista
          toDoList.removeAt(index);
          //salva a exclusao
          saveData();

          // O cara abaixo é um snack para poder desfazer a ação de excluir a tarefa
          final snack = SnackBar(
            content: Text('Tarefa ${lastRemoved[titulo]} removida'),
            action: SnackBarAction(
              label: 'Desfazer',
              onPressed: () {
                setState(() {
                  toDoList.insert(lastRemovedPosition, lastRemoved);
                  saveData();
                });
              },
            ),
            duration: Duration(seconds: 3),
          );
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(snack);
        });
      },
    );
  }

// consulta o arquivo json na memoria
  Future<File> getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/data.json');
  }

//salva o arquivo  json na memoria do aparelho
  Future<File> saveData() async {
    var data = json.encode(toDoList);
    final file = await getFile();
    return file.writeAsString(data);
  }

//consulta e le o arquivo json
  Future<String> readData() async {
    try {
      final file = await getFile();
      return file.readAsString();
    } catch (e) {
      rethrow;
    }
  }
}
