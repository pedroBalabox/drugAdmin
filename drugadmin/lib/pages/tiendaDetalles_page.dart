import 'dart:convert';
import 'dart:io';
import 'dart:html' as html;
import 'package:codigojaguar/codigojaguar.dart';
import 'package:drugadmin/model/farmacia_model.dart';
import 'package:drugadmin/service/restFunction.dart';
import 'package:drugadmin/service/sharedPref.dart';
import 'package:drugadmin/utils/globals.dart';
import 'package:drugadmin/utils/theme.dart';
import 'package:drugadmin/widget/drawerVendedor_widget.dart';
import 'package:drugadmin/widget/testRest.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jiffy/jiffy.dart';
import 'package:http/http.dart' as http;
import 'package:month_picker_dialog/month_picker_dialog.dart';

class Status {
  const Status(this.id, this.name);

  final String name;
  final String id;
}

class TiendaDetalles extends StatefulWidget {
  static const routeName = '/detalles-tienda';

  final dynamic jsonData;
  TiendaDetalles({Key key, @required this.jsonData}) : super(key: key);

  @override
  _TabAceptadaState createState() => _TabAceptadaState();
}

class _TabAceptadaState extends State<TiendaDetalles> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  RestFun rest = RestFun();

  FarmaciaModel farmaciaModel = FarmaciaModel();
  var mediaData;
  Image pickedImage;
  var imagePath;
  String base64Image;

  var jsonDetalles;

  String date;
  String errorStr;
  bool load = true;
  bool error = false;
  Status statusValue;
  List<Status> listaStatus = [];

  String tipoPersona;

  String logoUrl;

  var giroFarmacia = [
    'Farmacia de medicamentos',
    'Farmacia productos ',
    'Farmacia especializada',
    'Venta minorista'
  ];

  @override
  void initState() {
    super.initState();
    farmaciaModel = FarmaciaModel.fromJson(widget.jsonData.jsonData);
    sharedPrefs.init();
    Jiffy.locale('es');
    setState(() {
      tipoPersona = farmaciaModel.tipoPersona == "fisica" ? "Física" : "Moral";
      date = Jiffy(farmaciaModel.creation_date).format('MMMM do yyyy, h:mm a');
      logoUrl = farmaciaModel.logo;
    });
    listaStatus.add(Status('approved', 'Activa'));
    listaStatus.add(Status('rejected', 'Rechazada'));
    listaStatus.add(Status('waiting_for_review', 'Esperando revisión'));
    listaStatus.add(Status('blocked', 'Bloqueada'));
    getDetalles();
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showMonthPicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(DateTime.now().year - 10),
        lastDate: DateTime(DateTime.now().year + 2));
    if (picked != null) {
      setState(() {
        print(picked.month);
        print(picked.year);
        print(sharedPrefs.clientToken);
        launchURL('https://sandbox.app.drugsiteonline.com/report.php?DrJWT=' +
            sharedPrefs.clientToken +
            "&farmacia_id=" +
            farmaciaModel.farmacia_id +
            "&year=" +
            picked.year.toString() +
            "&month=" +
            picked.month.toString());
        //bannerModel.fechaDeExposicion = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _showYearMonthPicker(context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Descargar reporte de ventas',
            style: TextStyle(color: Colors.black87),
          ),
          content: Container(
            height: 80,
            child: Column(
              children: [
                Container(
                  child: Text(
                      "Selecciona un mes y un año para descargar el reporte de ventas"),
                ),
                SizedBox(
                  height: 20,
                ),
                InkWell(
                    onTap: () {
                      _selectDate(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Text("Seleccionar fecha"),
                    ))
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            )
          ],
        );
      },
    );
  }

  pickImage() async {
    final _picker = ImagePicker();
    PickedFile image =
        await _picker.getImage(source: ImageSource.gallery, imageQuality: 80);
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
      base64Image = imgBase64Str.toString();
    });
  }

  getDetalles() async {
    setState(() {
      load = true;
    });
    var arrayData = {
      'farmacia_id': farmaciaModel.farmacia_id,
    };
    await rest
        .restService(arrayData, '${urlApi}detalles/farmacia',
            sharedPrefs.clientToken, 'post')
        .then((value) {
      if (value['status'] == 'server_true') {
        var ordenResp = value['response'];
        ordenResp = jsonDecode(ordenResp)[1];
        setState(() {
          jsonDetalles = jsonDecode(value['response'])[1]['documentos'];
          farmaciaModel =
              FarmaciaModel.fromJson(jsonDecode(value['response'])[1]);
          if (farmaciaModel.estatus == 'approved') {
            statusValue = listaStatus[0];
          } else if (farmaciaModel.estatus == 'waiting_for_review') {
            statusValue = listaStatus[2];
          } else if (farmaciaModel.estatus == 'rejected') {
            statusValue = listaStatus[1];
          } else if (farmaciaModel.estatus == 'blocked') {
            statusValue = listaStatus[3];
          }
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

  cambiarStatus(id, status) {
    var arrayData = {"archivo_id": id, "estatus": status};
    rest
        .restService(arrayData, '${urlApi}documento/actualizar-estatus',
            sharedPrefs.clientToken, 'post')
        .then((value) {
      load = true;
      getDetalles();
    });
  }

  cambiarStatusTienda(id, status) {
    var arrayData = {"farmacia_id": id, "estatus": status};
    rest
        .restService(arrayData, '${urlApi}farmacia/actualizar-estatus',
            sharedPrefs.clientToken, 'post')
        .then((value) {
      print(value);
      load = true;
      getDetalles();
    });
  }

  cambiarStatusVerif(id, status) {
    var arrayData = {"farmacia_id": id, "estatus_verificacion": status};
    rest
        .restService(arrayData, '${urlApi}actualizar/farmacia',
            sharedPrefs.clientToken, 'post')
        .then((value) {
      print(value);
      load = true;
      getDetalles();
    });
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
                      child: bodyTienda(),
                    ),
                  ]),
        title: "Detalles de la tienda");
  }

  Widget bodyTienda() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Datos de la tienda',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        SizedBox(
          height: smallPadding,
        ),
        Container(child: miTienda(context)),
        SizedBox(
          height: smallPadding * 4,
        ),
        Text(
          'Documentos',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        SizedBox(
          height: smallPadding,
        ),
        Container(
          child: misDocs(context),
        ),
        SizedBox(
          height: smallPadding * 4,
        ),
        Container(
          child: miStatus(),
        ),
        SizedBox(
          height: smallPadding * 4,
        ),
        Container(
          child: verificacionSw(),
        )
      ],
    );
  }

  Widget verificacionSw() {
    var size = MediaQuery.of(context).size;

    bool isSwitched =
        farmaciaModel.estatus_verificacion == 'not_verified' ? false : true;
    var textValue = farmaciaModel.estatus_verificacion == 'not_verified'
        ? 'Tienda no verificada'
        : 'Tienda verificada';

    void toggleSwitch(bool value) {
      if (isSwitched == false) {
        setState(() {
          cambiarStatusVerif(farmaciaModel.farmacia_id, 'verified');
          // isSwitched = true;
          // textValue = 'Tienda Sí verificada';
        });
      } else {
        setState(() {
          cambiarStatusVerif(farmaciaModel.farmacia_id, 'not_verified');
          // isSwitched = true;
          // textValue = 'Tienda Sí verificada';
        });
        //print('Tienda No verificada');
      }
    }

    return Column(
      children: [
        Container(
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
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Verificación de la tienda',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 18)),
            Text(
              '$textValue',
              style: TextStyle(fontSize: 15),
            ),
            Transform.scale(
                scale: 1,
                child: Switch(
                  onChanged: toggleSwitch,
                  value: isSwitched,
                  activeColor: Theme.of(context).accentColor,
                  activeTrackColor: Colors.grey[300],
                  inactiveThumbColor: Colors.grey[300],
                  inactiveTrackColor: Colors.grey,
                )),
          ]),
        ),
        TextButton(
          onPressed: () {
            _showYearMonthPicker(context);
            //_selectDate(context);
          },
          child: Text("Descargar reporte de ventas mensual"),
        )
      ],
    );
  }

  miStatus() {
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
          Text(
            'Cambiar estatus',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DropdownButton<Status>(
                value: statusValue,
                icon: const Icon(Icons.arrow_drop_down),
                iconSize: 10,
                elevation: 16,
                style: const TextStyle(color: Colors.black87),
                underline: Container(
                  height: 2,
                  color: Colors.blue,
                ),
                onChanged: (Status newValue) {
                  setState(() {
                    statusValue = newValue;
                  });
                },
                items: listaStatus.map((Status status) {
                  return new DropdownMenuItem<Status>(
                    value: status,
                    child: new Text(
                      status.name,
                      style: new TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
              ),
              BotonSimple(
                action: () {
                  cambiarStatusTienda(
                      farmaciaModel.farmacia_id, statusValue.id);
                },
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
          )
        ],
      ),
    );
  }

  miTienda(context) {
    Widget statusWidget;
    switch (farmaciaModel.estatus) {
      case 'approved':
        statusWidget = statusApproved();
        break;
      case 'rejected':
        statusWidget = statusRejected();
        break;
      case 'blocked':
        statusWidget = statusBlocked();
        break;
      case 'waiting_for_review':
        statusWidget = statusReview();
        break;
      default:
    }
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
                        : logoUrl == null
                            ? AssetImage('images/logoDrug.png')
                            : NetworkImage(logoUrl),
                  ),
                ),
              ),
            ),
            SizedBox(height: smallPadding),
            statusWidget,
            farmaciaModel.estatus_verificacion == 'not_verified'
                ? Container()
                : statusVerficado(),
            // farmaciaModel.estatus == 'approved'
            //     ? statusApproved()
            //     : statusReview(),
            SizedBox(height: smallPadding),
            formNuevaTienda(),
          ],
        ));
  }

  formNuevaTienda() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          EntradaTexto(
            habilitado: true,
            valorInicial: farmaciaModel.nombre,
            estilo: inputPrimarystyle(
                context, Icons.store_outlined, 'Nombre comercial', null),
            tipoEntrada: TextInputType.emailAddress,
            textCapitalization: TextCapitalization.words,
            tipo: 'typeValidator',
            onChanged: (value) {
              setState(() {
                farmaciaModel.nombre = value;
              });
            },
          ),
          EntradaTexto(
            habilitado: true,
            valorInicial: farmaciaModel.nombrePropietario,
            estilo: inputPrimarystyle(
                context, Icons.person_outline, 'Nombre del propietario', null),
            tipoEntrada: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            tipo: 'typeValidator',
            onChanged: (value) {
              setState(() {
                farmaciaModel.nombrePropietario = value;
              });
            },
          ),
          EntradaTexto(
            habilitado: true,
            valorInicial: farmaciaModel.correo,
            estilo:
                inputPrimarystyle(context, Icons.mail_outline, 'Correo', null),
            tipoEntrada: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            tipo: 'typeValidator',
            onChanged: (value) {
              setState(() {
                farmaciaModel.correo = value;
              });
            },
          ),
          EntradaTexto(
            habilitado: true,
            valorInicial: farmaciaModel.rfc,
            estilo:
                inputPrimarystyle(context, Icons.store_outlined, 'RFC', null),
            tipoEntrada: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            tipo: 'typeValidator',
            onChanged: (value) {
              setState(() {
                farmaciaModel.rfc = value;
              });
            },
          ),
          DropdownButtonFormField<String>(
            focusColor: Theme.of(context).primaryColor,
            // dropdownColor: Theme.of(context).primaryColor,
            isExpanded: true,
            hint: Text("Tipo de persona"),
            value: tipoPersona,
            items: ["Moral", "Física"].map((value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Container(
                  child: Padding(
                    padding: EdgeInsets.only(left: 7),
                    child: Row(
                      children: [
                        Icon(Icons.store_outlined,
                            color: Theme.of(context).primaryColor),
                        SizedBox(
                          width: 7,
                        ),
                        Text("Tipo de persona: " + value.toString()),
                      ],
                    ),
                  ),
                  // height: 5.0,
                ),
              );
            }).toList(),
            onChanged: (String val) {
              setState(() {
                tipoPersona = val;
                farmaciaModel.tipoPersona =
                    val == "Física" ? "fisica" : "moral";
              });
            },
          ),
          DropdownButtonFormField<String>(
            isExpanded: true,
            hint: Text("Giro del negocio"),
            value: farmaciaModel.giro,
            items: giroFarmacia.map((value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Container(
                  child: Padding(
                    padding: EdgeInsets.only(left: 7),
                    child: Row(
                      children: [
                        Icon(Icons.store_outlined,
                            color: Theme.of(context).primaryColor),
                        SizedBox(
                          width: 7,
                        ),
                        Text("Giro del negocio: " + value.toString()),
                      ],
                    ),
                  ),
                  // height: 5.0,
                ),
              );
            }).toList(),
            onChanged: (String val) {
              setState(() {
                // tipoPersona = val;
                farmaciaModel.giro = val;
              });
            },
          ),
          SizedBox(
            height: smallPadding * 2,
          ),
          EntradaTexto(
            habilitado: false,
            valorInicial: date,
            estilo: inputPrimarystyle(context, Icons.calendar_today_outlined,
                'Fecha de registro', null),
            tipoEntrada: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            tipo: 'typeValidator',
          ),
          SizedBox(
            height: smallPadding * 2,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: medPadding * 2),
            child: BotonRestTest(
                showSuccess: true,
                token: sharedPrefs.clientToken,
                url: '$apiUrl/actualizar/farmacia',
                method: 'post',
                formkey: formKey,
                arrayData: {
                  'farmacia_id': farmaciaModel.farmacia_id,
                  "nombre": farmaciaModel.nombre,
                  "nombre_propietario": farmaciaModel.nombrePropietario,
                  "rfc": farmaciaModel.rfc,
                  "tipo_persona": farmaciaModel.tipoPersona,
                  "correo": farmaciaModel.correo,
                  "giro": farmaciaModel.giro,
                  "base64": base64Image == null ? null : base64Image
                },
                contenido: Text(
                  'Guardar',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                /* action: (value) => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/farmacia/miTienda/',
                      ModalRoute.withName('/farmacia/miCuenta'),
                    ).then((value) => setState(() {})), */
                action: (value) => () {},
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

  misDocs(context) {
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
            ListView.builder(
              itemCount: documents.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return document(documents[index]);
              },
            ),
          ],
        ));
  }

  document(doc) {
    Widget botonDoc;
    String status;

    switch (doc) {
      case 'Aviso de funcionamiento':
        if (jsonDetalles['avi_func']['status'] == 'rejected') {
          botonDoc = Row(
            children: [
              Flexible(
                flex: 3,
                child: Container(),
              ),
              Flexible(
                  flex: 2, child: botonValidar(doc, jsonDetalles['avi_func'])),
              Flexible(
                flex: 3,
                child: Container(),
              ),
            ],
          );
        } else if (jsonDetalles['avi_func']['status'] == 'approved') {
          botonDoc = Row(
            children: [
              Flexible(
                flex: 3,
                child: Container(),
              ),
              Flexible(
                  flex: 2, child: botonRechazar(doc, jsonDetalles['avi_func'])),
              Flexible(
                flex: 3,
                child: Container(),
              ),
            ],
          );
        } else if (jsonDetalles['avi_func']['status'] == 'active') {
          botonDoc = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              botonValidar(doc, jsonDetalles['avi_func']),
              SizedBox(width: smallPadding),
              botonRechazar(doc, jsonDetalles['avi_func'])
            ],
          );
        }
        status = jsonDetalles['avi_func']['status'];
        break;
      case 'Acta constitutiva':
        if (jsonDetalles['act_cons']['status'] == 'rejected') {
          botonDoc = Row(
            children: [
              Flexible(
                flex: 3,
                child: Container(),
              ),
              Flexible(
                  flex: 2, child: botonValidar(doc, jsonDetalles['act_cons'])),
              Flexible(
                flex: 3,
                child: Container(),
              ),
            ],
          );
        } else if (jsonDetalles['act_cons']['status'] == 'approved') {
          botonDoc = Row(
            children: [
              Flexible(
                flex: 3,
                child: Container(),
              ),
              Flexible(
                  flex: 2, child: botonRechazar(doc, jsonDetalles['act_cons'])),
              Flexible(
                flex: 3,
                child: Container(),
              ),
            ],
          );
        } else if (jsonDetalles['act_cons']['status'] == 'active') {
          botonDoc = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              botonValidar(doc, jsonDetalles['act_cons']),
              SizedBox(width: smallPadding),
              botonRechazar(doc, jsonDetalles['act_cons'])
            ],
          );
        }
        status = jsonDetalles['act_cons']['status'];
        break;
      case 'Comprobante de domicilio':
        if (jsonDetalles['comp_dom']['status'] == 'rejected') {
          botonDoc = Row(
            children: [
              Flexible(
                flex: 3,
                child: Container(),
              ),
              Flexible(
                  flex: 2, child: botonValidar(doc, jsonDetalles['comp_dom'])),
              Flexible(
                flex: 3,
                child: Container(),
              ),
            ],
          );
        } else if (jsonDetalles['comp_dom']['status'] == 'approved') {
          botonDoc = Row(
            children: [
              Flexible(
                flex: 3,
                child: Container(),
              ),
              Flexible(
                  flex: 2, child: botonRechazar(doc, jsonDetalles['comp_dom'])),
              Flexible(
                flex: 3,
                child: Container(),
              ),
            ],
          );
        } else if (jsonDetalles['comp_dom']['status'] == 'active') {
          botonDoc = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              botonValidar(doc, jsonDetalles['comp_dom']),
              SizedBox(width: smallPadding),
              botonRechazar(doc, jsonDetalles['comp_dom'])
            ],
          );
        }
        status = jsonDetalles['comp_dom']['status'];
        break;
      case 'INE vigente':
        if (jsonDetalles['ine']['status'] == 'rejected') {
          botonDoc = Row(
            children: [
              Flexible(
                flex: 3,
                child: Container(),
              ),
              Flexible(flex: 2, child: botonValidar(doc, jsonDetalles['ine'])),
              Flexible(
                flex: 3,
                child: Container(),
              ),
            ],
          );
        } else if (jsonDetalles['ine']['status'] == 'approved') {
          botonDoc = Row(
            children: [
              Flexible(
                flex: 3,
                child: Container(),
              ),
              Flexible(flex: 2, child: botonRechazar(doc, jsonDetalles['ine'])),
              Flexible(
                flex: 3,
                child: Container(),
              ),
            ],
          );
        } else if (jsonDetalles['ine']['status'] == 'active') {
          botonDoc = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              botonValidar(doc, jsonDetalles['ine']),
              SizedBox(width: smallPadding),
              botonRechazar(doc, jsonDetalles['ine'])
            ],
          );
        }
        status = jsonDetalles['ine']['status'];
        break;
      case 'Cédula fiscal SAT':
        if (jsonDetalles['ced_fis']['status'] == 'rejected') {
          botonDoc = Row(
            children: [
              Flexible(
                flex: 3,
                child: Container(),
              ),
              Flexible(
                  flex: 2, child: botonValidar(doc, jsonDetalles['ced_fis'])),
              Flexible(
                flex: 3,
                child: Container(),
              ),
            ],
          );
        } else if (jsonDetalles['ced_fis']['status'] == 'approved') {
          botonDoc = Row(
            children: [
              Flexible(
                flex: 3,
                child: Container(),
              ),
              Flexible(
                  flex: 2, child: botonRechazar(doc, jsonDetalles['ced_fis'])),
              Flexible(
                flex: 3,
                child: Container(),
              ),
            ],
          );
        } else if (jsonDetalles['ced_fis']['status'] == 'active') {
          botonDoc = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              botonValidar(doc, jsonDetalles['ced_fis']),
              SizedBox(width: smallPadding),
              botonRechazar(doc, jsonDetalles['ced_fis'])
            ],
          );
        }
        status = jsonDetalles['ced_fis']['status'];
        break;
      default:
    }

    return Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black12, width: 1.5)),
        ),
        padding: EdgeInsets.symmetric(vertical: smallPadding / 2),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon(Icons.file_copy_outlined),
                Flexible(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.attach_file_outlined,
                            size: 15,
                            color: Colors.black.withOpacity(0.8),
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Flexible(
                            child: Text(
                              doc,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                          )
                        ],
                      ),
                      farmaciaModel.estatus == 'approved'
                          ? Container()
                          : statusWidget(status)
                    ],
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: smallPadding),
                      child: BotonSimple(
                          contenido: Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: smallPadding),
                            child: Text(
                              'Ver',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          action: () {
                            switch (doc) {
                              case 'Aviso de funcionamiento':
                                launchURL(jsonDetalles['avi_func']['file']);
                                break;
                              case 'Acta constitutiva':
                                launchURL(jsonDetalles['act_cons']['file']);
                                break;
                              case 'Comprobante de domicilio':
                                launchURL(jsonDetalles['comp_dom']['file']);
                                break;
                              case 'INE vigente':
                                launchURL(jsonDetalles['ine']['file']);
                                break;
                              case 'Cédula fiscal SAT':
                                launchURL(jsonDetalles['ced_fis']['file']);
                                break;
                              default:
                            }
                          },
                          estilo: estiloBotonSecundary),
                    ),
                  ],
                ),
              ],
            ),
            farmaciaModel.estatus == 'approved' ||
                    farmaciaModel.estatus == 'blocked'
                ? Container()
                : botonDoc
          ],
        ));
  }

  Widget botonValidar(doc, myDoc) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: smallPadding),
      child: BotonSimple(
          contenido: Padding(
            padding: EdgeInsets.symmetric(horizontal: smallPadding),
            child: Text(
              'Validar',
              textAlign: TextAlign.center,
              overflow: TextOverflow.fade,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          action: () => cambiarStatus(myDoc['archivo_id'], 'approved'),
          estilo: estiloValidar),
    );
  }

  Widget botonRechazar(doc, myDoc) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: smallPadding),
      child: BotonSimple(
          contenido: Padding(
            padding: EdgeInsets.symmetric(horizontal: smallPadding),
            child: Text(
              'Rechazar',
              textAlign: TextAlign.center,
              overflow: TextOverflow.fade,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          action: () => cambiarStatus(myDoc['archivo_id'], 'rejected'),
          estilo: estiloRechazar),
    );
  }

  Widget statusWidget(status) {
    Widget myWidget;
    switch (status) {
      case 'rejected':
        myWidget = docRechazado();
        break;
      case 'active':
        myWidget = docActive();
        break;
      case 'approved':
        myWidget = docAceptado();
        break;
      default:
    }
    return myWidget;
  }

  Widget docActive() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 12,
          width: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.blue[200],
          ),
        ),
        SizedBox(
          width: 3,
        ),
        Flexible(
          child: Text(
            'En espera',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black45,
            ),
          ),
        )
      ],
    );
  }

  Widget docRechazado() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 13,
          width: 13,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.red.withOpacity(0.8),
          ),
          child: Icon(
            Icons.close,
            size: 8,
            color: Colors.white,
          ),
        ),
        SizedBox(
          width: 3,
        ),
        Flexible(
          child: Text(
            'Documento rechazado',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black45,
            ),
          ),
        )
      ],
    );
  }

  Widget docAceptado() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle,
          size: 13,
          color: Colors.green.withOpacity(0.8),
        ),
        SizedBox(
          width: 3,
        ),
        Flexible(
          child: Text(
            'Documento validado',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black45,
            ),
          ),
        )
      ],
    );
  }

  Widget docCargado(nombreDoc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle,
          size: 13,
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
              color: Colors.black45,
            ),
          ),
        )
      ],
    );
  }
}

Widget statusVerficado() {
  return Container(
      width: 150,
      padding: EdgeInsets.all(smallPadding / 2),
      // decoration: BoxDecoration(
      //     borderRadius: BorderRadius.circular(50),
      //     color: Colors.green[600].withOpacity(0.7)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star, color: Colors.orange[400], size: 17),
          SizedBox(
            width: 5,
          ),
          Text(
            'Tienda verificada',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
      ));
}

Widget statusApproved() {
  return Container(
      width: 150,
      padding: EdgeInsets.all(smallPadding / 2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.green[600].withOpacity(0.7)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check, color: Colors.white, size: 17),
          SizedBox(
            width: 5,
          ),
          Text(
            'Tienda Activa',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ));
}

Widget statusReview() {
  return Container(
      width: 170,
      padding: EdgeInsets.all(smallPadding / 2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.blue[600].withOpacity(0.7)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time_rounded, color: Colors.white, size: 17),
          SizedBox(
            width: 5,
          ),
          Text(
            'Esperando revisión',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ));
}

Widget statusRejected() {
  return Container(
      width: 170,
      padding: EdgeInsets.all(smallPadding / 2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.orange[600].withOpacity(0.7)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.close, color: Colors.white, size: 17),
          SizedBox(
            width: 5,
          ),
          Text(
            'Tienda rechazada',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ));
}

Widget statusBlocked() {
  return Container(
      width: 170,
      padding: EdgeInsets.all(smallPadding / 2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.red[600].withOpacity(0.7)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.block_outlined, color: Colors.white, size: 17),
          SizedBox(
            width: 5,
          ),
          Text(
            'Tienda bloqueada',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ));
}
