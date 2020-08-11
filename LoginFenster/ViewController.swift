//
//  ViewController.swift
//  LoginFenster
//
//  Created by Armin Vosoghi Marand on 08.08.20.
//  Copyright © 2020 NFCtronik-Team. All rights reserved.
//

import UIKit
import FirebaseAuth
class ViewController: UIViewController {

    let newLayer1 = CAGradientLayer()
    
    @IBOutlet weak var benutzerID: UITextField!
    @IBOutlet weak var passwort: UITextField!
    var boole: Bool = false
    @IBAction func button(_ sender: UIButton) {
        print("Hallo")
        guard let benutzer = benutzerID.text, !benutzer.isEmpty,
            let password = passwort.text,!password.isEmpty else{
                print("LEER")
                self.showCreateAccount()
                return
        }
        FirebaseAuth.Auth.auth().signIn(withEmail: benutzer, password: password, completion:  {[weak self] result, error in
            guard let strongSelf = self else{
                return
            }
            guard error == nil else{
                strongSelf.showCreateAccount(benutzerId: benutzer, password: password)
                return
            }
            print("Anmeldung erfolgreich")
        })
       
        guard let vc = storyboard?.instantiateViewController(identifier: "kart_VC") as? KartViewController else{
            return
        }
        present(vc,animated: true)
        
    }
    func showCreateAccount(benutzerId: String, password: String){
        let alert = UIAlertController(title: "Fehler", message: "Ungültige BenutzerID oder Passwort", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Verlassen", style: .cancel, handler: {_ in
            
        }))
        present(alert, animated: true)
    }
    func showCreateAccount(){
           let alert = UIAlertController(title: "Fehler", message: "Ungültige BenutzerID oder Passwort", preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "Verlassen", style: .cancel, handler: {_ in
               
           }))
           present(alert, animated: true)
       }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newLayer1.colors = [UIColor.init(red: (5/255), green: (105/255), blue: (127/255), alpha: 1.0).cgColor,
                            UIColor.init(red: (6/255), green: (136/255), blue: (164/255), alpha: 1.0).cgColor]
        newLayer1.frame=view.frame
        view.layer.anchorPointZ=5
        view.layer.addSublayer(newLayer1)
        newLayer1.anchorPointZ=1
        // Do any additional setup after loading the view.
    
    }
    
   

}

