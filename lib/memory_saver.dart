import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveStringToLocalStorage(String key, String value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

Future<String> getStringFromLocalStorage(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(key) ?? '';
}

Future<List<List<String>>> getRecentGroups() async {
  var groups = await getStringFromLocalStorage('groups');
  if (groups == '') {
    return [];
  }
  List<List<String>> groupsList = [];
  for (var a in groups.split(',')){
    if (a != '') {
      groupsList.add(a.split(';'));
    }
  }
  return groupsList;
}


Future<void> addRecentGroups(String name, String password) async {
  List<List<String>> groups = await getRecentGroups();
  List<String> group = [name, password];
  for (int i = 0; i < groups.length; ++i){
    if (groups[i][0] == group[0]){
      groups.removeAt(i);
      i--;
    }
  }
  groups = [group] + groups;
  var groupsString = "";
  String n, p;
  for (var g in groups){
    n = g[0];
    p = g[1];
    groupsString += "$n;$p,";
  }
  saveStringToLocalStorage('groups', groupsString);
}

Future<void> deleteAllGroups() async {
  saveStringToLocalStorage('groups', '');
}

