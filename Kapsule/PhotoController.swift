//
//  PhotoController.swift
//  Kapsule
//
//  Created by Done Santana on 3/11/18.
//  Copyright © 2018 Done Santana. All rights reserved.
//

import UIKit
import GGLSignIn
import GoogleSignIn
import CloudKit
import AssetsLibrary

class PhotoController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate {
    
    var camaraController: UIImagePickerController!
    
    @IBOutlet weak var kapsulePhotoView: UIImageView!
    @IBOutlet weak var DestinatarioTable: UITableView!
    @IBOutlet weak var asuntoText: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.DestinatarioTable.delegate = self
        self.asuntoText.delegate = self
        self.kapsulePhotoView.contentMode = .scaleAspectFill
        //self.kapsulePhotoView.layer.cornerRadius = self.kapsulePhotoView.frame.height
        self.kapsulePhotoView.clipsToBounds = true
        
        self.camaraController = UIImagePickerController()
        self.camaraController.delegate = self
        
        self.camaraController.sourceType = .camera
        self.camaraController.cameraCaptureMode = .photo
        self.present(self.camaraController, animated: true, completion: nil)
        
        // Do any additional setup after loading the view.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        if let type:AnyObject = mediaType {
            if type is String {
                    let stringType = type as! String
                    self.camaraController.dismiss(animated: true, completion: nil)
                    let newimage = info[UIImagePickerControllerOriginalImage] as? UIImage
                    myvariables.userperfil.GuardarFotoPerfil(newPhoto: newimage!)
                    self.kapsulePhotoView.image = newimage
            }
        }
        
    }
    
    //RENDER IMAGEN
    func saveImageToFile(_ image: UIImage) -> URL
    {
        let filemgr = FileManager.default
        
        let dirPaths = filemgr.urls(for: .documentDirectory,
                                    in: .userDomainMask)
        
        let fileURL = dirPaths[0].appendingPathComponent("currentImage.jpg")
        
        if let renderedJPEGData =
            UIImageJPEGRepresentation(image, 0.5) {
            try! renderedJPEGData.write(to: fileURL)
        }
    
        return fileURL
    }
    
    //FUNCIONES DE LOS BOTONES
    @IBAction func EnviarKapsule(_ sender: Any) {
        self.DestinatarioTable.isHidden = !self.DestinatarioTable.isHidden
        self.asuntoText.endEditing(true)
    }
    @IBAction func Cerrar(_ sender: Any) {
        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "InicioView") as! InicioController
        self.navigationController?.show(vc, sender: nil)
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
        
        let imagenURL = self.saveImageToFile(self.kapsulePhotoView.image!)
        let contenido = CKAsset(fileURL: imagenURL)
        var newKapsule = CKapsule(destinatarioEmail: myvariables.destinatariosMostrar[indexPath.row].email, destinatarioName: myvariables.destinatariosMostrar[indexPath.row].name, emisorEmail: myvariables.userperfil.email, emisorName: myvariables.userperfil.name, asunto: self.asuntoText.text!,geoposicion: myvariables.userperfil.location, direccion: myvariables.userAddress,tipoK: "K-Photo", urlContenido: contenido, vista: "NO", creada: "")
        newKapsule.sendKapsule()
        
        let alertaClose = UIAlertController (title: NSLocalizedString("Kapsule enviada",comment:"Close the Application"), message: NSLocalizedString("La Kapsule fue enviada a su destinatario.", comment:"No hay usuarios conectados"), preferredStyle: UIAlertControllerStyle.alert)
        alertaClose.addAction(UIAlertAction(title: NSLocalizedString("OK", comment:"Cerrar"), style: UIAlertActionStyle.default, handler: {alerAction in
            let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "InicioView") as! InicioController
            self.navigationController?.show(vc, sender: nil)
        }))
        self.present(alertaClose, animated: true, completion: nil)
    }
    
    //CONTROL DE TECLADO VIRTUAL
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateViewMoving(true, moveValue: 260, view: self.view)
    }
    func textFieldDidEndEditing(_ textfield: UITextField) {
        animateViewMoving(false, moveValue: 260, view: self.view)
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
