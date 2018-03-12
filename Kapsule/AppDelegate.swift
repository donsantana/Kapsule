//
//  AppDelegate.swift
//  NoIce
//
//  Created by Done Santana on 13/1/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import UIKit
import CoreData
import GGLSignIn
import GoogleSignIn
import GoogleMaps
import CloudKit


struct myvariables {
    static var kapsulesMostrar = [CKapsule]()
    static var kapsulesRecibidos = [CKapsule]()
    static var kapsulesEnviados = [CKapsule]()
    static var destinatariosMostrar = [CUser]()
    static var userAddress = String()
    static var userperfil = CUser(name: "", email: "")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
    var Appcontainer = CKContainer.default()
    
    var backgrounTaskIdentifier: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var myTimer: Timer?
    var BackgroundSeconds = 0

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey("AIzaSyDR3t4MqcsJfG9CZTjX4BQNiXq09VaXnFc")
        // Override point for customization after application launch.
        GIDSignIn.sharedInstance().delegate = self
        return true
    }
    
    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        
        return GIDSignIn.sharedInstance().handle(url as URL!,sourceApplication: sourceApplication,annotation: annotation)
    }
    
    private func application(app: UIApplication, openURL url: URL, options: [String : AnyObject]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url as URL!,
                                                 sourceApplication: options.index(forKey: "UIApplicationOpenURLOptionsSourceApplicationKey") as! String?,
                                                 annotation: options.index(forKey: "UIApplicationOpenURLOptionsAnnotationKey"))
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
       // FBSDKAppEvents.activateApp()

        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {


    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        //myvariables.socketConexion.connect()
        /*if myvariables.userperfil != nil{
            myvariables.userperfil.ActualizarConectado(estado: "1")
            sleep(2)
        }*/
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        //myvariables.socketConexion.disconnect()
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //self.saveContext()
        /*if myvariables.userperfil != nil{
            myvariables.userperfil.ActualizarConectado(estado: "0")
            sleep(2)
        }*/
    }
    
    // Finished disconnecting |user| from the app successfully if |error| is |nil|.
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!){
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }

}



