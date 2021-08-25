import 'dart:convert';
import 'dart:io';

import 'package:codigojaguar/codigojaguar.dart';
import 'package:drugadmin/model/user_model.dart';
import 'package:drugadmin/service/restFunction.dart';
import 'package:drugadmin/service/sharedPref.dart';
import 'package:drugadmin/utils/globals.dart';
import 'package:drugadmin/utils/theme.dart';
import 'package:drugadmin/widget/drawerVendedor_widget.dart';
import 'package:drugadmin/widget/testRest.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart' show kIsWeb;

class MiCuentaPage extends StatefulWidget {
  @override
  _MiCuentaPageState createState() => _MiCuentaPageState();
}

class _MiCuentaPageState extends State<MiCuentaPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String name;
  String first_lastname;
  String second_lastname;
  String mail;
  String phone;
  String password;
  UserModel userModel = UserModel();
  var mediaData;
  Image pickedImage;
  var imagePath;
  String base64Image;

  bool loadmiInfo = true;

  @override
  void initState() {
    super.initState();

    sharedPrefs.init().then((value) {
      getUserData();
    });
  }

  getUserData() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();

    // var jsonUser = jsonDecode(prefs.getString('partner_data'));

    setState(() {
      userModel = UserModel.fromJson(jsonDecode(sharedPrefs.clientData));
      loadmiInfo = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return ResponsiveApp(
        drawerMenu: true,
        screenWidht: MediaQuery.of(context).size.width,
        body: ListView(children: [
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: size.width > 700 ? size.width / 3 : medPadding * .5,
                vertical: medPadding * 1.5),
            color: bgGrey,
            width: size.width,
            child: tabMiCuenta(),
          ),
          footer(context),
        ]),
        title: "Mi cuenta");
  }

  tabMiCuenta() {
    return loadmiInfo
        ? bodyLoad(context)
        : Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Mis datos',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 20),
              ),
              SizedBox(
                height: smallPadding,
              ),
              Text(
                'Datos personales',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 18),
              ),
              SizedBox(
                height: smallPadding,
              ),
              Container(child: miCuenta(context)),
              SizedBox(height: medPadding / 2),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: medPadding * 2),
                child: BotonSimple(
                  action: () =>
                      Navigator.pushNamed(context, '/cambiar-contraseña'),
                  contenido: Text(
                    'Cambiar contraseña',
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  estilo: estiloBotonSecundary,
                ),
              )
            ],
          );
  }

  miCuenta(context) {
    var size = MediaQuery.of(context).size;
    return Container(
        padding: EdgeInsets.all(smallPadding * 2),
        width: size.width,
        // height: size.height,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 5.0, // soften the shadow
              spreadRadius: 1.0, //extend the shadow
              offset: Offset(
                0.0, // Move to right 10  horizontally
                3.0, // Move to bottom 10 Vertically
              ),
            )
          ],
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                padding: EdgeInsets.all(3),
                height: 130,
                width: 130,
                decoration: BoxDecoration(
                    gradient: gradientDrug,
                    borderRadius: BorderRadius.circular(100)),
                child: Hero(
                  tag: "profile_picture",
                  child: InkWell(
                    onTap: () async {
                      await pickImage();
                      setState(() {});
                    },
                    child: CircleAvatar(
                      backgroundImage: imagePath != null
                          ? !kIsWeb
                              ? FileImage(File(imagePath.path))
                              : NetworkImage(imagePath.path)
                          : NetworkImage(userModel.imgUrl),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: smallPadding),
            Text(
              'Toca para cambiar tu foto de perfil',
              style: TextStyle(color: Colors.black54),
            ),
            SizedBox(height: smallPadding),
            formCuenta(),
          ],
        ));
  }

  formCuenta() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          EntradaTexto(
            valorInicial: userModel.name,
            estilo: inputPrimarystyle(
                context, Icons.person_outline, 'Nombre', null),
            tipoEntrada: TextInputType.emailAddress,
            textCapitalization: TextCapitalization.words,
            tipo: 'nombre',
            onChanged: (value) {
              setState(() {
                name = value;
              });
            },
          ),
          EntradaTexto(
            valorInicial: userModel.first_lastname,
            estilo: inputPrimarystyle(
                context, Icons.person_outline, 'Primer apellido', null),
            tipoEntrada: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            tipo: 'apellido',
            onChanged: (value) {
              setState(() {
                first_lastname = value;
              });
            },
          ),
          EntradaTexto(
            requerido: false,
            valorInicial: userModel.second_lastname,
            estilo: inputPrimarystyle(context, Icons.person_outline,
                'Segundo apellido (opcional)', null),
            tipoEntrada: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            tipo: 'apellido',
            onChanged: (value) {
              setState(() {
                second_lastname = value;
              });
            },
          ),
          EntradaTexto(
            valorInicial: userModel.mail.toString(),
            estilo:
                inputPrimarystyle(context, Icons.mail_outline, 'Correo', null),
            tipoEntrada: TextInputType.phone,
            textCapitalization: TextCapitalization.none,
            tipo: 'correo',
            onChanged: (value) {
              setState(() {
                mail = value.toString();
              });
            },
          ),
          EntradaTexto(
            valorInicial: userModel.phone.toString(),
            estilo: inputPrimarystyle(
                context, Icons.phone_outlined, 'Teléfono', null),
            tipoEntrada: TextInputType.phone,
            textCapitalization: TextCapitalization.none,
            tipo: 'telefono',
            onChanged: (value) {
              setState(() {
                phone = value.toString();
              });
            },
          ),
          SizedBox(height: medPadding),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: medPadding * 2),
            child: BotonRestTest(
                showSuccess: true,
                token: sharedPrefs.clientToken,
                url: '$apiUrl/actualizar/usuario',
                method: 'post',
                formkey: formKey,
                arrayData: {
                  "user_id": userModel.user_id,
                  "name": name,
                  "first_lastname": first_lastname,
                  "second_lastname": second_lastname,
                  "password": "123456789",
                  "phone": phone,
                  "base64": base64Image == null ? null : base64Image
                },
                contenido: Text(
                  'Actualizar',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                action: (value) {
                  //print(value);
                  RestFun rest = RestFun();
                  rest
                      .restService('', '${urlApi}perfil/usuario',
                          sharedPrefs.clientToken, 'get')
                      .then((value) {
                    if (value['status'] == 'server_true') {
                      var jsonUser = jsonDecode(value['response']);
                      userModel = UserModel.fromJson(jsonUser[1]);
                      setState(() {
                        saveUserModel(userModel);
                      });
                    }
                  });
                },
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

  pickImage() async {
    int maxSize = 500;
    int quality = 60;

    try {
      final _picker = ImagePicker();
      PickedFile image = await _picker.getImage(
          source: ImageSource.gallery,
          imageQuality: quality,
          maxWidth: maxSize.toDouble(),
          maxHeight: maxSize.toDouble());
      showLoadingDialog(context, "Procesando imagen", "Espera un momento...");
      Future.delayed(Duration(milliseconds: 500), () {
        preprocessImage(image, context, maxSize, quality).then((base64) {
          if (base64 != "") {
            setState(() {
              imagePath = image;
              base64Image = base64.toString();
            });
          }
        });
      });
    } catch (e) {
      showErrorDialog(context, "Error para obtener la imagen", e.toString());
    }
  }

  /* pickImage() async {
    final _picker = ImagePicker();
    PickedFile image = await _picker.getImage(source: ImageSource.gallery);
    // final imgBase64Str = await kIsWeb
    //     ? networkImageToBase64(image.path)
    //     : mobileb64(File(image.path));
    var imgBase64Str;
    if (kIsWeb) {
      http.Response response = await http.get(Uri.parse(image.path));
      final bytes = response?.bodyBytes;
      //imgBase64Str = base64Encode(bytes);
      int maxSize = 500;
      img.Image chosenImage = img.decodeImage(bytes);
      img.Image thumbnail = isLandscape(chosenImage)
          ? img.copyResize(chosenImage, width: maxSize)
          : img.copyResize(chosenImage, height: maxSize);
      imgBase64Str = base64Encode(img.encodeJpg(thumbnail, quality: 60));
    } else {
      List<int> imageBytes = await File(image.path).readAsBytes();
      imgBase64Str = base64Encode(imageBytes);
    }
    setState(() {
      imagePath = image;
      base64Image = imgBase64Str.toString();
    });
  } */
}
