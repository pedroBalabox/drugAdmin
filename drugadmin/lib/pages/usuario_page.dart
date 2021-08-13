import 'dart:convert';
import 'package:drugadmin/service/restFunction.dart';
import 'package:drugadmin/service/sharedPref.dart';
import 'package:drugadmin/utils/globals.dart';
import 'package:drugadmin/utils/theme.dart';
import 'package:drugadmin/widget/drawerVendedor_widget.dart';
import 'package:drugadmin/widget/testRest.dart';
import 'package:flutter/material.dart';

class UsuariosPage extends StatefulWidget {
  UsuariosPage({Key key}) : super(key: key);

  @override
  _UsuariosPageState createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  var orden;

  var jsonOrden;

  RestFun rest = RestFun();

  String filterValue = 'Clientes';

  String errorStr;
  bool load = true;
  bool error = false;

  List searchList = [];
  bool _isSearching = false;

  List myUsers = [];

  @override
  void initState() {
    super.initState();
    sharedPrefs.init().then((value) => gerUser('client'));
  }

  gerUser(filter) async {
    setState(() {
      _isSearching = false;
    });
    var arrayData = {"estatus": null};
    await rest
        .restService(arrayData, '${urlApi}obtener/usuarios',
            sharedPrefs.clientToken, 'post')
        .then((value) {
      if (value['status'] == 'server_true') {
        var ordenResp = value['response'];
        ordenResp = jsonDecode(ordenResp)[1];
        setState(() {
          orden = ordenResp;
          // orden = ordenResp.values.toList();
        });
        filterType(filter);
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
      for (int i = 0; i < myUsers.length; i++) {
        String dataNombre = myUsers[i]['name'].toString();
        String dataPApellido = myUsers[i]['first_lastname'].toString();
        String dataSApellido = myUsers[i]['second_lastname'].toString();
        String dataSCorreo = myUsers[i]['mail'].toString();
        String dataPhone = myUsers[i]['phone'].toString();
        if (dataNombre.toLowerCase().contains(searchText.toLowerCase()) ||
            dataPApellido.toLowerCase().contains(searchText.toLowerCase()) ||
            dataSApellido.toLowerCase().contains(searchText.toLowerCase()) ||
            dataSCorreo.toLowerCase().contains(searchText.toLowerCase()) ||
            dataPhone.toLowerCase().contains(searchText.toLowerCase())) {
          setState(() {
            searchList.add(myUsers[i]);
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

  void filterType(String filter) {
    myUsers.clear();
    // _handleFilterStart();
    if (_isSearching != null) {
      for (int i = 0; i < orden.length; i++) {
        String dataType = orden[i]['type'].toString();
        if (dataType.toLowerCase().contains(filter.toLowerCase())) {
          setState(() {
            myUsers.add(orden[i]);
            load = false;
          });
        }
      }
    }
  }

  // void _handleFilterStart() {
  //   setState(() {
  //     _isFiltes = true;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return ResponsiveApp(
        drawerMenu: true,
        screenWidht: MediaQuery.of(context).size.width,
        body: bodyTiendas(),
        title: "Usuarios");
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
                  'Tipo:',
                  style: TextStyle(fontSize: 15),
                )
              : Container(),
          filterOption()
        ],
        showCheckboxColumn: false,
        columns: kTableColumns,
        source: DataSource(
            mycontext: context, dataData: _isSearching ? searchList : myUsers)
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
        if (newValue == 'Clientes') {
          gerUser('client');
        } else if (newValue == 'Vendedor') {
          gerUser('vendor');
        }
      },
      items: <String>['Clientes', 'Vendedor']
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
            hintText: 'Buscar usuario....',
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
      'Primer apellido',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Segundo apellido',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Tipo de usuario',
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
      'Teléfono',
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
      'Cambiar estatus',
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

    String userTag;

    switch (_myData['client_tag'].toString()) {
      case 'general':
        userTag = 'Público en general';
        break;
      case 'general_doctor':
        userTag = 'Médico General';
        break;
      case 'specialist_doctor':
        userTag = 'Médico Especialista';
        break;
      case 'professional':
        userTag = 'Profesional de la salud';
        break;
      case 'general_pharmacy':
        userTag = 'Farmacia General';
        break;
      case 'specialized_pharmacy':
        userTag = 'Farmacia especializada';
        break;
      case 'clinic':
        userTag = 'Clínica';
        break;
      case 'hospital':
        userTag = 'Hospital';
        break;
      case 'health_company':
        userTag = 'Empresa Sector Salud';
        break;
      case 'distributor':
        userTag = 'Distribuidor Farmacéutico';
        break;
      case 'wholesaler':
        userTag = 'Mayorista Farmacéutico';
        break;
      case 'retailer':
        userTag = 'Minorista Farmacéutico';
        break;
      case 'importer':
        userTag = 'Importadora';
        break;
      case 'marketer':
        userTag = 'Comercializadora';
        break;
      default:
        userTag = 'Desconocido';
    }

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
            backgroundImage: _myData['profile_picture'] == null
                ? AssetImage('images/logo.png')
                : NetworkImage(_myData['profile_picture']),
          )),
          DataCell(Text('${_myData['name']}')),
          DataCell(Text('${_myData['first_lastname']}')),
          DataCell(Text('${_myData['second_lastname']}')),
          DataCell(Text(userTag)),
          DataCell(Text('${_myData['mail']}')),
          DataCell(Text('${_myData['phone']}')),
          // DataCell(Text(_myData['type'] == 'client' ? 'Cliente' : 'Vendedor')),
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
          DataCell(BotonRestTest(
              method: 'post',
              arrayData: {"user_id": _myData['user_id']},
              token: sharedPrefs.clientToken,
              url: _myData['status'] != 'active'
                  ? '${urlApi}habilitar/usuario'
                  : '${urlApi}deshabilitar/usuario',
              estilo: _myData['status'] != 'active'
                  ? estiloBotonPrimary
                  : estiloBotonSecundary,
              action: (value) => Navigator.pushNamedAndRemoveUntil(
                  _context, '/usuarios', (route) => false),
              contenido: Text(
                  _myData['status'] != 'active' ? 'Activar' : 'Deshabilitar',
                  style: TextStyle(
                    color: Colors.white,
                  )))),
        ]);
  }

  @override
  int get rowCount => _dataData.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
