//
//  LoginController.swift
//  NoIce
//
//  Created by Done Santana on 21/4/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GoogleSignIn
import CloudKit

class LoginController: UIViewController,GIDSignInDelegate,GIDSignInUIDelegate {
    
    var loginContainer = CKContainer.default()
    var camaraPerfilController: UIImagePickerController!
    
    
    @IBOutlet weak var LoginView: UIView!
    @IBOutlet weak var LoadingView: UIView!
  
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = "87612102903-gccdrua07g6t6mpgdrpct985bidkvl3c.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().signInSilently()
    
    
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!){
        if error == nil {
            self.LoginView.isHidden = true
            self.LoadingView.isHidden = false
            myvariables.userperfil = CUser(nombreapellidos: user.profile.givenName + " " + user.profile.familyName, email: user.profile.email)
            myvariables.userperfil.ActualizarConectado()
            let predicate = NSPredicate(format: "email = %@",user.profile.email)
            let query = CKQuery(recordType:"CUsuarios", predicate: predicate)
            self.loginContainer.publicCloudDatabase.perform(query, inZoneWith: nil, completionHandler: ({results, error in
                if (error == nil) {
                    if results?.count == 0{
                        let EditPhoto = UIAlertController (title: NSLocalizedString("Select the profile photo",comment:"Cambiar la foto de perfil"), message: NSLocalizedString("Is required you have a photo in your profile. Take a profile picture.", comment:""), preferredStyle: UIAlertControllerStyle.alert)
                        
                        EditPhoto.addAction(UIAlertAction(title: NSLocalizedString("Take a picture", comment:"Yes"), style: UIAlertActionStyle.default, handler: {alerAction in
                            
                            self.camaraPerfilController.sourceType = .camera
                            self.camaraPerfilController.cameraCaptureMode = .photo
                            self.camaraPerfilController.cameraDevice = .front
                            self.present(self.camaraPerfilController, animated: true, completion: nil)
                            
                        }))
                        EditPhoto.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment:"Cancelar"), style: UIAlertActionStyle.destructive, handler: { action in
                        }))
                        self.present(EditPhoto, animated: true, completion: nil)
                    }else{
                            do{
                                let photo = results?[0].value(forKey: "foto") as! CKAsset
                                let photoPerfil = try Data(contentsOf: photo.fileURL as URL)
                                myvariables.userperfil.GuardarFotoPerfil(photo: UIImage(data: photoPerfil)!)
                            }catch{
                                myvariables.userperfil.GuardarFotoPerfil(photo:UIImage(named: "user")!)
                            }
                        DispatchQueue.main.async {
                            self.LoadingView.isHidden = true
                            let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "InicioView") as! ViewController
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
            myvariables.userperfil.RegistrarUser(NombreApellidos: myvariables.userperfil.NombreApellidos, Email: myvariables.userperfil.Email, photo: fotoContenido)
            myvariables.userperfil.GuardarFotoPerfil(photo: KPhotoPreview!)
        }else{
            self.camaraPerfilController.dismiss(animated: true, completion: nil)
            let EditPhoto = UIAlertController (title: NSLocalizedString("Error",comment:"Cambiar la foto de perfil"), message: NSLocalizedString("The profile only accept selfies photo.", comment:""), preferredStyle: UIAlertControllerStyle.alert)
            
            EditPhoto.addAction(UIAlertAction(title: NSLocalizedString("Take a picture again", comment:"Yes"), style: UIAlertActionStyle.default, handler: {alerAction in
                self.camaraPerfilController.sourceType = .camera
                self.camaraPerfilController.cameraCaptureMode = .photo
                self.camaraPerfilController.cameraDevice = .front
                self.present(self.camaraPerfilController, animated: true, completion: nil)
            }))
            EditPhoto.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment:"Cancelar"), style: UIAlertActionStyle.destructive, handler: { action in
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

    
}
