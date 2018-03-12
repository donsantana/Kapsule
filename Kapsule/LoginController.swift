//
//  LoginController.swift
//  Kapsule
//
//  Created by Done Santana on 3/8/18.
//  Copyright © 2018 Done Santana. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GoogleSignIn
import CloudKit

class LoginController: UIViewController,GIDSignInDelegate,GIDSignInUIDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var loginContainer = CKContainer.default()
    var camaraPerfilController: UIImagePickerController!
    
    
    @IBOutlet weak var LoginView: UIView!
    @IBOutlet weak var GmailBtn: GIDSignInButton!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = "1046754475692-nifgggpp63qamvbgdg2jiauuha60tpm8.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().signInSilently()
        
        self.camaraPerfilController = UIImagePickerController()
        self.camaraPerfilController.delegate = self
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!){
        if error == nil {
            self.LoginView.isHidden = true
            myvariables.userperfil = CUser(name: user.profile.givenName + " " + user.profile.familyName, email: user.profile.email)
            let predicate = NSPredicate(format: "email = %@",user.profile.email)
            let query = CKQuery(recordType:"kUsers", predicate: predicate)
            self.loginContainer.publicCloudDatabase.perform(query, inZoneWith: nil, completionHandler: ({results, error in
                if (error == nil) {
                    if results?.count == 0{
                        let EditPhoto = UIAlertController (title: NSLocalizedString("Hacer foto de perfil",comment:"Cambiar la foto de perfil"), message: NSLocalizedString("Is required you have a photo in your profile. Take a profile picture.", comment:""), preferredStyle: UIAlertControllerStyle.alert)
                        
                        EditPhoto.addAction(UIAlertAction(title: NSLocalizedString("Take a picture", comment:"Yes"), style: UIAlertActionStyle.default, handler: {alerAction in
                            
                            self.camaraPerfilController.sourceType = .camera
                            self.camaraPerfilController.cameraCaptureMode = .photo
                            self.camaraPerfilController.cameraDevice = .front
                            self.present(self.camaraPerfilController, animated: true, completion: nil)
                            
                        }))
                        EditPhoto.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment:"Cancelar"), style: UIAlertActionStyle.destructive, handler: { action in
                            exit(0)
                        }))
                        self.present(EditPhoto, animated: true, completion: nil)
                    }else{
                        do{
                            let photo = results?[0].value(forKey: "photo") as! CKAsset
                            let photoPerfil = try Data(contentsOf: photo.fileURL as URL)
                            myvariables.userperfil.GuardarFotoPerfil(newPhoto: UIImage(data: photoPerfil)!)
                        }catch{
                            myvariables.userperfil.GuardarFotoPerfil(newPhoto:UIImage(named: "user")!)
                        }
                        DispatchQueue.main.async {
                            let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "InicioView") as! InicioController
                            self.navigationController?.show(vc, sender: nil)
                        }
                    }
                }else{
                    print("ERROR DE CONSULTA " + error.debugDescription)
                }
            }))
        }else{
            print("ERROR DE LOGIN")
        }
    }
    
    
    // Finished disconnecting |user| from the app successfully if |error| is |nil|.
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!){
        if error == nil {
            exit(0)
        }
        else {
            
        }
    }
    
    //MARK: -EVENTO PARA DETECTAR FOTO Y VIDEO TIRADA
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if camaraPerfilController.cameraDevice == .front{
            let mediaType = info[UIImagePickerControllerMediaType] as! NSString
            self.camaraPerfilController.dismiss(animated: true, completion: nil)
            let KPhotoPreview = info[UIImagePickerControllerOriginalImage] as? UIImage
            let imagenURL = self.saveImageToFile(KPhotoPreview!)
            let fotoContenido = CKAsset(fileURL: imagenURL)
            myvariables.userperfil.RegistrarUser(NombreApellidos: myvariables.userperfil.name, Email: myvariables.userperfil.email, photo: fotoContenido)
            myvariables.userperfil.GuardarFotoPerfil(newPhoto: KPhotoPreview!)
            let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "Searching") as! LoginController
            self.navigationController?.show(vc, sender: nil)
        }else{
            self.camaraPerfilController.dismiss(animated: true, completion: nil)
            let EditPhoto = UIAlertController (title: NSLocalizedString("Error",comment:"Cambiar la foto de perfil"), message: NSLocalizedString("The profile only accept selfies photo.", comment:""), preferredStyle: UIAlertControllerStyle.alert)
            
            EditPhoto.addAction(UIAlertAction(title: NSLocalizedString("Repetir", comment:"Yes"), style: UIAlertActionStyle.default, handler: {alerAction in
                self.camaraPerfilController.sourceType = .camera
                self.camaraPerfilController.cameraCaptureMode = .photo
                self.camaraPerfilController.cameraDevice = .front
                self.present(self.camaraPerfilController, animated: true, completion: nil)
            }))
            EditPhoto.addAction(UIAlertAction(title: NSLocalizedString("Cancelar", comment:"Cancelar"), style: UIAlertActionStyle.destructive, handler: { action in
            }))
            self.present(EditPhoto, animated: true, completion: nil)
        }
        
    }
    
    //RENDER IMAGEN
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
    
    @IBAction func GmailSignBtn(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
}

