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
}
