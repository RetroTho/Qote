import 'package:flutter/cupertino.dart';
import 'package:qote/login.dart';
import 'package:qote/dependencies.dart';

class SettingsPage extends StatefulWidget {
  _SettingsPage createState() => new _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  TextEditingController _ipController = TextEditingController();
  String _status = '';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Settings'),
        previousPageTitle: 'Qote',
      ),
      child: ListView(
        children: [
          Column(
            children: [
              Padding(padding: new EdgeInsets.only(top: 20.0)),
              Text('Account Info'),
              Padding(padding: new EdgeInsets.only(top: 5.0)),
              Text('Name: ' +
                  QoteVars.currentUser['first_name'] +
                  ' ' +
                  QoteVars.currentUser['last_name']),
              Text('Username: ' + QoteVars.currentUser['username']),
              Text('Email: ' + QoteVars.currentUser['email']),
              Padding(padding: new EdgeInsets.only(top: 20.0)),
              CupertinoButton.filled(
                child: Text('Log Out'),
                onPressed: () {
                  QoteLocal.writeSharedPrefs('username', '');
                  QoteLocal.writeSharedPrefs('password', '');
                  QoteAPI.logout();
                  Navigator.push(context,
                          CupertinoPageRoute(builder: (context) => LoginPage()))
                      .then(
                    (value) {
                      Navigator.pop(context);
                    },
                  );
                },
              ),
              Padding(padding: new EdgeInsets.only(top: 20.0)),
              Text('Status: ' + _status),
              Padding(padding: new EdgeInsets.only(top: 10.0)),
              CupertinoTextField(
                controller: _ipController,
                placeholder: 'IP Address',
              ),
              Padding(padding: new EdgeInsets.only(top: 10.0)),
              CupertinoButton.filled(
                child: Text('Change IP'),
                onPressed: () {
                  QoteLocal.writeSharedPrefs(
                      'serverAddress', (_ipController.text + ':20000'));
                },
              ),
              Padding(padding: new EdgeInsets.only(top: 10.0)),
              CupertinoButton.filled(
                child: Text('Switch IP'),
                onPressed: () async {
                  if (await QoteLocal.readSharedPrefs('serverAddress') ==
                      'localhost:20000') {
                    QoteLocal.writeSharedPrefs(
                        'serverAddress', 'localhost20000');
                  } else {
                    QoteLocal.writeSharedPrefs(
                        'serverAddress', 'localhost:20000');
                  }
                  _status = 'success ' +
                      (await QoteLocal.readSharedPrefs('serverAddress'));
                  setState(() {});
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
