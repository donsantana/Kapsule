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
import CloudKit
import MapKit

class InicioController: UIViewController, CLLocationManagerDelegate, UITextViewDelegate, MKMapViewDelegate, UITextFieldDelegate{
    var coreLocationManager = CLLocationManager()
    var origen = MKPointAnnotation()
    var miposicion = MKPointAnnotation()
    var kapsulesAnotations = [MKPointAnnotation]()
    var kapsulesMostrar = [CKapsule]()
    var cloudContainer = CKContainer.default()
    
    @IBOutlet weak var mapaVista: MKMapView!
    @IBOutlet weak var ktextBtn: UIButton!
    @IBOutlet weak var kphotoBtn: UIButton!
    @IBOutlet weak var kvideoBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //LECTURA DEL FICHERO PARA AUTENTICACION
        
        self.mapaVista.delegate = self
        self.mapaVista.showsUserLocation = true
        coreLocationManager.delegate = self
    
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        coreLocationManager.startUpdatingLocation()  //Iniciar servicios de actualiación de localización del usuario
        
        if let tempLocation = self.coreLocationManager.location?.coordinate{
            self.miposicion.coordinate = (coreLocationManager.location?.coordinate)!
            self.miposicion.title = "origen"
        }else{
            coreLocationManager.requestWhenInUseAuthorization()
            self.miposicion.coordinate = (CLLocationCoordinate2D(latitude: -2.173714, longitude: -79.921601))
        }
        
        let span = MKCoordinateSpanMake(60.0,60.0)
        let region = MKCoordinateRegion(center: self.miposicion.coordinate, span: span)
        self.mapaVista.setRegion(region, animated: true)
        self.mapaVista.addAnnotation(miposicion)
        
        self.BuscarKapusulesRecibidos()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var anotationView = mapaVista.dequeueReusableAnnotationView(withIdentifier: "annotationView")
        anotationView = MKAnnotationView(annotation: self.origen, reuseIdentifier: "annotationView")
        switch annotation.title! as! String {
        case "in":
            anotationView?.image = UIImage(named: "kapsuleIn")
            break
        case "read":
            anotationView?.image = UIImage(named: "kapsuleRead")
            break
        case "out":
            anotationView?.image = UIImage(named: "kapsuleOut")
            break
        default:
            anotationView?.image = UIImage(named: "origen")
        }
        
        return anotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if view.annotation?.title! == "out"{
            
        }
        print("YEAHHH")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.miposicion.coordinate = (locations.last?.coordinate)!
    }
    
    func mapView(_ mapView: MKMapView, rendererFor
        overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.green
        renderer.lineWidth = 4.0
        return renderer
    }
    
    func BuscarKapusulesRecibidos(){
        
        let predicateKapsule = NSPredicate(format: "destinatarioEmail == %@ and vista == %@","donelkyss@gmail.com","NO")
        let queryKapsuleIn = CKQuery(recordType: "Kapsule",predicate: predicateKapsule)
        self.cloudContainer.publicCloudDatabase.perform(queryKapsuleIn, inZoneWith: nil, completionHandler: ({results, error in
            if (error == nil) {
                if (results?.count)! > 0{
                    self.kapsulesMostrar.removeAll()
                    print(results?.count)
                    var i = 0
                    while i < (results?.count)!{
                        //destinatarioEmail:String,destinatarioName:String,emisorEmail:String,emisorName:String,asunto:String,direccion:String,geoposicion:String,tipoK:String, urlContenido:String, estado:String
                        var geotemp = results?[i].value(forKey: "geoposicion") as! String
                        var geoposicion = String(describing: geotemp).components(separatedBy: ",")
                    
                        let Kcoordinate = CLLocationCoordinate2D(latitude: Double(geoposicion[0])!, longitude: Double(geoposicion[1])!)
                        
                        let kapsuleTemp = CKapsule(destinatarioEmail: results?[i].value(forKey: "destinatarioEmail") as! String, destinatarioName: results?[i].value(forKey: "destinatarioName") as! String,emisorEmail:results?[i].value(forKey: "emisorEmail") as! String,emisorName:results?[i].value(forKey: "emisorName") as! String,asunto:results?[i].value(forKey: "asunto") as! String,direccion:results?[i].value(forKey: "direccion") as! String,geoposicion: Kcoordinate, tipoK: results?[i].value(forKey: "tipoK") as! String, urlContenido:results?[i].value(forKey: "contenido") as! CKAsset, vista: results?[i].value(forKey: "vista") as! String)
                    
                        let klocation = CLLocation(latitude: Kcoordinate.latitude, longitude: Kcoordinate.longitude)
                        
                        if CLLocation(latitude: self.miposicion.coordinate.latitude, longitude: self.miposicion.coordinate.longitude).distance(from:klocation) > 200 {
                            kapsuleTemp.actulizarEstado(estado: "out")
                        }else{
                            kapsuleTemp.actulizarEstado(estado: "in")
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
    
    func dibujarK(){
        for kapsule in myvariables.kapsulesMostrar {
            let annotation = MKPointAnnotation()
            annotation.title = kapsule.estado
            annotation.coordinate = kapsule.geoposicion
            self.kapsulesAnotations.append(annotation)
        }
        self.mapaVista.addAnnotations(self.kapsulesAnotations)
        self.mapaVista.fitAll(in: self.mapaVista.annotations, andShow: true)
    }
    
    //BUTTONS ACTIONS
    @IBAction func CrearKapsule(_ sender: Any) {
        self.ktextBtn.isHidden = !self.ktextBtn.isHidden
        self.kphotoBtn.isHidden = !self.kphotoBtn.isHidden
        self.kvideoBtn.isHidden = !self.kvideoBtn.isHidden
    }
    
}

extension MKMapView {
    /// when we call this function, we have already added the annotations to the map, and just want all of them to be displayed.
    func fitAll() {
        var zoomRect            = MKMapRectNull;
        for annotation in annotations {
            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
            let pointRect       = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.01, 0.01)
            zoomRect            = MKMapRectUnion(zoomRect, pointRect);
        }
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsetsMake(100, 100, 100, 100), animated: true)
    }
    
    /// we call this function and give it the annotations we want added to the map. we display the annotations if necessary
    func fitAll(in annotations: [MKAnnotation], andShow show: Bool) {
        
        var zoomRect:MKMapRect  = MKMapRectNull
        
        for annotation in annotations {
            let aPoint          = MKMapPointForCoordinate(annotation.coordinate)
            let rect            = MKMapRectMake(aPoint.x, aPoint.y, 0.071, 0.071)
            
            if MKMapRectIsNull(zoomRect) {
                zoomRect = rect
            } else {
                zoomRect = MKMapRectUnion(zoomRect, rect)
            }
        }
        if(show) {
            addAnnotations(annotations)
        }
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
    }
}
