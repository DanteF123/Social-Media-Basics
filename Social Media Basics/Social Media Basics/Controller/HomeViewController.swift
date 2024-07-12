//
//  ViewController.swift
//  Social Media Basics
//
//  Created by Dante Fusaro on 6/18/24.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    
    @IBAction func logInBtnClicked(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text{
            Auth.auth().signIn(withEmail: email, password: password){authResult, error in if let e = error{
                
                    let message = e.localizedDescription
                    let alert = UIAlertController(title: "Oops", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Try Again", style: .default))
                    self.present(alert, animated: true, completion: nil)
                
            }else{
                let user = Auth.auth().currentUser
                print(user!.email!)
                self.performSegue(withIdentifier: "loginToHello", sender: self)
            }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loginButton.titleLabel?.numberOfLines = 0
        
    }


}

