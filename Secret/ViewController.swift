//
//  ViewController.swift
//  Secret
//
//  Created by Abdulrahman on 10/18/21.
//
import LocalAuthentication
import UIKit

class ViewController: UIViewController {

    @IBOutlet var secret: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Nothing to see here"
        
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustViewForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustViewForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(saveSecretMEssage), name: UIApplication.willResignActiveNotification, object: nil)
        
    }
    
    
    @objc func adjustViewForKeyboard(notification: Notification){
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            secret.contentInset = .zero
        } else {
            secret.contentInset = UIEdgeInsets(top: 0, left: 0 , bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        secret.scrollIndicatorInsets = secret.contentInset
        
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
        
    }
    
    @IBAction func authenticateTapped(_ sender: Any) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy( .deviceOwnerAuthenticationWithBiometrics , error: &error){
            let reason = "Indentify yourself!"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self?.unlockSecretMessage()
                    } else {
                        let ac = UIAlertController(title: "Authentication Failed", message: "You could not be verified, please try again!", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "Ok", style: .default))
                        self?.present(ac, animated: true)
                        
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Biometry Unavailable", message: "Your device is not configured for biometric authtentication", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            present(ac, animated: true)
        }
        
        
    }
    
    func unlockSecretMessage(){
        secret.isHidden = false
        title = "Secret Stuff!"
        
        secret.text = KeychainWrapper.standard.string(forKey: "SecretMessage") ?? ""
    }
    
    @objc func saveSecretMEssage(){
        guard secret.isHidden == false else {return}
        
        KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
        secret.resignFirstResponder()
        secret.isHidden = true
        title = "Nothing to see here"
    }
    

}

