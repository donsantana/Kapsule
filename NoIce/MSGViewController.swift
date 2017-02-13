//
//  MSGViewController.swift
//  NoIce
//
//  Created by Done Santana on 12/2/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class MSGViewController: UIViewController, UITextFieldDelegate {
    var mensajesChat = [CMensaje]()
    
    //MARK:- VARIABLES INTERFAZ
    @IBOutlet weak var ChatView: UIView!
    @IBOutlet weak var CreateMSGView: UIView!
    @IBOutlet weak var ChatTable: UITableView!
    @IBOutlet weak var DestinoImage: UIImageView!
    @IBOutlet weak var MensageText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.MensageText.delegate = self
        
    }
    
    //MARK: - ACTION DE BOTONES
  
    @IBAction func SendChatMensage(_ sender: Any) {
        self.MensageText.resignFirstResponder()
        //if self.chatsOpen.first?.DestinoImagen.isEqual(<#T##object: Any?##Any?#>)
        if !(self.MensageText.text?.isEmpty)!{
            let newmensaje = CMensaje(chatId: (myvariables.chatsOpen.first?.ChatID)!, mensaje: self.MensageText.text!)
            newmensaje.EnviarMensaje()
            self.mensajesChat.append(newmensaje)
            self.ChatTable.reloadData()
            self.MensageText.text?.removeAll()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.MensageText.resignFirstResponder()
        //if self.chatsOpen.first?.DestinoImagen.isEqual(<#T##object: Any?##Any?#>)
        if !(self.MensageText.text?.isEmpty)!{
            let newmensaje = CMensaje(chatId: (myvariables.chatsOpen.first?.ChatID)!, mensaje: self.MensageText.text!)
            newmensaje.EnviarMensaje()
            self.mensajesChat.append(newmensaje)
            self.ChatTable.reloadData()
            self.MensageText.text?.removeAll()
        }
        return true
    }

    
}
