//
//  LoginController.swift
//  Kapsule
//
//  Created by Done Santana on 3/8/18.
//  Copyright © 2018 Done Santana. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginController: UIViewController,FBSDKLoginButtonDelegate {
    
    var faceManager = FBSDKLoginManager()
    
    

    @IBOutlet weak var LoginView: UIView!
    @IBOutlet weak var FaceLoginBtn: FBSDKLoginButton!
    @IBOutlet weak var gmailBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.FaceLoginBtn.readPermissions = ["public_profile", "email"];
        self.FaceLoginBtn.delegate = self
        for const in self.FaceLoginBtn.constraints{
            if const.firstAttribute == NSLayoutAttribute.height && const.constant == 28{
                self.FaceLoginBtn.removeConstraint(const)
            }
        }
        let buttonText = NSAttributedString(string: "Facebook")
        self.FaceLoginBtn.setAttributedTitle(buttonText, for: .normal)
        self.getFBUserData()
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        self.getFBUserData()
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Login Out")
    }
    
    func getFBUserData(){
        
        if((FBSDKAccessToken.current()) != nil){
    /*
            FBSDKGraphRequest(graphPath: "me",parameters: ["fields": "id, name, email, age_range"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    var facePerfil = result as! NSDictionary
                    let temp = facePerfil["age_range"] as! NSDictionary
                    if temp["min"] as! Int > 14 {
                        myvariables.userperfil = CUser(nombreapellidos: facePerfil["name"] as! String, email: facePerfil["email"] as! String)
                        let predicate = NSPredicate(format: "email = %@",facePerfil["email"] as! String)
                        let query = CKQuery(recordType:"CUsuarios", predicate: predicate)
                        self.loginContainer.publicCloudDatabase.perform(query, inZoneWith: nil, completionHandler: ({results, error in
                            if (error == nil) {
                                if results?.count == 0{
                                    let EditPhoto = UIAlertController (title: NSLocalizedString("Profile photo",comment:"Cambiar la foto de perfil"), message: NSLocalizedString("Is required you have a photo in your profile. Take a profile picture.", comment:""), preferredStyle: UIAlertControllerStyle.alert)
                                    
                                    EditPhoto.addAction(UIAlertAction(title: NSLocalizedString("Take a photo", comment:"Yes"), style: UIAlertActionStyle.default, handler: {alerAction in
                                        
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
                                    myvariables.userperfil.recordName = results?[0].recordID.recordName
                                    
                                    myvariables.userperfil.ActualizarConectado(estado: "1")
                                    
                                    myvariables.userperfil.ActualizarPosicion(posicionActual: self.locationManager.location!)
                                    do{
                                        let photo = results?[0].value(forKey: "foto") as! CKAsset
                                        let photoPerfil = try Data(contentsOf: photo.fileURL as URL)
                                        myvariables.userperfil.GuardarFotoPerfil(photo: UIImage(data: photoPerfil)!)
                                    }catch{
                                        myvariables.userperfil.GuardarFotoPerfil(photo:UIImage(named: "user")!)
                                    }
                                    myvariables.userperfil.CargarBloqueados(bloqueados: results?[0].value(forKey: "bloqueados") as! [String])
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
                        let EditPhoto = UIAlertController (title: NSLocalizedString("Terms of Use",comment:"Age Policy"), message: NSLocalizedString("To use this application is required you are older than 14 years old.", comment:""), preferredStyle: UIAlertControllerStyle.alert)
                        
                        EditPhoto.addAction(UIAlertAction(title: NSLocalizedString("Close", comment:"Close"), style: UIAlertActionStyle.destructive, handler: { action in
                            exit(0)
                        }))
                        self.present(EditPhoto, animated: true, completion: nil)
                    }
                }
            })*/
        }
        }
}
