import 'dart:convert';

import 'package:codigojaguar/codigojaguar.dart';
import 'package:drugadmin/service/restFunction.dart';
import 'package:drugadmin/service/sharedPref.dart';
import 'package:drugadmin/utils/globals.dart';
import 'package:drugadmin/utils/theme.dart';
import 'package:drugadmin/widget/drawerVendedor_widget.dart';
import 'package:drugadmin/widget/testRest.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AddProducts extends StatefulWidget {
  static const routeName = '/agregar-productos';

  final dynamic jsonData;

  AddProducts({Key key, this.jsonData}) : super(key: key);
  @override
  _AddProductsState createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var jsonTienda;

  var docBase64;
  var docName;

  RestFun rest = RestFun();

  String errorStr;
  bool load = false;
  bool error = false;

  String successString;

  bool success = false;

  @override
  void initState() {
    super.initState();
    // print(widget.jsonData.jsonData.toString());
    sharedPrefs.init().then((value) {
      // getTienda();
    });
  }

  // getTienda() {
  //   rest
  //       .restService('', '${urlApi}obtener/mi-farmacia',
  //           sharedPrefs.clientToken, 'get')
  //       .then((value) {
  //     if (value['status'] == 'server_true') {
  //       setState(() {
  //         jsonTienda = jsonDecode(value['response']);
  //         load = false;
  //       });
  //     } else {
  //       setState(() {
  //         load = false;
  //         error = true;
  //         errorStr = value['message'];
  //       });
  //     }
  //   });
  // }

  subirDoc() async {
    try {
      FilePickerResult result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['csv'],
          allowCompression: true);

      var uri = Uri.dataFromBytes(result.files.first.bytes).toString();
      //print(result.files.single.size);
      if (result.files.single.size <= 10000000) {
        setState(() {
          docName = result.files.single.name;
          docBase64 = uri;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveApp(
        drawerMenu: false,
        screenWidht: MediaQuery.of(context).size.width,
        body: load
            ? bodyLoad(context)
            : error
                ? errorWidget(errorStr, context)
                : bodyCuenta(),
        title: "Aregar productos a ${widget.jsonData.jsonData['nombre']}");
  }

  bodyCuenta() {
    var size = MediaQuery.of(context).size;
    return ListView(children: [
      Container(
        // height: MediaQuery.of(context).size.height - 50,
        padding: EdgeInsets.symmetric(
            horizontal: size.width > 700 ? size.width / 3.5 : medPadding * .5,
            vertical: medPadding * 1.5),
        color: bgGrey,
        width: size.width,
        child: tabCargar(),
      ),
    ]);
  }

  tabCargar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(child: addProducts(context)),
      ],
    );
  }

  addProducts(context) {
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Proceso de carga de productos",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 24.0,
                  fontFamily: 'FjallaOne',
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: smallPadding * 2,
            ),
            Text(
              'Cargar porductos a ${widget.jsonData.jsonData['nombre']}:',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 15),
            ),
            SizedBox(
              height: smallPadding,
            ),
            Text(
              '1. Descarga el archivo plantilla con formato CSV.',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 15),
            ),
            Text(
              '2. Llena todos los campos por cada producto que deseas publicar.',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 15),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15),
              child: Text(
                'a. En el campo de cantidad debes de colocar la cantidad de productos que mandaras al equipo de DRUG para tener disponibles en almacenes..',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 15),
              ),
            ),
            Text(
              '3. Carga tu archivo con la informaci??n solicitada de tus productos.',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 15),
            ),
            Text(
              '4. El equipo de DRUG validar?? los productos. Te mantendremos al tanto del proceso a trav??s de correo electr??nico.',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 15),
            ),
            Text(
              '5. Una vez validados los productos se te ser?? notificado, para que procedas a mandarlos al almac??n DRUG.',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 15),
            ),
            Text(
              '6. Una vez recibidos los productos en nuestras instalaciones de almacenamientos, estos ser??n cargados al sistema por el equipo DRUG. Al terminar el proceso de carga al sistema ser??s notificado.',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 15),
            ),
            Text(
              '7. Finalmente podr??s agregar informaci??n personalizada a tu producto y habilitarlo  para que todos los usuarios de DRUG puedan comprarlo.',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 15),
            ),
            SizedBox(
              height: smallPadding * 2,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BotonSimple(
                    action: () {
                      launchURL(
                          '$baseFrontUrl/descargas/plantilla_productos_drug.csv');
                    },
                    estilo: estiloBotonPrimary,
                    contenido: Text(
                      'Descargar plantilla',
                      style: TextStyle(color: Colors.white),
                    )),
                SizedBox(
                  height: smallPadding,
                ),
                docBase64 == null
                    ? BotonSimple(
                        action: () => subirDoc(),
                        estilo: estiloBotonSecundary,
                        contenido: Text(
                          'Subir CSV',
                          style: TextStyle(color: Colors.white),
                        ))
                    : successString != null
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 15,
                                  color: Colors.green.withOpacity(0.8),
                                ),
                                SizedBox(
                                  width: 3,
                                ),
                                Flexible(
                                  child: Text(
                                    successString,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ])
                        : BotonRestTest(
                            token: sharedPrefs.clientToken,
                            url: '$apiUrl/farmacia/cargar-productos',
                            method: 'post',
                            arrayData: {
                              "farmacia_id":
                                  widget.jsonData.jsonData['farmacia_id'],
                              "lista_de_productos": docBase64
                            },
                            errorStyle: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.w600,
                            ),
                            action: (value) {
                              // print('ok---' +
                              //     jsonDecode(value['response'])
                              //         .length
                              //         .toString());
                              if (jsonDecode(value['response']).length > 2) {
                                var code =
                                    jsonDecode(value['response'])['code'];
                                if (code == 'warning') {
                                  setState(() {
                                    successString =
                                        "Hubo problema para cargar algunos productos";
                                    //  +
                                    // value['message'];
                                  });
                                }else{
                                  successString = value['message'];
                                }
                              } else {
                                setState(() {
                                  successString = value['message'];
                                });
                              }
                            },
                            estilo: estiloBotonSecundary,
                            // showSuccess: true,
                            stringCargando: 'Subiendo archivo...',
                            contenido: Text(
                              'Enviar',
                              style: TextStyle(color: Colors.white),
                            )),
                docName == null
                    ? Container()
                    : SizedBox(
                        height: smallPadding,
                      ),
                docName == null
                    ? Container()
                    : successString != null
                        ? Container()
                        : docCargado(docName)
              ],
            )
          ],
        ));
  }

  Widget docCargado(nombreDoc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle,
          size: 15,
          color: Colors.green.withOpacity(0.8),
        ),
        SizedBox(
          width: 3,
        ),
        Flexible(
          child: Text(
            nombreDoc,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(
          width: 5,
        ),
        InkWell(
          onTap: () {
            setState(() {
              docName = null;
              docBase64 = null;
            });
          },
          child: Container(
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(100)),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 10,
              )),
        )
      ],
    );
  }
}

// [{status: true, code: success, message: Los productos se cargaron exit??samente, receiver: both}, {successful_products: [[10101, SI, Paracetamol
// de 500mg, Comprimido bucodispersable: deshacer en la boca antes de ser tragado.
// Granulado efervescente: disolver en un vaso de agua, tomar cuando cese el burbujeo., Farmacias del ahorro, 90.00, 80.00, 50.00, 150, 1]]}]

// [{status: true, code: success, message: Los productos se cargaron exit??samente, receiver: both}, {successful_products: [[10101, SI, Paracetamol
// de 500mg, Comprimido bucodispersable: deshacer en la boca antes de ser tragado.
// Granulado efervescente: disolver en un vaso de agua, tomar cuando cese el burbujeo., Farmacias del ahorro, 90.00, 80.00, 50.00, 150, 1]]}]

// {status: true, code: warning, message: {successful_products: [[10108, SI, Paracetamol de 500mg ????, Comprimido bucodispersable: deshacer en la
// boca antes de ser tragado.
// Granulado efervescente: disolver en un vaso de agua, tomar cuando cese el burbujeo., Farmacias del ahorro, 0, 80.00, 50.00, -2, 30a]],
// error_products: [{product_data: [10103, SI, Paracetamol de 500mg, O??ppa?? (???-?????????????????)??? ,?????? S??t??yl??e?? ???, , dsg, c, c, -123,5, j], error: Problema para
// actualizar el producto: Array}, {product_data: [, , , , , , , , , ], error: Problema para crear el producto: Faltan los siguientes campos: "precio"=>
// No es un precio v??lido, "stock"=> No es un n??mero entero v??lido, "precio_con_descuento"=> No es un precio v??lido, "precio_mayoreo"=> No es un precio
// v??lido, "cantidad_mayoreo"=> No es un n??mero entero v??lido}, {product_data: [, , , , , , , , , ], error: Problema para crear el producto: Faltan los
// siguientes campos: "precio"=> No es un precio v??lido, "stock"=> No es un n??mero entero v??lido, "precio_con_descuento"=> No es un precio v??lido,
// "precio_mayoreo"=> No es un precio v??lido, "cantidad_mayoreo"=> No es un n??mero entero v??lido}, {product_data: [, , , , , , , , , ], error: Problema
// para crear el producto: Faltan los siguientes campos: "precio"=> No es un precio v??lido, "stock"=> No es un n??mero entero v??lido,
// "precio_con_descuento"=> No es un precio v??lido, "precio_mayoreo"=> No es un precio v??lido, "cantidad_mayoreo"=> No es un n??mero entero v??lido},
// {product_data: [, , , , , , , , , ], error: Problema para crear el producto: Faltan los siguientes campos: "precio"=> No es un precio v??lido,
// "stock"=> No es un n??mero entero v??lido, "precio_con_descuento"=> No es un precio v??lido, "precio_mayoreo"=> No es un precio v??lido,
// "cantidad_mayoreo"=> No es un n??mero entero v??lido}, {product_data: [, , , 0, , , , , , ], error: Problema para crear el producto: Faltan los
// siguientes campos: "precio"=> No es un precio v??lido, "stock"=> No es un n??mero entero v??lido, "precio_con_descuento"=> No es un precio v??lido,
// "precio_mayoreo"=> No es un precio v??lido, "cantidad_mayoreo"=> No es un n??mero entero v??lido}]}, receiver: both}

// status: true, code: warning, message: {successful_products: [[10101, SI, Paracetamol de 500mg ????, Comprimido bucodispersable: deshacer en
// la boca antes de ser tragado.
// Granulado efervescente: disolver en un vaso de agua, tomar cuando cese el burbujeo., Farmacias del ahorro, 0, 80.00, 50.00, -2, 30a], [10103, ON,
// Paracetamol de 500mg, ???, Farmacias del ahorro, 90.01, 80.01, 50.01, 97, 2], [10104, NO, Aspirina ?????, TextStyle( color: Colors.red[700], fontWeight:
// FontWeight.w600, ), ), !errorStr ? Container() : SizedBox( height: smallPadding, ), Padding(, Farmacias del ahorro, 20, 10, 25, 10, 2], [10105, SI ,
// Paracetamol??????, Comprimido bucodispersable: deshacer en la boca antes de ser tragado.
// Granulado efervescente: disolver en un vaso de agua, tomar cuando cese el burbujeo., Farmacias del ahorro, 90.02, 80.02, 50.02, 44, 3]],
// error_products: [{product_data: [10102, SI, Paracetamol de 500mg, O??ppa?? (???-?????????????????)??? ,?????? S??t??yl??e?? ???, , dsg, c, c, -123,5, j], error: Problema para
// crear el producto: Faltan los siguientes campos: "precio"=> No es un precio v??lido, "stock"=> No es un n??mero entero v??lido, "precio_con_descuento"=>
// No es un precio v??lido, "precio_mayoreo"=> No es un precio v??lido}, {product_data: [10106c, , (????????????)????????????????(??????? ), O??ppa?? (???-?????????????????)??? ,??????
// S??t??yl??e??, , dsg, c, c, 17,5, j], error: Problema para crear el producto: Faltan los siguientes campos: "precio"=> No es un precio v??lido, "stock"=>
// No es un n??mero entero v??lido, "precio_con_descuento"=> No es un precio v??lido, "precio_mayoreo"=> No es un precio v??lido}, {product_data: [, , , 0,
// , , , , , ], error: Problema para crear el producto: Faltan los siguientes campos: "precio"=> No es un precio v??lido, "stock"=> No es un n??mero
// entero v??lido, "precio_con_descuento"=> No es un precio v??lido, "precio_mayoreo"=> No es un precio v??lido, "cantidad_mayoreo"=> No es un n??mero
// entero v??lido}]

// message: {successful_products: [[10101, SI, Paracetamol de 500mg
// ????, Comprimido bucodispersable: deshacer en la boca antes de ser tragado.
// Granulado efervescente: disolver en un vaso de agua, tomar cuando cese el burbujeo., Farmacias del ahorro, 0, 80.00, 50.00, -2, 30a]],
// error_products: [{product_data: [10102, SI, Paracetamol de 500mg, O??ppa?? (???-?????????????????)??? ,?????? S??t??yl??e?? ???, , dsg, c, c, -123,5, j], error: Problema para
// crear el producto: Faltan los siguientes campos: "precio"=> No es un precio v??lido, "stock"=> No es un n??mero entero v??lido, "precio_con_descuento"=>
// No es un precio v??lido, "precio_mayoreo"=> No es un precio v??lido}, {product_data: [, , , , , , , , , ], error: Problema para crear el producto:
// Faltan los siguientes campos: "precio"=> No es un precio v??lido, "stock"=> No es un n??mero entero v??lido, "precio_con_descuento"=> No es un precio
// v??lido, "precio_mayoreo"=> No es un precio v??lido, "cantidad_mayoreo"=> No es un n??mero entero v??lido}, {product_data: [, , , , , , , , , ], error:
// Problema para crear el producto: Faltan los siguientes campos: "precio"=> No es un precio v??lido, "stock"=> No es un n??mero entero v??lido,
// "precio_con_descuento"=> No es un precio v??lido, "precio_mayoreo"=> No es un precio v??lido, "cantidad_mayoreo"=> No es un n??mero entero v??lido},
// {product_data: [, , , , , , , , , ], error: Problema para crear el producto: Faltan los siguientes campos: "precio"=> No es un precio v??lido,
// "stock"=> No es un n??mero entero v??lido, "precio_con_descuento"=> No es un precio v??lido, "precio_mayoreo"=> No es un precio v??lido,
// "cantidad_mayoreo"=> No es un n??mero entero v??lido}, {product_data: [, , , , , , , , , ], error: Problema para crear el producto: Faltan los
// siguientes campos: "precio"=> No es un precio v??lido, "stock"=> No es un n??mero entero v??lido, "precio_con_descuento"=> No es un precio v??lido,
// "precio_mayoreo"=> No es un precio v??lido, "cantidad_mayoreo"=> No es un n??mero entero v??lido}, {product_data: [, , , 0, , , , , , ], error: Problema
// para crear el producto: Faltan los siguientes campos: "precio"=> No es un precio v??lido, "stock"=> No es un n??mero entero v??lido,
// "precio_con_descuento"=> No es un precio v??lido, "precio_mayoreo"=> No es un precio v??lido, "cantidad_mayoreo"=> No es un n??mero entero v??lido}]}}

// {status: true, code: success, message: Los productos se cargaron exit??samente, receiver: both}, {successful_products: [[10101, SI, Paracetamol
// de 500mg, Comprimido bucodispersable: deshacer en la boca antes de ser tragado.
// Granulado efervescente: disolver en un vaso de agua, tomar cuando cese el burbujeo., Farmacias del ahorro, 90.00, 80.00, 50.00, 150, 1]]}]
