//
//  SentViewController.swift
//  NoIce
//
//  Created by Done Santana on 18/3/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import UIKit

class SentViewController: UIViewController, UITextViewDelegate {
    
    var destinoImage = UIImage()
    var destinoEmail: String!
    
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?

    //MENSAJE ENVIADO
    @IBOutlet weak var MensajeSent: UIView!
    @IBOutlet weak var TextToSend: UITextView!
    @IBOutlet weak var DestinoPhoto: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TextToSend.delegate = self
        self.DestinoPhoto.layer.cornerRadius =  self.DestinoPhoto.frame.width / 2
        self.DestinoPhoto.clipsToBounds = true
        self.DestinoPhoto.contentMode = .scaleAspectFill
        self.DestinoPhoto.image = self.destinoImage //self.resizeImage(image: self.destinoImage, newWidth: self.DestinoPhoto.frame.width)//self.imageWithImage(image: self.destinoImage, scaledToSize: self.DestinoPhoto.intrinsicContentSize)//self.destinoImage.withRenderingMode(.alwaysTemplate)

       NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }

    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage
    {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight)) //(newWidth, newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    @IBAction func SentMessage(_ sender: Any) {
        self.TextToSend.resignFirstResponder()
        let menssage = CMensaje(emailEmisor: myvariables.userperfil.Email, emailDestino: self.destinoEmail, mensaje: self.TextToSend.text)
        menssage.EnviarMensaje()
        
    }

    @IBAction func CancelMessage(_ sender: Any) {
        self.TextToSend.resignFirstResponder()
        
    }
    

    func keyboardNotification(notification: NSNotification){
        if let userInfo = notification.userInfo{
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 0.0
            } else {
                self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
}
