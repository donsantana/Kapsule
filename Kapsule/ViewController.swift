//
//  ViewController.swift
//  NoIce
//
//  Created by Done Santana on 13/1/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import UIKit
import GoogleSignIn
import CloudKit
import MapKit



class ViewController: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITextFieldDelegate{
    //MARK: - PROPIEDADES DE LA CLASE
    var locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    var camaraPerfilController: UIImagePickerController!
    var userTimer : Timer!
    var userperfil: MKAnnotation
    
    
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
        
        self.navigationItem.setHidesBackButton(true, animated:true)
        

        // Do any additional setup after loading the view, typically from a nib.
        
       //PARA MOSTRAR Y OCULTAR EL TECLADO
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    //MARK: - ACTUALIZACION DE GEOLOCALIZACION
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       
                self.userperfil = MKAnnotation(locations.last!)
        
        }
   
    //MARK: - BUSCAR USUARIOS CONECTADOS
    //MEJORAR ESTA FUNCION CAMBIAR EL CICLO FOR:
    func BuscarKapusulesRecibidos(){
        
            let predicateUsuarioIn = NSPredicate(format: "destinararioEmail != %@", self.userperfil.Posicion,self.userperfil.Email)
            self.TimerStart(estado: 0)
            //let predicateUsuarioIn = NSPredicate(format: "conectado == %@ and email != %@", "1", self.userperfil.Email)
            let queryKapsuleIn = CKQuery(recordType: "Kapsule",predicate: predicateUsuarioIn)
            self.cloudContainer.publicCloudDatabase.perform(queryKapsuleIn, inZoneWith: nil, completionHandler: ({results, error in
                if (error == nil) {
                        var bloqueados = [String]()
                    myvariables.kapsulesMostrar.removeAll()
                    if (results?.count)! > 0{
                        var i = 0
                        while i < (results?.count)!{
                            let usuarioTemp = CUser(nombreapellidos: results?[i].value(forKey: "nombreApellidos") as! String, email: results?[i].value(forKey: "email") as! String)
                            usuarioTemp.BuscarNuevosMSG(EmailDestino: self.userperfil.Email)
                            bloqueados = results?[i].value(forKey: "bloqueados") as! [String]
                            if  !bloqueados.contains(self.userperfil.Email) && !self.userperfil.bloqueados.contains(usuarioTemp.Email){
                                let photo = results?[i].value(forKey: "foto") as! CKAsset
                                let photoPerfil = NSData(contentsOf: photo.fileURL as URL)
                                let imagenEmisor = UIImage(data: photoPerfil! as Data)!
                                usuarioTemp.GuardarFotoPerfil(photo: imagenEmisor)
                                myvariables.usuariosMostrar.append(usuarioTemp)
                            }
                            i += 1
                        }
                    }else{
                        self.locationManager.stopUpdatingLocation()
                        let alertaClose = UIAlertController (title: NSLocalizedString("No user connected",comment:"Close the Application"), message: NSLocalizedString("There aren't any user connected near you.", comment:"No hay usuarios conectados"), preferredStyle: UIAlertControllerStyle.alert)
                        alertaClose.addAction(UIAlertAction(title: NSLocalizedString("Close", comment:"Cerrar"), style: UIAlertActionStyle.default, handler: {alerAction in
                                let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "ProfileView") as! ProfileController
                                self.navigationController?.show(vc, sender: nil)
                        }))
                        self.present(alertaClose, animated: true, completion: nil)
                    }
                }else{
                    print("ERROR DE CONSULTA " + error.debugDescription)
                }
            }))
    }
    //MARK: - ACTION BOTONES GRAFICOS
    @IBAction func ShowMenuBtn(_ sender: Any) {
        self.userperfil.ActualizarConectado(estado: "0")
        sleep(3)
        exit(0)
    }

}


