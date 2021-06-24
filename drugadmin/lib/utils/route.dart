import 'package:drugadmin/pages/addBanner_page.dart';
import 'package:drugadmin/pages/banner_page.dart';
import 'package:drugadmin/pages/lobby/lobbyAdmin.dart';
import 'package:drugadmin/pages/login_page.dart';
import 'package:drugadmin/pages/orden_page.dart';
import 'package:drugadmin/pages/productos_page.dart';
import 'package:drugadmin/pages/tienda_page.dart';
import 'package:drugadmin/pages/usuario_page.dart';

class TiendaDetailArguments {
  final dynamic jsonData;

  TiendaDetailArguments(this.jsonData);
}

class BannerDetailArguments {
  final dynamic jsonData;

  BannerDetailArguments(this.jsonData);
}

class OrdenDetailArguments {
  final dynamic jsonData;

  OrdenDetailArguments(this.jsonData);
}

class VerProductosDetailArguments {
  final dynamic jsonData;

  VerProductosDetailArguments(this.jsonData);
}

class TiendaProductosDetailArguments {
  final dynamic jsonData;

  TiendaProductosDetailArguments(this.jsonData);
}

class AddDetailArguments {
  final dynamic jsonData;

  AddDetailArguments(this.jsonData);
}

class CatDetailArguments {
  final dynamic jsonData;

  CatDetailArguments(this.jsonData);
}

class EditDetailArguments {
  final dynamic jsonData;

  EditDetailArguments(this.jsonData);
}

var rutasDrug = {
  '/login': (context) => LobbyAdmin(ruta: '/login'),
  '/farmacias': (context) => LobbyAdmin(ruta: '/farmacias'),
  '/productos': (context) =>LobbyAdmin(ruta: '/productos'),
  '/ordenes': (context) => LobbyAdmin(ruta: '/ordenes'),
  '/usuarios': (context) => LobbyAdmin(ruta: '/usuarios'),
  '/categorias': (context) => LobbyAdmin(ruta: '/categorias'),
  '/etiquetas': (context) => LobbyAdmin(ruta: '/etiquetas'),
  '/banner': (context) => LobbyAdmin(ruta: '/banner'),
  '/agregarbanner': (context) => LobbyAdmin(ruta: '/agregarbanner'),
  '/agregarCategoria': (context) => LobbyAdmin(ruta: '/agregarCategoria'),
  '/agregarEtiqueta': (context) => LobbyAdmin(ruta: '/agregarEtiqueta'),
};
