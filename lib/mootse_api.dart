import 'dart:async';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:tse_notes/coursesid.dart';

/// use init method
class MootseAPI {
  //try catch pour probleme de connexion

  final String host = 'mootse.telecom-st-etienne.fr';
  final String urlCall = '/webservice/rest/server.php';
  String? token, userid, firstname, lastname;

  // Notes de l'utilisateur
  Map<String, List<Map<String, dynamic>>> userReport = {};

  Future<void> init(String username, String password) async {
    await _getToken(username, password);
    await _getIdNamePassword();
  }

  /// Recupere le token qui permet de faire les calls API (utiliser await)
  Future<void> _getToken(String username, String password) async {
    var url = Uri.https(host, '/login/token.php', {
      'username': username,
      'password': password,
      'service': 'moodle_mobile_app'
    });
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      token = jsonResponse['token'];
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  /// Recupere l'id, le nom et le prénom de l'utilisateur (utiliser await)
  Future<void> _getIdNamePassword() async {
    var url = Uri.https(host, urlCall, {
      'wstoken': token,
      'wsfunction': 'core_webservice_get_site_info',
      'moodlewsrestformat': 'json'
    });
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      userid = jsonResponse['userid'].toString();
      firstname = jsonResponse['firstname'];
      lastname = jsonResponse['lastname'];
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  /// Recupere les notes,coeff etc d'une matiere
  Future<List> getUserCourseReport(String courseid) async {
    var url = Uri.https(host, urlCall, {
      'wstoken': token,
      'wsfunction': 'gradereport_user_get_grade_items',
      'courseid': courseid,
      'userid': userid,
      'moodlewsrestformat': 'json'
    });
    var response = await http.get(url);
    var elt;
    List<Map> courseReport = [];
    Map<String, dynamic> item = {};
    try {
      if (response.statusCode == 200) {
        var jsonResponse =
            convert.jsonDecode(response.body) as Map<String, dynamic>;
        elt = jsonResponse['usergrades'][0]['gradeitems'];
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
      for (var i = 0; i < elt.length; i++) {
        if (elt[i]['itemname'] != "" && elt[i]['graderaw'] != null) {
          item = {};
          item['item'] = elt[i]['itemname'];
          item['grade'] = elt[i]['gradeformatted'];
          item['grademax'] = elt[i]['grademax'].toString();
          item['weight'] = elt[i]['weightraw'];
          courseReport.add(item);
        }
      }
    } catch (e) {
      print(e);
    }
    return courseReport;
  }

  /// Récupère les ids de cours de l'utilisateur
  //Future<void> getUserIdCourses() async {}

  /// Récupère toutes les notes de l'utilisateur
  Future<void> getUserReport() async {
    var keys, values;
    var courseReport;
    List<Map<String, dynamic>> userReporttemp = [];
    // 2 boucles pour 2 semestres citise1[0]: S1; citise1[1]:S2
    for (int i = 0; i < citise1[0].length; i++) {
      keys = citise1[0].keys.toList(growable: false);
      values = citise1[0].values.toList(growable: false);

      courseReport = await getUserCourseReport(values[i]);
      userReporttemp.add({keys[i]: courseReport});
    }
    userReport['citise1S1'] = userReporttemp;
    print(userReport['citise1S1']);
    for (int i = 0; i < citise1[1].length; i++) {
      keys = citise1[1].keys.toList(growable: false);
      values = citise1[1].values.toList(growable: false);

      courseReport = await getUserCourseReport(values[i]);
      userReporttemp.add({keys[i]: courseReport});
    }
    userReport['citise1S2'] = userReporttemp;
    print(userReport['citise1S2']);

    // citise2
    for (int i = 0; i < citise1[1].length; i++) {
      keys = citise2[1].keys.toList(growable: false);
      values = citise2[1].values.toList(growable: false);

      courseReport = await getUserCourseReport(values[i]);
      userReporttemp.add({keys[i]: courseReport});
    }
    userReport['citise2S1'] = userReporttemp;
    print(userReport['citise2S1']);

    for (int i = 0; i < citise1[1].length; i++) {
      keys = citise2[1].keys.toList(growable: false);
      values = citise2[1].values.toList(growable: false);

      courseReport = await getUserCourseReport(values[i]);
      userReporttemp.add({keys[i]: courseReport});
    }
    userReport['citise2S2'] = userReporttemp;
  }
}

