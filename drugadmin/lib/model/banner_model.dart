// To parse this JSON data, do
//
//     final bannerModel = bannerModelFromJson(jsonString);

import 'dart:convert';

BannerModel bannerModelFromJson(String str) => BannerModel.fromJson(json.decode(str));

String bannerModelToJson(BannerModel data) => json.encode(data.toJson());

class BannerModel {
    BannerModel({
        this.idDeBanner,
        this.titulo,
        this.descripcion,
        this.imagenEscritorio,
        this.imagenMovil,
        this.fechaDeExposicion,
        this.posicion,
        this.linkExterno,
        this.idDeFarmacia,
    });

    String idDeBanner;
    String titulo;
    String descripcion;
    String imagenEscritorio;
    String imagenMovil;
    String fechaDeExposicion;
    String posicion;
    String linkExterno;
    String idDeFarmacia;

    factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
        idDeBanner: json["id_de_banner"],
        titulo: json["titulo"],
        descripcion: json["descripcion"],
        imagenEscritorio: json["imagen_escritorio"],
        imagenMovil: json["imagen_movil"],
        fechaDeExposicion:json["fecha_de_exposicion"],
        posicion: json["posicion"],
        linkExterno: json["link_externo"],
        idDeFarmacia: json["id_de_farmacia"],
    );

    Map<String, dynamic> toJson() => {
        "id_de_banner": idDeBanner,
        "titulo": titulo,
        "descripcion": descripcion,
        "imagen_escritorio": imagenEscritorio,
        "imagen_movil": imagenMovil,
        "fecha_de_exposicion": fechaDeExposicion,
        // "fecha_de_exposicion": "${fechaDeExposicion.year.toString().padLeft(4, '0')}-${fechaDeExposicion.month.toString().padLeft(2, '0')}-${fechaDeExposicion.day.toString().padLeft(2, '0')}",
        "posicion": posicion,
        "link_externo": linkExterno,
        "id_de_farmacia": idDeFarmacia,
    };
}
