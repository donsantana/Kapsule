//
//  LoginController.swift
//  NoIce
//
//  Created by Done Santana on 21/4/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn
import CloudKit
import FBSDKCoreKit
import FBSDKLoginKit


class LoginController: UIViewController,GIDSignInDelegate,GIDSignInUIDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, FBSDKLoginButtonDelegate {
    
    var locationManager = CLLocationManager()
    var loginContainer = CKContainer.default()
    var camaraPerfilController: UIImagePickerController!
    var faceManager = FBSDKLoginManager()
    
    
    @IBOutlet weak var LoginView: UIView!
    @IBOutlet weak var LoadingView: UIView!
    @IBOutlet weak var FaceLoginBtn: FBSDKLoginButton!
   
  
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = "319723960699-96388hc84tnoohlatvb8r7rhm2806br1.apps.googleusercontent.com"
        //GIDSignIn.sharedInstance().signInSilently()
        
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
        
    
        self.camaraPerfilController = UIImagePickerController()
        self.camaraPerfilController.delegate = self
        
        //MARK: -INICIALIZAR GEOLOCALIZACION
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        if self.appUpdateAvailable(){
            
            let alertaVersion = UIAlertController (title: "Application version", message: "Dear customer, it is necessary to update to the latest version of the application available in the AppStore. Do you want to do it at this time?", preferredStyle: .alert)
            alertaVersion.addAction(UIAlertAction(title: "Yes", style: .default, handler: {alerAction in
                
                UIApplication.shared.openURL(URL(string: "itms://itunes.apple.com/us/app/apple-store/id1290022053?mt=8")!)
            }))
            alertaVersion.addAction(UIAlertAction(title: "No", style: .default, handler: {alerAction in
                exit(0)
            }))
            self.present(alertaVersion, animated: true, completion: nil)
            
        }
        
    }
    
    func appUpdateAvailable() -> Bool
    {
        let storeInfoURL: String = "http://itunes.apple.com/lookup?bundleId=www.donelkys.NoIce"
        var upgradeAvailable = false
        
        // Get the main bundle of the app so that we can determine the app's version number
        let bundle = Bundle.main
        if let infoDictionary = bundle.infoDictionary {
            // The URL for this app on the iTunes store uses the Apple ID for the  This never changes, so it is a constant
            let urlOnAppStore = URL(string: storeInfoURL)
            if let dataInJSON = try? Data(contentsOf: urlOnAppStore!) {
                // Try to deserialize the JSON that we got
                if let lookupResults = try? JSONSerialization.jsonObject(with: dataInJSON, options: JSONSerialization.ReadingOptions()) as! Dictionary<String, Any>{
                    // Determine how many results we got. There should be exactly one, but will be zero if the URL was wrong
                    if let resultCount = lookupResults["resultCount"] as? Int {
                        if resultCount == 1 {
                            // Get the version number of the version in the App Store
                            //self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<String, AnyObject>>)[0]
                            if let appStoreVersion = (lookupResults["results"]as! Array<Dictionary<String, AnyObject>>)[0]["version"] as? String {
                                // Get the version number of the current version
                                if let currentVersion = infoDictionary["CFBundleShortVersionString"] as? String {
                                    // Check if they are the same. If not, an upgrade is available.
                                    if appStoreVersion > currentVersion {
                                        upgradeAvailable = true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        ///Volumes/Datos/Ecuador/Desarrollo/UnTaxi/UnTaxi/LocationManager.swift:635:31: Ambiguous use of 'indexOfObject'
        return upgradeAvailable
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!){
        if error == nil {
            self.LoginView.isHidden = true
            self.LoadingView.isHidden = false
            myvariables.userperfil = CUser(nombreapellidos: user.profile.givenName + " " + user.profile.familyName, email: user.profile.email)
            let predicate = NSPredicate(format: "email = %@",user.profile.email)
            let query = CKQuery(recordType:"CUsuarios", predicate: predicate)
            self.loginContainer.publicCloudDatabase.perform(query, inZoneWith: nil, completionHandler: ({results, error in
                if (error == nil) {
                    if results?.count == 0{
                        let EditPhoto = UIAlertController (title: NSLocalizedString("Profile photo",comment:"Profile photo"), message: NSLocalizedString("Is required you have a photo in your profile. Take a profile picture.", comment:""), preferredStyle: UIAlertControllerStyle.alert)
                        
                        EditPhoto.addAction(UIAlertAction(title: NSLocalizedString("Take a photo", comment:"Yes"), style: UIAlertActionStyle.default, handler: {alerAction in
                            
                            self.camaraPerfilController.sourceType = .camera
                            self.camaraPerfilController.cameraCaptureMode = .photo
                            self.camaraPerfilController.cameraDevice = .front
                            self.present(self.camaraPerfilController, animated: true, completion: nil)
                            
                        }))
                        EditPhoto.addAction(UIAlertAction(title: NSLocalizedString("Close", comment:"Cancelar"), style: UIAlertActionStyle.destructive, handler: { action in
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
            myvariables.userperfil.RegistrarUser(NombreApellidos: myvariables.userperfil.NombreApellidos, Email: myvariables.userperfil.Email, photo: fotoContenido,pos: myvariables.userperfil.Posicion)
            myvariables.userperfil.GuardarFotoPerfil(photo: KPhotoPreview!)
            self.LoadingView.isHidden = true
            let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "InicioView") as! ViewController
            self.navigationController?.show(vc, sender: nil)
        }else{
            self.camaraPerfilController.dismiss(animated: true, completion: nil)
            let EditPhoto = UIAlertController (title: NSLocalizedString("Error",comment:"Wrong Camara"), message: NSLocalizedString("The profile only accepts selfies photo.", comment:""), preferredStyle: UIAlertControllerStyle.alert)
            
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
    @IBAction func GmailLogin(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }

    @IBAction func FaceLogin(_ sender: Any) {
        
    }
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        self.getFBUserData()
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Login Out")
    }
    
    func getFBUserData(){
        
        if((FBSDKAccessToken.current()) != nil){
            self.LoadingView.isHidden = false
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
            })
        }
    }
}
