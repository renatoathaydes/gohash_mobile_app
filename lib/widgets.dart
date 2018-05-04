import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gohash_mobile/gohash_mobile.dart';

const _boldFont = TextStyle(fontWeight: FontWeight.bold);

class LoginInfoWidget extends StatelessWidget {
  final LoginInfo _loginInfo;

  LoginInfoWidget(this._loginInfo);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        trailing: Icon(Icons.description),
        onTap: () => _showPopup(context),
        title: Row(children: [
          Text(_loginInfo.name),
          CopierIcon(Icons.person, _loginInfo.username,
              onCopiedMessage: 'Username copied!'),
          CopierIcon(Icons.vpn_key, _loginInfo.password,
              onCopiedMessage: 'Password copied!'
                  '\nIt will be cleared after one minute.',
              clearAfterTimeout: true),
        ]));
  }

  _showPopup(BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) => SimpleDialog(
              contentPadding: EdgeInsets.all(10.0),
              children: [
                Text('Username:', style: _boldFont),
                Text(_loginInfo.username),
                Text('URL:', style: _boldFont),
                Text(_loginInfo.url),
                Text('Last changed:', style: _boldFont),
                Text("${_loginInfo.updatedAt}"),
                Text('Description:', style: _boldFont),
                Text(_loginInfo.description),
              ],
            ));
  }
}

class CopierIcon extends StatelessWidget {
  final String value;
  final bool clearAfterTimeout;
  final String onCopiedMessage;
  final IconData iconData;

  CopierIcon(IconData icon, String value,
      {String onCopiedMessage, bool clearAfterTimeout = false})
      : this.value = value,
        this.iconData = icon,
        this.onCopiedMessage = onCopiedMessage,
        this.clearAfterTimeout = clearAfterTimeout;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Clipboard.setData(ClipboardData(text: value));
          if (clearAfterTimeout) {
            Future.delayed(const Duration(seconds: 10), () async {
              final data = await Clipboard.getData('text/plain');
              if (data?.text == value) {
                Clipboard.setData(ClipboardData(text: ''));
              }
            });
          }
          Scaffold
              .of(context)
              .showSnackBar(SnackBar(content: Text(onCopiedMessage)));
        },
        child: Container(
            padding: EdgeInsets.only(left: 10.0), child: Icon(iconData)));
  }
}
