import 'dart:convert';

import 'package:codigojaguar/codigojaguar.dart';
import 'package:drugadmin/pages/addPorducts_page.dart';
import 'package:drugadmin/service/restFunction.dart';
import 'package:drugadmin/service/sharedPref.dart';
import 'package:drugadmin/utils/globals.dart';
import 'package:drugadmin/utils/route.dart';
import 'package:drugadmin/utils/theme.dart';
import 'package:drugadmin/widget/drawerVendedor_widget.dart';
import 'package:flutter/material.dart';

import 'editProduct_page.dart';

class VerProductos extends StatefulWidget {
  static const routeName = '/farmacia-verProductos';

  final dynamic jsonData;

  VerProductos({Key key, this.jsonData}) : super(key: key);

  @override
  _VerProductosState createState() => _VerProductosState();
}

class _VerProductosState extends State<VerProductos> {
  var orden;

  var jsonProdcut;

  RestFun rest = RestFun();

  String filterValue = 'Activas';

  String errorStr;
  bool load = true;
  bool error = false;

  List searchList = [];
  bool _isSearching = false;

  DateTime selectedDate = DateTime.now();

  bool cargarProductosRow = false;

  @override
  void initState() {
    super.initState();
    //print('----' + widget.jsonData.jsonData.toString());
    sharedPrefs.init().then((value) => getProductos());
  }

  getProductos() async {
    // setState(() {
    //   load = true;
    // });
    var arrayData = {"farmacia_id": widget.jsonData.jsonData['farmacia_id']};
    await rest
        .restService(arrayData, '${urlApi}farmacia/mis-productos',
            sharedPrefs.clientToken, 'post')
        .then((value) {
      if (value['status'] == 'server_true') {
        var productosResp = value['response'];
        productosResp = jsonDecode(productosResp)[1];
        setState(() {
          jsonProdcut = productosResp['productos'];
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

  // checkBoolRow() async {
  //   print('---' + DataSource.onTapProduct.toString());
  //   var arrayData = {"farmacia_id": widget.jsonData.jsonData['farmacia_id']};
  //   await rest
  //       .restService(arrayData, '${urlApi}farmacia/mis-productos',
  //           sharedPrefs.clientToken, 'post')
  //       .then((value) {
  //     if (value['status'] == 'server_true') {
  //       var productosResp = value['response'];
  //       productosResp = jsonDecode(productosResp)[1];
  //       setState(() {
  //         jsonProdcut = productosResp['productos'];
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
  //   // setState(() {
  //   //   cargarProductosRow = DataSource.onTapProduct;
  //   // });
  //   // () {};
  // }

  void searchOperation(String searchText) {
    searchList.clear();
    _handleSearchStart();
    if (_isSearching != null) {
      for (int i = 0; i < jsonProdcut.length; i++) {
        String dataNombre = jsonProdcut[i]['nombre'];
        if (dataNombre.toLowerCase().contains(searchText.toLowerCase())) {
          setState(() {
            searchList.add(jsonProdcut[i]);
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
        drawerMenu: false,
        screenWidht: MediaQuery.of(context).size.width,
        body: bodyTiendas(),
        title: "Productos de ${widget.jsonData.jsonData['nombre']}");
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
              onPressed: () =>
                  Navigator.pushNamed(context, AddProducts.routeName,
                      arguments: AddDetailArguments(
                        widget.jsonData.jsonData,
                      )).then((value) => getProductos()))
          // SimpleButtom(
          //     mainText: 'mainText',
          //     pressed: () => _buildMaterialDatePicker(context))
        ],
        showCheckboxColumn: false,
        columns: kTableColumns,
        source: DataSource(
            mycontext: context,
            dataData: _isSearching ? searchList : jsonProdcut,
            farmaciaData: widget.jsonData.jsonData)
        // dataCat: searchList.length == 0 ? userData : searchList),
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
            hintText: 'Buscar producto....',
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
      'Nombre',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Marca',
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
      'Stock',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Precio',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Precio mayoreo',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Precio descuento',
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
      '',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
];

////// Data source class for obtaining row data for PaginatedDataTable.
class DataSource extends DataTableSource {
  BuildContext _context;
  dynamic _dataData;
  dynamic _farmaciaData;

  DataSource({
    @required dynamic dataData,
    @required BuildContext mycontext,
    @required dynamic farmaciaData,
  })  : _dataData = dataData,
        _context = mycontext,
        _farmaciaData = farmaciaData,
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
          // Navigator.pushNamed(_context, BannerDetalles.routeName,
          //         arguments: BannerDetailArguments(
          //           _myData,
          //         ))
          //     .whenComplete(() => Navigator.pushNamedAndRemoveUntil(
          //         _context, '/banner', (route) => false));
        },
        cells: <DataCell>[
          DataCell(Container(
            width: 100,
            child: Text(
              '${_myData['nombre']}',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          )),
          DataCell(Container(
            width: 100,
            child: Text(
              '${_myData['marca']}',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          )),
          DataCell(Container(
            width: 200,
            child: Text(
              '${_myData['descripcion']}',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          )),
          DataCell(Text('${_myData['stock']}')),
          DataCell(Text('\$${_myData['precio']}')),
          DataCell(Text('\$${_myData['precio_mayoreo']}')),
          DataCell(Text('\$${_myData['precio_con_descuento']}')),
          DataCell(
            Text(
              _myData['status'] == 'active' ? 'Activo' : 'Inhabilitado',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _myData['status'] == 'active'
                      ? Colors.green[800]
                      : Colors.red[800]),
            ),
          ),
          DataCell(Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: BotonSimple(
              action: () {
                Navigator.pushNamed(_context, EditarProducto.routeName,
                        arguments: EditDetailArguments(_myData))
                    .whenComplete(() {
                  Navigator.pushNamedAndRemoveUntil(
                    _context,
                    VerProductos.routeName,
                    (route) => true,
                    arguments: VerProductosDetailArguments(
                      _farmaciaData,
                    ),
                  ).then((value) => Navigator.pop(_context));
                });
              },
              //       .then((value) => action);
              //   onTapProduct = true;
              // },
              // .whenComplete(() => Navigator.pushNamedAndRemoveUntil(
              //     _context, '/categorias', (route) => false)),
              estilo: estiloBotonPrimary,
              contenido: Padding(
                padding: EdgeInsets.all(0),
                child: Text('Ver más',
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
