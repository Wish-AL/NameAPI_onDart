import 'dart:convert';
import 'package:test3/test3.dart' as test3;
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:sqlite3/sqlite3.dart';


/*
// Example Usage
Map<String, dynamic> map = jsonDecode(<myJSONString>);
var myRootNode = Root.fromJson(map);
*/
var jsonText = '';
class GenderOfName {
  int? count;
  String? gender;
  String? name;
  double? probability;

  GenderOfName({this.count, this.gender, this.name, this.probability});

  GenderOfName.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    gender = json['gender'];
    name = json['name'];
    probability = json['probability'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['count'] = count;
    data['gender'] = gender;
    data['name'] = name;
    data['probability'] = probability;
    return data;
  }
}

void getData(String? name) async{
  final url = Uri.https(
    'api.genderize.io',
    '/',
    {'name': '${name}'},
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonResponse = GenderOfName.fromJson(convert.jsonDecode(response.body));
    print('Number of books about HTTP: ${jsonResponse.gender}');
    createDB(jsonResponse);
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }

}

void createDB(GenderOfName inputToDBData) {
  var db = sqlite3.open('database.db');

    db.execute('''
    CREATE TABLE IF NOT EXISTS NamesInfo (
      count INT, 
      gender VARCHAR(20),
      name VARCHAR(20) PRIMARY KEY ON CONFLICT REPLACE, 
      probability REAL
    );
  ''');

  db.execute(""" 
  INSERT INTO NamesInfo (count, gender, name, probability) 
    VALUES(
      ${inputToDBData.count}, 
      '${inputToDBData.gender}', 
      '${inputToDBData.name}', 
      ${inputToDBData.probability}
    );
  """);
  db.dispose();

   final ResultSet resultSet =
   db.select('SELECT * FROM NamesInfo WHERE name LIKE ?', ['The %']);

  for (final Row row in resultSet) {
    print('Artist[id: ${row['id']}, name: ${row['name']}]');
   }
}

void sendFromDB() async {
  var db = sqlite3.open('database.db');
  final ResultSet resultSet =
  db.select('SELECT * FROM NamesInfo');
  File file = File("jsonFromDB.txt");
  await file.create();

  for (final Row row in resultSet) {
    jsonText += jsonEncode(row.toTableColumnMap());
  }
  file.writeAsString(jsonText);
  print('file done');
  db.dispose();
}

void main(List<String> arguments) {
  //print('Hello world: ${test3.calculate()}!');
  //String? enterYourName = 'Alex'; //stdin.readLineSync();
  //getData(enterYourName);
  sendFromDB();
  //createDB();

}
