//
//  InicioController.swift
//  Kapsule
//
//  Created by Done Santana on 3/3/18.
//  Copyright © 2018 Done Santana. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn
import GoogleMaps
import CloudKit
import MapKit

class InicioController: UIViewController, CLLocationManagerDelegate, UITextViewDelegate, GMSMapViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource{
    var coreLocationManager = CLLocationManager()
    var origen = GMSMarker()
    var miposicion = GMSMarker()
    var kapsulesAnotations = [GMSMarker]()
    var kapsulesMostrar = [CKapsule]()
    var cloudContainer = CKContainer.default()
    
    @IBOutlet weak var mapaVista: GMSMapView!
    @IBOutlet weak var ktextBtn: UIButton!
    @IBOutlet weak var kphotoBtn: UIButton!
    @IBOutlet weak var kvideoBtn: UIButton!
    @IBOutlet weak var TransparenciaView: UIVisualEffectView!
    @IBOutlet weak var newKtextView: UIView!
    @IBOutlet weak var ktextMensaje: UITextView!
    @IBOutlet weak var DestinatarioTable: UITableView!
    
    @IBOutlet weak var ktextShow: UITextView!
    @IBOutlet weak var kphotoShow: UIImageView!
    @IBOutlet weak var asuntoText: UILabel!
    @IBOutlet weak var kShows: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //LECTURA DEL FICHERO PARA AUTENTICACION
        
        self.mapaVista.delegate = self
        coreLocationManager.delegate = self
        self.ktextMensaje.delegate = self
        self.DestinatarioTable.delegate = self
        
        self.mapaVista.isMyLocationEnabled = true
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        coreLocationManager.startUpdatingLocation()  //Iniciar servicios de actualiación de localización del usuario
        
        if let tempLocation = self.coreLocationManager.location?.coordinate{
            self.miposicion.position = (coreLocationManager.location?.coordinate)!
        }else{
            coreLocationManager.requestWhenInUseAuthorization()
            self.miposicion.position = (CLLocationCoordinate2D(latitude: -2.173714, longitude: -79.921601))
        }
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
            "           \"color\": \"9aadb6\"" +
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
            "           \"color\": \"#9aadb6\"" +
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
        
        
        do{
            self.mapaVista.mapStyle = try GMSMapStyle(jsonString: JSONStyle)
        }catch{
            print("NO PUEDEEEEEEEEEEEEEEEEEEEEEE")
        }
        
        mapaVista.isMyLocationEnabled = false
        if let tempLocation = self.coreLocationManager.location?.coordinate{
            self.miposicion.position = tempLocation
            self.mapaVista.camera = GMSCameraPosition.camera(withLatitude: (tempLocation.latitude), longitude: (tempLocation.longitude), zoom: 3.0)
        }else{
            coreLocationManager.requestAlwaysAuthorization()
            self.mapaVista.camera = GMSCameraPosition.camera(withLatitude: -2.173714, longitude: -79.921601, zoom: 1.0)
        }
        self.BuscarKapusulesRecibidos()
        self.BuscarDestinatarios()
    }

    //ACTUALICI'ON DE LA LOCALIZACI'ON
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.miposicion.position = (locations.last?.coordinate)!
    }
    
    func setuplocationMarker(_ coordinate: CLLocationCoordinate2D) {
        self.miposicion.position = coordinate
        miposicion.snippet = "Cliente"
        miposicion.icon = UIImage(named: "origen")
        mapaVista.camera = GMSCameraPosition.camera(withLatitude: miposicion.position.latitude,longitude:miposicion.position.longitude,zoom: 3.0)
    }

    //FUNCIN DETECCION DE TAP SOBRE KAPSULE
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if marker.title == "kapsuleOut"{
            let distanciaKm = CLLocation(latitude: marker.position.latitude, longitude: marker.position.longitude).distance(from: CLLocation(latitude: self.miposicion.position.latitude, longitude: self.miposicion.position.longitude))/1000
            let distancia = String(format:"%.2f",distanciaKm)
            let alertaDos = UIAlertController (title: "Ir a Kapsule", message: "Esta Kapsule se encuentra a una distancia de: \(distancia)km. Desea ir?", preferredStyle: UIAlertControllerStyle.alert)
            alertaDos.addAction(UIAlertAction(title: "Ir", style: .default, handler: {alerAction in
            
            }))
            
            self.present(alertaDos, animated: true, completion: nil)
        }else{
            var kapsuleShow = CKapsule()
            for kapsule in myvariables.kapsulesMostrar{
                if kapsule.recordName == marker.snippet{
                    kapsuleShow = kapsule
                }
            }
            self.TransparenciaView.isHidden = false
            self.showKapsules(kapsule: kapsuleShow)
        }
        
        return true
    }
    
    func dibujarK(){
        for kapsule in myvariables.kapsulesMostrar {
            let annotation = GMSMarker()
            annotation.title = kapsule.estado
            annotation.snippet = kapsule.recordName
            annotation.position = kapsule.geoposicion
            annotation.icon = UIImage(named: kapsule.estado)
            self.kapsulesAnotations.append(annotation)
            annotation.map = self.mapaVista
        }
        self.kapsulesAnotations.append(self.miposicion)
        self.fitAllMarkers(self.kapsulesAnotations)
    }
    
    //MOSTRAR TODOS LOS MARCADORES EN PANTALLA
    func fitAllMarkers(_ markers: [GMSMarker]) {
        var bounds = GMSCoordinateBounds()
        for marcador in markers{
            bounds = bounds.includingCoordinate(marcador.position)
        }
        mapaVista.animate(with: GMSCameraUpdate.fit(bounds))
    }
    
    //FUNCION DETERMINAR DIRECCIÓN A PARTIR DE COORDENADAS
    func DireccionDeCoordenada(){
        var address = ""
        let temporaLocation = CLLocation(latitude: self.miposicion.position.latitude, longitude: self.miposicion.position.longitude)
        CLGeocoder().reverseGeocodeLocation(temporaLocation, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
            }
            if (placemarks?.count)! > 0 {
                let placemark = (placemarks?[0])! as CLPlacemark
                if let name = placemark.addressDictionary?["Name"] as? String {
                    address += name
                }
                
                if let city = placemark.addressDictionary?["City"] as? String {
                    address += " \(city)"
                }
                
                if let state = placemark.addressDictionary?["State"] as? String {
                    address += " \(state)"
                }
                
                if let country = placemark.country{
                    address += " \(country)"
                }
            }else {
                address = "No disponible"
            }
            myvariables.userAddress = address
        })
    }
    
    func BuscarKapusulesRecibidos(){
        let predicateKapsule = NSPredicate(format: "destinatarioEmail == %@ and vista == %@",myvariables.userperfil.email,"NO")
        let queryKapsuleIn = CKQuery(recordType: "Kapsule",predicate: predicateKapsule)
        self.cloudContainer.publicCloudDatabase.perform(queryKapsuleIn, inZoneWith: nil, completionHandler: ({results, error in
            if (error == nil) {
                if (results?.count)! > 0{
                    self.kapsulesMostrar.removeAll()
                    var i = 0
                    while i < (results?.count)!{
                        //destinatarioEmail:String,destinatarioName:String,emisorEmail:String,emisorName:String,asunto:String,direccion:String,geoposicion:String,tipoK:String, urlContenido:String, estado:String
                        var geotemp = results?[i].value(forKey: "geoposicion") as! String
                        var geoposicion = String(describing: geotemp).components(separatedBy: ",")
                    
                        let kapsulePosition = CLLocationCoordinate2D(latitude: Double(geoposicion[0])!, longitude: Double(geoposicion[1])!)
                        
                        let kapsuleTemp = CKapsule(destinatarioEmail: results?[i].value(forKey: "destinatarioEmail") as! String, destinatarioName: results?[i].value(forKey: "destinatarioName") as! String,emisorEmail:results?[i].value(forKey: "emisorEmail") as! String,emisorName:results?[i].value(forKey: "emisorName") as! String,asunto:results?[i].value(forKey: "asunto") as! String, geoposicion: kapsulePosition, direccion: results?[i].value(forKey: "direccion") as! String, tipoK: results?[i].value(forKey: "tipoK") as! String, urlContenido:results?[i].value(forKey: "contenido") as! CKAsset, vista: results?[i].value(forKey: "vista") as! String)
                        
                        kapsuleTemp.setRecordName(recordName: (results?[i].recordID.recordName)!)
                    
                        let klocation = CLLocation(latitude: kapsulePosition.latitude, longitude: kapsulePosition.longitude)
                        
                        if CLLocation(latitude: self.miposicion.position.latitude, longitude: self.miposicion.position.longitude).distance(from:klocation) > 200 {
                            kapsuleTemp.actulizarEstado(estado: "kapsuleOut")
                        }else{
                            kapsuleTemp.actulizarEstado(estado: "kapsuleIn")
                        }
                        i += 1
                        
                        myvariables.kapsulesMostrar.append(kapsuleTemp)
                    }
                    self.dibujarK()
                }else{
                    self.coreLocationManager.stopUpdatingLocation()
                    let alertaClose = UIAlertController (title: NSLocalizedString("No kapsule found",comment:"Close the Application"), message: NSLocalizedString("There aren't any new kapsule for you.", comment:"No hay usuarios conectados"), preferredStyle: UIAlertControllerStyle.alert)
                    alertaClose.addAction(UIAlertAction(title: NSLocalizedString("Close", comment:"Cerrar"), style: UIAlertActionStyle.default, handler: {alerAction in
                    
                    }))
                    self.present(alertaClose, animated: true, completion: nil)
                }
            }else{
                print("ERROR DE CONSULTA " + error.debugDescription)
            }
        }))
    }
    
    func BuscarDestinatarios(){
        let predicateKapsule = NSPredicate(format: "email != %@","eldony09@gmail.com")
        let queryKapsuleIn = CKQuery(recordType: "kUsers",predicate: predicateKapsule)
        self.cloudContainer.publicCloudDatabase.perform(queryKapsuleIn, inZoneWith: nil, completionHandler: ({results, error in
            if (error == nil) {
                if (results?.count)! > 0{
                    myvariables.destinatariosMostrar.removeAll()
                    var i = 0
                    while i < (results?.count)!{
                        let newDestinatario = CUser(name: results![i].value(forKey: "name") as! String, email: results![i].value(forKey: "email") as! String)
                        myvariables.destinatariosMostrar.append(newDestinatario)
                        i += 1
                    }
                   
                    self.DestinatarioTable.reloadData()
                }
            }
        }))
    }
    
    func showKapsules(kapsule: CKapsule) {
        if kapsule.tipoK == "K-Text"{
            self.ktextShow.text = kapsule.asunto
            self.asuntoText.isHidden = true
            self.kphotoShow.isHidden = true
            self.ktextShow.isHidden = false
        }else{
            do{
                let kphoto = try Data(contentsOf: kapsule.contenido.fileURL as URL)
                self.asuntoText.text = kapsule.asunto
                self.kphotoShow.image = UIImage(data: kphoto)
            }catch{
                
            }
           
        }
        self.kShows.isHidden = false
    }
    
    //BUTTONS ACTIONS
    @IBAction func CrearKapsule(_ sender: Any) {
        self.ktextBtn.isHidden = !self.ktextBtn.isHidden
        self.kphotoBtn.isHidden = !self.kphotoBtn.isHidden
        self.kvideoBtn.isHidden = !self.kvideoBtn.isHidden
        myvariables.userperfil.location = self.miposicion.position
        self.DireccionDeCoordenada()
    }
    @IBAction func CrearKtext(_ sender: Any) {
        self.TransparenciaView.isHidden = false
        self.newKtextView.isHidden = false
    }
    @IBAction func CerrarKText(_ sender: Any) {
        self.TransparenciaView.isHidden = true
        self.newKtextView.isHidden = true
        self.ktextMensaje.endEditing(true)
    }
    @IBAction func EnviarKapsule(_ sender: Any) {
        self.DestinatarioTable.reloadData()
        self.DestinatarioTable.isHidden = !self.DestinatarioTable.isHidden
        self.ktextMensaje.endEditing(true)
    }

    @IBAction func CerrarKShows(_ sender: Any) {
        self.kShows.isHidden = true
        self.TransparenciaView.isHidden = true
    }
    
    
    //MARK:- FUNCIONES DE LAS TABLAS
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
       
        return myvariables.destinatariosMostrar.count
    }
    
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "Destinatarios", for: indexPath)
        
        cell.textLabel?.text = myvariables.destinatariosMostrar[indexPath.row].email
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.DestinatarioTable.isHidden = true
        self.TransparenciaView.isHidden = true
        self.newKtextView.isHidden = true
        self.ktextMensaje.endEditing(true)
        
        let contenido = CKAsset(fileURL: CFile().createFile(fileContent: self.ktextMensaje.text))
        var newKapsule = CKapsule(destinatarioEmail: myvariables.destinatariosMostrar[indexPath.row].email, destinatarioName: myvariables.destinatariosMostrar[indexPath.row].name, emisorEmail: myvariables.userperfil.email, emisorName: myvariables.userperfil.name, asunto: self.ktextMensaje.text,geoposicion: myvariables.userperfil.location, direccion: myvariables.userAddress, tipoK: "K-Text", urlContenido: contenido, vista: "NO")
        newKapsule.sendKapsule()
        
        let alertaClose = UIAlertController (title: NSLocalizedString("Kapsule enviada",comment:"Close the Application"), message: NSLocalizedString("La Kapsule fue enviada a su destinatario.", comment:"No hay usuarios conectados"), preferredStyle: UIAlertControllerStyle.alert)
        alertaClose.addAction(UIAlertAction(title: NSLocalizedString("OK", comment:"Cerrar"), style: UIAlertActionStyle.default, handler: {alerAction in
            
        }))
        self.present(alertaClose, animated: true, completion: nil)
    }

    
    //MARK:- CONTROL DE TECLADO VIRTUAL
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text.removeAll()
        animateViewMoving(true, moveValue: 240, view: self.view)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        animateViewMoving(false, moveValue: 240, view: self.view)
    }
    
    func textViewDidChange(_ textView: UITextView) {
       
    }
    
    func animateViewMoving (_ up:Bool, moveValue :CGFloat, view : UIView){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        view.frame = view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
}

