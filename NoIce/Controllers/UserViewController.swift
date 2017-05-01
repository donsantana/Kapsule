//
//  UserViewController.swift
//  NoIce
//
//  Created by Done Santana on 24/2/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import UIKit
import CloudKit

class UserViewController: UITableViewController  {

    var userContainer = CKContainer.default()
    var connectedTimer: Timer!
    @IBOutlet weak var UserConnectedTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectedTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(BuscarUsuariosConectados), userInfo: nil, repeats: true)

    }
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
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
        //cell.textLabel?.text = "Clic to send friend´s request"*/
        print("Resultado: \(myvariables.usuariosMostrar[indexPath.row].NewMsg)")
        if myvariables.usuariosMostrar[indexPath.row].NewMsg == true {
            print("mostrar nuevo mensaje")
                cell.NewMsg.isHidden = false
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "MSGView") as! MSGViewController
        vc.chatOpenPos = indexPath.row
        self.navigationController?.show(vc, sender: nil)
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
            myvariables.usuariosMostrar.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
            tableView.reloadData()
        }
    
    }
    
    func BuscarUsuariosConectados(){        
        let predicateUsuarioIn = NSPredicate(format: "distanceToLocation:fromLocation:(posicion, %@) < 40 and conectado == %@ and email != %@", myvariables.userperfil.Posicion, "1", myvariables.userperfil.Email)
        
        //let predicateUsuarioIn = NSPredicate(format: "conectado == %@ and email != %@", "1", myvariables.userperfil.Email)
        let queryUsuarioIn = CKQuery(recordType: "CUsuarios",predicate: predicateUsuarioIn)
        self.userContainer.publicCloudDatabase.perform(queryUsuarioIn, inZoneWith: nil, completionHandler: ({results, error in
            if (error == nil) {
                if (results?.count)! != myvariables.usuariosMostrar.count{
                //if (results?.count)! > 0{
                    myvariables.usuariosMostrar.removeAll()
                    var i = 0
                    while i < (results?.count)!{
                        let usuarioTemp = CUser(nombreapellidos: results?[i].value(forKey: "nombreApellidos") as! String, email: results?[i].value(forKey: "email") as! String)
                        usuarioTemp.BuscarNuevosMSG(EmailDestino: myvariables.userperfil.Email)
                        let imagenEmisor: UIImage!
                        do{
                            let photo = results?[i].value(forKey: "foto") as! CKAsset
                            let photoPerfil = try Data(contentsOf: photo.fileURL as URL)
                            imagenEmisor = UIImage(data: photoPerfil)!
                        }catch{
                            imagenEmisor = UIImage(named: "user")
                        }
                        usuarioTemp.BuscarNuevosMSG(EmailDestino: myvariables.userperfil.Email)
                        usuarioTemp.GuardarFotoPerfil(photo: imagenEmisor!)
                        myvariables.usuariosMostrar.append(usuarioTemp)
                        i += 1
                    }

            }else{
                var i = 0
                while i < (results?.count)!{
                    myvariables.usuariosMostrar[i].BuscarNuevosMSG(EmailDestino: myvariables.userperfil.Email)
                    i += 1
                }
                    
            }
            }else{
                print("ERROR DE CONSULTA " + error.debugDescription)
            }
            DispatchQueue.main.async {
                print("Actualizando tabla")
                self.tableView.reloadData()
            }
        }))
    }
    
    func BuscarNewMsg() {
        print("Buscando MSG")
       self.tableView.reloadData()
    }


}
