//
//  LoginViewController.swift
//  FirebaseSample
//
//  Created by Moritz Sternemann on 23.02.17.
//  Copyright © 2017 Moritz Sternemann. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
// MARK: - Actions
    
    @IBAction func didTapSignup() {
        guard let email = self.emailField.text, let password = self.passwordField.text else { return showMessagePrompt("email and password can't be empty") }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password) { user, error in
            guard error == nil else { return self.showMessagePrompt(error!.localizedDescription) }
            
            print("\(user!.email!) created")
            self.navigationController?.dismiss(animated: true)
        }
    }

    @IBAction func didTapSignin() {
        guard let email = self.emailField.text, let password = self.passwordField.text else { return showMessagePrompt("email and password can't be empty") }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password) { user, error in
            guard error == nil else { return self.showMessagePrompt(error!.localizedDescription) }
            
            print("\(user!.email!) signed in")
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func didTapForgotPassword() {
        guard let email = self.emailField.text else { return showMessagePrompt("email can't be empty") }
        
        FIRAuth.auth()?.sendPasswordReset(withEmail: email) { error in
            guard error == nil else { return self.showMessagePrompt(error!.localizedDescription) }
            
            self.showMessagePrompt("Sent!")
        }
    }
    
    func showMessagePrompt(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        
        self.present(alert, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

