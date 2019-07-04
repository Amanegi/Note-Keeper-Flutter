import 'package:flutter/material.dart';
import 'package:notes_keeper_flutter/utils/database_helper.dart';
import 'package:notes_keeper_flutter/models/note.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  var _formKey = GlobalKey<FormState>();
  String appBarTitle;
  Note note;
  final _minPadding = 10.0;
  static var _priorities = ['High', 'Low'];
  DatabaseHelper databaseHelper = DatabaseHelper();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle mTextStyle =
        Theme.of(context).textTheme.subtitle.copyWith(fontSize: 18.0);
    TextStyle mButtonTextStyle = Theme.of(context)
        .textTheme
        .subtitle
        .copyWith(fontSize: 16.0, color: Colors.white);

    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(
      onWillPop: () {
        moveToLastScreen();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.only(
                top: _minPadding * 2, left: _minPadding, right: _minPadding),
            child: ListView(
              children: <Widget>[
                ListTile(
                  title: DropdownButton(
                    items: _priorities.map((String dropDownStringItem) {
                      return DropdownMenuItem<String>(
                        value: dropDownStringItem,
                        child: Text(dropDownStringItem),
                      );
                    }).toList(),
                    style: mTextStyle,
                    value: getPriorityAsString(note.priority),
                    onChanged: (value) {
                      setState(() {
                        updatePriorityAsInt(value);
                      });
                    },
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(top: _minPadding, bottom: _minPadding),
                  child: TextFormField(
                    controller: titleController,
                    style: mTextStyle,
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'Please enter title';
                      }
                    },
//                    onFieldSubmitted: (value) {
//                      updateTitle();
//                    },
                    decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: mTextStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(top: _minPadding, bottom: _minPadding),
                  child: TextField(
                    controller: descriptionController,
                    style: mTextStyle,
                    onChanged: (value) {
                      updateDescription();
                    },
                    decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: mTextStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(top: _minPadding, bottom: _minPadding),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                            color: Theme.of(context).primaryColorDark,
                            textColor: Theme.of(context).primaryColorLight,
                            child: Text(
                              'Save',
                              style: mButtonTextStyle,
                            ),
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                _save();
                              }
                            }),
                      ),
                      Container(
                        width: 5.0,
                      ),
                      Expanded(
                        child: RaisedButton(
                            color: Theme.of(context).primaryColorDark,
                            child: Text(
                              'Delete',
                              style: mButtonTextStyle,
                            ),
                            onPressed: () {
                              _delete();
                            }),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
  }

  void updateTitle() {
    note.title = titleController.text;
  }

  void updateDescription() {
    note.description = descriptionController.text;
  }

  void _save() async {
    moveToLastScreen();
    int result;
    note.date = DateFormat.yMMMd().format(DateTime.now());
    if (note.id != null) {
      //update operation
      result = await databaseHelper.updateNote(note);
    } else {
      //insert operation
      result = await databaseHelper.insertNote(note);
    }

    if (result != 0) {
      // success
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {
      // failure
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  void _delete() async {
    moveToLastScreen();
    // check for if user tries to delete a new note
    if (note.id == null) {
      _showAlertDialog('Status', 'No Note Deleted');
      return;
    }

    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      // success
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      // failure
      _showAlertDialog('Status', 'Problem Deleting Note');
    }
  }

  void _showAlertDialog(String title, String msg) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(msg),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  void moveToLastScreen() {
    // the value true will be returned to the last screen
    Navigator.pop(context, true);
  }

  @override
  void initState() {
    super.initState();
    // to handle onChanged property of TextFormField
    titleController.addListener(() {
      updateTitle();
    });
  }
}
