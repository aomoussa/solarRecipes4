//
//  ViewController.swift
//  solarRecipes2
//
//  Created by Ahmed Moussa on 11/9/16.
//  Copyright © 2016 Ahmed Moussa. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore


// I'm ahmed and i changed this code

class loginViewController: UIViewController {

    @IBOutlet weak var FBLoginButton: UIButton!
    
    @IBAction func bypassLogin(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toHome", sender: self)
    }
    
    @IBAction func FBLoginClicked(_ sender: UIButton) {
        
        if let accessToken = AccessToken.current {
            self.performSegue(withIdentifier: "toHome", sender: self)
            glblFBHandler = facebookHandler(accessToken: accessToken)
        }
        else{
            let loginManager = LoginManager()
            loginManager.logIn([ .publicProfile ], viewController: self) { loginResult in
                switch loginResult {
                case .failed(let error):
                    print(error)
                case .cancelled:
                    print("User cancelled login.")
                case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                    print("Logged in!")
                    glblFBHandler = facebookHandler(accessToken: accessToken)
                    self.performSegue(withIdentifier: "toHome", sender: self)
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if let accessToken = AccessToken.current {
            setLoginButtonTitleToFBName(accessToken: accessToken)
        }
        else{
            //FBLoginButton.alpha = 0
        }
        // Do any additional varup after loading the view, typically from a nib.
    }

    func setLoginButtonTitleToFBName(accessToken: AccessToken){
        let req = GraphRequest(graphPath: "me", parameters: ["fields":"name"], accessToken: accessToken, httpMethod: GraphRequestHTTPMethod(rawValue: "GET")!, apiVersion: FacebookCore.GraphAPIVersion.defaultVersion)
        req.start { (response, result) in
            switch result {
            case .success(let value):
                print(value.dictionaryValue)
                print(value.stringValue)
                print(value.arrayValue)
                
                //self.FBID = value.dictionaryValue!["id"] as! String //["id"] //(forKey: "id")
                let FBName = value.dictionaryValue!["name"] as! String
                
                self.FBLoginButton.setTitle("Continue as \"\(FBName)\"", for: UIControlState.normal) //titleLabel?.text = "LOGIN AS \(FBName)"
                
                //print(self.FBID)
                //print(self.FBName)
                //self.usernameLabel.text = self.FBName
                //self.getFBProfilePic(userFBID: self.FBID)
                //self.addRefresherToCollectionView()
                //self.getRecipeData(fbid: self.FBID)
            //print(value.dictionaryValue)
            case .failed(let error):
                print(error)
            }
        }
    }


}

