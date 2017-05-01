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

class MSGViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate {
    
    var chatOpenPos: Int!
    var mensajesMostrados = [CMensaje]()
    var MSGTimer : Timer!
    var MSGContainer = CKContainer.default()
    
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
        self.ChatTable.delegate = self
        self.DestinoImage.image = myvariables.usuariosMostrar[self.chatOpenPos].FotoPerfil
        self.DestinoImage.layer.cornerRadius = self.DestinoImage.frame.width / 2
        self.DestinoImage.contentMode = .scaleAspectFill
        self.DestinoImage.clipsToBounds = true
        
        
        //MASK: - PARA MOSTRAR Y OCULTAR EL TECLADO
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        MSGTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(BuscarNewMSG), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.MSGTimer.invalidate()
    }
    
    func BuscarNewMSG() {
        let predicateMesajes = NSPredicate(format: "destinoEmail == %@ and emisorEmail == %@", myvariables.userperfil.Email, myvariables.usuariosMostrar[chatOpenPos].Email)
        
        let queryKapsuleVista = CKQuery(recordType: "CMensaje",predicate: predicateMesajes)
        
        self.MSGContainer.publicCloudDatabase.perform(queryKapsuleVista, inZoneWith: nil, completionHandler: ({results, error in
            if (error == nil) {
                if (results?.count)! > 0{
                    var i = 0
                    while i < (results?.count)!{
                        let MSG = CMensaje(emailEmisor: results?[i].value(forKey: "emisorEmail") as! String, emailDestino: results?[i].value(forKey: "destinoEmail") as! String, mensaje: results?[i].value(forKey: "textoMensaje") as! String)
                        self.EliminarMSGRead(record: (results?[i].recordID)!)
                        self.mensajesMostrados.append(MSG)
                        myvariables.usuariosMostrar[self.chatOpenPos].NewMsg = false
                        i += 1
                    }
                }
            }
        }))
        DispatchQueue.main.async {
            self.ChatTable.reloadData()
        }
       
    }

    func EliminarMSGRead(record : CKRecordID) {
        self.MSGContainer.publicCloudDatabase.delete(withRecordID: record, completionHandler: { _,_ in })
    }
    
    func SendNewMessage() {
        self.MensageText.resignFirstResponder()
        if !(self.MensageText.text?.isEmpty)!{
            let newmensaje = CMensaje(emailEmisor: myvariables.userperfil.Email, emailDestino: myvariables.usuariosMostrar[chatOpenPos].Email, mensaje: self.MensageText.text!)
            newmensaje.EnviarMensaje()
            self.mensajesMostrados.append(newmensaje)
            self.ChatTable.reloadData()
            self.MensageText.text?.removeAll()
        }
    }
    
    //MARK: - ACTION DE BOTONES
  
    @IBAction func SendChatMensage(_ sender: Any) {
        self.SendNewMessage()
    }
    @IBAction func CloseChat(_ sender: Any) {
        self.ChatView.isHidden = true
    }
    
    
    //MARK:- MOSTRAR Y OCULTAR EL TECLADO
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.SendNewMessage()
        
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
        return self.mensajesMostrados.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        //var cell: UITableViewCell!
  
        if self.mensajesMostrados[indexPath.row].EmailEmisor == myvariables.userperfil.Email{
            let cell = Bundle.main.loadNibNamed("EmisorTableViewCell", owner: self, options: nil)?.first as! EmisorTableViewCell
            cell.MSGText.text = self.mensajesMostrados[indexPath.row].Mensaje
            cell.textLabel?.textAlignment = .right
            cell.textLabel?.backgroundColor = UIColor(red: 226, green: 241, blue: 255, alpha: 1)
            //SHOW LAST CELL
            let lastRow: Int = tableView.numberOfRows(inSection: 0) - 1
            let indexPath = IndexPath(row: lastRow, section: 0);
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            return cell
        }else{
            let cell = Bundle.main.loadNibNamed("DestinoTableViewCell", owner: self, options: nil)?.first as! DestinoTableViewCell
            cell.MSGText.text = self.mensajesMostrados[indexPath.row].Mensaje
            cell.textLabel?.backgroundColor = UIColor(red: 226, green: 231, blue: 136, alpha: 1)
            cell.textLabel?.textAlignment = .left
            //SHOW LAST CELL
            let lastRow: Int = tableView.numberOfRows(inSection: 0) - 1
            let indexPath = IndexPath(row: lastRow, section: 0);
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            return cell
        }
        //return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        self.MensageText.resignFirstResponder()
    }

    
}
