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

class Status {
  const Status(this.id, this.name);

  final String name;
  final String id;
}

class ProductosPage extends StatefulWidget {
  ProductosPage({Key key}) : super(key: key);

  @override
  _ProductosPageState createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  var orden;

  var jsonOrden;

  RestFun rest = RestFun();

  String filterValue = 'Publicado';

  String errorStr;
  bool load = true;
  bool error = false;

  List searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    Jiffy.locale('es');
    sharedPrefs.init().then((value) => getProductos('published'));
  }

  getProductos(status) async {
    setState(() {
      _isSearching = false;
    });
    var arrayData = {"estatus": status};
    await rest
        .restService(arrayData, '${urlApi}ver/carga-productos',
            sharedPrefs.clientToken, 'post')
        .then((value) {
      if (value['status'] == 'server_true') {
        var ordenResp = value['response'];
        ordenResp = jsonDecode(ordenResp)[1];
        setState(() {
          orden = ordenResp['solicitudes'];
          // orden = ordenResp.values.toList();
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

  void searchOperation(String searchText) {
    searchList.clear();
    _handleSearchStart();
    if (_isSearching != null) {
      for (int i = 0; i < orden.length; i++) {
        String dataFolio = orden[i]['folio'];
        String dataNombre = orden[i]['nombre'];
        if (dataFolio.toLowerCase().contains(searchText.toLowerCase()) ||
            dataNombre.toLowerCase().contains(searchText.toLowerCase())) {
          setState(() {
            searchList.add(orden[i]);
          });
        }
      }
    }
  }

  void _handleSearchStart() {
    setState(() {
      _isSearching = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveApp(
        drawerMenu: true,
        screenWidht: MediaQuery.of(context).size.width,
        body: bodyTiendas(),
        title: "Productos");
  }

  Widget bodyTiendas() {
    var size = MediaQuery.of(context).size;
    return Container(
      color: bgGrey,
      height: MediaQuery.of(context).size.height,
      child: load
          ? bodyLoad(context)
          : error
              ? errorWidget(errorStr, context)
              : Column(
                  children: [
                    // SizedBox(
                    //   height: medPadding * 1.6,
                    // ),
                    Expanded(
                      child: ListView(children: [
                        Container(
                          padding: EdgeInsets.all(size.width > 850
                              ? medPadding * .75
                              : medPadding * .5),
                          color: bgGrey,
                          width: MediaQuery.of(context).size.width / 6,
                          child: misVentas(),
                        ),
                      ]),
                    ),
                  ],
                ),
    );
  }

  misVentas() {
    return PaginatedDataTable(
        // headingRowHeight: 180,
        // rowsPerPage: 7,
        header: MediaQuery.of(context).size.width > 700
            ? Row(
                children: [
                  Flexible(
                    flex: 2,
                    child: Container(),
                  ),
                  Flexible(
                    flex: 5,
                    child: search(),
                  ),
                  Flexible(
                    flex: 2,
                    child: Container(),
                  )
                ],
              )
            : search(),
        actions: [
          MediaQuery.of(context).size.width > 700
              ? Text(
                  'Estatus:',
                  style: TextStyle(fontSize: 15),
                )
              : Container(),
          filterOption()
        ],
        showCheckboxColumn: false,
        columns: kTableColumns,
        source: DataSource(
            mycontext: context, dataData: _isSearching ? searchList : orden)
        // dataCat: searchList.length == 0 ? userData : searchList),
        );
  }

  filterOption() {
    return DropdownButton<String>(
      value: filterValue,
      icon: const Icon(Icons.arrow_drop_down),
      iconSize: 10,
      elevation: 16,
      style: const TextStyle(color: Colors.black87),
      underline: Container(
        height: 2,
        color: Colors.blue,
      ),
      onChanged: (String newValue) {
        setState(() {
          filterValue = newValue;
          load = true;
        });
        if (newValue == 'Esperando productos') {
          getProductos('waiting_for_products');
        } else if (newValue == 'En revisión') {
          getProductos('review');
        } else if (newValue == 'Publicado') {
          getProductos('published');
        } else if (newValue == 'En espera') {
          getProductos('active');
        }
      },
      items: <String>[
        'Publicado',
        'En revisión',
        'Esperando productos',
        'En espera'
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  search() {
    return Container(
      height: 35,
      child: TextField(
        textInputAction: TextInputAction.search,
        textAlignVertical: TextAlignVertical.bottom,
        onChanged: (value) => searchOperation(value),
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(0)),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(0)),
            hintStyle: TextStyle(),
            hintText: 'Buscar folio o farmacia....',
            fillColor: bgGrey,
            filled: true),
      ),
    );
  }
}

////// Columns in table.
const kTableColumns = <DataColumn>[
  DataColumn(
    label: Text(
      '',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Folio',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Nombre',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Fecha',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Estatus',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Descargar',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
];

////// Data source class for obtaining row data for PaginatedDataTable.
class DataSource extends DataTableSource {
  BuildContext _context;
  dynamic _dataData;
  DataSource({
    @required dynamic dataData,
    @required BuildContext mycontext,
  })  : _dataData = dataData,
        _context = mycontext,
        assert(dataData != null);

  // DataSource({@required User userData}) : _vendedorData = userData;

  int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);

    if (index >= _dataData.length) {
      return null;
    }
    final _myData = _dataData[index];

    Icon iconStatus;

    return DataRow.byIndex(
        index: index, // DONT MISS THIS
        onSelectChanged: (bool value) {
          // _dialogCall(_context, _myData.categoria_id, _myData);
          // Navigator.pushNamed(_context, TiendaDetalles.routeName,
          //         arguments: TiendaDetailArguments(
          //           _myData,
          //         ))
          //     .whenComplete(() => Navigator.pushNamedAndRemoveUntil(
          //         _context, '/farmacias', (route) => false));
        },
        cells: <DataCell>[
          DataCell(CircleAvatar(
            backgroundColor: Colors.grey[400],
            backgroundImage: _myData['logo'] == null
                ? AssetImage('images/logo.png')
                : NetworkImage(_myData['logo']),
          )),
          DataCell(Text('${_myData['folio']}')),
          DataCell(Text('${_myData['nombre']}')),
          // DataCell(getstatus(_myData['estatus'])),
          DataCell(Text(Jiffy(_myData['fecha_de_creacion'])
              .format('MMMM do yyyy, h:mm a'))),
          DataCell(Padding(
              padding: const EdgeInsets.symmetric(vertical: 7.0),
              child: Row(
                children: [
                  getstatus(_myData['estatus']),
                  SizedBox(
                    width: 7,
                  ),
                  BotonSimple(
                    action: () => _editStatus(_context, _myData).whenComplete(
                        () => Navigator.pushNamedAndRemoveUntil(
                            _context, '/productos', (route) => false)),
                    // estilo: estiloBotonPrimary,
                    contenido: Icon(
                      Icons.more_vert_outlined,
                      color: Colors.black38,
                      size: 15,
                    ),
                  ),
                ],
              ))),
          DataCell(Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: BotonSimple(
              action: () => launchURL(_myData['url_archivo']),
              estilo: estiloBotonSecundary,
              contenido: Padding(
                padding: EdgeInsets.all(0),
                child: Text('Descargar',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
          )),
        ]);
  }

  @override
  int get rowCount => _dataData.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}

Widget getstatus(status) {
  Widget myWidget;

  switch (status) {
    case 'waiting_for_products':
      myWidget = Text('Esperando productos');
      break;
    case 'review':
      myWidget = Text('En revisión');
      break;
    case 'published':
      myWidget = Text('Publicado');
      break;
    case 'active':
      myWidget = Text('En espera');
      break;
    default:
  }
  return myWidget;
}

Future<void> _editStatus(BuildContext context, item) {
  return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return CambiarStatus(myItem: item);
      });
}

class CambiarStatus extends StatefulWidget {
  final dynamic myItem;
  CambiarStatus({Key key, @required this.myItem}) : super(key: key);

  @override
  _CambiarStatusState createState() => _CambiarStatusState();
}

class _CambiarStatusState extends State<CambiarStatus> {
  Status statusValue;

  List<Status> listaStatus = [];

  @override
  void initState() {
    super.initState();
    sharedPrefs.init();
    listaStatus.add(Status('published', 'Publicado'));
    listaStatus.add(Status('review', 'En revisión'));
    listaStatus.add(Status('waiting_for_products', 'Esperando productos'));
    listaStatus.add(Status('active', 'En espera'));
    if (widget.myItem['estatus'] == 'published') {
      statusValue = listaStatus[0];
    } else if (widget.myItem['estatus'] == 'review') {
      statusValue = listaStatus[1];
    } else if (widget.myItem['estatus'] == 'waiting_for_products') {
      statusValue = listaStatus[2];
    } else if (widget.myItem['estatus'] == 'active') {
      statusValue = listaStatus[3];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        clipBehavior: Clip.antiAlias,
        actions: [
          // InkWell(child: Text('Cancelar')),
          // InkWell(
          //     onTap: () => cambiarStatus(widget.myItem, statusValue),
          //     child: Text('Guardar'))
          BotonRestTest(
            method: 'post',
            url: '${urlApi}documento/actualizar-estatus',
            arrayData: {
              "archivo_id": widget.myItem['archivo_id'],
              "estatus": statusValue.id
            },
            token: sharedPrefs.clientToken,
            contenido: Text('Guardar'),
            action: (value) => Navigator.pop(context),
          )
        ],
        title: Text(
          'Cambiar status',
          textAlign: TextAlign.center,
        ),
        content: DropdownButton<Status>(
          value: statusValue,
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Colors.black38,
          ),
          iconSize: 13,
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
        ));
  }
}

// cambiarStatus(item, newStatus) async {
//   RestFun rest = RestFun();
//   var arrayData = {"archivo_id": item['archivo_id'], "estatus": newStatus.id};
//   await rest
//       .restService(arrayData, '${urlApi}documento/actualizar-estatus',
//           sharedPrefs.clientToken, 'post')
//       .then((value) => null);
// }
