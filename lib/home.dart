import 'package:flutter/cupertino.dart';
import 'package:qote/dependencies.dart';
import 'package:qote/note.dart';
import 'package:qote/settings.dart';
import 'package:qote/login.dart';

class HomePage extends StatefulWidget {
  _HomePage createState() => new _HomePage();
}

class _HomePage extends State<HomePage> {
  void refresh() {
    setState(() {});
  }

  Future<Widget> notesList() async {
    Map<String, dynamic> packet = {};
    try {
      packet = await QoteAPI.getNotes();
    } catch (e) {}
    List<Widget> cols = [];
    List<Widget> rows = [];
    if (packet['attempt'] != 'failed') {
      int counter = 0;
      for (int i = 0; i < packet.length; i++) {
        if (counter >= 2) {
          cols.add(
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: rows,
            ),
          );
          cols.add(Padding(
              padding: new EdgeInsets.only(
                  top: MediaQuery.of(context).size.width * 0.025)));
          rows = [];
          counter = 0;
        } else if (counter == 1) {
          rows.add(Padding(
              padding: new EdgeInsets.only(
            right: MediaQuery.of(context).size.width * 0.025,
          )));
        }
        rows.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                child: SizedBox(
                  height: MediaQuery.of(context).size.width * 0.48,
                  width: MediaQuery.of(context).size.width * 0.48,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Container(
                      alignment: Alignment.center,
                      height: MediaQuery.of(context).size.width * 0.48,
                      width: MediaQuery.of(context).size.width * 0.48,
                      decoration: BoxDecoration(
                          color: Color(int.parse(
                              '0xff' + packet[i.toString()]['color'])),
                          borderRadius: BorderRadius.all(Radius.circular(25))),
                      child: Container(
                        alignment: Alignment.center,
                        height: MediaQuery.of(context).size.width * 0.43,
                        width: MediaQuery.of(context).size.width * 0.43,
                        child: Text(
                          packet[i.toString()]['title'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      QoteVars.currentNote = i;
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => NotePage(),
                        ),
                      ).then((value) {
                        QoteAPI.editNote(
                            value[0], value[1], QoteVars.currentNote);
                        refresh();
                      });
                    },
                  ),
                ),
                onLongPress: () {
                  showCupertinoModalPopup<void>(
                    context: context,
                    builder: (BuildContext context) => CupertinoActionSheet(
                      title: Text('"' + packet[i.toString()]['title'] + '"'),
                      message: Text('Select an action.'),
                      cancelButton: CupertinoActionSheetAction(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      actions: [
                        CupertinoActionSheetAction(
                          child: Text('Color: Gray'),
                          onPressed: () {
                            Navigator.pop(context);
                            QoteAPI.colorNote(i, '171717');
                            refresh();
                          },
                        ),
                        CupertinoActionSheetAction(
                          child: Text('Color: Red'),
                          onPressed: () {
                            Navigator.pop(context);
                            QoteAPI.colorNote(i, 'CC2323');
                            refresh();
                          },
                        ),
                        CupertinoActionSheetAction(
                          child: Text('Color: Purple'),
                          onPressed: () {
                            Navigator.pop(context);
                            QoteAPI.colorNote(i, 'D244F2');
                            refresh();
                          },
                        ),
                        CupertinoActionSheetAction(
                          child: Text('Color: Custom'),
                          onPressed: () {
                            TextEditingController _customColor =
                                TextEditingController();
                            Navigator.pop(context);
                            showCupertinoDialog<bool>(
                              context: context,
                              builder: (context) {
                                return CupertinoAlertDialog(
                                  title: Text('Hex Color Value'),
                                  content: Column(children: [
                                    Padding(padding: EdgeInsets.only(top: 10)),
                                    CupertinoTextField(
                                      controller: _customColor,
                                    )
                                  ]),
                                  actions: [
                                    CupertinoDialogAction(
                                      child: Text('Set'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        QoteAPI.colorNote(
                                            i, (_customColor.text));
                                        refresh();
                                      },
                                    ),
                                    CupertinoDialogAction(
                                      child: Text('Cancel'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      isDefaultAction: true,
                                    )
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        CupertinoActionSheetAction(
                          child: Text('Delete'),
                          isDestructiveAction: true,
                          onPressed: () {
                            Navigator.pop(context);
                            QoteAPI.deleteNote(i);
                            refresh();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
        counter++;
      }

      cols.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: rows,
            )
          ],
        ),
      );
    }
    return new Container(
      width: (((MediaQuery.of(context).size.width * 0.48) * 2) +
          MediaQuery.of(context).size.width * 0.025),
      child: new Column(
        children: cols,
      ),
    );
  }

  void startupLogin() async {
    if (await QoteLocal.checkSharedPref('serverAddress')) {
      QoteVars.serverAddress = await QoteLocal.readSharedPrefs('serverAddress');
    }
    try {
      bool result = await QoteAPI.login(
          await QoteLocal.readSharedPrefs('username'),
          await QoteLocal.readSharedPrefs('password'));
      if (result) {
        QoteVars.currentUser = await QoteAPI.getAccount();
        refresh();
      } else {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => LoginPage(),
          ),
        ).then((value) {
          refresh();
        });
      }
    } catch (e) {
      print(e.toString() + 'logininit');
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Connection Error'),
          content: Text('An error occured while connecting to the server.'),
          actions: [
            CupertinoDialogAction(
              child: Text('Retry'),
              onPressed: () async {
                Navigator.pop(context);
                Navigator.pop(context);
                startupLogin();
              },
            )
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    startupLogin();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: CupertinoColors.white,
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.zero,
              child: Image.asset(
                'assets/logo.png',
                height: 40,
              ),
            ),
            trailing: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () async {
                    await QoteAPI.newNote();
                    QoteVars.currentNote =
                        (await QoteAPI.getNotes()).length - 1;
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => NotePage(),
                        )).then((value) {
                      if (value[0] == '' && value[1] == '') {
                        QoteAPI.deleteNote(QoteVars.currentNote);
                      } else {
                        QoteAPI.editNote(
                            value[0], value[1], QoteVars.currentNote);
                        refresh();
                      }
                    });
                  },
                  child: Icon(CupertinoIcons.add_circled),
                ),
                Padding(
                    padding: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width * 0.05)),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => SettingsPage(),
                        )).then((value) {
                      refresh();
                    });
                  },
                  child: Icon(CupertinoIcons.gear),
                ),
              ],
            ),
          ),
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              refresh();
            },
          ),
          SliverToBoxAdapter(
            child: FutureBuilder(
              future: notesList(),
              builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                Widget child = Container();
                if (snapshot.hasData) {
                  child = snapshot.data!;
                } else if (snapshot.hasError) {
                  child = Icon(CupertinoIcons.wifi_slash);
                } else {
                  child = CupertinoActivityIndicator();
                }
                return SizedBox(
                  child: Column(
                    children: [
                      Padding(padding: EdgeInsets.only(top: 10)),
                      child,
                      Padding(padding: EdgeInsets.only(top: 40)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
