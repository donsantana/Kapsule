//
//  ChatVC.swift
//  Chat App For iOS 10
//
//  Created by MacBook on 11/23/16.
//  Copyright © 2016 Awesome Tuts. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import CloudKit

class ChatViewController: JSQMessagesViewController, UINavigationControllerDelegate {
    
    var chatOpenPos: Int!
    var MSGTimer : Timer!
    var MSGContainer = CKContainer.default()
    @IBOutlet weak var EmisorImage: UIImageView!
    @IBOutlet weak var ImagePreview: UIImageView!
    @IBOutlet var Preview: UIView!
    @IBOutlet weak var imagenBtn: UIButton!
    
    
    var mensajesMostrados = [JSQMessage]()
    
    //var message1 = JSQMessage(senderId: "1", displayName: "", text: "Hola")
    //var message2 = JSQMessage(senderId: "2", displayName: "", text: "Hola tu")
    
    //let picker = UIImagePickerController();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderId = myvariables.userperfil.Email
        self.senderDisplayName = ""
       /*  mensajesMostrados.append(message2!)*/
        /*MessagesHandler.Instance.delegate = self;
        
        self.senderId = AuthProvider.Instance.userID()
        self.senderDisplayName = AuthProvider.Instance.userName;
        
        MessagesHandler.Instance.observeMessages();
        MessagesHandler.Instance.observeMediaMessages();*/
        
        MSGTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(BuscarNewMSG), userInfo: nil, repeats: true)
        
        self.EmisorImage.layer.cornerRadius = self.EmisorImage.frame.height/4
        self.EmisorImage.clipsToBounds = true
        self.EmisorImage.image = myvariables.usuariosMostrar[self.chatOpenPos].FotoPerfil

        //Hide avatar
        collectionView?.collectionViewLayout.incomingAvatarViewSize = .zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
        //Hide adjunte button
        self.inputToolbar.contentView.leftBarButtonItem = nil
        
    }
    
    // COLLECTION VIEW FUNCTIONS
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        let message = mensajesMostrados[indexPath.item]
        if message.senderId == self.senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        } else {
            return bubbleFactory?.incomingMessagesBubbleImage(with: UIColor(red: 0.67, green: 0.75, blue: 0.79, alpha: 1))
        }
         
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = mensajesMostrados[indexPath.item]
        if message.senderId == self.senderId {
            return nil //JSQMessagesAvatarImageFactory.avatarImage(with: myvariables.userperfil.FotoPerfil, diameter: 70)
        } else {
            return nil //JSQMessagesAvatarImageFactory.avatarImage(with: myvariables.usuariosMostrar[self.chatOpenPos].FotoPerfil, diameter: 70)
        }
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return mensajesMostrados[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        
        let msg = mensajesMostrados[indexPath.item]
        
        if msg.isMediaMessage {
            if let mediaItem = msg.media as? JSQVideoMediaItem {
                let player = AVPlayer(url: mediaItem.fileURL)
                let playerController = AVPlayerViewController()
                playerController.player = player;
                self.present(playerController, animated: true, completion: nil)
            }
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mensajesMostrados.count;
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
       
        cell.textView.textColor = UIColor.black

        return cell
    }
    
    // END COLLECTION VIEW FUNCTIONS
    
    // SENDING BUTTONS FUNCTIONS
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        mensajesMostrados.append(JSQMessage(senderId: myvariables.userperfil.Email, displayName: "", text: text))
        collectionView.reloadData()
        SendNewMessage(text: text)
        finishSendingMessage()
    }
    
    /*override func didPressAccessoryButton(_ sender: UIButton!) {
        let alert = UIAlertController(title: "Media Messages", message: "Please Select A Media", preferredStyle: .actionSheet);
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil);
        
        let photos = UIAlertAction(title: "Photos", style: .default,    handler: { (alert: UIAlertAction) in
            self.chooseMedia(type: kUTTypeImage);
        })
        
        let videos = UIAlertAction(title: "Videos", style: .default,    handler: { (alert: UIAlertAction) in
            self.chooseMedia(type: kUTTypeMovie);
        })
        
        alert.addAction(photos);
        alert.addAction(videos);
        alert.addAction(cancel);
        present(alert, animated: true, completion: nil);
        
    }
    
    // END SENDING BUTTONS FUNCTIONS
    
    // PICKER VIEW FUNCTIONS
    
    private func chooseMedia(type: CFString) {
        picker.mediaTypes = [type as String]
        present(picker, animated: true, completion: nil);
    }
 
    // END PICKER VIEW FUNCTIONS
    
    // DELEGATION FUNCTIONS
    
    func messageReceived(senderID: String, senderName: String, text: String) {
        mensajesMostrados.append(JSQMessage(senderId: senderID, displayName: senderName, text: text));
        collectionView.reloadData();
    }*/
    
    
    // END DELEGATION FUNCTIONS
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil);
    }
    
    //FUNCTION TO SEARCH NEW MESSAGES
    func BuscarNewMSG() {
        let predicateMesajes = NSPredicate(format: "destinoEmail == %@ and emisorEmail == %@", myvariables.userperfil.Email, myvariables.usuariosMostrar[chatOpenPos].Email)
        
        let queryKapsuleVista = CKQuery(recordType: "CMensaje",predicate: predicateMesajes)
        
        self.MSGContainer.publicCloudDatabase.perform(queryKapsuleVista, inZoneWith: nil, completionHandler: ({results, error in
            if (error == nil) {
                if (results?.count)! > 0{
                    var i = 0
                    while i < (results?.count)!{
                        let MSG = JSQMessage(senderId: results?[i].value(forKey: "emisorEmail") as! String, displayName: "", text: results?[i].value(forKey: "textoMensaje") as! String)
                        self.EliminarMSGRead(record: (results?[i].recordID)!)
                        self.mensajesMostrados.append(MSG!)
                        myvariables.usuariosMostrar[self.chatOpenPos].NewMsg = false
                        i += 1
                    }
                }
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }))
        
    }
    
    @IBAction func BlockUser(_ sender: Any) {
        myvariables.userperfil.ActualizarBloqueo(emailBloqueado: myvariables.usuariosMostrar[self.chatOpenPos].Email){ success in
            if success{
                self.MSGTimer.invalidate()
                myvariables.usuariosMostrar.remove(at: self.chatOpenPos)
                DispatchQueue.main.async {
                    //let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "UserConnected") as! UserViewController
                    let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "InicioView") as! ViewController
                    self.navigationController?.show(vc, sender: nil)
                }
            }
            
        }

    }
   
    func EliminarMSGRead(record : CKRecordID) {
        self.MSGContainer.publicCloudDatabase.delete(withRecordID: record, completionHandler: { _,_ in })
    }
    
    func SendNewMessage(text: String) {
            let newmensaje = CMensaje(emailEmisor: myvariables.userperfil.Email, emailDestino: myvariables.usuariosMostrar[chatOpenPos].Email, mensaje: text)
            newmensaje.EnviarMensaje()
    }
}









































