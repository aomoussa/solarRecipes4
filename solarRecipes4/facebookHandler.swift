//
//  facebookHandler.swift
//  solarRecipes2
//
//  Created by Ahmed Moussa on 6/17/17.
//  Copyright © 2017 Ahmed Moussa. All rights reserved.
//

import Foundation
import FacebookLogin
import FacebookCore

class facebookHandler{
    //var accessToken: AccessToken
    var FBID = "ID not retrieved"
    var FBName = "FB name not retrieved"
    var FBProfilePicture = UIImage(named: "plus.jpg")
    
    init(accessToken: AccessToken) {
        //self.accessToken = accessToken
        self.getFBProfile(accessToken: accessToken)
        
    }
    init(){
        FBID = "id but not yet"
        FBName = "name but not yet"
        FBProfilePicture = UIImage(named: "plus.jpg")!
        //accessToken =
    }
    func getFBProfile(accessToken: AccessToken){
        let req = GraphRequest(graphPath: "me", parameters: ["fields":"name"], accessToken: accessToken, httpMethod: GraphRequestHTTPMethod(rawValue: "GET")!, apiVersion: FacebookCore.GraphAPIVersion.defaultVersion)
        req.start { (response, result) in
            switch result {
            case .success(let value):
                
                self.FBID = value.dictionaryValue!["id"] as! String //["id"] //(forKey: "id")
                self.FBName = value.dictionaryValue!["name"] as! String
                
                self.getFBProfilePic(userFBID: self.FBID)
            case .failed(let error):
                print(error)
            }
        }
    }
    func getFBProfilePic(userFBID: String){
        let ahmedsPicURL = URL(string: "https://graph.facebook.com/10155692326063868/picture?type=large")
        let picURL = URL(string: "https://graph.facebook.com/\(userFBID)/picture?type=large")
        print(picURL)
        
        
        print("Download Started")
        getDataFromUrl(url: picURL!) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? picURL?.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
                self.FBProfilePicture = UIImage(data: data)!
            }
        }
        
    }
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
}
var glblFBHandler = facebookHandler()
