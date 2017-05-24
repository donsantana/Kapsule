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



class ViewController: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITextFieldDelegate{
    //MARK: - PROPIEDADES DE LA CLASE
    var locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    var camaraPerfilController: UIImagePickerController!
    var userTimer : Timer!
    
    
    //CLOUD VARIABLES
    var cloudContainer = CKContainer.default()
    var userContainer = CKContainer.default()
    var photoAsset: CKAsset!
    
    //Visual variables

    
    @IBOutlet weak var SearchingView: UIView!

    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        //MARK: -INICIALIZAR CAMARA
        self.camaraPerfilController = UIImagePickerController()
        self.camaraPerfilController.delegate = self
        
        //MARK: -INICIALIZAR GEOLOCALIZACION
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        
        myvariables.userperfil.ActualizarPosicion(posicionActual: self.locationManager.location!)

        //self.userTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(BuscarUsuariosConectados), userInfo: nil, repeats: true)

        // Do any additional setup after loading the view, typically from a nib.
        
       //PARA MOSTRAR Y OCULTAR EL TECLADO
        /*NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)*/
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.TimerStart(estado: 1)
    }
    
    //MARK: - ACTUALIZACION DE GEOLOCALIZACION
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if myvariables.userperfil != nil{
            if myvariables.userperfil.Posicion.distance(from: locations.last!) > 10{
                myvariables.userperfil.ActualizarPosicion(posicionActual: locations.last!)
            }
        }
    }
    
    //MARK: -FUNCIONES GOOGLE SIGN-IN DELEGATE
    
    // The sign-in flow has finished and was successful if |error| is |nil|.
   
   //FUNCTION TIMER
    func TimerStart(estado: Int){
        if estado == 1{
            self.userTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(BuscarUsuariosConectados), userInfo: nil, repeats: true)
            print("Activando Timer")
        }else{
            self.userTimer.invalidate()
        }
    }

   
    
    //MARK: - BUSCAR USUARIOS CONECTADOS
    //MEJORAR ESTA FUNCION CAMBIAR EL CICLO FOR:
    func BuscarUsuariosConectados(){
        
            let predicateUsuarioIn = NSPredicate(format: "distanceToLocation:fromLocation:(posicion, %@) < 40 and conectado == %@ and email != %@", myvariables.userperfil.Posicion, "1", myvariables.userperfil.Email)
            self.TimerStart(estado: 0)
            //let predicateUsuarioIn = NSPredicate(format: "conectado == %@ and email != %@", "1", myvariables.userperfil.Email)
            let queryUsuarioIn = CKQuery(recordType: "CUsuarios",predicate: predicateUsuarioIn)
            self.cloudContainer.publicCloudDatabase.perform(queryUsuarioIn, inZoneWith: nil, completionHandler: ({results, error in
                if (error == nil) {
                        var bloqueados = [String]()
                    if (results?.count)! != myvariables.usuariosMostrar.count{
                        myvariables.usuariosMostrar.removeAll()
                        var i = 0
                        while i < (results?.count)!{
                            
                            let usuarioTemp = CUser(nombreapellidos: results?[i].value(forKey: "nombreApellidos") as! String, email: results?[i].value(forKey: "email") as! String)
                            usuarioTemp.BuscarNuevosMSG(EmailDestino: myvariables.userperfil.Email)
                            bloqueados = results?[i].value(forKey: "bloqueados") as! [String]
                             print("aqui estoys")
                            if  !bloqueados.contains(myvariables.userperfil.Email) && !myvariables.userperfil.bloqueados.contains(usuarioTemp.Email){
                                let photo = results?[i].value(forKey: "foto") as! CKAsset
                                let photoPerfil = NSData(contentsOf: photo.fileURL as URL)
                                let imagenEmisor = UIImage(data: photoPerfil! as Data)!
                            
                                usuarioTemp.GuardarFotoPerfil(photo: imagenEmisor)
                                myvariables.usuariosMostrar.append(usuarioTemp)
                            }
                            i += 1
                        }
                    }else{
                        var i = 0
                        while i < myvariables.usuariosMostrar.count{
                            myvariables.usuariosMostrar[i].BuscarNuevosMSG(EmailDestino: myvariables.userperfil.Email)
                            i += 1
                        }
                    }
                }else{
                    print("ERROR DE CONSULTA " + error.debugDescription)
                }
                if myvariables.usuariosMostrar.count == 0{
                    self.locationManager.stopUpdatingLocation()
                    let alertaClose = UIAlertController (title: NSLocalizedString("No user connected",comment:"Close the Application"), message: NSLocalizedString("There aren't any user connected near you.", comment:"No hay usuarios conectados"), preferredStyle: UIAlertControllerStyle.alert)
                    alertaClose.addAction(UIAlertAction(title: NSLocalizedString("Close", comment:"Cerrar"), style: UIAlertActionStyle.default, handler: {alerAction in
                        DispatchQueue.main.async {
                            let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "ProfileView") as! ProfileController
                            self.navigationController?.show(vc, sender: nil)
                        }
                    }))
                    self.present(alertaClose, animated: true, completion: nil)
                }else{
                    DispatchQueue.main.async {
                        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "UserConnected") as! UserViewController
                        self.navigationController?.show(vc, sender: nil)
                    }
                }
            }))

        
    }
    //MARK: - ACTION BOTONES GRAFICOS
    @IBAction func ShowMenuBtn(_ sender: Any) {
        myvariables.userperfil.ActualizarDesconectado()
        sleep(3)
        exit(0)
    }

}

