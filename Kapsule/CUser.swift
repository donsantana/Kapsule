//
//  CUser.swift
//  Kapsule
//
//  Created by Done Santana on 3/7/18.
//  Copyright © 2018 Done Santana. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CloudKit

class CUser {
    var name:String
    var email:String
    var location:CLLocationCoordinate2D
    var photoPerfil: UIImage
    var UserContainer = CKContainer.default()

    init(name:String, email:String) {
        self.name = name
        self.email = email
        self.location = CLLocationCoordinate2D()
        self.photoPerfil = UIImage()
    }
    
    func updateLocation(newLocation:CLLocationCoordinate2D) {
        self.location = newLocation
    }
    
    func RegistrarUser(NombreApellidos: String, Email: String, photo: CKAsset){
        let recordUser = CKRecord(recordType: "KUsers")
        recordUser.setObject(Email as CKRecordValue, forKey: "email")
        recordUser.setObject(NombreApellidos as CKRecordValue, forKey: "name")
        recordUser.setObject(photo as CKRecordValue, forKey: "photo")
        
        let userRecordsOperation = CKModifyRecordsOperation(
            recordsToSave: [recordUser],
            recordIDsToDelete: nil)
        self.UserContainer.publicCloudDatabase.add(userRecordsOperation)
        
    }
    
    func GuardarFotoPerfil(newPhoto: UIImage) {
        self.photoPerfil = newPhoto
    }
    
    func ActualizarPhoto(newphoto: UIImage){
        let imagenURL = self.saveImageToFile(newphoto)
        let photoUser = CKAsset(fileURL: imagenURL)
        
        let predicateVista = NSPredicate(format: "email == %@", self.email)
        
        let queryVista = CKQuery(recordType: "kUsers",predicate: predicateVista)
        
        self.UserContainer.publicCloudDatabase.perform(queryVista, inZoneWith: nil, completionHandler: ({results, error in
            
            if (error == nil) {
                if results?.count != 0{
                    let recordID = results?[0].recordID
                    
                    self.UserContainer.publicCloudDatabase.fetch(withRecordID: recordID!, completionHandler: { (record, error) in
                        if error != nil {
                            print("Error fetching record: \(error?.localizedDescription)")
                        } else {
                            record?.setObject(photoUser as CKRecordValue?, forKey: "photo")
                            
                            // Save this record again
                            self.UserContainer.publicCloudDatabase.save(record!, completionHandler: { (savedRecord, saveError) in
                                if saveError != nil {
                                    
                                } else {
                                    self.photoPerfil = newphoto
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

}
