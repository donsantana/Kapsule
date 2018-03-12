//
//  CKapsule.swift
//  Kapsule
//
//  Created by Done Santana on 2/25/18.
//  Copyright © 2018 Done Santana. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class CKapsule {
    //properties
    var recordName: String
    var destinatarioEmail:String
    var destinatarioName:String
    var emisorEmail:String
    var emisorName:String
    var asunto:String
    var direccion:String
    var geoposicion:CLLocationCoordinate2D
    var geoposicionString: String
    var tipoK:String
    var contenido:CKAsset
    var vista:String //SI/NO
    var estado: String //in, out, read
    
    var KapsuleContainer = CKContainer.default()
    
    init() {
        self.destinatarioEmail = ""
        self.destinatarioName = ""
        self.emisorEmail = ""
        self.emisorName = ""
        self.asunto = ""
        self.geoposicion = CLLocationCoordinate2D()
        self.geoposicionString = ""
        self.tipoK = ""
        self.contenido = CKAsset(fileURL: URL(fileURLWithPath: ""))
        self.vista = ""
        self.estado = ""
        self.direccion = ""
        self.recordName = ""
    }
    
    init(destinatarioEmail:String,destinatarioName:String,emisorEmail:String,emisorName:String,asunto:String,geoposicion:CLLocationCoordinate2D, direccion: String, tipoK:String, urlContenido:CKAsset, vista:String) {
        self.destinatarioEmail = destinatarioEmail
        self.destinatarioName = destinatarioName
        self.emisorEmail = emisorEmail
        self.emisorName = emisorName
        self.asunto = asunto
        self.geoposicion = geoposicion
        self.geoposicionString = String(self.geoposicion.latitude)+","+String(geoposicion.longitude)
        self.tipoK = tipoK
        self.contenido = urlContenido
        self.vista = vista
        self.estado = "new"
        self.direccion = direccion
        self.recordName = "new"
    }
    
    func actulizarEstado(estado:String){
        self.estado = estado
    }
    
    func sendKapsule(){
        //asunt,contenido,destinoEmail,destinoName,direccion,emisorEmail,emisorName,geoposicion,tipoK,vista
        let recordKapsule = CKRecord(recordType: "Kapsule")
        recordKapsule.setObject(self.destinatarioName as CKRecordValue, forKey: "destinatarioName")
        recordKapsule.setObject(self.destinatarioEmail as CKRecordValue, forKey: "destinatarioEmail")
        recordKapsule.setObject(self.emisorEmail as CKRecordValue, forKey: "emisorEmail")
        recordKapsule.setObject(self.emisorName as CKRecordValue, forKey: "emisorName")
        recordKapsule.setObject(self.asunto as CKRecordValue, forKey: "asunto")
        recordKapsule.setObject(self.direccion as CKRecordValue, forKey: "direccion")
        recordKapsule.setObject(self.geoposicionString as CKRecordValue, forKey: "geoposicion")
        recordKapsule.setObject(self.contenido as CKRecordValue, forKey: "contenido")
        recordKapsule.setObject(self.tipoK as CKRecordValue, forKey: "tipoK")
        recordKapsule.setObject(self.vista as CKRecordValue, forKey: "vista")

        let kapsuleRecordsOperation = CKModifyRecordsOperation(recordsToSave: [recordKapsule], recordIDsToDelete: nil)
        self.KapsuleContainer.publicCloudDatabase.add(kapsuleRecordsOperation)
    }
    
    func prepararContenido(newphoto: UIImage)->CKAsset{
        let imagenURL = self.saveImageToFile(newphoto)
        let photoUser = CKAsset(fileURL: imagenURL)

        return photoUser
    }
    
    func setRecordName(recordName:String) {
        self.recordName = recordName
    }
    
    
    //RENDER IMAGEN
    func saveImageToFile(_ image: UIImage) -> URL
    {
        let filemgr = FileManager.default
        
        let dirPaths = filemgr.urls(for: .documentDirectory,
                                    in: .userDomainMask)
        
        let fileURL = dirPaths[0].appendingPathComponent("currentImage.jpg")
        
        if let renderedJPEGData =
            UIImageJPEGRepresentation(image, 0.5) {
            try! renderedJPEGData.write(to: fileURL)
        }
        
        return fileURL
    }
    
    
    
}
