import 'package:flutter/cupertino.dart';
import 'package:qote/dependencies.dart';
import 'package:qote/signup.dart';

class LoginPage extends StatefulWidget {
  _LoginPage createState() => new _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String loginResult = '';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: ListView(
      physics: NeverScrollableScrollPhysics(),
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.9,
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            children: [
              Image.asset(
                'assets/logo.png',
                width: 150,
              ),
              Padding(padding: EdgeInsets.only(top: 10)),
              Text(
                loginResult,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFF0000),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 10)),
              Container(
                height: 42,
                width: MediaQuery.of(context).size.width * 0.9,
                child: CupertinoTextField(
                  controller: _usernameController,
                  placeholder: 'Username',
                  textAlignVertical: TextAlignVertical.center,
                  decoration: BoxDecoration(
                      color: Color(0x07FFFFFF),
                      border: Border.all(color: Color(0x30FFFFFF), width: 1),
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 10)),
              Container(
                height: 42,
                width: MediaQuery.of(context).size.width * 0.9,
                child: CupertinoTextField(
                  controller: _passwordController,
                  placeholder: 'Password',
                  obscureText: true,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: BoxDecoration(
                      color: Color(0x07FFFFFF),
                      border: Border.all(color: Color(0x30FFFFFF), width: 1),
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 30)),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: CupertinoButton.filled(
                  child: Text('Log In'),
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () async {
                    QoteLocal.writeSharedPrefs(
                        'username', _usernameController.text);
                    QoteLocal.writeSharedPrefs(
                        'password', _passwordController.text);
                    if (await QoteAPI.login(
                        _usernameController.text, _passwordController.text)) {
                      QoteVars.currentUser = await QoteAPI.getAccount();
                      Navigator.pop(context);
                    } else {
                      loginResult = 'incorrect login info';
                      setState(() {});
                    }
                  },
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 70)),
              Text('Dont have an account?'),
              CupertinoButton(
                child: Text('Sign Up'),
                padding: EdgeInsets.zero,
                onPressed: () async {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => SignUpPage(),
                    ),
                  );
                },
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
      ],
    ));
  }
}
