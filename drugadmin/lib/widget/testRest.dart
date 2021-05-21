// import 'package:drugapp/src/service/restFunction.dart';
// import 'package:flutter/material.dart';

// class TestDos extends StatefulWidget {
//   /// Boton de código Jaguar con RestFunction para realizar lladamas REST a una [url]
//   /// con un [metodo] y si la respuesta es true se realiza una [action].
//   /// [estilo] define el estilo del boton, el [contendio] del boton, puede estar ligado a un
//   /// form con un [formkey] y enseña un mensaje de error [errorStyle] cuando la respuesta es false.
//   /// También se puede mostrar un [showModalLoader] con un [stringCargando].
//   const TestDos(
//       {Key key,
//       @required this.contenido,
//       this.estilo,
//       this.url,
//       this.method,
//       this.action,
//       this.formkey,
//       this.arrayData,
//       this.errorStyle,
//       this.showModalLoader = true,
//       this.stringCargando = 'Cargando...'})
//       : super(key: key);

//   final Widget contenido;
//   final BoxDecoration estilo;
//   final String url;
//   final String method;
//   final Function action;
//   final formkey;
//   final dynamic arrayData;
//   final TextStyle errorStyle;
//   final bool showModalLoader;
//   final String stringCargando;

//   @override
//   _TestDosState createState() => _TestDosState();
// }

// class _TestDosState extends State<TestDos> {
//   bool load = false;
//   bool error = false;
//   String errorString = 'Algo salio mal';

//   Rest restFunction = Rest();

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         error
//             ? Padding(
//                 padding: const EdgeInsets.only(bottom: 15),
//                 child: Text(
//                   errorString,
//                   textAlign: TextAlign.center,
//                   style: widget.errorStyle,
//                 ),
//               )
//             : Container(),
//         Container(
//           decoration: widget.estilo,
//           child: Material(
//             clipBehavior: Clip.hardEdge,
//             color: Colors.transparent,
//             child: InkWell(
//               highlightColor: Colors.grey.withOpacity(0.2),
//               onTap: () {
//                 if (!load) {
//                   if (widget.formkey.currentState.validate()) {
//                     widget.formkey.currentState.save();
//                     setState(() {
//                       load = true;
//                     });
//                     if (widget.showModalLoader) {
//                       loadingDialog(context, widget.stringCargando);
//                     }
//                     restFunction
//                         .restService(
//                             widget.arrayData, widget.url, null, widget.method)
//                         .then((serverResp) {
//                       if (serverResp['status'] == 'server_true') {
//                         Navigator.pop(context);
//                         setState(() {
//                           load = false;
//                           error = false;
//                         });
//                         widget.action();
//                       } else {
//                         Navigator.pop(context);
//                         setState(() {
//                           load = false;
//                           error = true;
//                           errorString = serverResp['message'].toString();
//                         });
//                       }
//                     });
//                   }
//                 }
//               },
//               child: Container(
//                   padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
//                   alignment: Alignment.center,
//                   child: load
//                       ? Container(
//                           height: 18,
//                           width: 18,
//                           child: CircularProgressIndicator(
//                             backgroundColor: Colors.white,
//                             strokeWidth: 3,
//                           ))
//                       : widget.contenido),
//             ),
//           ),
//         )
//       ],
//     );
//   }

//   loadingDialog(BuildContext context, String stringCarga) {
//     AlertDialog alert = AlertDialog(
//       content: WillPopScope(
//         onWillPop: () {},
//         child: Row(
//           children: [
//             CircularProgressIndicator(),
//             Container(
//                 margin: EdgeInsets.only(left: 7),
//                 child: Text(stringCarga.toString())),
//           ],
//         ),
//       ),
//     );
//     showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (BuildContext context) {
//         return alert;
//       },
//     );
//   }
// }
import 'package:codigojaguar/restFunction.dart';
import 'package:drugadmin/service/restFunction.dart';
import 'package:flutter/material.dart';

class BotonRestTest extends StatefulWidget {
  /// Boton de código Jaguar con RestFunction para realizar lladamas REST a una [url]
  /// con un [metodo] y si la respuesta es true se realiza una [action].
  /// [estilo] define el estilo del boton, el [contendio] del boton, puede estar ligado a un
  /// form con un [formkey] y enseña un mensaje de error [errorStyle] cuando la respuesta es false.
  /// También se puede mostrar un [showModalLoader] con un [stringCargando].
  const BotonRestTest(
      {Key key,
      @required this.contenido,
      this.estilo,
      this.url,
      this.method,
      // this.action,
      this.formkey,
      this.arrayData,
      this.errorStyle,
      this.showModalLoader = true,
      this.stringCargando = 'Cargando...',
      this.action,
      this.token,
      this.showSuccess = false,
      this.succesStyle,
      this.habilitado = true,
      this.restriccion = false,
      this.restriccionStr,
      this.restriccionStyle, this.primerAction})
      : super(key: key);

  final Function(dynamic) action;
  final Function primerAction;
  final Widget contenido;
  final BoxDecoration estilo;
  final String url;
  final String method;
  // final Function action;
  final formkey;
  final dynamic arrayData;
  final TextStyle errorStyle;
  final TextStyle succesStyle;
  final bool showModalLoader;
  final String stringCargando;
  final String token;
  final bool showSuccess;
  final bool habilitado;
  final bool restriccion;
  final String restriccionStr;
  final TextStyle restriccionStyle;

  @override
  _BotonRestTestState createState() => _BotonRestTestState();
}

class _BotonRestTestState extends State<BotonRestTest> {
  bool load = false;
  bool error = false;
  bool restiction = false;
  String errorString = 'Algo salio mal';

  bool success = false;
  String succesString = 'Todo bien';

  RestFun restFunction = RestFun();

  String response;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.showSuccess
            ? success
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      succesString,
                      textAlign: TextAlign.center,
                      style: widget.succesStyle,
                    ),
                  )
                : Container()
            : Container(),
        error
            ? Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text(
                  errorString,
                  textAlign: TextAlign.center,
                  style: widget.errorStyle,
                ),
              )
            : Container(),
        widget.restriccion
            ? restiction
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      widget.restriccionStr,
                      textAlign: TextAlign.center,
                      style: widget.restriccionStyle,
                    ),
                  )
                : Container()
            : Container(),
        Container(
          decoration: widget.estilo,
          child: Material(
            clipBehavior: Clip.hardEdge,
            color: Colors.transparent,
            child: InkWell(
              highlightColor: Colors.grey.withOpacity(0.2),
              onTap: () {
                if (!load) {
                  if (widget.habilitado) {
                    widget.primerAction();
                    if (widget.formkey != null) {
                      if (widget.formkey.currentState.validate()) {
                        widget.formkey.currentState.save();
                        setState(() {
                          load = true;
                        });
                        if (widget.showModalLoader) {
                          loadingDialog(context, widget.stringCargando);
                        }
                        restFunction
                            .restService(widget.arrayData, widget.url,
                                widget.token, widget.method)
                            .then((serverResp) {
                          setState(() {
                            response = serverResp.toString();
                          });
                          if (serverResp['status'] == 'server_true') {
                            Navigator.pop(context);
                            widget.action(serverResp);
                            setState(() {
                              load = false;
                              error = false;
                              restiction = false;
                              success = true;
                              succesString = serverResp['message'].toString();
                            });
                          } else {
                            Navigator.pop(context);
                            setState(() {
                              load = false;
                              error = true;
                              restiction = false;
                              success = false;
                              errorString = serverResp['message'].toString();
                            });
                          }
                        });
                      }
                    } else {
                      setState(() {
                        load = true;
                      });
                      if (widget.showModalLoader) {
                        loadingDialog(context, widget.stringCargando);
                      }
                      restFunction
                          .restService(widget.arrayData, widget.url,
                              widget.token, widget.method)
                          .then((serverResp) {
                        setState(() {
                          response = serverResp.toString();
                        });
                        if (serverResp['status'] == 'server_true') {
                          Navigator.pop(context);
                          widget.action(serverResp);
                          setState(() {
                            load = false;
                            error = false;
                            restiction = false;
                            success = true;
                            succesString = serverResp['message'].toString();
                          });
                        } else {
                          Navigator.pop(context);
                          setState(() {
                            load = false;
                            error = true;
                            restiction = false;
                            success = false;
                            errorString = serverResp['message'].toString();
                          });
                        }
                      });
                    }
                  } else {
                    setState(() {
                      restiction = true;
                    });
                  }
                }
              },
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  alignment: Alignment.center,
                  child: load
                      ? Container(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                            strokeWidth: 3,
                          ))
                      : widget.contenido),
            ),
          ),
        )
      ],
    );
  }

  Future<String> function() async {
    return response;
  }

  loadingDialog(BuildContext context, String stringCarga) {
    AlertDialog alert = AlertDialog(
      content: WillPopScope(
        onWillPop: () {},
        child: Row(
          children: [
            CircularProgressIndicator(),
            Container(
                margin: EdgeInsets.only(left: 7),
                child: Text(stringCarga.toString())),
          ],
        ),
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
