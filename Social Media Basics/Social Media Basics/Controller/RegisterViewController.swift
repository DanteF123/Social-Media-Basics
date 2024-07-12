import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    let db = Firestore.firestore()
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text {
                    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                        if let e = error {
                            let message = e.localizedDescription
                            let alert = UIAlertController(title: "Oops", message: message, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Try Again", style: .default))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            if let user = authResult?.user {
                                let userID = user.uid
                                self.db.collection("users").document(userID).setData([
                                    "email": email,
                                    "name": name
                                ]) { error in
                                    if let error = error {
                                        print("Error adding user: \(error)")
                                    } else {
                                        print("User added successfully")
                                    }
                                }
                            }
                            
                            let message = "User Created"
                            let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
                                // Navigate to Hello after the alert is dismissed
                                self.performSegue(withIdentifier: "registerToHello", sender: self)
                            })
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
    
}

extension RegisterViewController {
    func userCreated() {
        // Implement any additional functionality if needed
    }
}
