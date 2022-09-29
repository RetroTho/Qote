import 'package:flutter/cupertino.dart';
import 'package:qote/dependencies.dart';

class NotePage extends StatefulWidget {
  _NotePage createState() => new _NotePage();
}

class _NotePage extends State<NotePage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _bodyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: EdgeInsetsDirectional.zero,
        automaticallyImplyLeading: false,
        leading: Container(
          padding: EdgeInsets.zero,
          alignment: Alignment.centerLeft,
          child: CupertinoNavigationBarBackButton(
            previousPageTitle: 'Qote',
            onPressed: () {
              Navigator.pop(
                  context, [_titleController.text, _bodyController.text]);
            },
          ),
        ),
        middle: Text('Note'),
      ),
      child: FutureBuilder(
        future: QoteAPI.getNotes(),
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>> snapshot) {
          List<Widget> children = [];
          if (snapshot.hasData) {
            _titleController.text =
                snapshot.data![QoteVars.currentNote.toString()]['title'];
            _bodyController.text =
                snapshot.data![QoteVars.currentNote.toString()]['body'];
            children = [
              Container(
                child: CupertinoTextField(
                  expands: true,
                  controller: _titleController,
                  placeholder: 'Title',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlignVertical: TextAlignVertical.center,
                  minLines: null,
                  maxLines: null,
                  decoration: BoxDecoration(border: null),
                ),
              ),
              Align(
                child: Container(
                  height: 1.5,
                  width: MediaQuery.of(context).size.width * 0.8,
                  //alignment: Alignment.center,
                  color: CupertinoColors.darkBackgroundGray,
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.75,
                child: CupertinoTextField(
                  controller: _bodyController,
                  placeholder: 'Body',
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  minLines: null,
                  maxLines: null,
                  expands: true,
                  decoration: BoxDecoration(border: null),
                ),
              ),
            ];
          } else if (snapshot.hasError) {
            children = [Icon(CupertinoIcons.wifi_slash)];
          } else {
            children = [
              SizedBox(
                child: CupertinoActivityIndicator(),
                width: 60,
                height: 60,
              ),
            ];
          }
          return ListView(
            children: [
              SizedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: children,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
