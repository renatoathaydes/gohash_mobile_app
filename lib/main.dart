import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gohash_mobile/gohash_mobile.dart';
import 'package:gohash_mobile_app/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

const _biggerFont = TextStyle(fontSize: 18.0);

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
  String _errorMessage = '';
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
    GohashDb database = const GohashDb('', []);
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
      errorMessage = 'Error reading go-hash database: $e';
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

  Widget _buildGroupBody(Group group) {
    return Column(
        children: group.entries.map((e) => new LoginInfoWidget(e)).toList());
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
    if (_database == null || _database.groups.isEmpty) {
      return Text(
        'Empty go-hash database',
        style: _biggerFont,
      );
    }

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
