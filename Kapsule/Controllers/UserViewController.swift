//
//  UserViewController.swift
//  NoIce
//
//  Created by Done Santana on 24/2/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import UIKit
import CloudKit

class UserViewController: UITableViewController {

    var userContainer = CKContainer.default()
    var connectedTimer: Timer!
    @IBOutlet weak var UserConnectedTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //connectedTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(BuscarUsuariosConectados), userInfo: nil, repeats: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        //self.BuscarUsuariosConectados()

        if myvariables.usuariosMostrar.count == 0{
            let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "InicioView") as! ViewController
            self.navigationController?.show(vc, sender: nil)
        }else{
            connectedTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(BuscarUsuariosConectados), userInfo: nil, repeats: true)
            self.tableView.reloadData()
        }

        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        connectedTimer.invalidate()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return myvariables.usuariosMostrar.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("UserTableViewCell", owner: self, options: nil)?.first as! UserTableViewCell
        // Configure the cell...
        cell.UserConectedImage.image = myvariables.usuariosMostrar[indexPath.row].FotoPerfil
        cell.UserConectedImage.layer.cornerRadius = (cell.UserConectedImage.frame.width) / 4
        cell.UserConectedImage.contentMode = .scaleAspectFill
        cell.UserConectedImage.clipsToBounds = true
        if myvariables.usuariosMostrar[indexPath.row].NewMsg == true {
            print("hereeee")
                cell.NewMsg.isHidden = false
        }else{
                cell.NewMsg.isHidden = true
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        /*let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "Chat") as! ChatViewController
        vc.chatOpenPos = indexPath.row
        self.navigationController?.show(vc, sender: nil)*/
    }
    
    //FUNCIONES Y EVENTOS PARA ELIMIMAR CELLS, SE NECESITA AGREGAR UITABLEVIEWDATASOURCE
   override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Hide"
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            myvariables.userperfil.ActualizarBloqueo(emailBloqueado: myvariables.usuariosMostrar[indexPath.row].Email, completionHandler: {results in
                myvariables.usuariosMostrar.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
                tableView.reloadData()
            })

        }
    }
    
    func BuscarUsuariosConectados(){
        
        let predicateUsuarioIn = NSPredicate(format: "distanceToLocation:fromLocation:(posicion, %@) < 300 and conectado == %@ and email != %@", myvariables.userperfil.Posicion, "1", myvariables.userperfil.Email)
        
        let queryUsuarioIn = CKQuery(recordType: "CUsuarios",predicate: predicateUsuarioIn)
        self.userContainer.publicCloudDatabase.perform(queryUsuarioIn, inZoneWith: nil, completionHandler: ({results, error in
            if (error == nil) {
                myvariables.usuariosMostrar.removeAll()
                //if (results?.count)! != myvariables.usuariosMostrar.count{
                if (results?.count)! > 0{
                    var bloqueados = [String]()
                    var i = 0
                    while i < (results?.count)!{
                        let usuarioTemp = CUser(nombreapellidos: results?[i].value(forKey: "nombreApellidos") as! String, email: results?[i].value(forKey: "email") as! String)
                        usuarioTemp.BuscarNuevosMSG(EmailDestino: myvariables.userperfil.Email)
                        bloqueados = results?[i].value(forKey: "bloqueados") as! [String]
                        
                        if  !bloqueados.contains(myvariables.userperfil.Email) && !myvariables.userperfil.bloqueados.contains(usuarioTemp.Email){
                            let photo = results?[i].value(forKey: "foto") as! CKAsset
                            let photoPerfil = NSData(contentsOf: photo.fileURL as URL)
                            let imagenEmisor = UIImage(data: photoPerfil as! Data)!
                            
                            usuarioTemp.GuardarFotoPerfil(photo: imagenEmisor)
                            myvariables.usuariosMostrar.append(usuarioTemp)
                        }
                        i += 1
                    }
                }else{
                    self.connectedTimer.invalidate()
                    let alertaClose = UIAlertController (title: NSLocalizedString("No user connected",comment:"No user connected"), message: NSLocalizedString("There aren't any user connected near you.", comment:"No hay usuarios conectados"), preferredStyle: UIAlertControllerStyle.alert)
                    alertaClose.addAction(UIAlertAction(title: NSLocalizedString("Close", comment:"Cerrar"), style: UIAlertActionStyle.default, handler: {alerAction in
                            self.tableView.reloadData()
                            let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "ProfileView") as! ProfileController
                            self.navigationController?.show(vc, sender: nil)
                    }))
                    self.present(alertaClose, animated: true, completion: nil)
                }
            }else{
                print("ERROR DE CONSULTA " + error.debugDescription)
            }
        }))
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func BuscarNewMsg() {
       self.tableView.reloadData()
    }
}
