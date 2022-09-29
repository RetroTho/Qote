import 'package:flutter/cupertino.dart';
import 'package:qote/dependencies.dart';
import 'package:qote/home.dart';

void main() {
  runApp(Qote());
}

class Qote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: QoteVars.mainRed,
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: true,
    );
  }
}
