import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:html';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tse_notes/Mootse_API.dart';
import 'package:html/parser.dart' as parser;

void main() async {
  var api = MootseAPI();
  await api.init('username', 'mdp');

  print('Bonjour ${api.firstname} ${api.lastname} votre id est ${api.userid}');
  await api.getUserReport();
  var s2 = api.userReport['citise1S1'];
  print(s2);
}
