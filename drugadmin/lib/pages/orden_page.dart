import 'dart:convert';
import 'package:drugadmin/pages/ordenDetalles_page.dart';
import 'package:drugadmin/service/restFunction.dart';
import 'package:drugadmin/service/sharedPref.dart';
import 'package:drugadmin/utils/globals.dart';
import 'package:drugadmin/utils/route.dart';
import 'package:drugadmin/utils/theme.dart';
import 'package:drugadmin/widget/drawerVendedor_widget.dart';
import 'package:flutter/material.dart';

class OrdenPage extends StatefulWidget {
  OrdenPage({Key key}) : super(key: key);

  @override
  _OrdenPageState createState() => _OrdenPageState();
}

class _OrdenPageState extends State<OrdenPage> {
  var orden;

  var jsonOrden;

  RestFun rest = RestFun();

  String filterValue = 'Confirmado';

  String errorStr;
  bool load = true;
  bool error = false;

  List searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    sharedPrefs.init().then((value) => getOrden('confirmed'));
  }

  getOrden(String status) async {
    var arrayData = {"estatus": status};
    await rest
        .restService(
            arrayData, '${urlApi}ver/ordenes', sharedPrefs.clientToken, 'post')
        .then((value) {
      if (value['status'] == 'server_true') {
        var ordenResp = value['response'];
        ordenResp = jsonDecode(ordenResp)[1];
        setState(() {
          orden = ordenResp['orders'];
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
        String dataNombre = orden[i]['folio'];
        if (dataNombre.toLowerCase().contains(searchText.toLowerCase())) {
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
        title: "Órdenes");
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
        switch (newValue) {
          case 'En revisión':
            getOrden('in_process');
            break;
          case 'Confirmado':
            getOrden('confirmed');
            break;
          case 'En camino':
            getOrden('shipped');
            break;
          case 'Entregado':
            getOrden('delivered');
            break;
          case 'Cancelado':
            getOrden('cancelled');
            break;
          case 'Esperando pago':
            getOrden('waiting_for_payment');
            break;
          case 'Todas':
            getOrden(null);
            break;
          default:
            getOrden(null);
        }
      },
      items: <String>[
        'Todas',
        'En revisión',
        'Confirmado',
        'En camino',
        'Entregado',
        'Cancelado',
        'Esperando pago'
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
            hintText: 'Buscar órden....',
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
      'Folio',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Cliente',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Núm. de procutos',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Total',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Estatus de órden',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Estatus de envio',
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

    String estatusOrden;
    String estatusEnvio;

    // estatus de orden
    switch (_myData['estatus_de_orden']) {
      case 'confirmed':
        estatusOrden = 'Confirmado';
        break;
      case 'in_process':
        estatusOrden = 'En revisión';
        break;
      case 'shipped':
        estatusOrden = 'En camino';
        break;
      case 'delivered':
        estatusOrden = 'Entregado';
        break;
      case 'cancelled':
        estatusOrden = 'Cancelado';
        break;
      case 'waiting_for_payment':
        estatusOrden = 'Esperando pago';
        break;
      default:
        estatusOrden = 'Desconocido';
    }

    // estatus de orden
    switch (_myData['estatus_de_envio']) {
      case 'preparing':
        estatusEnvio = 'En preparación';
        break;
      case 'on_the_way':
        estatusEnvio = 'En camino';
        break;
      case 'delivered':
        estatusEnvio = 'Entregado';
        break;
      default:
        estatusEnvio = 'Desconocido';
    }

    return DataRow.byIndex(
        index: index, // DONT MISS THIS
        onSelectChanged: (bool value) {
          // _dialogCall(_context, _myData.categoria_id, _myData);
          Navigator.pushNamed(_context, OrdenDetalles.routeName,
                  arguments: OrdenDetailArguments(
                    _myData,
                  ))
              .whenComplete(() => Navigator.pushNamedAndRemoveUntil(
                  _context, '/ordenes', (route) => false));
        },
        cells: <DataCell>[
          DataCell(Text('${_myData['id_de_orden']}')),
          DataCell(Text('${_myData['cliente']}')),
          DataCell(Text('${_myData['cantidad_de_productos']}')),
          DataCell(Text('\$${_myData['monto_total']}')),
          DataCell(Text(estatusOrden)),
          DataCell(Text(estatusEnvio)),
        ]);
  }

  @override
  int get rowCount => _dataData.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
