//
//  imageDownloadHandler.swift
//  solarRecipes2
//
//  Created by Ahmed Moussa on 11/9/16.
//  Copyright © 2016 Ahmed Moussa. All rights reserved.
//

import Foundation
import AWSMobileHubHelper

class imageDownloadHandler{
    
    private var manager: AWSUserFileManager!
    
    
    
    init(){
        let S3Bucket = "solarrecipes-userfiles-mobilehub-623139932"
        let credentialProvider = AWSCognitoCredentialsProvider(regionType: .usEast1, identityPoolId: "us-east-1:0f8aff81-0c9c-41f4-bd2a-e9083e706388")
        let configuration = AWSServiceConfiguration(region: .usEast1, credentialsProvider: credentialProvider)
        let userFileManagerConfiguration = AWSUserFileManagerConfiguration(bucketName: S3Bucket, serviceConfiguration: configuration)
        AWSUserFileManager.register(with: userFileManagerConfiguration, forKey: "randomManagerIJustCreated")
        
        manager = AWSUserFileManager.UserFileManager(forKey: "randomManagerIJustCreated")
    }
    
    func getPicture(prefix: String, imgCompletionHandler: @escaping (_ content: AWSContent?, _ data: Data?, _ error: Error?) -> Void) {
        var contentsHere: [AWSContent]?
        var markerHere: String?
        var didLoadAllContents: Bool!
        let completionHandler = {[weak self](contents: [AWSContent]?, nextMarker: String?, error: Error?) -> Void in
            guard let strongSelf = self else { return }
            if let error = error {
                
                print("Failed to load the list of contents. \(error)")
            }
            if let contents = contents , contents.count > 0 {
                contentsHere = contents
                if let nextMarker = nextMarker , !nextMarker.isEmpty {
                    didLoadAllContents = false
                } else {
                    didLoadAllContents = true
                }
                markerHere = nextMarker
            }
            
            print("contents is \(contentsHere)")
            if (contentsHere != nil){
                //done
                self?.downloadContent(content: (contentsHere?[0])!, pinOnCompletion: false, imgCompletionHandler: imgCompletionHandler)
                //for temp in contentsHere!{
                    //print(temp.key)
                    //doneeee????
                    //self?.downloadContent(content: temp, pinOnCompletion: false, i:i)
                //}
            }
        }
        if (markerHere != nil){
            loadContentsAtDirectory(prefix: prefix, markerHere: markerHere!, completionHandler: completionHandler)
        }
        else{
            loadContentsAtDirectory(prefix: prefix, markerHere: "", completionHandler: completionHandler)
        }
        
    }
    private func downloadContent(content: AWSContent, pinOnCompletion: Bool, imgCompletionHandler: @escaping (_ content: AWSContent?, _ data: Data?, _ error: Error?) -> Void) {
        content.download(
            with: .ifNewerExists,
            pinOnCompletion: pinOnCompletion,
            progressBlock: {[weak self](content: AWSContent?, progress: Progress?) -> Void in
                guard self != nil else { return }
                /* Show progress in UI. */
            },
            completionHandler: imgCompletionHandler)
    }
    private func loadContentsAtDirectory(prefix: String, markerHere: String, completionHandler: @escaping (_ contents: [AWSContent]?, _ nextMarker: String?, _ error: Error?) -> Void) {
        print("prefix recieved was \(prefix)")
        
        manager.listAvailableContents(withPrefix: prefix, marker: markerHere, completionHandler: completionHandler)
    }
/*fb stuff
     func getFBProfilePicForIndex(userFBID: String, i: Int){
     let picURL = URL(string: "https://graph.facebook.com/\(userFBID)/picture?type=large")
     print(picURL)
     
     print("Download Started")
     getDataFromUrl(url: picURL!) { (data, response, error)  in
     guard let data = data, error == nil else { return }
     print(response?.suggestedFilename ?? picURL?.lastPathComponent)
     print("Download Finished")
     DispatchQueue.main.async() { () -> Void in
     let image = UIImage(data: data)
     self.recies[i].creatorPP = image!
     }
     }
     
     }
     func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
     URLSession.shared.dataTask(with: url) {
     (data, response, error) in
     completion(data, response, error)
     }.resume()
     }

     */
}
let glblImageDownloadHandler = imageDownloadHandler()
