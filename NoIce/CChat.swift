//
//  CChat.swift
//  NoIce
//
//  Created by Done Santana on 6/2/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

class CChat{
    var ChatID: String!
    var EmailEmisor : String!
    var EmailDestino : String!
    var EmisorImagen: UIImage!
    var DestinoImagen: UIImage!
    var MensajesChat: [CMensaje]
    var ChatContainer = CKContainer.default()
    
    init(chatID: String,emisorImagen: UIImage, destinoImagen: UIImage) {
        self.ChatID = chatID
        let temporal = (chatID).components(separatedBy: "+")
        self.EmailEmisor = temporal[0]
        self.EmailDestino = temporal[1]
        self.EmisorImagen = emisorImagen
        self.DestinoImagen = destinoImagen
        self.MensajesChat = [CMensaje]()
        self.GuardarChat()
    }
    
    func AgregarMensaje(newMensaje: CMensaje){
        self.MensajesChat.append(newMensaje)
    }
    
    func GuardarChat(){
        let predicateChatID = NSPredicate(format: "emisorDestino contains %@", self.EmailEmisor)
        
        let queryChatID = CKQuery(recordType: "CChat",predicate: predicateChatID)
        
        self.ChatContainer.publicCloudDatabase.perform(queryChatID, inZoneWith: nil, completionHandler: ({results, error in
            
            if (error == nil) {
                if results?.count != 0{
                    
                }else{
                    let emisorImagenURL = self.saveImageToFile(self.EmisorImagen!)
                    let emisorImagen = CKAsset(fileURL: emisorImagenURL)
                    
                    let destinoImagenURL = self.saveImageToFile(self.DestinoImagen!)
                    let destinoImagen = CKAsset(fileURL: destinoImagenURL)
                    
                    let recordChat = CKRecord(recordType: "CChat")
                    recordChat.setObject(self.ChatID as CKRecordValue, forKey: "chatID")
                    recordChat.setObject(emisorImagen as CKRecordValue, forKey: "emisorImagen")
                    recordChat.setObject(destinoImagen as CKRecordValue, forKey: "destinoImagen")
                    recordChat.setObject([self.EmailEmisor,self.EmailDestino] as CKRecordValue, forKey: "emisorDestino")
                    let chatRecordsOperation = CKModifyRecordsOperation(
                        recordsToSave: [recordChat],
                        recordIDsToDelete: nil)
                    self.ChatContainer.publicCloudDatabase.add(chatRecordsOperation)
                }
            }
        }))
    }
    
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
