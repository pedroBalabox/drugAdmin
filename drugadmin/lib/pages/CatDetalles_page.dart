import 'dart:convert';
import 'dart:io';

import 'package:codigojaguar/codigojaguar.dart';
import 'package:drugadmin/service/restFunction.dart';
import 'package:drugadmin/service/sharedPref.dart';
import 'package:drugadmin/utils/globals.dart';
import 'package:drugadmin/utils/theme.dart';
import 'package:drugadmin/widget/drawerVendedor_widget.dart';
import 'package:drugadmin/widget/testRest.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jiffy/jiffy.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class DetallesCat extends StatefulWidget {
  static const routeName = '/detalles';

  final dynamic jsonData;

  DetallesCat(this.jsonData);

  @override
  _DetallesCatState createState() => _DetallesCatState();
}

class _DetallesCatState extends State<DetallesCat> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  RestFun rest = RestFun();

  var jsonDetalles;

  String nombre;
  String descripcion;
  String imagen;
  String imgBase64;

  String date;
  String errorStr;
  bool load = false;
  bool error = false;

  bool correcto = false;

  String correctoCatStr = 'Categoria actualizada correctamente';
  String correctoLabelStr = 'Etiqueta actualizada correctamente';

  var imagePath;

  @override
  void initState() {
    super.initState();
    sharedPrefs.init();
    Jiffy.locale('es');
    nombre = widget.jsonData.jsonData['data']['nombre'];
    descripcion = widget.jsonData.jsonData['data']['descripcion'];
    imagen = widget.jsonData.jsonData['data']['imagen'];
    // nombre = widget.jsonData.jsonData['type']
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
        title: "${widget.jsonData.jsonData['data']['nombre']}");
  }

  Widget bodyBanner() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Text(
        //   'Datos',
        //   style: TextStyle(
        //       color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
        // ),
        // SizedBox(
        //   height: smallPadding,
        // ),
        Container(child: miBanner(context)),
        SizedBox(
          height: medPadding,
        ),
        BotonRestTest(
            token: sharedPrefs.clientToken,
            url: widget.jsonData.jsonData['type'] == 'cat'
                ? '$apiUrl/eliminar/categoria'
                : '$apiUrl/eliminar/etiqueta',
            arrayData: widget.jsonData.jsonData['type'] == 'cat'
                ? {
                    "categoria_id": widget.jsonData.jsonData['data']
                        ['categoria_id']
                  }
                : {
                    "id_de_etiqueta": widget.jsonData.jsonData['data']
                        ['id_de_etiqueta']
                  },
            method: 'post',
            action: (value) => Navigator.pop(context),
            contenido: Text(
              'Eliminar',
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
            widget.jsonData.jsonData['type'] == 'cat'
                ? Column(
                    children: [
                      InkWell(
                        onTap: correcto
                            ? () {}
                            : () async {
                                await pickImage();
                                setState(() {});
                              },
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                              color: bgGrey,
                              image: DecorationImage(
                                  image: imagePath == null
                                      ? imagen == null
                                          ? AssetImage('images/logoDrug.png')
                                          : NetworkImage(imagen)
                                      : imagePath != null
                                          ? !kIsWeb
                                              ? FileImage(File(imagePath.path))
                                              : NetworkImage(imagePath.path)
                                          : AssetImage('images/logoDrug.png'))),
                        ),
                      ),
                      correcto
                          ? Container()
                          : Text(
                              'Selecciona una imagen.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 13),
                            ),
                    ],
                  )
                : Container(),
            SizedBox(height: smallPadding),
            formNuevaBanner(),
          ],
        ));
  }

  pickImage() async {
    int maxSize = 700;
    int quality = 100;

    try {
      final _picker = ImagePicker();
      PickedFile image = await _picker.getImage(
          source: ImageSource.gallery,
          imageQuality: quality,
          maxWidth: maxSize.toDouble(),
          maxHeight: maxSize.toDouble());
      showLoadingDialog(context, "Procesando imagen", "Espera un momento...");
      Future.delayed(Duration(milliseconds: 500), () {
        preprocessImage(image, context, maxSize, quality,
                maxMegabytes: 1, skipImageProcessing: true)
            .then((base64) {
          if (base64 != "") {
            setState(() {
              imagePath = image;
              imgBase64 = base64.toString();
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
          EntradaTexto(
            habilitado: !correcto,
            valorInicial: nombre,
            longMinima: 1,
            longMaxima: 100,
            estilo:
                inputPrimarystyle(context, Icons.star_outline, 'Nombre', null),
            tipoEntrada: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            onChanged: (value) {
              setState(() {
                nombre = value;
              });
            },
          ),
          EntradaTexto(
            habilitado: !correcto,
            lineasMax: 2,
            longMinima: 1,
            longMaxima: 500,
            valorInicial: descripcion,
            estilo: inputPrimarystyle(
                context, Icons.info_outline, 'Descripción', null),
            tipoEntrada: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            onChanged: (value) {
              setState(() {
                descripcion = value;
              });
            },
          ),
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
                        widget.jsonData.jsonData['type'] == 'cat'
                            ? correctoCatStr
                            : correctoLabelStr,
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
                  arrayData: widget.jsonData.jsonData['type'] == 'cat'
                      ? {
                          "categoria_id": widget.jsonData.jsonData['data']
                              ['categoria_id'],
                          "nombre": nombre,
                          "descripcion": descripcion,
                          "imagen": imgBase64,
                        }
                      : {
                          "id_de_etiqueta": widget.jsonData.jsonData['data']
                              ['id_de_etiqueta'],
                          "nombre": nombre,
                          "descripcion": descripcion,
                          "imagen": imgBase64,
                        },
                  showSuccess: true,
                  url: widget.jsonData.jsonData['type'] == 'cat'
                      ? '$apiUrl/actualizar/categoria'
                      : '$apiUrl/actualizar/etiqueta',
                  method: 'post',
                  formkey: formKey,
                  token: sharedPrefs.clientToken,
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
                    setState(() {
                      correcto = true;
                      // _catalogBloc.sendEvent.add(RemoveAllCatalogItemEvent());
                      // // compraRealizada = true;
                      // Navigator.pushNamed(context, '/miCuenta');
                    });
                  },
                  errorStyle: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.w600,
                  ),
                  estilo: nombre == null
                      ? estiloBotonDisabled
                      : descripcion == null
                          ? estiloBotonDisabled
                          : estiloBotonPrimary),
        ],
      ),
    );
  }
}
