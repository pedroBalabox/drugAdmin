import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EntradaTextoTest extends StatefulWidget {
  final String tipo;
  final FormFieldSetter<String> onSaved;
  final FormFieldSetter<String> onChanged;
  final Function onEditingComplete;
  final bool habilitado;
  final int lineasMax;
  final int longText;
  final String valorInicial;
  final TextCapitalization textCapitalization;
  final InputDecoration estilo;
  final TextInputAction action;
  final TextInputType tipoEntrada;
  final GlobalKey<FormState> formkey;

  EntradaTextoTest(
      {Key key,
      this.tipo = 'textoCorto',
      this.onSaved,
      this.onChanged,
      this.habilitado = true,
      this.lineasMax = 1,
      this.longText,
      this.valorInicial,
      this.textCapitalization = TextCapitalization.sentences,
      this.estilo,
      this.action = TextInputAction.next,
      this.tipoEntrada = TextInputType.name,
      this.onEditingComplete, this.formkey})
      : super(key: key);

  @override
  _EntradaTextoTestState createState() => _EntradaTextoTestState();
}

class _EntradaTextoTestState extends State<EntradaTextoTest> {
  Function(String) typeValidator;
  int maxCharacters;

  @override
  Widget build(BuildContext context) {
    switch (widget.tipo) {
      case "telefono":
        typeValidator = (value) {
          if (value.isEmpty || value.length < 10) {
            return 'Ingresa un teléfono';
          } else {
            return null;
          }
        };
        maxCharacters = 20;
        break;
      case "correo":
        typeValidator = (value) {
          if (value.isEmpty || value.length < 5 || !value.contains('@')) {
            return 'Ingresa un correo';
          } else {
            return null;
          }
        };
        maxCharacters = 150;
        break;
      case "password":
        typeValidator = (value) {
          if (value.isEmpty || value.length < 8) {
            return 'Ingresa tu contraseña';
          } else {
            return null;
          }
        };
        maxCharacters = 150;
        break;
      case "nombre":
        typeValidator = (value) {
          if (value.isEmpty || value.length < 1) {
            return 'Ingresa nombre';
          } else {
            return null;
          }
        };
        maxCharacters = 150;
        break;
      case "apellido":
        typeValidator = (value) {
          if (value.isEmpty || value.length < 2) {
            return 'Ingresa apellido';
          } else {
            return null;
          }
        };
        maxCharacters = 150;
        break;
      case "textoCorto":
        typeValidator = (value) {
          if (value.isEmpty || value.length < 5) {
            return 'Es necesario este campo';
          } else {
            return null;
          }
        };
        maxCharacters = 500;
        break;
      case "textoLargo":
        typeValidator = (value) {
          if (value.isEmpty || value.length < 5) {
            return 'Es necesario este campo';
          } else {
            return null;
          }
        };
        maxCharacters = 3000;
        break;
      case "precio":
        typeValidator = (value) {
          if (value.isEmpty || value.length < 1) {
            return 'Es necesario este campo';
          } else {
            return null;
          }
        };
        maxCharacters = 10;
        break;
      case "numero":
        typeValidator = (value) {
          if (value.isEmpty || value.length < 1) {
            return 'Es necesario este campo';
          } else {
            return null;
          }
        };
        maxCharacters = 50;
        break;
      case "opcional":
        maxCharacters = 500;
        break;
      default:
        typeValidator = (value) {
          if (value.isEmpty || value.length < 2) {
            return 'Es necesario este campo';
          } else {
            return null;
          }
        };
        maxCharacters = 50;
    }

    return TextFormField(
      decoration: widget.estilo,
      validator: typeValidator,
      maxLength: widget.longText == null ? maxCharacters : widget.longText,
      onSaved: widget.onSaved,
      onChanged: (value){
         if (value != "") {
                  widget.formkey.currentState.save();
                }
      },
      // onEditingComplete = widget.onEditingComplete,
      obscureText: widget.tipo == 'password' ? true : false,
      enabled: widget.habilitado,
      maxLines: widget.lineasMax,
      initialValue: widget.valorInicial,
      textCapitalization: widget.textCapitalization,
      textInputAction: widget.action,
      keyboardType: widget.tipoEntrada,
      inputFormatters: widget.tipo == 'telefono' || widget.tipo == 'numero'
          ? [
              // DecimalTextInputFormatter(),
              FilteringTextInputFormatter.allow(RegExp("[0-9 .]"))
            ]
          : null,
    );
  }
}
