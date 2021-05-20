import 'dart:convert';
import 'dart:io';

import 'package:drugadmin/model/banner_model.dart';
import 'package:drugadmin/service/restFunction.dart';
import 'package:drugadmin/service/sharedPref.dart';
import 'package:drugadmin/utils/globals.dart';
import 'package:drugadmin/utils/theme.dart';
import 'package:drugadmin/widget/drawerVendedor_widget.dart';
import 'package:drugadmin/widget/testRest.dart';
import 'package:drugadmin/widget/textfieldTest_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jiffy/jiffy.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class BannerDetalles extends StatefulWidget {
  static const routeName = '/detalles-banner';

  final dynamic jsonData;
  BannerDetalles({Key key, @required this.jsonData}) : super(key: key);

  @override
  _TabAceptadaState createState() => _TabAceptadaState();
}

class _TabAceptadaState extends State<BannerDetalles> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  RestFun rest = RestFun();

  BannerModel bannerModel = BannerModel();

  var jsonDetalles;

  String date;
  String errorStr;
  bool load = true;
  bool error = false;

  var imagePathDesktop;
  var imagePathMobile;

  @override
  void initState() {
    super.initState();
    bannerModel = BannerModel.fromJson(widget.jsonData.jsonData);
    sharedPrefs.init();
    Jiffy.locale('es');
    getDetalles();
  }

  getDetalles() async {
    setState(() {
      load = true;
    });
    var arrayData = {
      'id_de_banner': bannerModel.idDeBanner,
    };
    await rest
        .restService(arrayData, '${urlApi}detalles/banner',
            sharedPrefs.clientToken, 'post')
        .then((value) {
      if (value['status'] == 'server_true') {
        var ordenResp = value['response'];
        ordenResp = jsonDecode(ordenResp)[1];
        setState(() {
          // jsonDetalles = jsonDecode(value['response'])[1]['documentos'];
          // bannerModel =
          //     FarmaciaModel.fromJson(jsonDecode(value['response'])[1]);
          load = false;
        });
      } else {
        setState(() {
          load = false;
          error = true;
          errorStr = value['message'];
        });
      }
    });
  }

  // cambiarStatus(id, status) {
  //   var arrayData = {"archivo_id": id, "estatus": status};
  //   rest
  //       .restService(arrayData, '${urlApi}detalles/farmacia',
  //           sharedPrefs.clientToken, 'post')
  //       .then((value) {
  //     load = true;
  //     getDetalles();
  //   });
  // }

  // cambiarStatusTienda(id, status) {
  //   var arrayData = {"farmacia_id": id, "estatus": status};
  //   rest
  //       .restService(arrayData, '${urlApi}farmacia/actualizar-estatus',
  //           sharedPrefs.clientToken, 'post')
  //       .then((value) {
  //     print(value);
  //     load = true;
  //     getDetalles();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return ResponsiveApp(
        drawerMenu: false,
        screenWidht: MediaQuery.of(context).size.width,
        body: load
            ? bodyLoad(context)
            : error
                ? errorWidget(errorStr, context)
                : ListView(children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width > 1100
                              ? size.width / 3
                              : medPadding * .5,
                          vertical: medPadding * 1.5),
                      color: bgGrey,
                      width: size.width,
                      child: bodyBanner(),
                    ),
                  ]),
        title: "Detalles de banner");
  }

  Widget bodyBanner() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Datos del banner',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        SizedBox(
          height: smallPadding,
        ),
        Container(child: miBanner(context)),
        SizedBox(
          height: medPadding,
        ),
        BotonRestTest(
            token: sharedPrefs.clientToken,
            url: '${urlApi}eliminar/banner',
            formkey: formKey,
            arrayData: {"id_de_banner": bannerModel.idDeBanner},
            method: 'post',
            action: (value) => Navigator.popUntil(context, (route) => false),
            contenido: Text(
              'Eliminar banner',
              style: TextStyle(
                  fontSize: 20,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ))
      ],
    );
  }

  miBanner(context) {
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
            Row(
              children: [
                Expanded(
                    child: Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        await pickImage('desktop');
                        setState(() {});
                      },
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                            color: bgGrey,
                            image: DecorationImage(
                              image: bannerModel.imagenEscritorio == null
                                  ? AssetImage('images/logoDrug.png')
                                  : imagePathDesktop != null
                                      ? !kIsWeb
                                          ? FileImage(
                                              File(imagePathDesktop.path))
                                          : NetworkImage(imagePathDesktop.path)
                                      : NetworkImage(
                                          bannerModel.imagenEscritorio),
                            )),
                      ),
                    ),
                    Text(
                      'Selecciona un banner para web (300x300 px)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                )),
                SizedBox(
                  width: smallPadding,
                ),
                Expanded(
                    child: Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        await pickImage('mobile');
                        setState(() {});
                      },
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                            color: bgGrey,
                            image: DecorationImage(
                              image: imagePathMobile == null
                                  ? AssetImage('images/logoDrug.png')
                                  : imagePathMobile != null
                                      ? !kIsWeb
                                          ? FileImage(
                                              File(imagePathMobile.path))
                                          : NetworkImage(imagePathMobile.path)
                                      : NetworkImage(bannerModel.imagenMovil),
                            )),
                      ),
                    ),
                    Text(
                      'Selecciona un banner para móvil (300x300 px)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                )),
              ],
            ),
            SizedBox(height: smallPadding),
            formNuevaBanner(),
          ],
        ));
  }

  pickImage(type) async {
    final _picker = ImagePicker();
    PickedFile image = await _picker.getImage(source: ImageSource.gallery);
    // final imgBase64Str = await kIsWeb
    //     ? networkImageToBase64(image.path)
    //     : mobileb64(File(image.path));
    var imgBase64Str;
    if (kIsWeb) {
      http.Response response = await http.get(Uri.parse(image.path));
      final bytes = response?.bodyBytes;
      imgBase64Str = base64Encode(bytes);
    } else {
      List<int> imageBytes = await File(image.path).readAsBytes();
      imgBase64Str = base64Encode(imageBytes);
    }
    setState(() {
      if (type == 'desktop') {
        imagePathDesktop = image;
        bannerModel.imagenEscritorio = imgBase64Str.toString();
      } else {
        imagePathMobile = image;
        bannerModel.imagenMovil = imgBase64Str.toString();
      }
    });
  }

  formNuevaBanner() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // TODO: boton para fecha
          // EntradaTextoTest(
          //   habilitado: false,
          //   valorInicial: bannerModel.fechaDeExposicion.toString(),
          //   estilo: inputPrimarystyle(
          //       context, Icons.store_outlined, 'Nombre comercial', null),
          //   tipoEntrada: TextInputType.emailAddress,
          //   textCapitalization: TextCapitalization.words,
          //   tipo: 'typeValidator',
          // ),
          EntradaTextoTest(
            formkey: formKey,
            valorInicial: bannerModel.titulo,
            estilo:
                inputPrimarystyle(context, Icons.star_outline, 'Título', null),
            tipoEntrada: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            tipo: 'typeValidator',
            onSaved: (value) => setState(() {
              bannerModel.titulo = value;
            }),
          ),
          EntradaTextoTest(
            formkey: formKey,
            valorInicial: bannerModel.descripcion,
            estilo: inputPrimarystyle(
                context, Icons.star_outline, 'Descripción', null),
            tipoEntrada: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            tipo: 'typeValidator',
            onSaved: (value) => setState(() {
              bannerModel.descripcion = value;
            }),
          ),
          EntradaTextoTest(
              formkey: formKey,
              valorInicial: bannerModel.posicion.toString(),
              estilo: inputPrimarystyle(
                  context, Icons.keyboard_arrow_up, 'Posición', null),
              tipoEntrada: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              tipo: 'numero',
              onSaved: (value) => setState(() {
                    bannerModel.posicion = value;
                  })),
          EntradaTextoTest(
            formkey: formKey,
            valorInicial: bannerModel.linkExterno,
            estilo: inputPrimarystyle(
                context, Icons.attach_file_outlined, 'Link externo', null),
            tipoEntrada: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            tipo: 'typeValidator',
            onSaved: (value) => setState(() {
              bannerModel.linkExterno = value;
            }),
          ),
          EntradaTextoTest(
            formkey: formKey,
            valorInicial: bannerModel.idDeFarmacia,
            estilo: inputPrimarystyle(
                context, Icons.store_outlined, 'Farmacia', null),
            tipoEntrada: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            tipo: 'typeValidator',
            onSaved: (value) => setState(() {
              bannerModel.idDeFarmacia = value;
            }),
          ),
          SizedBox(height: smallPadding * 2),
          BotonRestTest(
            restriccion: true,
            restriccionStr: 'Falta información',
            habilitado: bannerModel.imagenMovil == null
                ? false
                : bannerModel.imagenEscritorio == null
                    ? false
                    : true,
            token: sharedPrefs.clientToken,
            url: '${urlApi}actualizar/banner',
            formkey: formKey,
            arrayData: {
              "id_de_banner": bannerModel.idDeBanner,
              "titulo": bannerModel.titulo,
              "descripcion": bannerModel.descripcion,
              "imagen_escritorio": bannerModel.imagenEscritorio,
              "imagen_movil": bannerModel.imagenMovil,
              "fecha_de_exposicion": "2021-06-15",
              "posicion": int.parse(bannerModel.posicion),
              "link_externo": bannerModel.linkExterno,
              "id_de_farmacia": bannerModel.idDeFarmacia,
            },
            method: 'post',
            action: (value) => print(value),
            showSuccess: true,
            contenido: Padding(
              padding: EdgeInsets.symmetric(horizontal: smallPadding),
              child: Text(
                'Guardar',
                textAlign: TextAlign.center,
                overflow: TextOverflow.fade,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            estilo: estiloBotonPrimary,
          )
        ],
      ),
    );
  }
}
