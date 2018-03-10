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
import CloudKit
import FBSDKLoginKit
import FBSDKCoreKit


struct myvariables {
    static var kapsulesMostrar = [CKapsule]()
    static var kapsulesRecibidos = [CKapsule]()
    static var kapsulesEnviados = [CKapsule]()
    static var userperfil = CUser(name: "", email: "")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var Appcontainer = CKContainer.default()
    
    var backgrounTaskIdentifier: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var myTimer: Timer?
    var BackgroundSeconds = 0

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //GMSServices.provideAPIKey("AIzaSyBnKURUhbBUr74PbpPgtPA1driuRaTShGo")
        // Override point for customization after application launch.
        //GIDSignIn.sharedInstance().delegate = self
        
        //FBSDKApplicationDelegate.sharedInstance().application( application, didFinishLaunchingWithOptions: launchOptions)
        //GIDSignIn.sharedInstance().clientID = "319723960699-96388hc84tnoohlatvb8r7rhm2806br1.apps.googleusercontent.com"
        //GIDSignIn.sharedInstance().signInSilently()
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        //return true
    }
    
    @objc func TimerMethod(sender: Timer){
        /*let backgroundTimeRemaining = UIApplication.shared.backgroundTimeRemaining
        if backgroundTimeRemaining == Double.greatestFiniteMagnitude{
            print("Background Time Remaining = Undetermined")
        }else{
            if BackgroundSeconds <= 1200{
                BackgroundSeconds += 1
            }else{
                if myvariables.userperfil != nil{
                    myvariables.userperfil.ActualizarConectado(estado: "0")
                    sleep(2)
                    exit(0)
                }
            }
        }*/
    }
    
    func endBackgroundTask(){
        if let timer = self.myTimer{
            timer.invalidate()
            self.myTimer = nil
            UIApplication.shared.endBackgroundTask(self.backgrounTaskIdentifier)
            self.backgrounTaskIdentifier = UIBackgroundTaskInvalid
        }
    }
    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        
        //let googleLogin = GIDSignIn.sharedInstance().handle(url as URL!,sourceApplication: sourceApplication,annotation: annotation)
        let faceLogin = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        
        //return googleLogin || faceLogin
        return faceLogin
        
        //return true
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
        myTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self,selector: #selector(TimerMethod), userInfo: nil, repeats: true)
        backgrounTaskIdentifier = application.beginBackgroundTask(withName: "task1", expirationHandler: {
            [weak self] in
            self!.endBackgroundTask()
        })
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        if backgrounTaskIdentifier != UIBackgroundTaskInvalid{
            endBackgroundTask()
        }
        let badgeResetOperation = CKModifyBadgeOperation(badgeValue: 0)
        badgeResetOperation.modifyBadgeCompletionBlock = { (error) -> Void in
            if error != nil {
                print("Error resetting badge: \(String(describing: error))")
            }
            else {
                application.applicationIconBadgeNumber = 0
            }
        }
        CKContainer.default().add(badgeResetOperation)

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



