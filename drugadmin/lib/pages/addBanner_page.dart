import 'dart:convert';
import 'dart:io';

import 'package:codigojaguar/codigojaguar.dart';
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
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;

class CrearBanner extends StatefulWidget {
  @override
  _CrearBannerState createState() => _CrearBannerState();
}

class _CrearBannerState extends State<CrearBanner> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  RestFun rest = RestFun();

  BannerModel bannerModel = BannerModel();

  var jsonDetalles;

  String date;
  String errorStr;
  bool load = false;
  bool error = false;

  var imagePathDesktop;
  var imagePathMobile;

  bool correcto = false;

  String correctoStr = 'Banner agregado correctamente';

  String fechaBanner;

  @override
  void initState() {
    super.initState();
    sharedPrefs.init();
    bannerModel.posicion = '0';
    Jiffy.locale('es');
  }

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
        title: "Crear banner");
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
        // SizedBox(
        //   height: medPadding,
        // ),
        // BotonRestTest(
        //     token: sharedPrefs.clientToken,
        //     url: '${urlApi}eliminar/banner',
        //     formkey: formKey,
        //     arrayData: {"id_de_banner": bannerModel.idDeBanner},
        //     method: 'post',
        //     action: (value) => Navigator.popUntil(context, (route) => false),
        //     contenido: Text(
        //       'Eliminar banner',
        //       style: TextStyle(
        //           fontSize: 20,
        //           decoration: TextDecoration.underline,
        //           fontWeight: FontWeight.bold,
        //           color: Colors.blue),
        //     ))
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
                      onTap: correcto
                          ? () {}
                          : () async {
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
                    correcto
                        ? Container()
                        : Text(
                            'Selecciona un banner para web (1000x300 px)',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: Colors.black54, fontSize: 13),
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
                      onTap: correcto
                          ? () {}
                          : () async {
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
                    correcto
                        ? Container()
                        : Text(
                            'Selecciona un banner para móvil (600x200 px)',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: Colors.black54, fontSize: 13),
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
    int maxSize = 900;
    int quality = 70;

    try {
      final _picker = ImagePicker();
      PickedFile image = await _picker.getImage(
          source: ImageSource.gallery,
          imageQuality: quality,
          maxWidth: maxSize.toDouble(),
          maxHeight: maxSize.toDouble());
      showLoadingDialog(context, "Procesando imagen", "Espera un momento...");
      Future.delayed(Duration(milliseconds: 500), () {
        preprocessImage(image, context, maxSize, quality, maxMegabytes: 2)
            .then((base64) {
          if (base64 != "") {
            setState(() {
              if (type == 'desktop') {
                imagePathDesktop = image;
                bannerModel.imagenEscritorio = base64.toString();
              } else {
                imagePathMobile = image;
                bannerModel.imagenMovil = base64.toString();
              }
            });
          }
        });
      });
    } catch (e) {
      showErrorDialog(context, "Error para obtener la imagen", e.toString());
    }
  }

  formNuevaBanner() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 15),
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(5)),
            child: InkWell(
                onTap: () {
                  !correcto ? _selectDate(context) : print('ok');
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Fecha de exibición",
                      style: TextStyle(color: Colors.black54, fontSize: 15),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      fechaBanner == null
                          ? 'Selecciona una fecha'
                          : DateFormat('yyyy-MM')
                              .format(DateTime.parse(fechaBanner)),
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 15),
                    )
                  ],
                )),
          ),
          EntradaTexto(
            habilitado: !correcto,
            longMinima: 1,
            longMaxima: 100,
            estilo:
                inputPrimarystyle(context, Icons.star_outline, 'Título', null),
            tipoEntrada: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            onChanged: (value) {
              setState(() {
                bannerModel.titulo = value;
              });
            },
          ),
          EntradaTexto(
            habilitado: !correcto,
            longMinima: 1,
            longMaxima: 500,
            lineasMax: 2,
            estilo: inputPrimarystyle(
                context, Icons.star_outline, 'Descripción', null),
            tipoEntrada: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            onChanged: (value) {
              setState(() {
                bannerModel.descripcion = value;
              });
            },
          ),
          EntradaTexto(
            habilitado: !correcto,
            longMinima: 1,
            longMaxima: 50,
            estilo: inputPrimarystyle(
                context, Icons.star_outline, 'Posición', null),
            tipo: 'numeroINT',
            tipoEntrada: TextInputType.visiblePassword,
            textCapitalization: TextCapitalization.words,
            onChanged: (value) {
              setState(() {
                bannerModel.posicion = value;
              });
            },
          ),
          /* EntradaTexto(
            habilitado: !correcto,
            longMinima: 1,
            longMaxima: 100,
            estilo: inputPrimarystyle(
                context, Icons.star_outline, 'Link externo', null),
            tipoEntrada: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            onChanged: (value) {
              setState(() {
                bannerModel.linkExterno = value;
              });
            },
          ), */
          SizedBox(height: smallPadding * 2),
          correcto
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 17,
                      color: Colors.green.withOpacity(0.8),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Flexible(
                      child: Text(
                        correctoStr,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                )
              : BotonRestTest(
                  primerAction: () {
                    if (formKey.currentState.validate()) {
                      formKey.currentState.save();
                    }
                  },
                  // restriccion: true,
                  // restriccionStr: 'Falta información',
                  habilitado: bannerModel.imagenMovil == null
                      ? false
                      : bannerModel.imagenEscritorio == null
                          ? false
                          : true,
                  token: sharedPrefs.clientToken,
                  url: '${urlApi}crear/banner',
                  formkey: formKey,
                  arrayData: {
                    "titulo": bannerModel.titulo,
                    "descripcion": bannerModel.descripcion,
                    "imagen_escritorio": bannerModel.imagenEscritorio,
                    "imagen_movil": bannerModel.imagenMovil,
                    "fecha_de_exposicion": fechaBanner,
                    "posicion": bannerModel.posicion == '' ||
                            bannerModel.posicion == null ||
                            bannerModel.posicion == ' '
                        ? null
                        : bannerModel.posicion == '0'
                            ? 1
                            : int.parse(bannerModel.posicion),
                    /* "link_externo": bannerModel.linkExterno, */
                    "id_de_farmacia": bannerModel.idDeFarmacia,
                  },
                  method: 'post',
                  action: (value) {
                    setState(() {
                      correcto = true;
                    });
                  },
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
                  estilo: bannerModel.imagenMovil == null
                      ? estiloBotonDisabled
                      : bannerModel.imagenEscritorio == null
                          ? estiloBotonDisabled
                          : estiloBotonPrimary,
                )
        ],
      ),
    );
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showMonthPicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(DateTime.now().year, DateTime.now().month),
        lastDate: DateTime(DateTime.now().year + 2));
    if (picked != null) {
      setState(() {
        fechaBanner = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
}
