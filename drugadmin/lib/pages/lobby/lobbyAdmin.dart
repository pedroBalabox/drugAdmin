import 'package:drugadmin/pages/addBanner_page.dart';
import 'package:drugadmin/pages/banner_page.dart';
import 'package:drugadmin/pages/lobby/validate_page.dart';
import 'package:drugadmin/pages/login_page.dart';
import 'package:drugadmin/pages/orden_page.dart';
import 'package:drugadmin/pages/productos_page.dart';
import 'package:drugadmin/pages/tienda_page.dart';
import 'package:drugadmin/pages/usuario_page.dart';
import 'package:flutter/material.dart';

class LobbyAdmin extends StatefulWidget {
  final String ruta;
  LobbyAdmin({Key key, @required this.ruta}) : super(key: key);
  @override
  _LobbyAdminState createState() => _LobbyAdminState();
}

class _LobbyAdminState extends State<LobbyAdmin> {
  @override
  void initState() {
    super.initState();
    validateClientToken(context).then((value) {
      if (value == 'null') {
        redirigirRuta(false);
      } else {
        validateClient(context, value).then((value) {
          redirigirRuta(value);
        });
      }
    });
  }

  redirigirRuta(bool clientAuth) {
    print('MI RUTAAA!!' + widget.ruta.toString());
    switch (widget.ruta) {
      case '/':
        if (clientAuth) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/tiendas', (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
        }
        break;
      case '/login':
        if (clientAuth) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/tiendas', (route) => false);
        } else {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LoginPage()),
              (Route<dynamic> route) => false);
        }
        break;
      case '/tiendas':
        if (clientAuth) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => TiendasPage()),
              (Route<dynamic> route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
        }
        break;
      case '/productos':
        if (clientAuth) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => ProductosPage()),
              (Route<dynamic> route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
        }
        break;
      case '/ordenes':
        if (clientAuth) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => OrdenPage()),
              (Route<dynamic> route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
        }
        break;
      case '/usuarios':
        if (clientAuth) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => UsuariosPage()),
              (Route<dynamic> route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
        }
        break;
      case '/banner':
        if (clientAuth) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => BannerPage()),
              (Route<dynamic> route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
        }
        break;
      case '/agregarbanner':
        if (clientAuth) {
          Navigator.of(context)
              .pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => CrearBanner()),
                  (route) => true)
              .then((value) => Navigator.pop(context));
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
        }
        break;
      default:
        if (clientAuth) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/banner', (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
