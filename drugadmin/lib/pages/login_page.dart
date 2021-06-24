import 'package:drugadmin/model/user_model.dart';
import 'package:drugadmin/service/restFunction.dart';
import 'package:drugadmin/service/sharedPref.dart';
import 'package:drugadmin/utils/globals.dart';
import 'package:drugadmin/utils/theme.dart';
import 'package:drugadmin/widget/assetImage_widget.dart';
import 'package:drugadmin/widget/buttom_widget.dart';
import 'package:drugadmin/widget/testRest.dart';
import 'package:drugadmin/widget/textfieldTest_widget.dart';
import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:codigojaguar/codigojaguar.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String correo;
  String password;
  UserModel userModel = UserModel();

  @override
  void initState() {
    sharedPrefs.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: LayoutBuilder(builder: (context, constraints) {
        return constraints.maxWidth < 700
            ? CustomScrollView(
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Column(
                        children: [
                          Container(
                            height: 150,
                            child: Stack(children: [
                              Image.asset(
                                'images/drug3.jpg',
                                fit: BoxFit.cover,
                                width: double.maxFinite,
                                height: 400,
                              ),
                              Opacity(
                                  opacity: 0.75,
                                  child: Image.asset('images/coverColor.png',
                                      width: double.maxFinite,
                                      height: 400,
                                      fit: BoxFit.cover)),
                              Padding(
                                padding: const EdgeInsets.all(30.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 5),
                                    RichText(
                                      textAlign: TextAlign.start,
                                      text: TextSpan(
                                        text: 'Somos ',
                                        style: TextStyle(
                                            fontSize: constraints.maxWidth < 700
                                                ? 22
                                                : 47,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white),
                                        children: <TextSpan>[
                                          TextSpan(
                                              text: 'Drug.',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              )),
                                        ],
                                      ),
                                    ),
                                    Text('Sí, medicina on demand.',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize: constraints.maxWidth < 700
                                                ? 22
                                                : 47,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white))
                                  ],
                                ),
                              ),
                            ]),
                          ),
                          _formContainer(constraints)
                        ],
                      ),
                      childCount: 1,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    flex: 6,
                    child: Stack(fit: StackFit.expand, children: [
                      Image.asset(
                        'images/drug3.jpg',
                        fit: BoxFit.cover,
                        width: double.maxFinite,
                        height: 400,
                      ),
                      Opacity(
                          opacity: 0.75,
                          child: Image.asset('images/coverColor.png',
                              width: double.maxFinite,
                              height: 400,
                              fit: BoxFit.cover)),
                      _infoContainer(constraints)
                    ]),
                  ),
                  Flexible(flex: 4, child: _formContainer(constraints)),
                ],
              );
      }),
    );
  }

  _formContainer(constraints) {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('images/coverBlanco.png'))),
        child: ListView(
          shrinkWrap: true,
          physics: constraints.maxWidth > 700
              ? null
              : NeverScrollableScrollPhysics(),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth < 1000 ? 30 : 85,
                  vertical: constraints.maxWidth < 1000 ? 10 : 85),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    getAsset(
                        'logoDrug.png', MediaQuery.of(context).size.height / 7),
                    SizedBox(height: medPadding),
                    Text(
                      'Inicia sesión',
                      style:
                          TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: smallPadding),
                    Text(
                      'Ingresa como administrador',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w300),
                    ),
                    SizedBox(height: medPadding),
                    _formLogin(),
                    SizedBox(height: medPadding),
                    Text(
                      '¿Olvidaste tu contraseña?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey),
                    ),
                    SizedBox(height: smallPadding * 1.25),
                    InkWell(
                      onTap: () =>
                          launchURL('https://app.drugsiteonline.com/login'),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: '¿No eres administrador?, ',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey),
                          children: <TextSpan>[
                            TextSpan(
                                text: 'Entra aquí',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor)),
                          ],
                        ),
                      ),
                    ),
                    constraints.maxWidth > 700
                        ? Container()
                        : SizedBox(height: medPadding),
                    constraints.maxWidth > 700
                        ? Container()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                flex: 3,
                                child: SimpleButtom(
                                  gcolor: gradientWhite,
                                  mainText: 'Aviso de privacidad',
                                  textWhite: false,
                                  pressed: () {},
                                ),
                              ),
                              Flexible(
                                  flex: 1, child: SizedBox(width: medPadding)),
                              Flexible(
                                flex: 3,
                                child: SimpleButtom(
                                  gcolor: gradientBlueLight,
                                  mainText: 'Condiciones de uso',
                                  textWhite: true,
                                  pressed: () {},
                                ),
                              ),
                            ],
                          ),
                  ]),
            )
          ],
        ));
  }

  _formLogin() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // EntradaTextoTest(
          //   requerido: false,
          //   estilo: inputPrimarystyle(
          //       context, Icons.lock_outline, 'Contraseña', null),
          //   tipoEntrada: TextInputType.name,
          //   textCapitalization: TextCapitalization.none,
          //   action: TextInputAction.done,
          //   tipo: 'texto',
          //   onChanged: (value) {
          //     setState(() {
          //       password = value;
          //     });
          //   },
          // ),
          EntradaTextoTest(
            longMaxima: 50,
            estilo: inputPrimarystyle(
                context, Icons.person_outline, 'Correo', null),
            tipoEntrada: TextInputType.emailAddress,
            textCapitalization: TextCapitalization.none,
            tipo: 'correo',
            onChanged: (value) {
              setState(() {
                correo = value;
              });
            },
          ),
          EntradaTextoTest(
            longMinima: 8,
            longMaxima: 50,
            estilo: inputPrimarystyle(
                context, Icons.lock_outline, 'Contraseña', null),
            tipoEntrada: TextInputType.visiblePassword,
            textCapitalization: TextCapitalization.none,
            action: TextInputAction.done,
            tipo: 'password',
            onChanged: (value) {
              setState(() {
                password = value;
              });
            },
          ),
          SizedBox(height: medPadding),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: medPadding * 2),
            child: BotonRestTest(
                primerAction: () {
                  if (formKey.currentState.validate()) {
                    formKey.currentState.save();
                  }
                },
                url: '${urlApi}login',
                method: 'post',
                formkey: formKey,
                arrayData: {
                  'mail': '$correo',
                  'password': '$password',
                  'type': 'admin'
                },
                // action: () => Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => HomeClient())),
                action: (value) {
                  var jsonResp = jsonDecode(value['response']);
                  saveUserToken(jsonResp[1]['token']).then((value) {
                    loginFuntion();
                  });
                },
                contenido: Text(
                  'Iniciar sesión',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                errorStyle: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.w600,
                ),
                estilo: estiloBotonPrimary),
          ),
        ],
      ),
    );
  }

  _infoContainer(constraints) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: constraints.maxWidth < 700 ? 30 : 55.0,
          vertical: constraints.maxWidth < 700
              ? 30
              : MediaQuery.of(context).size.width / 8),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                text: 'Somos ',
                style: TextStyle(
                    fontSize: constraints.maxWidth < 700 ? 22 : 47,
                    fontWeight: FontWeight.w400,
                    color: Colors.white),
                children: <TextSpan>[
                  TextSpan(
                      text: 'Drug.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ),
          ),
          Flexible(
            child: Text('Sí, medicina on demand.',
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: constraints.maxWidth < 700 ? 22 : 47,
                    fontWeight: FontWeight.w400,
                    color: Colors.white)),
          ),
          constraints.maxWidth < 700
              ? Container()
              : Flexible(
                  child: Text('Somos una empresa comprometida contigo.',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: constraints.maxWidth < 700 ? 17 : 32,
                          fontWeight: FontWeight.w400,
                          color: Colors.white)),
                ),
          SizedBox(height: medPadding),
          constraints.maxWidth < 700
              ? Container()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 2,
                      child: SimpleButtom(
                        gcolor: gradientWhite,
                        mainText: 'Aviso de privacidad',
                        textWhite: false,
                        pressed: () {},
                      ),
                    ),
                    Flexible(flex: 2, child: SizedBox(width: medPadding)),
                    Flexible(
                      flex: 2,
                      child: SimpleButtom(
                        gcolor: gradientBlueLight,
                        mainText: 'Condiciones de uso',
                        textWhite: true,
                        pressed: () {},
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  loginFuntion() {
    RestFun rest = RestFun();
    rest
        .restService(
            '', '${urlApi}perfil/usuario', sharedPrefs.clientToken, 'get')
        .then((value) {
      print(value);
      if (value['status'] == 'server_true') {
        var jsonUser = jsonDecode(value['response']);
        userModel = UserModel.fromJson(jsonUser[1]);
        saveUserModel(userModel).then((value) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/farmacias', (route) => false);
        });
      }
    });
    // get userData from API and then
    // userModel = UserModel.fromJson(jsonDecode(dummyUser));
  }
}
