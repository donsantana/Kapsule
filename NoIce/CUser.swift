//
//  CUser.swift
//  NoIce
//
//  Created by Done Santana on 14/1/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//


import Foundation
import UIKit
import CloudKit

class CUser{
    //Atributos
    var NombreApellidos: String
    var Email: String
    var Telefono: String
    var FotoPerfil: UIImage
    var Posicion: CLLocation
    var UserContainer = CKContainer.default()
    var conectado: String!
    var NewMsg: Bool!
    var bloqueados: [String]!
    
    var recordName: String!
    
    //Métodos
    init(nombreapellidos: String, email: String){
        self.NombreApellidos = nombreapellidos
        self.Email = email
        self.Telefono = "movil"
        self.FotoPerfil = UIImage(named: "user")!
        self.Posicion = CLLocation()
        self.conectado = "1"
        self.NewMsg = false
        self.bloqueados = [String]()
        
        self.recordName = "new"
    }
    
    func RegistrarUser(NombreApellidos: String, Email: String, photo: CKAsset, pos: CLLocation){
        let bloqueados = ["nadie"]
        self.Posicion = pos
        let recordUser = CKRecord(recordType: "CUsuarios")
        recordUser.setObject(Email as CKRecordValue, forKey: "email")
        recordUser.setObject(NombreApellidos as CKRecordValue, forKey: "nombreApellidos")
        recordUser.setObject(photo as CKRecordValue, forKey: "foto")
        recordUser.setObject(bloqueados as CKRecordValue, forKey: "bloqueados")
        recordUser.setObject("1" as CKRecordValue, forKey: "conectado")
        recordUser.setObject(pos as CKRecordValue, forKey: "posicion")
        
        let userRecordsOperation = CKModifyRecordsOperation(
            recordsToSave: [recordUser],
            recordIDsToDelete: nil)
        self.UserContainer.publicCloudDatabase.add(userRecordsOperation)
        
        self.recordName = recordUser.recordID.recordName

    }
    func GuardarFotoPerfil(photo: UIImage){
        self.FotoPerfil = photo
    }
    
    func ActualizarTelefono(movil: String){
        self.Telefono = movil
    }
    
    func ActualizarPosicion(posicionActual: CLLocation) {
            self.Posicion = posicionActual
            let predicateKapsuleVista = NSPredicate(format: "email == %@", self.Email)
            
            let queryKapsuleVista = CKQuery(recordType: "CUsuarios",predicate: predicateKapsuleVista)
            
            self.UserContainer.publicCloudDatabase.perform(queryKapsuleVista, inZoneWith: nil, completionHandler: ({results, error in
                
                if (error == nil) {
                    if results?.count != 0{
                        let recordID = results?[0].recordID
                        
                        print("Este RecordId \(recordID?.recordName)")
                        
                        self.UserContainer.publicCloudDatabase.fetch(withRecordID: recordID!, completionHandler: { (record, error) in
                            if error != nil {
                                print("Error fetching record: \(error?.localizedDescription)")
                            } else {
                                record?.setObject(self.Posicion as CKRecordValue?, forKey: "posicion")
                                
                                // Save this record again
                                self.UserContainer.publicCloudDatabase.save(record!, completionHandler: { (savedRecord, saveError) in
                                    if saveError != nil {
                                        print("Error saving record: \(saveError?.localizedDescription)")
                                    } else {
                                        print("ACTUALIZADA POSICION")
                                    }
                                })
                            }
                            
                        })
                    }else{
                        print("NO SE ENCONTRO EL USUARIO")
                    }
                }
            }))

    }
    
    func ActualizarConectado(estado: String){
        
        let recordID = CKRecordID(recordName: self.recordName)
                    
        self.UserContainer.publicCloudDatabase.fetch(withRecordID: recordID, completionHandler: { (record, error) in
            print("Entre aqui")
            if error != nil {
                print("Error fetching record: \(String(describing: error?.localizedDescription))")
            } else {
                record?.setObject(estado as CKRecordValue?, forKey: "conectado")
                self.UserContainer.publicCloudDatabase.save(record!, completionHandler: { (savedRecord, saveError) in
                    if saveError != nil {
                        print("Error saving conectado: \(String(describing: saveError?.localizedDescription))")
                    } else {
                        print("ACTUALIZADO CONECTADO")
                        self.conectado = estado
                    }
                })
            }
        })
    }
    
    func ActualizarPhoto(newphoto: UIImage){
        let imagenURL = self.saveImageToFile(newphoto)
        let photoUser = CKAsset(fileURL: imagenURL)
        
        let predicateVista = NSPredicate(format: "email == %@", myvariables.userperfil.Email)
        
        let queryVista = CKQuery(recordType: "CUsuarios",predicate: predicateVista)
        
        self.UserContainer.publicCloudDatabase.perform(queryVista, inZoneWith: nil, completionHandler: ({results, error in
            
            if (error == nil) {
                if results?.count != 0{
                    let recordID = results?[0].recordID
                    
                    self.UserContainer.publicCloudDatabase.fetch(withRecordID: recordID!, completionHandler: { (record, error) in
                        if error != nil {
                            print("Error fetching record: \(error?.localizedDescription)")
                        } else {
                            record?.setObject(photoUser as CKRecordValue?, forKey: "foto")
                            
                            // Save this record again
                            self.UserContainer.publicCloudDatabase.save(record!, completionHandler: { (savedRecord, saveError) in
                                if saveError != nil {
                                    
                                } else {
                                    self.FotoPerfil = newphoto
                                }
                            })
                        }
                        
                    })
                }else{
                    print("NO SE ENCONTRO EL USER")
                }
            }
        }))

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

    
    func BuscarNuevosMSG(EmailDestino: String) {
        
        let predicateMesajes = NSPredicate(format: "destinoEmail == %@ and emisorEmail ==%@",EmailDestino,self.Email)
        
        let queryKapsuleVista = CKQuery(recordType: "CMensaje",predicate: predicateMesajes)
        
        self.UserContainer.publicCloudDatabase.perform(queryKapsuleVista, inZoneWith: nil, completionHandler: ({results, error in
            if (error == nil) {
                if (results?.count)! > 0{
                    self.NewMsg = true
                }
                
            }
        }))
  
    }
    
    func ActualizarBloqueo(emailBloqueado: String, completionHandler: @escaping(Bool)->()){

            let predicateMesajes = NSPredicate(format: "email == %@",self.Email)
            
            let queryVista = CKQuery(recordType: "CUsuarios",predicate: predicateMesajes)
            
            self.UserContainer.publicCloudDatabase.perform(queryVista, inZoneWith: nil, completionHandler: ({results, error in
                if (error == nil) {
                    if (results?.count)! > 0{
                        let recordID = results?[0].recordID
                        self.bloqueados = results?[0].value(forKey: "bloqueados") as! [String]
                        self.bloqueados.append(emailBloqueado)

                        self.UserContainer.publicCloudDatabase.fetch(withRecordID: recordID!, completionHandler: { (record, error) in
                            if error != nil {
                                print("Error fetching record: \(error?.localizedDescription)")
                            } else {
                                record?.setObject(self.bloqueados as CKRecordValue?, forKey: "bloqueados")
                                // Save this record again
                                self.UserContainer.publicCloudDatabase.save(record!, completionHandler: { (savedRecord, saveError) in
                                    if saveError != nil {
                                        completionHandler(false)
                                    } else {
                                        completionHandler(true)
                                    }
                                })
                            }
                            
                        })

                    }else{

                    }
                }
            }))

    }
    func CargarBloqueados(bloqueados: [String]){
        self.bloqueados = bloqueados
    }
    
}
