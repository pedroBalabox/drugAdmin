import 'dart:convert';
import 'package:codigojaguar/codigojaguar.dart';
import 'package:drugadmin/pages/productosFarmacia_page.dart';
import 'package:drugadmin/pages/productosTienda_page.dart';
import 'package:drugadmin/pages/tiendaDetalles_page.dart';
import 'package:drugadmin/service/restFunction.dart';
import 'package:drugadmin/service/sharedPref.dart';
import 'package:drugadmin/utils/globals.dart';
import 'package:drugadmin/utils/route.dart';
import 'package:drugadmin/utils/theme.dart';
import 'package:drugadmin/widget/drawerVendedor_widget.dart';
import 'package:flutter/material.dart';

class TiendasPage extends StatefulWidget {
  TiendasPage({Key key}) : super(key: key);

  @override
  _TiendasPageState createState() => _TiendasPageState();
}

class _TiendasPageState extends State<TiendasPage> {
  var orden;

  var jsonOrden;

  RestFun rest = RestFun();

  String filterValue = 'Activas';

  String errorStr;
  bool load = true;
  bool error = false;

  List searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    sharedPrefs.init().then((value) => getTiendas('approved'));
  }

  getTiendas(status) async {
    var arrayData = {"estatus": status};
    setState(() {
      _isSearching = false;
    });
    await rest
        .restService(arrayData, '${urlApi}obtener/farmacias',
            sharedPrefs.clientToken, 'post')
        .then((value) {
      if (value['status'] == 'server_true') {
        var ordenResp = value['response'];
        ordenResp = jsonDecode(ordenResp)[1];
        setState(() {
          orden = ordenResp;
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
        String dataNombre = orden[i]['nombre'];
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
        title: "Farmacias");
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
        if (newValue == 'Activas') {
          getTiendas('approved');
        } else if (newValue == 'Espera') {
          getTiendas('waiting_for_review');
        } else if (newValue == 'Rechazadas') {
          getTiendas('rejected');
        } else if (newValue == 'Bloquedas') {
          getTiendas('blocked');
        }
      },
      items: <String>['Activas', 'Espera', 'Rechazadas', 'Bloquedas']
          .map<DropdownMenuItem<String>>((String value) {
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
            hintText: 'Buscar tienda....',
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
      'Nombre',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Giro',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Nombre del propietario',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Correo',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Ver más',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Ver productos',
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
          DataCell(Text('${_myData['nombre']}')),
          DataCell(Text('${_myData['giro']}')),
          DataCell(Text('${_myData['nombre_propietario']}')),
          DataCell(Text('${_myData['correo']}')),
          DataCell(Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: BotonSimple(
              action: () =>
                  Navigator.pushNamed(_context, TiendaDetalles.routeName,
                          arguments: TiendaDetailArguments(
                            _myData,
                          ))
                      .whenComplete(() => Navigator.pushNamedAndRemoveUntil(
                          _context, '/farmacias', (route) => false)),
              estilo: estiloBotonSecundary,
              contenido: Padding(
                padding: EdgeInsets.all(0),
                child: Text('Ver más',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
          )),
          DataCell(Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: BotonSimple(
              action: () =>
                  Navigator.pushNamed(_context, VerProductos.routeName,
                          arguments: VerProductosDetailArguments(
                            _myData,
                          ))
                      .whenComplete(() => Navigator.pushNamedAndRemoveUntil(
                          _context, '/farmacias', (route) => false)),
              estilo: estiloBotonPrimary,
              contenido: Padding(
                padding: EdgeInsets.all(0),
                child: Text('Ver productos',
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
