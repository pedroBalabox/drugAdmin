import 'dart:convert';
import 'package:drugadmin/pages/bannerDetalles_page.dart';
import 'package:drugadmin/pages/tiendaDetalles_page.dart';
import 'package:drugadmin/service/restFunction.dart';
import 'package:drugadmin/service/sharedPref.dart';
import 'package:drugadmin/utils/globals.dart';
import 'package:drugadmin/utils/route.dart';
import 'package:drugadmin/utils/theme.dart';
import 'package:drugadmin/widget/buttom_widget.dart';
import 'package:drugadmin/widget/drawerVendedor_widget.dart';
import 'package:drugadmin/widget/month_widget.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:intl/intl.dart';

class BannerPage extends StatefulWidget {
  BannerPage({Key key}) : super(key: key);

  @override
  _BannerPageState createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage> {
  var orden;

  var jsonOrden;

  RestFun rest = RestFun();

  String filterValue = 'Activas';

  String errorStr;
  bool load = true;
  bool error = false;

  List searchList = [];
  bool _isSearching = false;

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    sharedPrefs.init().then((value) => getBanner('approved'));
  }

  getBanner(status) async {
    setState(() {
      load = true;
    });
    // var arrayData = {"fecha_de_exposicion": selectedDate};
    await rest
        .restService(
            null, '${urlApi}obtener/banners', sharedPrefs.clientToken, 'post')
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
        String dataNombre = orden[i]['titulo'];
        String dataDate = orden[i]['fecha_de_exposicion'].toString();
        if (dataNombre.toLowerCase().contains(searchText.toLowerCase()) ||
            dataDate.toLowerCase().contains(searchText.toLowerCase())) {
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
        title: "Banners");
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
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () => Navigator.pushNamed(context, '/agregarbanner')
                  .then((value) => getBanner('approved')))
          // SimpleButtom(
          //     mainText: 'mainText',
          //     pressed: () => _buildMaterialDatePicker(context))
        ],
        showCheckboxColumn: false,
        columns: kTableColumns,
        source: DataSource(
            mycontext: context, dataData: _isSearching ? searchList : orden)
        // dataCat: searchList.length == 0 ? userData : searchList),
        );
  }

  _buildMaterialDatePicker(BuildContext context) async {
    showMonthPicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 2),
      initialDate: DateTime.now(),
      locale: Locale("es"),
    ).then((date) {
      if (date != null) {
        setState(() {
          selectedDate = date;
        });
      }
    });
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
          getBanner('approved');
        } else if (newValue == 'Espera') {
          getBanner('waiting_for_review');
        } else if (newValue == 'Rechazadas') {
          getBanner('rejected');
        } else if (newValue == 'Bloquedas') {
          getBanner('blocked');
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
            hintText: 'Buscar banner....',
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
      'Titulo',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Descripción',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Fecha de exposición',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Posición',
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
          Navigator.pushNamed(_context, BannerDetalles.routeName,
                  arguments: BannerDetailArguments(
                    _myData,
                  ))
              .whenComplete(() => Navigator.pushNamedAndRemoveUntil(
                  _context, '/banner', (route) => false));
        },
        cells: <DataCell>[
          DataCell(Container(
            width: 40,
            decoration: BoxDecoration(
                image: DecorationImage(
              image: _myData['imagen_escritorio'] == null
                  ? AssetImage('images/logo.png')
                  : NetworkImage(_myData['imagen_escritorio']),
            )),
          )),
          DataCell(Text('${_myData['titulo']}')),
          DataCell(Container(
            width: 200,
            child: Text(
              '${_myData['descripcion']}',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          )),
          DataCell(_myData['fecha_de_exposicion'] == null
              ? Container()
              : Text(DateFormat('yyyy-MM')
                  .format(DateTime.parse(_myData['fecha_de_exposicion'])))),
          DataCell(Text('${_myData['posicion']}')),
        ]);
  }

  @override
  int get rowCount => _dataData.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
