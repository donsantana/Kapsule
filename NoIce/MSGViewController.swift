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
    var destinoChat: String!
    var mensajesContainer = CKContainer.default()
    var chatIDOpen: String!
    
    //MARK:- VARIABLES INTERFAZ
    @IBOutlet weak var ChatView: UIView!
    @IBOutlet weak var CreateMSGView: UIView!
    @IBOutlet weak var ChatTable: UITableView!
    @IBOutlet weak var DestinoImage: UIImageView!
    @IBOutlet weak var MensageText: UITextField!
    
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.MensageText.delegate = self
        //self.CargarMensajes()
        self.ChatTable.reloadData()
        if destinoChat == "E"{
            self.DestinoImage.image = myvariables.chatsOpen.first?.DestinoImagen
        }else{
            self.DestinoImage.image = myvariables.chatsOpen.first?.EmisorImagen
        }
        self.DestinoImage.layer.cornerRadius = self.DestinoImage.frame.width / 8
        self.DestinoImage.clipsToBounds = true
        
        //MASK: - PARA MOSTRAR Y OCULTAR EL TECLADO
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    func CargarMensajes(){
        let predicateMesajes = NSPredicate(format: "chatID == %@", self.chatIDOpen)
        
        let queryKapsuleVista = CKQuery(recordType: "CMensaje",predicate: predicateMesajes)
        
        self.mensajesContainer.publicCloudDatabase.perform(queryKapsuleVista, inZoneWith: nil, completionHandler: ({results, error in
            if (error == nil) {
                if results?.count != 0{
                    for mensajetemp in results!{
                        let mensajenew = CMensaje(chatId: mensajetemp.value(forKey: "chatID") as! String, mensaje: mensajetemp.value(forKey: "textoMensaje") as! String, emisor: mensajetemp.value(forKey: "emisor") as! String)
                        self.mensajesChat.append(mensajenew)
                    }
                    self.ChatTable.reloadData()
                }
                
            }
        }))
        
    }
    
    //MARK: - ACTION DE BOTONES
  
    @IBAction func SendChatMensage(_ sender: Any) {
        self.MensageText.resignFirstResponder()
        if !(self.MensageText.text?.isEmpty)!{
            let newmensaje = CMensaje(chatId: (myvariables.chatsOpen.first?.ChatID)!, mensaje: self.MensageText.text!, emisor: self.destinoChat)
            newmensaje.EnviarMensaje()
            self.mensajesChat.append(newmensaje)
            self.ChatTable.reloadData()
            self.MensageText.text?.removeAll()
        }
    }
    @IBAction func CloseChat(_ sender: Any) {
        self.ChatView.isHidden = true
    }
    
    
    //MARK:- MOSTRAR Y OCULTAR EL TECLADO
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.MensageText.resignFirstResponder()
        if !(self.MensageText.text?.isEmpty)!{
            let newmensaje = CMensaje(chatId: (myvariables.chatsOpen.first?.ChatID)!, mensaje: self.MensageText.text!, emisor: self.destinoChat)
            newmensaje.EnviarMensaje()
            self.mensajesChat.append(newmensaje)
            self.ChatTable.reloadData()
            self.MensageText.text?.removeAll()
        }
        return true
    }

    
    func keyboardNotification(notification: NSNotification){
        if let userInfo = notification.userInfo{
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 0.0
            } else {
                self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }

    
    //MARK: -TABLE DELEGATE METODOS
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mensajesChat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
            cell = tableView.dequeueReusableCell(withIdentifier: "MSG", for: indexPath)
            // Configure the cell...
            cell.textLabel?.clipsToBounds = true
            cell.textLabel?.text = self.mensajesChat[indexPath.row].Mensaje
            cell.textLabel?.layer.cornerRadius = 15
        if self.mensajesChat[indexPath.row].EmailEmisor == myvariables.userperfil.Email{
            cell.textLabel?.textAlignment = .right
            cell.textLabel?.backgroundColor = UIColor(red: 226, green: 241, blue: 255, alpha: 1)
        }else{
            cell.textLabel?.backgroundColor = UIColor(red: 226, green: 231, blue: 136, alpha: 1)
            cell.textLabel?.textAlignment = .left
        }
        
        // First figure out how many sections there are
        let lastSectionIndex = tableView.numberOfSections - 1
        // Then grab the number of rows in the last section
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        
        // Now just construct the index path
        //let pathToLastRow = NSIndexPath(indexPathforRow: lastRowIndex, inSection: lastSectionIndex)
        
        // Make the last row visible
        tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        self.MensageText.endEditing(true)
    }
    
}
