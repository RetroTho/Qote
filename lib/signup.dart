import 'package:flutter/cupertino.dart';
import 'package:qote/dependencies.dart';

class SignUpPage extends StatefulWidget {
  _SignUpPage createState() => new _SignUpPage();
}

class _SignUpPage extends State<SignUpPage> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailAddressController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String signupResult = '';

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
                signupResult,
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
                  controller: _firstNameController,
                  placeholder: 'First Name',
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
                  controller: _lastNameController,
                  placeholder: 'Last Name',
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
                  controller: _emailAddressController,
                  placeholder: 'Email Address',
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
                  child: Text('Sign Up'),
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () async {
                    if (await QoteAPI.signup(
                        _firstNameController.text,
                        _lastNameController.text,
                        _emailAddressController.text,
                        _usernameController.text,
                        _passwordController.text)) {
                      Navigator.pop(context);
                    } else {
                      signupResult = QoteVars.latestResult;
                      setState(() {});
                    }
                  },
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 70)),
              Text('Already have an account?'),
              CupertinoButton(
                child: Text('Log In'),
                padding: EdgeInsets.zero,
                onPressed: () async {
                  Navigator.pop(context);
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
