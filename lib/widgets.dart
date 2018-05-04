import 'package:flutter/material.dart';
import 'package:gohash_mobile/gohash_mobile.dart';
import 'package:gohash_mobile_app/functions.dart';
import 'package:url_launcher/url_launcher.dart';

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
                Hyperlink(_loginInfo.url)
                  ..tapCallback = copyToClipboard(_loginInfo.password,
                      clearAfterTimeout: true),
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
          copyToClipboard(value, clearAfterTimeout: clearAfterTimeout);
          Scaffold
              .of(context)
              .showSnackBar(SnackBar(content: Text(onCopiedMessage)));
        },
        child: Container(
            padding: EdgeInsets.only(left: 10.0), child: Icon(iconData)));
  }
}

const hyperlinkStyle =
    TextStyle(color: Colors.blue, decoration: TextDecoration.underline);

class Hyperlink extends StatelessWidget {
  final String text;
  GestureTapCallback tapCallback;

  Hyperlink(String text) : this.text = _toLink(text);

  static String _toLink(String value) {
    if (value.isEmpty) {
      // no value, can't make up any links
      return '';
    }
    if (value.startsWith(RegExp('http:|https:|tel:|sms:|mailto:'))) {
      // this is most likely a link already
      return value;
    }
    // make it a link
    return "https://$value";
  }

  _onTap() async {
    launch(text);
    if (tapCallback != null) {
      tapCallback();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return const Text('');
    }

    return GestureDetector(
      child: Text(text, style: hyperlinkStyle),
      onTap: _onTap,
    );
  }
}
