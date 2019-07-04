class Note {
  int _id, _priority;
  String _title, _description, _date;

  Note(this._title, this._date, this._priority, [this._description]);

  Note.withId(this._id, this._title, this._date, this._priority,
      [this._description]);

  int get id => _id;

  String get title => _title;

  String get description => _description;

  int get priority => _priority;

  String get date => _date;

  set title(String value) {
    if (value.length <= 255) {
      _title = value;
    }
  }

  set description(value) {
    if (value.length <= 255) {
      _description = value;
    }
  }

  set date(value) {
    _date = value;
  }

  set priority(value) {
    if (value >= 1 && value <= 2) {
      _priority = value;
    }
  }

  //Convert note object to map object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['title'] = _title;
    map['description'] = _description;
    map['priority'] = _priority;
    map['date'] = _date;

    return map;
  }

//Extract note object from map object
  Note.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._title = map['title'];
    this._description = map['description'];
    this._priority = map['priority'];
    this.date = map['date'];
  }
}
