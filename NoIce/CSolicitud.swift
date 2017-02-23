//
//  CSolicitud.swift
//  NoIce
//
//  Created by Done Santana on 27/1/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class CSolicitud {
    //atributos
    var FotoEmisor: UIImage!
    var FotoDestino: UIImage!
    var EmailEmisor: String!
    var EmailDestino: String!
    var Estado: String!
    var SolicitudContainer = CKContainer.default()
    
    //Metodos
    init(fotoEmisor: UIImage, fotoDestino: UIImage,emailEmisor: String, emailDestino: String, estado: String) {
        self.FotoEmisor = fotoEmisor
        print(self.FotoEmisor.description)
        self.FotoDestino = fotoDestino
        print(self.FotoDestino.description)
        self.EmailEmisor = emailEmisor
        self.EmailDestino = emailDestino
        self.Estado = estado
    }
    
    func ActualizarEstado(newEstado: String){
        self.Estado = newEstado
        let predicateKapsuleVista = NSPredicate(format: "emailEmisor == %@", self.EmailEmisor)
        
        let queryKapsuleVista = CKQuery(recordType: "CSolicitud",predicate: predicateKapsuleVista)
        
        self.SolicitudContainer.publicCloudDatabase.perform(queryKapsuleVista, inZoneWith: nil, completionHandler: ({results, error in
            
            if (error == nil) {
                if results?.count != 0{
                    for solicitudEstado in (results)!{
                        if solicitudEstado.value(forKey: "emailDestino") as! String == self.EmailDestino{
                            let recordID = solicitudEstado.recordID
                    
                    self.SolicitudContainer.publicCloudDatabase.fetch(withRecordID: recordID, completionHandler: { (record, error) in
                        if error != nil {
                            print("Error fetching record: \(error?.localizedDescription)")
                        } else {
                            record?.setObject(self.Estado as CKRecordValue?, forKey: "estado")
                            
                            // Save this record again
                            self.SolicitudContainer.publicCloudDatabase.save(record!, completionHandler: { (savedRecord, saveError) in
                                if saveError != nil {
                                    print("Error saving estado: \(saveError?.localizedDescription)")
                                } else {
                                    print("ACTUALIZADO ESTADO")
                                }
                            })
                        }
                        
                    })
                    }
                    }
                }else{
                    print("NO SE ENCONTRO LA CONSULTA ESTADO")
                }
            }else{
                print("ERROR DE CONSULTA ESTADO")
            }
        }))

    }
    
    func EnviarSolicitud(){
        let imagenURL = self.saveImageToFile(self.FotoEmisor!)
        let fotoPerfil = CKAsset(fileURL: imagenURL)
        
        let imagenURL2 = self.saveImageToFile(self.FotoDestino!)
        let fotoDestino = CKAsset(fileURL: imagenURL2)
        
        let recordUser = CKRecord(recordType: "CSolicitud")
        recordUser.setObject(self.EmailEmisor as CKRecordValue, forKey: "emailEmisor")
        recordUser.setObject(self.EmailDestino as CKRecordValue, forKey: "emailDestino")
        recordUser.setObject(fotoPerfil as CKRecordValue, forKey: "fotoEmisor")
        recordUser.setObject(fotoDestino as CKRecordValue, forKey: "fotoDestino")
        recordUser.setObject(self.Estado as CKRecordValue, forKey: "estado")
        //print("PHOTOOOOOOO: " + myFilePathString)
        //recordUser.setObject(photoTemporal, forKey: "photo")
        
        let userRecordsOperation = CKModifyRecordsOperation(
            recordsToSave: [recordUser],
            recordIDsToDelete: nil)
        self.SolicitudContainer.publicCloudDatabase.add(userRecordsOperation)
        print("Solicitud Enviada")
    }
    
    //RENDER IMAGEN
    func saveImageToFile(_ image: UIImage) -> URL
    {
        let filemgr = FileManager.default
        
        let dirPaths = filemgr.urls(for: .documentDirectory,
                                    in: .userDomainMask)
        
        let fileURL = dirPaths[0].appendingPathComponent(image.description)
        
        if let renderedJPEGData =
            UIImageJPEGRepresentation(image, 0.5) {
            try! renderedJPEGData.write(to: fileURL)
        }
        return fileURL
    }

}
