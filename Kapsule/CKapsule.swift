//
//  CKapsule.swift
//  Kapsule
//
//  Created by Done Santana on 2/25/18.
//  Copyright © 2018 Done Santana. All rights reserved.
//

import Foundation
import CloudKit

class CKapsule {
    //properties
    var destinatarioEmail:String
    var destinatarioName:String
    var emisorEmail:String
    var emisorName:String
    var asunto:String
    var direccion:String
    var geoposicion:CLLocationCoordinate2D
    var tipoK:String
    var contenido:CKAsset
    var vista:String //SI/NO
    var estado: String //in, out, read
    
    init(destinatarioEmail:String,destinatarioName:String,emisorEmail:String,emisorName:String,asunto:String,direccion:String,geoposicion:CLLocationCoordinate2D,tipoK:String, urlContenido:CKAsset, vista:String) {
        self.destinatarioEmail = destinatarioEmail
        self.destinatarioName = destinatarioName
        self.emisorEmail = emisorEmail
        self.emisorName = emisorName
        self.asunto = asunto
        self.direccion = direccion
        self.geoposicion = geoposicion
        self.tipoK = tipoK
        self.contenido = urlContenido
        self.vista = vista
        self.estado = "new"
    }
    
    func actulizarEstado(estado:String){
        self.estado = estado
    }
    
}
