//
//  ViewController.swift
//  NoIce
//
//  Created by Done Santana on 13/1/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import UIKit
import GoogleMaps
import GoogleSignIn
import CloudKit

struct myvariables {
    static var chatsOpen = [CChat]()
    static var userperfil: CUser!
}

class ViewController: UIViewController, GIDSignInDelegate, CLLocationManagerDelegate, GIDSignInUIDelegate, GMSMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITextFieldDelegate{
    //MARK: - PROPIEDADES DE LA CLASE
    var locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    //var userperfil: CUser!
    var camaraPerfilController: UIImagePickerController!
    var usuariosMostrar = [CUser]()
    var solicitudesRecibidas = [CSolicitud]()
    var solicitudesAceptadas = [CSolicitud]()
    
    //var TableControler = ChatViewController()
    //var mensajesChat = [CMensaje]()
    //var chatsOpen = [CChat]()
    
    //@IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    
    //CLOUD VARIABLES
    var cloudContainer = CKContainer.default()
    var photoAsset: CKAsset!
    
    //Visual variables
    @IBOutlet weak var UserPerfilView: UIView!
    @IBOutlet weak var LoginView: UIView!
    @IBOutlet weak var MapaView: GMSMapView!
    @IBOutlet weak var LoadingView: UIView!
    @IBOutlet weak var userPerfilPhoto: UIImageView!
    
    //TABLA USUARIOS CONECTADOS
    @IBOutlet weak var UserConnectView: UIView!
    @IBOutlet weak var UserConnectedTable: UITableView!
    
    //SOLICITUDES RECIBIDAS
    @IBOutlet weak var SolicitudView: UIView!
    @IBOutlet weak var EmisorPhoto: UIImageView!
    
    // CHAT
    @IBOutlet weak var OpenChatView: UIView!
    @IBOutlet weak var OpenChatTable: UITableView!
    /*@IBOutlet weak var ChatView: UIView!
    @IBOutlet weak var CreateMSGView: UIView!
    @IBOutlet weak var ChatTable: UITableView!
    @IBOutlet weak var DestinoImage: UIImageView!
    @IBOutlet weak var MensageText: UITextField!*/
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.MapaView.delegate = self
        //self.MensageText.delegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = "87612102903-gccdrua07g6t6mpgdrpct985bidkvl3c.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().signInSilently()
        
        //MARK: -INICIALIZAR CAMARA
        self.camaraPerfilController = UIImagePickerController()
        self.camaraPerfilController.delegate = self
        
        //MARK: -INICIALIZAR GEOLOCALIZACION
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        self.MapaView.isMyLocationEnabled = true
        
        myvariables.chatsOpen = [CChat]()
        //self.userMarker = GMSMarker()
        let JSONStyle = "[" +
            "  {" +
            "    \"featureType\": \"all\"," +
            "    \"elementType\": \"geometry.fill\"," +
            "    \"stylers\": [" +
            "      {" +
            "        \"weight\": \"2.00\"" +
            "      }" +
            "    ]" +
            "  }," +
            "       {" +
            "           \"featureType\": \"all\"," +
            "           \"elementType\": \"geometry.stroke\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#9c9c9c\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"landscape\"," +
            "           \"elementType\": \"all\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#f2f2f2\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"landscape\"," +
            "           \"elementType\": \"all\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#f2f2f2\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"landscape\"," +
            "           \"elementType\": \"geometry.fill\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#ffffff\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"landscape.man_made\"," +
            "           \"elementType\": \"geometry.fill\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#ffffff\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"poi\"," +
            "           \"elementType\": \"all\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"visibility\": \"off\"" +
            "           }" +
            "           ]" +
            "      }," +
            "       {" +
            "           \"featureType\": \"road\"," +
            "           \"elementType\": \"all\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"saturation\": -100" +
            "           }," +
            "           {" +
            "           \"lightness\": 45" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"road\"," +
            "           \"elementType\": \"geometry.fill\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#e1e2e2\"" +
            "          }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"road\"," +
            "           \"elementType\": \"labels.text.fill\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#232323\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"road\"," +
            "           \"elementType\": \"labels.text.stroke\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#ffffff\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"road.highway\"," +
            "           \"elementType\": \"all\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"visibility\": \"simplified\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "          \"featureType\": \"road.arterial\"," +
            "           \"elementType\": \"labels.icon\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"visibility\": \"off\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"transit\"," +
            "           \"elementType\": \"all\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"visibility\": \"on\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"water\"," +
            "           \"elementType\": \"all\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"9aadb5\"" +
            "           }," +
            "           {" +
            "           \"visibility\": \"on\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"water\"," +
            "           \"elementType\": \"geometry.fill\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#9aadb5\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"water\"," +
            "           \"elementType\": \"labels.text.fill\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#070707\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"water\"," +
            "           \"elementType\": \"labels.text.stroke\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#ffffff\"" +
            "           }" +
            "           ]" +
            "       }," +
            
            "  {" +
            "    \"featureType\": \"transit\"," +
            "    \"elementType\": \"labels.icon\"," +
            "    \"stylers\": [" +
            "      {" +
            "        \"visibility\": \"on\"" +
            "      }" +
            "    ]" +
            "  }" +
        "]"
        
        
        if let tempLocation = self.locationManager.location?.coordinate{
            self.userLocation = tempLocation
            self.MapaView.camera = GMSCameraPosition.camera(withLatitude: (userLocation.latitude), longitude: (userLocation.longitude), zoom: 16.0)
        }else{
            self.MapaView.camera = GMSCameraPosition.camera(withLatitude: 25.770928, longitude: -80.194877, zoom: 5.0)
        }

        do{
            self.MapaView.mapStyle = try GMSMapStyle(jsonString: JSONStyle)
        }catch{
            print("NO PUEDEEEEEEEEEEEEEEEEEEEEEE")
        }
        // Do any additional setup after loading the view, typically from a nib.
        
       //PARA MOSTRAR Y OCULTAR EL TECLADO
        /*NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)*/
    }

    //MARK: - ACTUALIZACION DE GEOLOCALIZACION
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if myvariables.userperfil != nil{
            if myvariables.userperfil.Posicion.distance(from: locations.last!) > 10{
                myvariables.userperfil.ActualizarPosicion(posicionActual: locations.last!)
            }
            if self.usuariosMostrar.count == 0{
                self.BuscarUsuariosConectados()
            }else{
                self.UserConnectedTable.reloadData()
            }

            //FUNCION PARA BUSCAR SOLICITUDES RECIBIDAS
            myvariables.userperfil.BuscarSolRecibidas(completionHandler: {
                (respuesta)->Void in
                self.solicitudesRecibidas = respuesta
                if self.solicitudesRecibidas.count != 0{
                    self.EmisorPhoto.image = self.solicitudesRecibidas.first?.FotoEmisor
                    self.SolicitudView.isHidden = false
                }else{
                    print("NADA")
                }
            })
            
            myvariables.userperfil.BuscarSolAceptadas(completionHandler: {
                (respuesta) -> Void in
                if respuesta.count > 0{
                    let chatIDTemp = (respuesta.first?.EmailEmisor)! + "+" + (respuesta.first?.EmailDestino)!
                    
                        if respuesta.first?.Estado == "A"{
                            let newChat = CChat(chatID: chatIDTemp, emisorImagen: (respuesta.first?.FotoEmisor)!, destinoImagen: (respuesta.first?.FotoDestino)!)
                            self.AgregarChat(newChat: newChat)
                            let alertaOpcionesChat = UIAlertController (title: NSLocalizedString("Request Acepted",comment:"Request Acepted"), message: NSLocalizedString("Your request to meet this person were acepted. Now you can chat.", comment:"Mensaje de salir"), preferredStyle: UIAlertControllerStyle.alert)
                            alertaOpcionesChat.addAction(UIAlertAction(title: NSLocalizedString("Acept", comment:"Text Message"), style: UIAlertActionStyle.default, handler: {alerAction in
                                let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "MSGView") as! MSGViewController
                                vc.destinoChat = "E"
                                self.navigationController?.show(vc, sender: nil)
                                myvariables.userperfil.DeletedSolicitud(solicitud: (respuesta.first)!)
                            }))
                            self.present(alertaOpcionesChat, animated: true, completion: nil)

                        }else{
                            if respuesta.first?.Estado == "R" {
                                let alertaOpcionesChat = UIAlertController (title: NSLocalizedString("Request Declined",comment:"Request Declined"), message: NSLocalizedString("Your request to meet this person were decline.", comment:"Mensaje de salir"), preferredStyle: UIAlertControllerStyle.alert)
                                alertaOpcionesChat.addAction(UIAlertAction(title: NSLocalizedString("Acept", comment:"Text Message"), style: UIAlertActionStyle.default, handler: {alerAction in
                                    myvariables.userperfil.DeletedSolicitud(solicitud: (respuesta.first)!)
                                }))
                                self.present(alertaOpcionesChat, animated: true, completion: nil)
                            }
                            
                        }
                        self.solicitudesAceptadas = respuesta
                }
            })

        }
    }
    
    //MARK: -FUNCIONES GOOGLE SIGN-IN DELEGATE
    
    // The sign-in flow has finished and was successful if |error| is |nil|.
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!){
        if error == nil {
            self.LoginView.isHidden = true
            self.LoadingView.isHidden = false
            myvariables.userperfil = CUser(nombreapellidos: user.profile.givenName + " " + user.profile.familyName, email: user.profile.email)
            myvariables.userperfil.ActualizarConectado()
            let predicate = NSPredicate(format: "email = %@",user.profile.email)
            let query = CKQuery(recordType:"CUsuarios", predicate: predicate)
            self.cloudContainer.publicCloudDatabase.perform(query, inZoneWith: nil, completionHandler: ({results, error in
                if (error == nil) {
                    if results?.count == 0{
                        //let myFilePathString = Bundle.main.path(forResource: "userphoto", ofType: "png")!
                        //let photoTemporal = CKAsset(fileURL: URL(fileURLWithPath: myFilePathString))
                        let EditPhoto = UIAlertController (title: NSLocalizedString("Select the profile photo",comment:"Cambiar la foto de perfil"), message: NSLocalizedString("Is required you have a photo in your profile. Take a profile picture.", comment:""), preferredStyle: UIAlertControllerStyle.alert)
                        //to change font of title and message.
                        
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
                        DispatchQueue.main.async {
                        do{
                            let photo = results?[0].value(forKey: "foto") as! CKAsset
                            let photoPerfil = try Data(contentsOf: photo.fileURL as URL)
                            self.userPerfilPhoto.image = UIImage(data: photoPerfil)
                            myvariables.userperfil.FotoPerfil = UIImage(data: photoPerfil)!
                            self.LoadingView.isHidden = true
                            self.UserPerfilView.isHidden = false
                        }catch{
                            self.userPerfilPhoto.image = UIImage(named: "user")
                            self.LoadingView.isHidden = true
                            self.UserPerfilView.isHidden = false
                        }
                    }
                        
                    }
                }else{
                    print("ERROR DE CONSULTA " + error.debugDescription)
                }
            }))
            //self.userperfil.ActualizarConectado()
            
            let exito = myvariables.userperfil.ChatOpens(completionHandler: {
                return true
            })
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

    //MARK: -EVENTO PARA DETECTAR FOTO Y VIDEO TIRADA
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
                        self.camaraPerfilController.dismiss(animated: true, completion: nil)
                        let KPhotoPreview = info[UIImagePickerControllerOriginalImage] as? UIImage
                        let imagenURL = self.saveImageToFile(KPhotoPreview!)
                        let fotoContenido = CKAsset(fileURL: imagenURL)
                        myvariables.userperfil.RegistrarUser(NombreApellidos: myvariables.userperfil.NombreApellidos, Email: myvariables.userperfil.Email, photo: fotoContenido)
    }
    
    //MARK: - BUSCAR USUARIOS CONECTADOS
    func BuscarUsuariosConectados(){

        let predicateUsuarioIn = NSPredicate(format: "conectado == %@", "1")
        let queryUsuarioIn = CKQuery(recordType: "CUsuarios",predicate: predicateUsuarioIn)
        
        self.cloudContainer.publicCloudDatabase.perform(queryUsuarioIn, inZoneWith: nil, completionHandler: ({results, error in
            if (error == nil) {
                if (results?.count)! > 1{
                    self.usuariosMostrar.removeAll()
                    for usuarios in results!{
                        if usuarios.value(forKey: "email") as! String != myvariables.userperfil.Email{
                            let ususarioLocation = usuarios.value(forKey: "posicion") as! CLLocation
                            let distancia = ususarioLocation.distance(from: myvariables.userperfil.Posicion)
                            print(distancia.description)
                        if (distancia < 40.0){
                            let usuarioTemp = CUser(nombreapellidos: usuarios.value(forKey: "nombreApellidos") as! String, email: usuarios.value(forKey: "email") as! String)
                            DispatchQueue.main.async {
                                do{
                                    let photo = usuarios.value(forKey: "foto") as! CKAsset
                                    let photoPerfil = try Data(contentsOf:(photo.fileURL as URL))
                                    usuarioTemp.ActulizarFotoPerfil(photo: UIImage(data: photoPerfil)!)
                                    self.usuariosMostrar.append(usuarioTemp)
                                    self.LoadingView.isHidden = true
                                }catch{
                                    
                                }
                            }
                        }else{
                            
                        }
                        }
                    }
                }else{
                    
                }
            }else{
                print("ERROR DE CONSULTA " + error.debugDescription)
            }
        }))
    }
    
    //BUSCAR SOLICITUDES ACEPTADAS
    func BuscarSolAceptadas(){
        myvariables.userperfil.BuscarSolAceptadas(completionHandler: {
            (respuesta) -> Void in
            print("Estoy metio aqui" + String(respuesta.count))
            if respuesta.count > 0{
                let chatIDTemp = (respuesta.first?.EmailEmisor)! + "+" + (respuesta.first?.EmailDestino)!
                if respuesta.count > myvariables.chatsOpen.count{
                    let newChat = CChat(chatID: chatIDTemp, emisorImagen: (respuesta.first?.FotoEmisor)!, destinoImagen: (respuesta.first?.FotoDestino)!)
                    self.AgregarChat(newChat: newChat)
                }
            }
        })
    }
    
    func AgregarChat(newChat: CChat) {
        var cant = 0
        while (cant <  myvariables.chatsOpen.count) && (myvariables.chatsOpen[cant]).ChatID != newChat.ChatID{
            cant += 1
        }
        if cant == myvariables.chatsOpen.count{
            myvariables.chatsOpen.append(newChat)
        }
    }
    
    /*func BuscarSolEnChat(solicitud: CSolicitud)->Bool{
        var resultado = false
        for sol in myvariables.chatsOpen{
            if sol.ChatID == solicitud.EmailEmisor+solicitud.EmailDestino{
                resultado = true
            }
        }
        return resultado
    }*/
    
//MARK: - ACTION BOTONES GRAFICOS
    @IBAction func ShowMenuBtn(_ sender: Any) {
        myvariables.userperfil.ActualizarDesconectado()
        sleep(3)
        exit(0)
        /*let alertaClose = UIAlertController (title: NSLocalizedString("Close the Application",comment:"Close the Application"), message: NSLocalizedString("Do you want to save your data for the next time you start the application?", comment:"Mensaje de salir"), preferredStyle: UIAlertControllerStyle.alert)
        alertaClose.addAction(UIAlertAction(title: NSLocalizedString("YES", comment:"Yes"), style: UIAlertActionStyle.default, handler: {alerAction in
            
        }))
        
        alertaClose.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.default, handler: {alerAction in
            
        }))
        
        self.present(alertaClose, animated: true, completion: nil)*/
    }
    @IBAction func ShowOpenChat(_ sender: Any) {
        if myvariables.chatsOpen.count == 0{
            let alertaClose = UIAlertController (title: NSLocalizedString("No chats avaliable",comment:"Close the Application"), message: NSLocalizedString("There aren't any chat avaliable for you at this moment.", comment:"No hay usuarios conectados"), preferredStyle: UIAlertControllerStyle.alert)
            alertaClose.addAction(UIAlertAction(title: NSLocalizedString("Close", comment:"Cerrar"), style: UIAlertActionStyle.default, handler: {alerAction in

            }))
            self.present(alertaClose, animated: true, completion: nil)
        }else{
            let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            self.navigationController?.show(vc, sender: nil)
        }
       
    }
    
    @IBAction func FindSolRecibidas(_ sender: Any) {
        if self.solicitudesRecibidas.count == 0{
            let alertaClose = UIAlertController (title: NSLocalizedString("No Request",comment:"Close the Application"), message: NSLocalizedString("There aren't any request for you.", comment:"No hay usuarios conectados"), preferredStyle: UIAlertControllerStyle.alert)
            alertaClose.addAction(UIAlertAction(title: NSLocalizedString("Close", comment:"Cerrar"), style: UIAlertActionStyle.default, handler: {alerAction in
              
            }))
            self.present(alertaClose, animated: true, completion: nil)
        }else{
            let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "RequestViewController") as! RequestViewController
            vc.PendientRequest = self.solicitudesRecibidas
            self.navigationController?.show(vc, sender: nil)
        }
    }
    
    @IBAction func CerrarSesion(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().disconnect()
    }
    
    
    @IBAction func FindUserConnected(_ sender: Any) {
        
        if self.usuariosMostrar.count == 0{
            let alertaClose = UIAlertController (title: NSLocalizedString("No user connected",comment:"Close the Application"), message: NSLocalizedString("There aren't any user connected near you.", comment:"No hay usuarios conectados"), preferredStyle: UIAlertControllerStyle.alert)
            alertaClose.addAction(UIAlertAction(title: NSLocalizedString("Close", comment:"Cerrar"), style: UIAlertActionStyle.default, handler: {alerAction in
                self.UserPerfilView.isHidden = false
                self.UserConnectView.isHidden = true
                self.LoadingView.isHidden = true
            }))
            self.present(alertaClose, animated: true, completion: nil)
        }else{
            self.LoadingView.isHidden = true
            self.UserPerfilView.isHidden = true
            self.UserConnectView.isHidden = false
        }
        self.UserConnectedTable.reloadData()
        
    }
    @IBAction func CloseUserConnectedView(_ sender: Any) {
        self.UserPerfilView.isHidden = false
        self.UserConnectView.isHidden = true
        self.LoadingView.isHidden = true
    }
    @IBAction func AceptarSolicitud(_ sender: Any) {
        self.solicitudesRecibidas.first?.ActualizarEstado(newEstado: "A")
        
        var newChat = CChat(chatID: (self.solicitudesRecibidas.first?.EmailEmisor)! + "+" + (self.solicitudesRecibidas.first?.EmailDestino)!, emisorImagen: (self.solicitudesRecibidas.first?.FotoEmisor)!, destinoImagen: myvariables.userperfil.FotoPerfil)
        self.AgregarChat(newChat: newChat)
        let alertaOpcionesChat = UIAlertController (title: NSLocalizedString("Request Acepted",comment:"Request Acepted"), message: NSLocalizedString("You have acepted to meet this person. Now you can chat.", comment:"Mensaje de salir"), preferredStyle: UIAlertControllerStyle.alert)
        alertaOpcionesChat.addAction(UIAlertAction(title: NSLocalizedString("Acept", comment:"Text Message"), style: UIAlertActionStyle.default, handler: {alerAction in

            let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "MSGView") as! MSGViewController
            vc.destinoChat = "D"
            self.navigationController?.show(vc, sender: nil)
            
        }))

        alertaOpcionesChat.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment:"Cancel"), style: UIAlertActionStyle.default, handler: {alerAction in
            
        }))
        
        self.present(alertaOpcionesChat, animated: true, completion: nil)
        
        self.SolicitudView.isHidden = true
    }
    @IBAction func RechazarSolicitud(_ sender: Any) {
        self.solicitudesRecibidas.first?.ActualizarEstado(newEstado: "R")
        self.SolicitudView.isHidden = true
    }
    //CHAT BUTTONs
    @IBAction func CloseChat(_ sender: Any) {
 
    }
   
   /* @IBAction func SendMensage(_ sender: Any) {
        self.MensageText.resignFirstResponder()
        //if self.chatsOpen.first?.DestinoImagen.isEqual(<#T##object: Any?##Any?#>)
        if !(self.MensageText.text?.isEmpty)!{
           let newmensaje = CMensaje(chatId: (myvariables.chatsOpen.first?.ChatID)!, mensaje: self.MensageText.text!)
            newmensaje.EnviarMensaje()
            self.mensajesChat.append(newmensaje)
            self.ChatTable.reloadData()
            self.MensageText.text?.removeAll()
        }
    }*/

    
    //MARK: -TABLE DELEGATE METODOS
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.isEqual(UserConnectedTable){
            return usuariosMostrar.count
        }else{
            if tableView.isEqual(self.OpenChatTable){
                return myvariables.chatsOpen.count
            }else{
               return 0 //mensajesChat.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if tableView.isEqual(UserConnectedTable){
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            // Configure the cell...
            cell.imageView?.image = usuariosMostrar[indexPath.row].FotoPerfil
            cell.imageView?.layer.cornerRadius = (cell.imageView?.frame.width)! / 8
            cell.imageView?.clipsToBounds = true
            cell.textLabel?.text = "Clic to send friend´s request"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if tableView.isEqual(UserConnectedTable){
            var solicitud = CSolicitud(fotoEmisor: myvariables.userperfil.FotoPerfil, fotoDestino: (tableView.cellForRow(at: indexPath)?.imageView?.image)!, emailEmisor: myvariables.userperfil.Email, emailDestino: self.usuariosMostrar[indexPath.row].Email, estado: "S")
            solicitud.EnviarSolicitud()
            
            let alertaOpcionesChat = UIAlertController (title: NSLocalizedString("Request Sent",comment:"Request Acepted"), message: NSLocalizedString("You have acepted to meet this person. Now you can chat.", comment:"Mensaje de salir"), preferredStyle: UIAlertControllerStyle.alert)
            alertaOpcionesChat.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment:"Text Message"), style: UIAlertActionStyle.default, handler: {alerAction in
                
            }))
            
            self.present(alertaOpcionesChat, animated: true, completion: nil)
        }
        else{
            
        }
    }
    
    //MARK: -TEXFIELD DELEGATE
    /*func textViewDidEndEditing(_ textView: UITextView) {
        animateViewMoving(false, moveValue: 240)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        animateViewMoving(true, moveValue: 240)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.isEqual(self.MensageText){
            animateViewMoving(false, moveValue: 150,view: self.CreateMSGView)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.isEqual(self.MensageText){
            animateViewMoving(true, moveValue: 150,view: self.CreateMSGView)
        }
    }
    */
    /*func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
    }*/
    
    func animateViewMoving (_ up:Bool, moveValue :CGFloat, view: UIView){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
    /*func keyboardNotification(notification: NSNotification){
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
    }*/
}

