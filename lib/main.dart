import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gohash_mobile/gohash_mobile.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() => runApp(new GoHashApp());

class GoHashApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'go-hash',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new HomePage(title: 'go-hash'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  final _biggerFont = const TextStyle(fontSize: 18.0);
  final _boldFont = const TextStyle(fontWeight: FontWeight.bold);
  String _errorMessage = 'No errors!';
  GohashDb _database;
  int _selectedGroupIndex;

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  /// Temporary function to read a go-hash database from assets, writing it
  /// to a file in the Documents dir, where it's accessible to Go code.
  Future<File> _loadDbFile() async {
    final dbBytes = await rootBundle.load('assets/gohash_db');
    final docsDir = await getApplicationDocumentsDirectory();
    final destinationFile = File("${docsDir.path}/gohash_db");
    destinationFile.createSync();
    return destinationFile.writeAsBytes(dbBytes.buffer.asUint8List());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    GohashDb database;
    var errorMessage = '';
    final dbFile = await _loadDbFile();

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      database =
          await GohashMobile.getDb(dbFile.absolute.path, 'secret_password');
      errorMessage = '';
    } on PlatformException {
      errorMessage = 'Platform error';
    } on MissingPluginException {
      // method is missing
      errorMessage = 'Internal app error - missing method';
    } on Error catch (e) {
      errorMessage = 'Catastrophic error: $e';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _errorMessage = errorMessage;
      _database = database;
      _selectedGroupIndex = 0;
    });
  }

  _showEntry(LoginInfo loginInfo) {
    showDialog(
        context: context,
        builder: (ctx) => SimpleDialog(
              contentPadding: EdgeInsets.all(10.0),
              children: [
                Text('Username:', style: _boldFont),
                Text(loginInfo.username),
                Text('URL:', style: _boldFont),
                Text(loginInfo.url),
                Text('Last changed:', style: _boldFont),
                Text("${loginInfo.updatedAt}"),
                Text('Description:', style: _boldFont),
                Text(loginInfo.description),
              ],
            ));
  }

  Widget _buildCopierIcon(IconData icon, String value) {
    return GestureDetector(
        onTap: () => Clipboard.setData(ClipboardData(text: value)),
        child:
            Container(padding: EdgeInsets.only(left: 10.0), child: Icon(icon)));
  }

  Widget buildEntry(LoginInfo loginInfo) {
    return ListTile(
        trailing: Icon(Icons.description),
        title: Row(children: [
          Text(loginInfo.name),
          _buildCopierIcon(Icons.person, loginInfo.username),
          _buildCopierIcon(Icons.vpn_key, loginInfo.password),
        ]),
        onTap: () => _showEntry(loginInfo));
  }

  Widget _buildGroupBody(Group group) {
    return Column(children: group.entries.map(buildEntry).toList());
  }

  ExpansionPanel _buildGroup(int index, Group group) {
    return ExpansionPanel(
        headerBuilder: (ctx, isExpanded) => Text(
              group.name,
              textAlign: TextAlign.start,
              style: _biggerFont,
            ),
        isExpanded: index == _selectedGroupIndex,
        body: _buildGroupBody(group));
  }

  Widget _buildGroups() {
    final panels = _database.groups
        .asMap()
        .map((index, group) => MapEntry(index, _buildGroup(index, group)));

    return ExpansionPanelList(
        children: panels.values.toList(),
        expansionCallback: (index, isExpanded) =>
            setState(() => _selectedGroupIndex = index));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(title: Text('go-hash')),
      body: _errorMessage.isEmpty
          ? SingleChildScrollView(
              child: SafeArea(
                child: Material(
                  child: _buildGroups(),
                ),
              ),
            )
          : Center(
              child: Text("Error: $_errorMessage",
                  style: _biggerFont.apply(color: Colors.red))),
    ));
  }
}
