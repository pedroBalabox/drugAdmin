// To parse this JSON data, do
//
//     final farmaciaModel = farmaciaModelFromJson(jsonString);

import 'dart:convert';

FarmaciaModel farmaciaModelFromJson(String str) => FarmaciaModel.fromJson(json.decode(str));

String farmaciaModelToJson(FarmaciaModel data) => json.encode(data.toJson());

class FarmaciaModel {
    FarmaciaModel({
        this.nombre,
        this.nombrePropietario,
        this.rfc,
        this.tipoPersona,
        this.correo,
        this.giro,
        this.farmacia_id,
        this.logo,
        this.creation_date,
        this.estatus
    });

    String nombre;
    String nombrePropietario;
    String rfc;
    String tipoPersona;
    String correo;
    String giro;
    String farmacia_id;
    String logo;
    dynamic creation_date;
    String estatus;

    factory FarmaciaModel.fromJson(Map<String, dynamic> json) => FarmaciaModel(
        nombre: json["nombre"],
        nombrePropietario: json["nombre_propietario"],
        rfc: json["rfc"],
        tipoPersona: json["tipo_persona"],
        correo: json["correo"],
        giro: json["giro"],
        farmacia_id: json['farmacia_id'],
        logo: json['logo'],
        creation_date: json['creation_date'],
        estatus: json['estatus']
    );

    Map<String, dynamic> toJson() => {
        "nombre": nombre,
        "nombre_propietario": nombrePropietario,
        "rfc": rfc,
        "tipo_persona": tipoPersona,
        "correo": correo,
        "giro": giro,
        "farmacia_id": farmacia_id,
        "logo": logo,
        "creation_date": creation_date,
        "estatus": estatus
    };
}
