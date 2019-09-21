//
//  AuthenticationViewController.swift
//  Stress Scanner
//
//  Created by Fauzan Achmad on 19/09/19.
//  Copyright © 2019 Fauzan Achmad. All rights reserved.
//

import UIKit
import LocalAuthentication

class AuthenticationViewController : UIViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        touchIdAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func touchIdAction() {
        let myContext = LAContext()
        let myLocalizedReasonString = "Biometric Authntication testing !! "
        
        var authError: NSError?
        if #available(iOS 8.0, macOS 10.12.1, *) {
            if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString) { success, evaluateError in
                    
                    DispatchQueue.main.async {
                        if success {
                            // User authenticated successfully, take appropriate action
                            self.performSegue(withIdentifier: "home", sender: nil)
                            
//                            print("Success")
                        } else {
                            // User did not authenticate successfully, look at error and take appropriate action
                            
                        }
                    }
                }
            } else {
                // Could not evaluate policy; look at authError and present an appropriate message to user
                print("error biometric policy")
            }
        } else {
            // Fallback on earlier versions
            
        }
    }
}
