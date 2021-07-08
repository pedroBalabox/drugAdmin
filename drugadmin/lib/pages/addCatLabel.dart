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

class CrearLabelCat extends StatefulWidget {
  final String type;

  CrearLabelCat(this.type);

  @override
  _CrearLabelCatState createState() => _CrearLabelCatState();
}

class _CrearLabelCatState extends State<CrearLabelCat> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  RestFun rest = RestFun();

  var jsonDetalles;

  String nombre;
  String descripcion;
  String imgBase64;

  String date;
  String errorStr;
  bool load = false;
  bool error = false;

  bool correcto = false;

  String correctoCatStr = 'Categoria agregada correctamente';
  String correctoLabelStr = 'Etiqueta agregada correctamente';

  var imagePath;

  @override
  void initState() {
    super.initState();
    sharedPrefs.init();
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
        title: widget.type == 'cat' ? "Crear categoria" : 'Crear etiqueta');
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
            widget.type == 'cat'
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
                                      ? AssetImage('images/logoDrug.png')
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
      imagePath = image;
      imgBase64 = imgBase64Str.toString();
    });
  }

  formNuevaBanner() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          EntradaTexto(
            habilitado: !correcto,
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
                        widget.type == 'cat'
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
                  habilitado: widget.type == 'cat'
                      ? imgBase64 == null
                          ? false
                          : true
                      : true,
                  primerAction: () {
                    if (formKey.currentState.validate()) {
                      formKey.currentState.save();
                    }
                  },
                  arrayData: {
                    "nombre": nombre,
                    "descripcion": descripcion,
                    "imagen": imgBase64,
                  },
                  showSuccess: true,
                  url: widget.type == 'cat'
                      ? '$apiUrl/crear/categoria'
                      : '$apiUrl/crear/etiqueta',
                  method: 'post',
                  formkey: formKey,
                  token: sharedPrefs.clientToken,
                  contenido: Text(
                    'Agregar',
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
                  estilo: widget.type == 'cat'
                      ? imgBase64 == null
                          ? estiloBotonDisabled
                          : nombre == null
                              ? estiloBotonDisabled
                              : descripcion == null
                                  ? estiloBotonDisabled
                                  : estiloBotonPrimary
                      : estiloBotonPrimary),
        ],
      ),
    );
  }
}


