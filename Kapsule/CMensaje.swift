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
    var EmailEmisor : String!
    var EmailDestino : String!
    var Mensaje: String!
    
    var MensajeContainer = CKContainer.default()
    

    init(emailEmisor: String, emailDestino: String, mensaje: String) {
        self.EmailEmisor = emailEmisor
        self.EmailDestino = emailDestino
        self.Mensaje = mensaje
    }    
    func RecibirMensaje() {
        self.Mensaje = "Resultado de Consulta"
    }
    func EnviarMensaje(){
        //Enviar el mensaje al servidor
        
        let recordMensaje = CKRecord(recordType: "CMensaje")
        recordMensaje.setObject(self.EmailDestino as CKRecordValue, forKey: "destinoEmail")
        recordMensaje.setObject(self.EmailEmisor as CKRecordValue, forKey: "emisorEmail")
        recordMensaje.setObject(self.Mensaje as CKRecordValue, forKey: "textoMensaje")
        
        let chatRecordsOperation = CKModifyRecordsOperation(
            recordsToSave: [recordMensaje],
            recordIDsToDelete: nil)
        self.MensajeContainer.publicCloudDatabase.add(chatRecordsOperation)
    }
    
}
