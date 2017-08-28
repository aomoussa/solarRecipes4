//
//  DBQueryHandler.swift
//  solarRecipes2
//
//  Created by Ahmed Moussa on 11/9/16.
//  Copyright © 2016 Ahmed Moussa. All rights reserved.
//

import Foundation
import AWSDynamoDB
import AWSMobileHubHelper
import FacebookCore

class queryHandler{
    
    let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
    
    
    init(){
        
    }
    
    func scanWithExpression(scanExpression: AWSDynamoDBScanExpression, completionHandler: @escaping (_ response: AWSDynamoDBPaginatedOutput?, _ error: Error?) -> Void) {
        
        dynamoDBObjectMapper.scan(DBRecipe.self, expression: scanExpression, completionHandler: {(response: AWSDynamoDBPaginatedOutput?, error: Error?) -> Void in
            DispatchQueue.main.async(execute: {
                completionHandler(response, error)
                
            })
        })
    }
    func ovenScanWithExpression(scanExpression: AWSDynamoDBScanExpression, completionHandler: @escaping (_ response: AWSDynamoDBPaginatedOutput?, _ error: Error?) -> Void) {
        
        dynamoDBObjectMapper.scan(DBOven.self, expression: scanExpression, completionHandler: {(response: AWSDynamoDBPaginatedOutput?, error: Error?) -> Void in
            DispatchQueue.main.async(execute: {
                completionHandler(response, error)
                
            })
        })
    }
    func commentsScanWithExpression(scanExpression: AWSDynamoDBScanExpression, completionHandler: @escaping (_ response: AWSDynamoDBPaginatedOutput?, _ error: Error?) -> Void) {
        
        dynamoDBObjectMapper.scan(Comments.self, expression: scanExpression, completionHandler: {(response: AWSDynamoDBPaginatedOutput?, error: Error?) -> Void in
            DispatchQueue.main.async(execute: {
                completionHandler(response, error)
                
            })
        })
    }
    func queryOvenData(completionHandler: @escaping (_ response: AWSDynamoDBPaginatedOutput?, _ error: Error?) -> Void) {
        
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.limit = 100;
        ovenScanWithExpression(scanExpression: scanExpression, completionHandler: completionHandler)
    }
    func queryRecipeData(completionHandler: @escaping (_ response: AWSDynamoDBPaginatedOutput?, _ error: Error?) -> Void) {
        
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.limit = 100;
        scanWithExpression(scanExpression: scanExpression, completionHandler: completionHandler)
    }
    
    func dealWithAnyDifficulty(difficulty: NSNumber) -> String{
        var difficultyComparator = "="
        if(difficulty == 0){
            difficultyComparator = ">"
        }
        return difficultyComparator
    }
    func dealWithAnyDuration(duration: NSNumber) -> String{
        if(duration == 0){
            return ">"
        }
        return "<"
    }
    /*
     func dealWithNoFilterName(filterName: String) -> String{
     if(filterName == ""){
     return ""
     }
     else{
     return "contains(#name, :name) AND "
     }
     }*/
    func advancedScanNoFilterName(fromTemperature: NSNumber, toTemperature: NSNumber, duration: NSNumber, difficulty: NSNumber, completionHandler: @escaping (_ response: AWSDynamoDBPaginatedOutput?, _ error: Error?) -> Void) {
        let scanExpression = AWSDynamoDBScanExpression()
        let difficultyComparator = dealWithAnyDifficulty(difficulty: difficulty)
        let durationComparator = dealWithAnyDuration(duration: duration)
        scanExpression.filterExpression = "#toTemperature > :fromTemperature AND #froTemperature < :toTemperature AND #duration \(durationComparator) :duration  AND #difficulty \(difficultyComparator) :difficulty"
        scanExpression.expressionAttributeNames = [
            "#froTemperature": "temperature",
            "#toTemperature": "toTemperature",
            "#duration": "duration",
            "#difficulty": "difficulty"
        ]
        scanExpression.expressionAttributeValues = [
            ":fromTemperature": fromTemperature,
            ":toTemperature": toTemperature,
            ":duration": duration,
            ":difficulty": difficulty
        ]
        
        scanExpression.limit = 100
        
        scanWithExpression(scanExpression: scanExpression, completionHandler: completionHandler)
        
    }
    func advancedScan(filterName: String, fromTemperature: NSNumber, toTemperature: NSNumber, duration: NSNumber, difficulty: NSNumber, completionHandler: @escaping (_ response: AWSDynamoDBPaginatedOutput?, _ error: Error?) -> Void) {
        let scanExpression = AWSDynamoDBScanExpression()
        
        let difficultyComparator = dealWithAnyDifficulty(difficulty: difficulty)
        let durationComparator = dealWithAnyDuration(duration: duration)
        //let nameStuff = dealWithNoFilterName(filterName: filterName)
        
        scanExpression.filterExpression = "contains(#name, :name) AND #toTemperature > :fromTemperature AND #froTemperature < :toTemperature AND #duration \(durationComparator) :duration  AND #difficulty \(difficultyComparator) :difficulty"
        scanExpression.expressionAttributeNames = [
            "#name": "name",
            "#froTemperature": "temperature",
            "#toTemperature": "toTemperature",
            "#duration": "duration",
            "#difficulty": "difficulty"
        ]
        scanExpression.expressionAttributeValues = [
            ":name": filterName,
            ":fromTemperature": fromTemperature,
            ":toTemperature": toTemperature,
            ":duration": duration,
            ":difficulty": difficulty
        ]
        
        scanExpression.limit = 100
        
        scanWithExpression(scanExpression: scanExpression, completionHandler: completionHandler)
        
    }
    func advancedScanJustName(filterName: String,  completionHandler: @escaping (_ response: AWSDynamoDBPaginatedOutput?, _ error: Error?) -> Void) {//i don't use this rn
        let scanExpression = AWSDynamoDBScanExpression()
        
        scanExpression.filterExpression = "contains(#name, :name)"
        scanExpression.expressionAttributeNames = [
            "#name": "name"
        ]
        scanExpression.expressionAttributeValues = [
            ":name": filterName
        ]
        
        scanExpression.limit = 100
        
        scanWithExpression(scanExpression: scanExpression, completionHandler: completionHandler)
        
    }
    func scanByFBID(fbid: String,  completionHandler: @escaping (_ response: AWSDynamoDBPaginatedOutput?, _ error: Error?) -> Void) {//for profile page
        let scanExpression = AWSDynamoDBScanExpression()
        
        scanExpression.filterExpression = "#creatorFBID = :fbid"
        scanExpression.expressionAttributeNames = [
            "#creatorFBID": "creatorFBID"
        ]
        scanExpression.expressionAttributeValues = [
            ":fbid": fbid
        ]
        
        scanExpression.limit = 100
        
        scanWithExpression(scanExpression: scanExpression, completionHandler: completionHandler)
        
    }
    
    func scanCommentsByID(aboutID: String,  completionHandler: @escaping (_ response: AWSDynamoDBPaginatedOutput?, _ error: Error?) -> Void) {//for details page
        let scanExpression = AWSDynamoDBScanExpression()
        
        
        scanExpression.filterExpression = "#aboutID = :aboutID"
        scanExpression.expressionAttributeNames = [
            "#aboutID": "aboutID"
        ]
        scanExpression.expressionAttributeValues = [
            ":aboutID": aboutID
        ]
 
        scanExpression.limit = 100
        
        commentsScanWithExpression(scanExpression: scanExpression, completionHandler: completionHandler)
        
    }
    //------------ ---------------- ------------- -------- upload stuff ------ ---------------- --------------- ------ starts
    var tvc = UIViewController()
    var uploadStatusView = UILabel()
    var progressBar = UIView()
    var progress = 0.0 as Float
    func makeLoadingView(){
        //iterative solution to topViewController from stackoverflow by rickerbh
        //http://stackoverflow.com/questions/26667009/get-top-most-uiviewcontroller
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            // topController should now be your topmost view controller
            tvc = topController
        }
        
        let swidth = tvc.view.frame.width
        let sheight = tvc.view.frame.height
        
        uploadStatusView = UILabel(frame: CGRect(x: 0, y: 0, width: swidth, height: sheight*0.1))
        uploadStatusView.text = "UPLOADING..."
        uploadStatusView.backgroundColor = UIColor.gray
        tvc.view.addSubview(uploadStatusView)
    }
    func removeLoadingView(){
        uploadStatusView.removeFromSuperview()
    }
    
    func updateLoadingView(progress: Float, progressBar: UIView){
        uploadStatusView.removeFromSuperview()
        uploadStatusView.backgroundColor = UIColor.green
        
        
        let swidth = tvc.view.frame.width
        let sheight = tvc.view.frame.height
        uploadStatusView.frame = CGRect(x: 0, y: 0, width: CGFloat(progress)*swidth, height: sheight*0.1)
        tvc.view.addSubview(uploadStatusView)
    }
    func getFBProfileAndUploadRecipeAndPics(recipe: recipe, pictures: [UIImage]){
        if AccessToken.current != nil {
            
            makeLoadingView()
            let req = GraphRequest(graphPath: "me", parameters: ["fields":"name"], accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod(rawValue: "GET")!, apiVersion: FacebookCore.GraphAPIVersion.defaultVersion)
            req.start { (response, result) in
                switch result {
                case .success(let value):
                    //print(value.dictionaryValue)
                    
                    let creatorFBID = value.dictionaryValue!["id"] as! String //["id"] //(forKey: "id")
                    let creatorName = value.dictionaryValue!["name"] as! String
                    //print(creatorFBID)
                    //print(creatorName)
                    recipe.recie?._creatorFBID = creatorFBID
                    recipe.recie?._creatorName = creatorName
                    recipe.recie?._id = "r\(creatorFBID)\((recipe.recie?._timestamp!)!)"
                    
                    self.uploadRecipe(recipe.recie!).continue({
                        (task: AWSTask!) -> AWSTask<AnyObject>! in
                        
                        if (task.error != nil) {
                            print(task.error!)
                            self.showAlertWithTitle(title: "problem!", message: "error uploading recipe")
                            self.removeLoadingView()
                            
                        } else {
                            NSLog("DynamoDB save succeeded")
                            
                            //do this when done
                            self.uploadPictures(pictures, folderName: (recipe.recie?._name)!)
                        }
                        return nil
                    })            //print(value.dictionaryValue)
                case .failed(let error):
                    print(error)
                }
            }
        }
        else{
            print("facebook access token is nil")
            showAlertWithTitle(title: "problem!", message: "facebook access token is nil")
        }
    }
    func getFBProfileAndUploadOvenAndPics(oven: oven, pictures: [UIImage]){
        if AccessToken.current != nil {
            
            makeLoadingView()
            let req = GraphRequest(graphPath: "me", parameters: ["fields":"name"], accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod(rawValue: "GET")!, apiVersion: FacebookCore.GraphAPIVersion.defaultVersion)
            req.start { (response, result) in
                switch result {
                case .success(let value):
                    //print(value.dictionaryValue)
                    
                    let creatorFBID = value.dictionaryValue!["id"] as! String //["id"] //(forKey: "id")
                    let creatorName = value.dictionaryValue!["name"] as! String
                    //print(creatorFBID)
                    //print(creatorName)
                    oven.ove?._userId = creatorFBID
                    oven.ove?._creatorName = creatorName
                    oven.ove?._id = "o\(creatorFBID)\((oven.ove?._timestamp!)!)"
                    
                    self.uploadOven(oven.ove!).continue({
                        (task: AWSTask!) -> AWSTask<AnyObject>! in
                        
                        if (task.error != nil) {
                            print(task.error!)
                            self.showAlertWithTitle(title: "problem!", message: "error uploading recipe")
                            self.removeLoadingView()
                            
                        } else {
                            NSLog("DynamoDB save succeeded")
                            
                            //do this when done
                            self.uploadPictures(pictures, folderName: (oven.ove?._name)!)
                        }
                        return nil
                    })            //print(value.dictionaryValue)
                case .failed(let error):
                    print(error)
                }
            }
        }
        else{
            print("facebook access token is nil")
            showAlertWithTitle(title: "problem!", message: "facebook access token is nil")
        }
    }
    func prepAndUploadComment(comment: Comments){
        
        self.uploadComment(comment).continue({
            (task: AWSTask!) -> AWSTask<AnyObject>! in
            
            if (task.error != nil) {
                print(task.error!)
                self.showAlertWithTitle(title: "problem!", message: "error uploading recipe")
                self.removeLoadingView()
                
            } else {
                NSLog("DynamoDB save succeeded")
            }
            return nil
        })
        
        
    }
    func uploadComment(_ comment: Comments) -> AWSTask<AnyObject>! {
        let mapper = AWSDynamoDBObjectMapper.default()
        let task = mapper.save(comment)
        return(AWSTask(forCompletionOfAllTasks: [task]))
    }
    func uploadOven(_ oven: DBOven) -> AWSTask<AnyObject>! {
        let mapper = AWSDynamoDBObjectMapper.default()
        let task = mapper.save(oven)
        return(AWSTask(forCompletionOfAllTasks: [task]))
    }
    func uploadRecipe(_ recie: DBRecipe) -> AWSTask<AnyObject>! {
        let mapper = AWSDynamoDBObjectMapper.default()
        let task = mapper.save(recie)
        return(AWSTask(forCompletionOfAllTasks: [task]))
    }
    func uploadPicture(_ picName: String, picture: UIImage, i: Int, numOfPictures: Int) {
        let key = "public/\(picName)"
        let imageData: Data = UIImageJPEGRepresentation(picture, 0.1)!
        
        uploadWithData(imageData, forKey: key, i:i, numOfPictures: numOfPictures)
    }
    func uploadPictures(_ pictures: [UIImage], folderName: String){
        var i = 1
        for pic in pictures{
            let picName = "\(folderName)/ picture\(i)"
            uploadPicture(picName, picture: pic, i:i, numOfPictures: pictures.count)
            
            if(i==pictures.count){
                removeLoadingView()
                showAlertWithTitle(title: "Upload Complete!", message: "Your recipe/oven has been uploaded successfully")
            }
            i = i + 1
        }
    }
    func uploadWithData(_ data: Data, forKey key: String, i: Int, numOfPictures: Int) {
        
        let S3Bucket = "solarrecipes-userfiles-mobilehub-623139932"
        let credentialProvider = AWSCognitoCredentialsProvider(regionType: .usEast1, identityPoolId: "us-east-1:0f8aff81-0c9c-41f4-bd2a-e9083e706388")
        let configuration = AWSServiceConfiguration(region: .usEast1, credentialsProvider: credentialProvider)
        let userFileManagerConfiguration = AWSUserFileManagerConfiguration(bucketName: S3Bucket, serviceConfiguration: configuration)
        
        AWSUserFileManager.register(with: userFileManagerConfiguration, forKey: "randomManagerIJustCreated")
        
        let manager = AWSUserFileManager.UserFileManager(forKey: "randomManagerIJustCreated")
        let localContent = manager.localContent(with: data, key: key)
        print("about to upload picture rn ")
        localContent.uploadWithPin(
            onCompletion: false,
            progressBlock: {[weak self](content: AWSLocalContent?, progress: Progress?) -> Void in
                guard self != nil else { return }
                /* Show progress in UI. */
                DispatchQueue.main.async(execute: { () -> Void in
                    print(progress?.fractionCompleted ?? 0)
                    self?.progress += Float((progress?.fractionCompleted)!)/Float(numOfPictures)
                    self?.updateLoadingView(progress: (self?.progress)!, progressBar: (self?.progressBar)!)
                })
            },
            completionHandler: {[weak self](content: AWSContent?, error: Error?) -> Void in
                guard self != nil else { return }
                if let error = error {
                    print("Failed to upload an object. \(error)")
                    self?.showAlertWithTitle(title: "problem!", message: "error uploading recipe pictures")
                    self?.removeLoadingView()
                } else {
                    print("Object upload complete. \(error)")
                    if(i==numOfPictures){
                        self?.removeLoadingView()
                        self?.showAlertWithTitle(title: "Upload Complete!", message: "Your recipe/oven has been uploaded successfully")
                    }
                }
        })
    }
    func showAlertWithTitle(title: String, message: String) {
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        tvc.present(alertController, animated: true, completion: nil)
    }
    
    //------------ ---------------- ------------- -------- upload stuff ------ ---------------- --------------- ------ starts
}
let glblQueryHandler = queryHandler()
