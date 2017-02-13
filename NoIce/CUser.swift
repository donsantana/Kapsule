//
//  CUser.swift
//  NoIce
//
//  Created by Done Santana on 14/1/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//


import Foundation
import UIKit
import GoogleMaps
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
    
    //Métodos
    init(nombreapellidos: String, email: String){
        self.NombreApellidos = nombreapellidos
        self.Email = email
        self.Telefono = "movil"
        self.FotoPerfil = UIImage(named: "user")!
        self.Posicion = CLLocation()
        self.conectado = "1"
    }
    
    func RegistrarUser(NombreApellidos: String, Email: String, photo: CKAsset){
        let recordUser = CKRecord(recordType: "CUsuarios")
        recordUser.setObject(Email as CKRecordValue, forKey: "email")
        recordUser.setObject(NombreApellidos as CKRecordValue, forKey: "nombreApellidos")
        recordUser.setObject(photo as CKRecordValue, forKey: "foto")
        //print("PHOTOOOOOOO: " + myFilePathString)
        //recordUser.setObject(photoTemporal, forKey: "photo")
        
        let userRecordsOperation = CKModifyRecordsOperation(
            recordsToSave: [recordUser],
            recordIDsToDelete: nil)
        self.UserContainer.publicCloudDatabase.add(userRecordsOperation)

    }
    func ActulizarFotoPerfil(photo: UIImage){
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
    
    func ActualizarConectado(){
        self.conectado = "1"
        let predicateKapsuleVista = NSPredicate(format: "email == %@", self.Email)
        
        let queryKapsuleVista = CKQuery(recordType: "CUsuarios",predicate: predicateKapsuleVista)
        
        self.UserContainer.publicCloudDatabase.perform(queryKapsuleVista, inZoneWith: nil, completionHandler: ({results, error in
            
            if (error == nil) {
                if results?.count != 0{
                    let recordID = results?[0].recordID
                    
                    self.UserContainer.publicCloudDatabase.fetch(withRecordID: recordID!, completionHandler: { (record, error) in
                        if error != nil {
                            print("Error fetching record: \(error?.localizedDescription)")
                        } else {
                            record?.setObject("1" as CKRecordValue?, forKey: "conectado")
                            
                            // Save this record again
                            self.UserContainer.publicCloudDatabase.save(record!, completionHandler: { (savedRecord, saveError) in
                                if saveError != nil {
                                    print("Error saving conectado: \(saveError?.localizedDescription)")
                                } else {
                                    print("ACTUALIZADO CONECTADO")
                                }
                            })
                        }
                        
                    })
                }else{

                }
            }
        }))
    }
    func ActualizarDesconectado(){
        self.conectado = "0"
        let predicateKapsuleVista = NSPredicate(format: "email == %@", self.Email)
        
        let queryKapsuleVista = CKQuery(recordType: "CUsuarios",predicate: predicateKapsuleVista)
        
        self.UserContainer.publicCloudDatabase.perform(queryKapsuleVista, inZoneWith: nil, completionHandler: ({results, error in
            
            if (error == nil) {
                if results?.count != 0{
                    let recordID = results?[0].recordID
                    
                    self.UserContainer.publicCloudDatabase.fetch(withRecordID: recordID!, completionHandler: { (record, error) in
                        if error != nil {
                            print("Error fetching record: \(error?.localizedDescription)")
                        } else {
                            record?.setObject("0" as CKRecordValue?, forKey: "conectado")
                            
                            // Save this record again
                            self.UserContainer.publicCloudDatabase.save(record!, completionHandler: { (savedRecord, saveError) in
                                if saveError != nil {
                                    print("Error saving Desconectado: \(saveError?.localizedDescription)")
                                } else {
                                    print("ACTUALIZADO DESCONECTADO")
                                }
                            })
                        }
                        
                    })
                }else{
                    
                }
            }
        }))
    }
    
    func BuscarSolRecibidas(completionHandler:@escaping ([CSolicitud]) -> ()) {
        var solicitudesRecibidas = [CSolicitud]()
        var imagenEmisor: UIImage!
        var imagenDestino: UIImage!
        let predicateSolRecibida = NSPredicate(format: "emailDestino == %@", self.Email)
        
        let queryKapsuleVista = CKQuery(recordType: "CSolicitud",predicate: predicateSolRecibida)
        
        self.UserContainer.publicCloudDatabase.perform(queryKapsuleVista, inZoneWith: nil, completionHandler: ({results, error in
            if (error == nil) {
                if results?.count != 0{
                    
                    for solicitud in results!{
                        if solicitud.value(forKey: "estado") as! String == "S"{
                            //DispatchQueue.main.async {
                                do{
                                    let photo = solicitud.value(forKey: "fotoEmisor") as! CKAsset
                                    let photoPerfil = try Data(contentsOf: photo.fileURL as URL)
                                    imagenEmisor = UIImage(data: photoPerfil)
                                    
                                    let photo2 = solicitud.value(forKey: "fotoDestino") as! CKAsset
                                    let photoPerfil2 = try Data(contentsOf: photo2.fileURL as URL)
                                    imagenDestino = UIImage(data: photoPerfil2)
                                    
                                }catch{
                                    imagenEmisor = UIImage(named: "user1")
                                    imagenDestino = UIImage(named: "user1")
                                }
                            var solitudTemporal = CSolicitud(fotoEmisor: imagenEmisor,fotoDestino: imagenDestino, emailEmisor: solicitud.value(forKey: "emailEmisor") as! String, emailDestino: solicitud.value(forKey: "emailDestino") as! String, estado: solicitud.value(forKey: "estado") as! String)
                            solicitudesRecibidas.append(solitudTemporal)
                        }else{
                            print("POR AWUI")
                        }
                    }
                    //print("SE DEVUELVE" + String(solicitudesRecibidas.count))
                }else{
                    
                }
            }
            print("SE DEVUELVE" + String(solicitudesRecibidas.count))
            completionHandler(solicitudesRecibidas)
        }))
    }

    //BUSCAR SOLICITUDES ACEPTADAS
    func BuscarSolAceptadas(completionHandler:@escaping ([CSolicitud]) -> ()) {
        var solicitudesAceptadas = [CSolicitud]()
        var imagenEmisor: UIImage!
        var imagenDestino: UIImage!
        let predicateSolRecibida = NSPredicate(format: "emailEmisor == %@", self.Email)
        
        let queryKapsuleVista = CKQuery(recordType: "CSolicitud",predicate: predicateSolRecibida)
        
        self.UserContainer.publicCloudDatabase.perform(queryKapsuleVista, inZoneWith: nil, completionHandler: ({results, error in
            if (error == nil) {
                if results?.count != 0{
                    
                    for solicitud in results!{
                        if solicitud.value(forKey: "estado") as! String == "A"{
                            //DispatchQueue.main.async {
                            do{
                                let photo = solicitud.value(forKey: "fotoEmisor") as! CKAsset
                                let photoPerfil = try Data(contentsOf: photo.fileURL as URL)
                                imagenEmisor = UIImage(data: photoPerfil)
                                
                                let photo2 = solicitud.value(forKey: "fotoDestino") as! CKAsset
                                let photoPerfil2 = try Data(contentsOf: photo2.fileURL as URL)
                                imagenDestino = UIImage(data: photoPerfil2)
                                
                            }catch{
                                imagenEmisor = UIImage(named: "user1")
                                imagenDestino = UIImage(named: "user1")
                            }
                            var solitudTemporal = CSolicitud(fotoEmisor: imagenEmisor,fotoDestino: imagenDestino, emailEmisor: solicitud.value(forKey: "emailEmisor") as! String, emailDestino: solicitud.value(forKey: "emailDestino") as! String, estado: solicitud.value(forKey: "estado") as! String)
                            solicitudesAceptadas.append(solitudTemporal)
                        }else{
                            print("POR AWUI")
                        }
                    }
                    //print("SE DEVUELVE" + String(solicitudesRecibidas.count))
                }else{
                    print("NO HAY SOLICITUDES ACEPTADAS")
                }
            }
            print("SE DEVUELVE" + String(solicitudesAceptadas.count))
            completionHandler(solicitudesAceptadas)
        }))
    }

    
}
