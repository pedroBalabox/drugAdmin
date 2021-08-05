import 'dart:convert';
import 'package:codigojaguar/codigojaguar.dart';
import 'package:drugadmin/service/restFunction.dart';
import 'package:drugadmin/service/sharedPref.dart';
import 'package:drugadmin/utils/globals.dart';
import 'package:drugadmin/utils/theme.dart';
import 'package:drugadmin/widget/drawerVendedor_widget.dart';
import 'package:drugadmin/widget/testRest.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Status {
  const Status(this.id, this.name);

  final String name;
  final String id;
}

class StatusEnvio {
  const StatusEnvio(this.id, this.name);

  final String name;
  final String id;
}

class StatusPago {
  const StatusPago(this.id, this.name);

  final String name;
  final String id;
}

class OrdenDetalles extends StatefulWidget {
  static const routeName = '/detalles-orden';

  final dynamic jsonData;
  OrdenDetalles({Key key, @required this.jsonData}) : super(key: key);

  @override
  _OrdenDetallesState createState() => _OrdenDetallesState();
}

class _OrdenDetallesState extends State<OrdenDetalles> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  RestFun rest = RestFun();

  var jsonDetalles;

  var jsonRelaciones;

  Status statusValue;
  StatusEnvio statusValueEnvio;
  StatusPago statusValuePago;
  List<Status> listaStatus = [];
  List<StatusEnvio> listaStatusEnvio = [];
  List<StatusPago> listaStatusPago = [];

  String date;
  String errorStr;
  bool load = true;
  bool error = false;

  var jsonOrden;

  var imagePathDesktop;

  @override
  void initState() {
    super.initState();
    sharedPrefs.init();
    Jiffy.locale('es');
    listaStatus.add(Status('in_process', 'En revisión'));
    listaStatus.add(Status('confirmed', 'Confirmado'));
    listaStatus.add(Status('shipped', 'En camino'));
    listaStatus.add(Status('delivered', 'Entregado'));
    listaStatus.add(Status('cancelled', 'Cancelado'));
    listaStatus.add(Status('waiting_for_payment', 'Esperando pago'));
    listaStatus.add(Status('unknown', 'Desconocido'));
    listaStatusEnvio.add(StatusEnvio('preparing', 'En preparación'));
    listaStatusEnvio.add(StatusEnvio('on_the_way', 'En camino'));
    listaStatusEnvio.add(StatusEnvio('delivered', 'Entregado'));
    listaStatusEnvio.add(StatusEnvio('unknown', 'Desconocido'));

    listaStatusPago
        .add(StatusPago('oder_paid_by_client', 'Pagado por cliente'));
    listaStatusPago
        .add(StatusPago('order_paid_to_store"', 'Pagado a la tienda'));
    listaStatusPago.add(StatusPago('order_payment_rejected', 'Pago rechazado'));
    listaStatusPago.add(StatusPago('unknown', 'Desconocido'));

    setState(() {
      jsonOrden = widget.jsonData.jsonData;
    });
    if (jsonOrden['status'] == 'in_process') {
      statusValue = listaStatus[0];
    } else if (jsonOrden['estatus_de_orden'] == 'confirmed') {
      statusValue = listaStatus[1];
    } else if (jsonOrden['estatus_de_orden'] == 'shipped') {
      statusValue = listaStatus[2];
    } else if (jsonOrden['estatus_de_orden'] == 'delivered') {
      statusValue = listaStatus[3];
    } else if (jsonOrden['estatus_de_orden'] == 'cancelled') {
      statusValue = listaStatus[4];
    } else if (jsonOrden['estatus_de_orden'] == 'waiting_for_payment') {
      statusValue = listaStatus[5];
    } else {
      statusValue = listaStatus[6];
    }

    if (jsonOrden['estatus_de_envio'] == 'preparing') {
      statusValueEnvio = listaStatusEnvio[0];
    } else if (jsonOrden['estatus_de_envio'] == 'on_the_way') {
      statusValueEnvio = listaStatusEnvio[1];
    } else if (jsonOrden['estatus_de_envio'] == 'delivered') {
      statusValueEnvio = listaStatusEnvio[2];
    } else {
      statusValueEnvio = listaStatusEnvio[3];
    }

    if (jsonOrden['estatus_de_pago'] == 'oder_paid_by_client') {
      statusValuePago = listaStatusPago[0];
    } else if (jsonOrden['estatus_de_pago'] == 'order_paid_to_store') {
      statusValuePago = listaStatusPago[1];
    } else if (jsonOrden['estatus_de_pago'] == 'order_payment_rejected') {
      statusValuePago = listaStatusPago[2];
    } else {
      statusValuePago = listaStatusPago[3];
    }

    getDetalles();
  }

  getDetalles() async {
    setState(() {
      load = true;
    });
    var arrayData = {
      'id_de_orden': jsonOrden['id_de_orden'],
    };
    await rest
        .restService(
            arrayData, '${urlApi}ver/orden', sharedPrefs.clientToken, 'post')
        .then((value) {
      if (value['status'] == 'server_true') {
        var ordenResp = value['response'];
        ordenResp = jsonDecode(ordenResp)[1];
        setState(() {
          jsonOrden = jsonDecode(value['response'])[1]['details'];
          // bannerModel =
          //     FarmaciaModel.fromJson(jsonDecode(value['response'])[1]);
        });
        getRelaciones();
      } else {
        setState(() {
          load = false;
          error = true;
          errorStr = value['message'];
        });
      }
    });
  }

  getRelaciones() async {
    setState(() {
      load = true;
    });
    var arrayData = {
      'id_de_orden': jsonOrden['id_de_orden'],
    };
    await rest
        .restService(arrayData, '${urlApi}ver/relaciones',
            sharedPrefs.clientToken, 'post')
        .then((value) {
      if (value['status'] == 'server_true') {
        var ordenResp = value['response'];
        ordenResp = jsonDecode(ordenResp)[1];
        setState(() {
          jsonRelaciones = jsonDecode(value['response'])[1]['related_items'];
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
        title: "Detalles del pedido");
  }

  Widget bodyBanner() {
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Datos del pedido',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
          ),
          SizedBox(
            height: smallPadding,
          ),
          Container(child: miOrden(context)),
          SizedBox(
            height: smallPadding * 4,
          ),
          Text(
            'Productos',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
          ),
          SizedBox(
            height: smallPadding,
          ),
          Container(child: misProductos(context)),
          SizedBox(
            height: smallPadding * 4,
          ),
          jsonOrden['archivo_receta_medica'] == null
              ? Container()
              : recetaMedica(),
          Container(
            child: miStatus(),
          ),
        ],
      ),
    );
  }

  recetaMedica() {
    return Column(
      children: [
        Text(
          'Receta médica',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        SizedBox(
          height: smallPadding,
        ),
        Container(child: miReceta()),
        SizedBox(
          height: smallPadding * 4,
        ),
      ],
    );
  }

  miReceta() {
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
        child: BotonSimple(
            action: () => launchURL(jsonOrden['archivo_receta_medica']),
            contenido: Text(
              'Ver receta',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            estilo: estiloBotonSecundary));
  }

  miOrden(context) {
    var size = MediaQuery.of(context).size;
    Widget miEstatus;

    switch (jsonOrden['estatus_de_orden']) {
      case 'confirmed':
        miEstatus = statusConfirmed();
        break;
      case 'in_process':
        miEstatus = statusProcess();
        break;
      case 'shipped':
        miEstatus = statusShipped();
        break;
      case 'delivered':
        miEstatus = statusDelivered();
        break;

      case 'cancelled':
        miEstatus = statusCancel();
        break;
      case 'waiting_for_payment':
        miEstatus = statusWaitingPay();
        break;
      default:
        miEstatus = statusUnknown();
    }

    var numCard = jsonDecode(jsonOrden['detalles_cargo']);

    var iconCard = Icons.payment_outlined;

    switch (numCard['card']['brand']) {
      case 'visa':
        iconCard = (FontAwesomeIcons.ccVisa);
        break;
      case 'mastercard':
        iconCard = FontAwesomeIcons.ccMastercard;
        break;
      case 'americanexpress':
        iconCard = FontAwesomeIcons.ccAmex;
        break;
      default:
        iconCard = Icons.payment_outlined;
    }

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
              jsonOrden['id_de_orden'],
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 15),
            ),
            SizedBox(
              height: smallPadding,
            ),
            miEstatus,
            SizedBox(
              height: smallPadding * 2,
            ),
            infoOrden(jsonOrden['cliente'], Icons.person_outline, context),
            infoOrden(jsonOrden['mail'], Icons.mail_outline, context),
            infoOrden(
                jsonOrden['telefono_contacto'], Icons.phone_outlined, context),
            infoOrden(numCard['card']['card_number'], iconCard, context),
            infoOrden(
                jsonOrden['calle'].toString() +
                    ',' +
                    ' ' +
                    jsonOrden['colonia'].toString(),
                Icons.location_on_outlined,
                context),
            // infoOrden(jsonOrden['colonia'],
            //     Icons.location_on_outlined, context),
            Row(
              children: [
                Flexible(
                  child: infoOrden(jsonOrden['numero_exterior'],
                      Icons.location_on_outlined, context),
                ),
                Flexible(
                  child: infoOrden(jsonOrden['numero_interior'],
                      Icons.location_on_outlined, context),
                ),
                Flexible(
                  child: infoOrden(jsonOrden['codigo_postal'],
                      Icons.location_on_outlined, context),
                ),
              ],
            ),
            infoOrden(
                jsonOrden['referencias'], Icons.location_on_outlined, context),
            infoOrden(jsonOrden['comentarios'], Icons.edit_outlined, context),
            infoOrden(jsonOrden['fecha_de_creacion'],
                Icons.calendar_today_outlined, context),
          ],
        ));
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
            'Cambiar estatus de pedido',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
          ),
          Column(
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: medPadding),
                child: BotonRestTest(
                  token: sharedPrefs.clientToken,
                  url: '${urlApi}actualizar/estatus-orden',
                  formkey: formKey,
                  arrayData: {
                    "id_de_orden": jsonOrden['id_de_orden'],
                    "estatus_de_orden": statusValue.id,
                    "estatus_de_envio": jsonOrden['estatus_de_envio'],
                    "comments": null
                  },
                  method: 'post',
                  action: (value) => getDetalles(),
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
                ),
              )
            ],
          ),
          SizedBox(height: medPadding),
          Text(
            'Cambiar estatus de envio',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DropdownButton<StatusEnvio>(
                value: statusValueEnvio,
                icon: const Icon(Icons.arrow_drop_down),
                iconSize: 10,
                elevation: 16,
                style: const TextStyle(color: Colors.black87),
                underline: Container(
                  height: 2,
                  color: Colors.blue,
                ),
                onChanged: (StatusEnvio newValueEnvio) {
                  setState(() {
                    statusValueEnvio = newValueEnvio;
                  });
                },
                items: listaStatusEnvio.map((StatusEnvio statusEnvio) {
                  return new DropdownMenuItem<StatusEnvio>(
                    value: statusEnvio,
                    child: new Text(
                      statusEnvio.name,
                      style: new TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: medPadding),
                child: BotonRestTest(
                  token: sharedPrefs.clientToken,
                  url: '${urlApi}actualizar/estatus-orden',
                  formkey: formKey,
                  arrayData: {
                    "id_de_orden": jsonOrden['id_de_orden'],
                    "estatus_de_envio": statusValueEnvio.id,
                    "estatus_de_orden": jsonOrden['estatus_de_orden'],
                    "comments": null
                  },
                  method: 'post',
                  action: (value) => getDetalles(),
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
                ),
              )
            ],
          ),
          SizedBox(height: medPadding),
          Text(
            'Cambiar estatus de pago',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DropdownButton<StatusPago>(
                value: statusValuePago,
                icon: const Icon(Icons.arrow_drop_down),
                iconSize: 10,
                elevation: 16,
                style: const TextStyle(color: Colors.black87),
                underline: Container(
                  height: 2,
                  color: Colors.blue,
                ),
                onChanged: (StatusPago newValueEnvio) {
                  setState(() {
                    statusValuePago = newValueEnvio;
                  });
                },
                items: listaStatusPago.map((StatusPago statusPago) {
                  return new DropdownMenuItem<StatusPago>(
                    value: statusPago,
                    child: new Text(
                      statusPago.name,
                      style: new TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: medPadding),
                child: BotonRestTest(
                  token: sharedPrefs.clientToken,
                  url: '${urlApi}actualizar/estatus-orden',
                  formkey: formKey,
                  arrayData: {
                    "id_de_orden": jsonOrden['id_de_orden'],
                    "estatus_de_envio": jsonOrden['estatus_de_envio'],
                    "estatus_de_orden": jsonOrden['estatus_de_orden'],
                    "estatus_de_pago": statusValuePago.id,
                    "comments": null
                  },
                  method: 'post',
                  action: (value) => getDetalles(),
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
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  cambiarStatusOrden(id, status) {
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

  misProductos(context) {
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
        child: products(jsonRelaciones));
  }

  products(prod) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          itemCount: prod.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return productList(prod[index]);
          },
        ),
        // Divider(
        //   color: bgGrey,
        //   thickness: 2,
        // ),
        SizedBox(
          height: smallPadding,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TOTAL',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 17),
            ),
            Text(
              '\$${jsonOrden['monto_total']} MXN',
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 17),
            )
          ],
        )
      ],
    );
  }

  productList(prodjson) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: smallPadding,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Flexible(
            //   flex: 2,
            //   child: getAsset(prodjson['img'], 60),
            // ),
            Flexible(
              flex: 5,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: smallPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(prodjson['nombre'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        )),
                    Text('${prodjson['nombre_farmacia']}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                            fontSize: 13)),
                    // SizedBox(height: smallPadding * 2),
                  ],
                ),
              ),
            ),
            Flexible(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '\$${prodjson['subtotal']} MXN ',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.blue),
                    ),
                    Text(
                      'x ${prodjson['cantidad']} unidades',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    )
                  ],
                )),
          ],
        ),
        Divider(
          color: bgGrey,
          thickness: 2,
        ),
      ],
    );
  }
}

Widget statusProcess() {
  return Container(
      width: 150,
      padding: EdgeInsets.all(smallPadding / 2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.blue[600].withOpacity(0.7)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info, color: Colors.white, size: 17),
          SizedBox(
            width: 5,
          ),
          Text(
            'Pedido en proceso',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ));
}

Widget statusShipped() {
  return Container(
      width: 150,
      padding: EdgeInsets.all(smallPadding / 2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.blue[600].withOpacity(0.7)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_shipping_outlined, color: Colors.white, size: 17),
          SizedBox(
            width: 5,
          ),
          Text(
            'Pedido en camino',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ));
}

Widget statusConfirmed() {
  return Container(
      width: 155,
      padding: EdgeInsets.all(smallPadding / 2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.orange[600].withOpacity(0.7)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time_rounded, color: Colors.white, size: 17),
          SizedBox(
            width: 5,
          ),
          Text(
            'Pedido confirmado',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ));
}

Widget statusDelivered() {
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
            'Pedido entregado',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ));
}

Widget statusWaitingPay() {
  return Container(
      width: 150,
      padding: EdgeInsets.all(smallPadding / 2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.orange[600].withOpacity(0.7)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.payment_outlined, color: Colors.white, size: 17),
          SizedBox(
            width: 5,
          ),
          Text(
            'Esperando pago',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ));
}

Widget statusUnknown() {
  return Container(
      width: 170,
      padding: EdgeInsets.all(smallPadding / 2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.blue[700].withOpacity(0.7)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, color: Colors.white, size: 17),
          SizedBox(
            width: 5,
          ),
          Text(
            'Estado desconocidio',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ));
}

Widget statusCancel() {
  return Container(
      width: 180,
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
            'Pedido cancelado',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ));
}

Widget infoOrden(String str, icon, context) {
  return str == null
      ? Container()
      : Padding(
          padding: EdgeInsets.only(bottom: smallPadding),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              SizedBox(
                width: smallPadding,
              ),
              Flexible(
                child: Text(
                  str.toString(),
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        );
}
