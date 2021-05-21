import 'dart:io';

import 'package:drugadmin/pages/addPorducts_page.dart';
import 'package:drugadmin/pages/bannerDetalles_page.dart';
import 'package:drugadmin/pages/lobby/lobbyAdmin.dart';
import 'package:drugadmin/pages/ordenDetalles_page.dart';
import 'package:drugadmin/pages/productosFarmacia_page.dart';
import 'package:drugadmin/pages/productosTienda_page.dart';
import 'package:drugadmin/pages/tiendaDetalles_page.dart';
import 'package:drugadmin/utils/route.dart';
import 'package:drugadmin/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_strategy/url_strategy.dart';
import 'dart:html' as html;

void main() async {
  setPathUrlStrategy();

  runApp(MyApp());
  if (!kIsWeb) {
    checkInternet();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Drug App',
      theme: appTheme(),
      debugShowCheckedModeBanner: false,
      // home: LobbyAdmin(
      //   ruta: html.window.location.pathname,
      //   // ruta: window.location.href
      //   //     .substring(16, window.location.href.length - 1)
      // ),
      initialRoute: '/login',
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (_) => LobbyAdmin(ruta: '/login'));
      },
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == TiendaDetalles.routeName) {
          // Cast the arguments to the correct
          // type: ScreenArguments.
          final TiendaDetailArguments args =
              settings.arguments as TiendaDetailArguments;

          // Then, extract the required data from
          // the arguments and pass the data to the
          // correct screen.
          return MaterialPageRoute(
            builder: (context) {
              return TiendaDetalles(
                jsonData: args,
              );
            },
          );
        }

        if (settings.name == BannerDetalles.routeName) {
          // Cast the arguments to the correct
          // type: ScreenArguments.
          final BannerDetailArguments args =
              settings.arguments as BannerDetailArguments;

          // Then, extract the required data from
          // the arguments and pass the data to the
          // correct screen.
          return MaterialPageRoute(
            builder: (context) {
              return BannerDetalles(
                jsonData: args,
              );
            },
          );
        }
        if (settings.name == OrdenDetalles.routeName) {
          // Cast the arguments to the correct
          // type: ScreenArguments.
          final OrdenDetailArguments args =
              settings.arguments as OrdenDetailArguments;

          // Then, extract the required data from
          // the arguments and pass the data to the
          // correct screen.
          return MaterialPageRoute(
            builder: (context) {
              return OrdenDetalles(
                jsonData: args,
              );
            },
          );
        }

        if (settings.name == TiendaProductos.routeName) {
          // Cast the arguments to the correct
          // type: ScreenArguments.
          final TiendaProductosDetailArguments args =
              settings.arguments as TiendaProductosDetailArguments;
          // Then, extract the required data from
          // the arguments and pass the data to the
          // correct screen.
          return MaterialPageRoute(
            builder: (context) {
              return TiendaProductos(
                jsonData: args,
              );
            },
          );
        }

        if (settings.name == VerProductos.routeName) {
          // Cast the arguments to the correct
          // type: ScreenArguments.
          final VerProductosDetailArguments args =
              settings.arguments as VerProductosDetailArguments;
          // Then, extract the required data from
          // the arguments and pass the data to the
          // correct screen.
          return MaterialPageRoute(
            builder: (context) {
              return VerProductos(
                jsonData: args,
              );
            },
          );
        }

        if (settings.name == AddProducts.routeName) {
          // Cast the arguments to the correct
          // type: ScreenArguments.
          final AddDetailArguments args =
              settings.arguments as AddDetailArguments;
          // Then, extract the required data from
          // the arguments and pass the data to the
          // correct screen.
          return MaterialPageRoute(
            builder: (context) {
              return AddProducts(
                jsonData: args,
              );
            },
          );
        }
      },
      routes: rutasDrug,
    );
  }
}

checkInternet() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      //Connected
    }
  } on SocketException catch (_) {
    // Not connected
    if (!Get.isSnackbarOpen)
      Get.snackbar(
        'Ha ocurrido un error', // title
        'Parece que no tienes conexión a internet', // message
        colorText: Colors.white,
        backgroundColor: Colors.red[600],
        barBlur: 20,
        isDismissible: true,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 5),
        animationDuration: Duration(milliseconds: 300),
      );
  }
}
