//
//  CMensaje.swift
//  NoIce
//
//  Created by Done Santana on 4/2/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class CMensaje {
    var ChatID: String!
    var EmailEmisor : String!
    var EmailDestino : String!
    var Mensaje: String!
    var Emisor: String!
    var MensajeContainer = CKContainer.default()
    

    init(chatId: String, mensaje: String, emisor: String) {
        self.ChatID = chatId
        let temporal = (chatId).components(separatedBy: "+")
        self.Emisor = emisor
        if emisor == "E"{
            self.EmailEmisor = temporal[0]
            self.EmailDestino = temporal[1]
        }else{
            self.EmailEmisor = temporal[1]
            self.EmailDestino = temporal[0]
        }
        self.Mensaje = mensaje

    }    
    func RecibirMensaje() {
        self.Mensaje = "Resultado de Consulta"
    }
    func EnviarMensaje(){
        //Enviar el mensaje al servidor
        let recordMensaje = CKRecord(recordType: "CMensaje")
        recordMensaje.setObject(self.ChatID as CKRecordValue, forKey: "chatID")
        recordMensaje.setObject(self.Mensaje as CKRecordValue, forKey: "textoMensaje")
        recordMensaje.setObject(self.Emisor as CKRecordValue, forKey: "emisor")
        
        let chatRecordsOperation = CKModifyRecordsOperation(
            recordsToSave: [recordMensaje],
            recordIDsToDelete: nil)
        self.MensajeContainer.publicCloudDatabase.add(chatRecordsOperation)
    }
}
