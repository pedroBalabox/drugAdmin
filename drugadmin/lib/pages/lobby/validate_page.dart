import 'dart:convert';

import 'package:drugadmin/model/user_model.dart';
import 'package:drugadmin/service/restFunction.dart';
import 'package:drugadmin/service/sharedPref.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> validateClient(context, token) async {
  UserModel userModel = UserModel();
  RestFun rest = RestFun();

  rest.restService('', '${urlApi}perfil/usuario', token, 'get').then((value) {
    if (value['status'] == 'server_true') {
      var jsonUser = jsonDecode(value['response']);
      userModel = UserModel.fromJson(jsonUser[1]);
      saveUserModel(userModel);
    }
  });
  return userModel == null ? false : true;
}

Future<String> validateClientToken(context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  var clientToken = prefs.getString("user_token");

  if (clientToken != null) {
    return clientToken.toString();
  } else {
    return clientToken.toString();
  }
}
