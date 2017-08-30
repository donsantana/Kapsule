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
import UserNotifications
import CloudKit
import FBSDKLoginKit
import SocketIO


struct myvariables {
    static var chatsOpen = [CUser]()
    static var userperfil: CUser!
    static var usuariosMostrar = [CUser]()
    static var MensajesRecibidos = [CMensaje]()
    static var MensajesEnviados = [CMensaje]()
    static var socketConexion = SocketIOClient(socketURL: URL(string: "ddlf")!, config: [.log(false), .forcePolling(true)])
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, GIDSignInUIDelegate,UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var Appcontainer = CKContainer.default()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //GMSServices.provideAPIKey("AIzaSyBnKURUhbBUr74PbpPgtPA1driuRaTShGo")
        // Override point for customization after application launch.
        GIDSignIn.sharedInstance().delegate = self
        
        //FBSDKApplicationDelegate.sharedInstance().application( application, didFinishLaunchingWithOptions: launchOptions)
        //application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()

            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { authorized, error in
                if authorized {
                    //application.registerForRemoteNotifications()
                }
            })
        }else {

        }
        GIDSignIn.sharedInstance().clientID = "319723960699-96388hc84tnoohlatvb8r7rhm2806br1.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().signInSilently()
        //return true
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        
        let googleLogin = GIDSignIn.sharedInstance().handle(url as URL!,sourceApplication: sourceApplication,annotation: annotation)
        let faceLogin = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        
        return googleLogin || faceLogin
    }
    
    private func application(app: UIApplication, openURL url: URL, options: [String : AnyObject]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url as URL!,
                                                 sourceApplication: options.index(forKey: "UIApplicationOpenURLOptionsSourceApplicationKey") as! String?,
                                                 annotation: options.index(forKey: "UIApplicationOpenURLOptionsAnnotationKey"))
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        
       // FBSDKAppEvents.activateApp()
        
        //myvariables.userperfil.ActualizarConectado(estado: "0")
        //sleep(2)
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        let badgeResetOperation = CKModifyBadgeOperation(badgeValue: 0)
        badgeResetOperation.modifyBadgeCompletionBlock = { (error) -> Void in
            if error != nil {
                print("Error resetting badge: \(String(describing: error))")
            }
            else {
                application.applicationIconBadgeNumber = 0
                application.cancelAllLocalNotifications()
            }
        }
        CKContainer.default().add(badgeResetOperation)

    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        myvariables.socketConexion.connect()
         //myvariables.userperfil.ActualizarConectado(estado: "1")
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        myvariables.socketConexion.disconnect()
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //self.saveContext()
    }
    
    // Finished disconnecting |user| from the app successfully if |error| is |nil|.
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!){
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {

    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        if #available(iOS 10.0, *) {
           /* print("registrando")
            let subscription = CKQuerySubscription(recordType: "CMensaje", predicate: NSPredicate(format:"destinoEmail == %@", myvariables.userperfil.Email), options: .firesOnRecordCreation)
            let info = CKNotificationInfo()
            info.alertBody = "You had received a new message!"
            info.shouldBadge = true
            info.soundName = "default"
            
            subscription.notificationInfo = info
            
            CKContainer.default().publicCloudDatabase.save(subscription, completionHandler: { subscription, error in
                if error == nil {
                    // Subscription saved successfully
                } else {
                    // An error occurred
                }
            })*/

        } else {
            // Fallback on earlier versions
        }
        
    }

}



