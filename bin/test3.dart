import 'package:test3/test3.dart' as test3;
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:sqlite3/sqlite3.dart';


/*
// Example Usage
Map<String, dynamic> map = jsonDecode(<myJSONString>);
var myRootNode = Root.fromJson(map);

Getting JSON from API, deserialise it and put to DB, put to file, make JSON and send in POST on server
*/
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

void getData() async{
  final url = Uri.https(
    'api.genderize.io',
    '/',
    {'name': 'Alex'},
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

  // Prepare a statement to run it multiple times:
  db.execute(""" 
  INSERT INTO NamesInfo (count, gender, name, probability) 
    VALUES(
      ${inputToDBData.count}, 
      '${inputToDBData.gender}', 
      '${inputToDBData.name}', 
      ${inputToDBData.probability}
    );
  """);


  // Dispose a statement when you don't need it anymore to clean up resources.
  //stmt.dispose();

  // You can run select statements with PreparedStatement.select, or directly
  // on the database:
  // final ResultSet resultSet =
  // db.select('SELECT * FROM artists WHERE name LIKE ?', ['The %']);

  // You can iterate on the result set in multiple ways to retrieve Row objects
  // one by one.
  // for (final Row row in resultSet) {
  //   print('Artist[id: ${row['id']}, name: ${row['name']}]');
  // }

  // Register a custom function we can invoke from sql:
  // db.createFunction(
  //   functionName: 'dart_version',
  //   argumentCount: const AllowedArgumentCount(0),
  //   function: (args) => Platform.version,
  // );
  // print(db.select('SELECT dart_version()'));

  // Don't forget to dispose the database to avoid memory leaks
  db.dispose();
}

void main(List<String> arguments) {
  //print('Hello world: ${test3.calculate()}!');
  getData();
  //createDB();

}
