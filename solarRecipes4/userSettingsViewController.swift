//
//  userSettingsViewController.swift
//  Pods
//
//  Created by Ahmed Moussa on 11/13/16.
//
//


import UIKit
import FacebookLogin
import FacebookCore
import AWSMobileHubHelper
import AWSDynamoDB

class userSettingsViewController: UIViewController , UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var userRecipesCollectionView: UICollectionView!
    
    @IBOutlet weak var profilePictureButton: UIButton!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBAction func logoutButtonClicked(_ sender: UIButton) {
        if AccessToken.current != nil {
            let loginManager = LoginManager()
            loginManager.logOut()
            self.performSegue(withIdentifier: "logout", sender: self)
        }
        else{
            print("you were never logged in? this shouldn't happen i think")
        }
    }
    
    let yellowColor = UIColor(red: 218/255, green: 205/255, blue: 0, alpha: 1)
    let maroonColor = UIColor(red: 167/255, green: 49/255, blue: 46/255, alpha: 1)
    
    @IBOutlet weak var recipesButton: UIButton!
    
    @IBOutlet weak var ovensButton: UIButton!
    
    @IBAction func recipesTapped(_ sender: UIButton) {
        recipesButton.backgroundColor = yellowColor
        ovensButton.backgroundColor = maroonColor
        state = "recipes"
        userRecipesCollectionView.reloadData()
    }
    
    @IBAction func ovensTapped(_ sender: UIButton) {
        ovensButton.backgroundColor = yellowColor
        recipesButton.backgroundColor = maroonColor
        state = "ovens"
        userRecipesCollectionView.reloadData()
        if(oves.count == 0){
            getOvenData()
        }
    }
    
    
    var state = "recipes"
    var oves = [oven]()
    var recies = [recipe]()
    var FBID = ""
    var FBName = ""
    
    override func viewDidLoad() {
        userRecipesCollectionView.delegate = self
        userRecipesCollectionView.dataSource = self
        
        //let userNameLabel = UILabel()
        if AccessToken.current != nil {
            getFBProfile(accessToken: AccessToken.current!)
            
        }
        
    }
    
    func getFBProfile(accessToken: AccessToken){
        let req = GraphRequest(graphPath: "me", parameters: ["fields":"name"], accessToken: accessToken, httpMethod: GraphRequestHTTPMethod(rawValue: "GET")!, apiVersion: FacebookCore.GraphAPIVersion.defaultVersion)
        req.start { (response, result) in
            switch result {
            case .success(let value):
                print(value.dictionaryValue)
                print(value.stringValue)
                print(value.arrayValue)
                
                self.FBID = value.dictionaryValue!["id"] as! String //["id"] //(forKey: "id")
                self.FBName = value.dictionaryValue!["name"] as! String
                print(self.FBID)
                print(self.FBName)
                self.usernameLabel.text = self.FBName
                self.getFBProfilePic(userFBID: self.FBID)
                self.addRefresherToCollectionView()
                self.getRecipeData(fbid: self.FBID)
            //print(value.dictionaryValue)
            case .failed(let error):
                print(error)
            }
        }
    }
    func getFBProfilePic(userFBID: String){
        let ahmedsPicURL = URL(string: "https://graph.facebook.com/10155692326063868/picture?type=large")
        let picURL = URL(string: "https://graph.facebook.com/\(userFBID)/picture?type=large")
        print(picURL)
        
        let activityInd = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityInd.startAnimating()
        activityInd.center = profilePictureButton.center
        self.view.addSubview(activityInd)
        
        
        print("Download Started")
        getDataFromUrl(url: picURL!) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? picURL?.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
                let image = UIImage(data: data)
                self.profilePictureButton.contentMode = .scaleAspectFill
                self.profilePictureButton.setImage(image, for: UIControlState.normal)
                let imageView = UIImageView(image: image)
                imageView.frame = self.profilePictureButton.frame
                imageView.contentMode = .scaleAspectFit
                self.view.addSubview(imageView)
                activityInd.removeFromSuperview()
            }
        }
        
    }
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    //--------- -------------- ------------- ------ collection view stuff ---------- ------------- -------------- begins
    //----------------------------- COLLECTIONVIEW CODE -------------------------------- starts
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch(state){
        case "recipes":
            return recies.count
        case "ovens":
            return oves.count
        default:
            return 1
        }
    }
    let difficulties = ["Hard","Medium","Easy"]
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch(state){
        case "ovens":
            return makeOvenCell(indexPath: indexPath, collectionView: collectionView)
        default:
            return makeRecipeCell(indexPath: indexPath, collectionView: collectionView)
        }
        /*were supposed to be lines.. ignore for now
         let cellHeight = self.view.frame.height/2
         let cellWidth = self.view.frame.width/2.2
         
         let lineAtBottom = UIView(frame: CGRect(x: cellWidth*0.15, y: cellHeight, width: cellWidth*0.7, height: 5.0))
         let lineAtSide = UIView(frame: CGRect(x: cellWidth, y: cellHeight*0.15, width: 5.0, height: cellHeight*0.7))
         
         lineAtBottom.backgroundColor = UIColor.gray
         lineAtSide.backgroundColor = UIColor.gray
         
         cell.addSubview(lineAtBottom)
         cell.addSubview(lineAtSide)
         */
    }
    func editOvenClicked(sender: UIButton){
        self.performSegue(withIdentifier: "toEditOven", sender: self.oves[sender.tag])
    }
    
    func deleteOvenClicked(sender: UIButton){
        self.showDeleteAlertForOven(oven: oves[sender.tag])//title: "Are you sure?", message: "Do you want to delete this oven?")
    }
    func makeOvenCell(indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ovenCell", for: indexPath) as! ovenCollectionViewCell
        if(indexPath.row < oves.count){
            cell.editButton.tag = indexPath.row
            cell.editButton.addTarget(self, action: #selector(self.editOvenClicked(sender:)), for: UIControlEvents.touchUpInside)
            cell.deleteButton.tag = indexPath.row
            cell.deleteButton.addTarget(self, action: #selector(self.deleteOvenClicked(sender:)), for: UIControlEvents.touchUpInside)
            cell.creatorName.text = "By: \((oves[indexPath.row].ove?._creatorName)!)"
            cell.title.text = oves[indexPath.row].ove?._name
            cell.difficulty.text = difficulties[Int((oves[indexPath.row].ove?._difficulty!)!) - 1]
            cell.ovenType.text = "A \((oves[indexPath.row].ove?._ovenType)!) oven"
            if( oves[indexPath.row].picures.count > 1){
                cell.image.image = oves[indexPath.row].picures[1]
            }
        }
        
        return cell
    }
    func makeRecipeCell(indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recipeCell", for: indexPath) as! recipeCollectionViewCell
        if(indexPath.row < recies.count){
            cell.creatorNameLabel.text = "By: \((recies[indexPath.row].recie?._creatorName)!)"
            cell.recipeNameLabel.text = recies[indexPath.row].recie?._name
            cell.tempValueLabel.text = "\(String(describing: (recies[indexPath.row].recie?._temperature)!))-\(String(describing: (recies[indexPath.row].recie?._toTemperature)!))F"
            //cell.toTempValueLabel.text = "\(String(describing: (recies[indexPath.row].recie?._toTemperature)!))F"
            cell.diffValueLabel.text = difficulties[Int((recies[indexPath.row].recie?._difficulty!)!) - 1]
            cell.durValueLabel.text = makeDurationString(duration: Int(String(describing: (recies[indexPath.row].recie?._duration)!))!, toDuration: Int(String(describing: (recies[indexPath.row].recie?._toDuration)!))!)
            //cell.toDurValueLabel.text = "\(String(describing: (recies[indexPath.row].recie?._toDuration)!))min"
            cell.ovenTypeLabel.text = "For: \((recies[indexPath.row].recie?._ovenType)!) ovens"
            if( recies[indexPath.row].picures.count > 1){
                cell.recipeImageView.image = recies[indexPath.row].picures[1]
            }
            makeLabelResizeText(label: cell.recipeNameLabel)
            makeLabelResizeText(label: cell.tempValueLabel)
            //makeLabelResizeText(label: cell.toTempValueLabel)
            makeLabelResizeText(label: cell.durValueLabel)
            //makeLabelResizeText(label: cell.toDurValueLabel)
            
        }
        
        return cell
    }
    
    func makeDurationString(duration: Int, toDuration: Int) -> String{
        var durHalfHr = ""
        var toDurHalfHr = ""
        if(duration%60 >= 30){
            durHalfHr = ".5"
        }
        if(toDuration%60 >= 30){
            toDurHalfHr = ".5"
        }
        return "\(duration/60)\(durHalfHr)-\(toDuration/60)\(toDurHalfHr)hrs"
    }
    func makeLabelResizeText(label: UILabel){//, downTo: Int){
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenHeight = self.view.frame.height
        let screenWidth = self.view.frame.width
        return CGSize(width: screenWidth/2.1, height: screenHeight/2.5)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch(state){
        case "ovens":
            populateOvenPicturesAtIndex(i: indexPath.row)
        default:
            populatePicturesAtIndex(i: indexPath.row)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch(state){
        case "ovens":
            
            self.performSegue(withIdentifier: "toOven", sender: oves[indexPath.row])
        
        default:
            
            self.performSegue(withIdentifier: "toRecipe", sender: recies[indexPath.row])
        }
    }
    //incomplete
    //func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //self.performSegue(withIdentifier: "toRecipeDetails", sender: recies[indexPath.row])
    //}
    
    //----------------------------- COLLECTIONVIEW CODE -------------------------------- ends
    //--------- -------------- ------------- ------ collection view stuff ---------- ------------- -------------- ends
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch(segue.identifier!){
        case "toOven":
            let destVC = segue.destination as! ovenDetailsViewController
            destVC.oven1 = (sender as? oven)!
        case "toRecipe":
            let destVC = segue.destination as! recipeDetailsViewController
            destVC.recie1 = (sender as? recipe)!
        case "toEditOven":
            let destVC = segue.destination as! addOvenViewController
            destVC.ovenToEdit = (sender as? oven)!
            destVC.state = "edit"
        default:
            break
        }
    }
    //------------- -------------- ----------- recipe data retrieval stuff ---------- ----------- ------------ begins
    func populateOvenPicturesAtIndex(i: Int){
        
        if(i < oves.count && oves[i].picures.count == 0){
            oves[i].picures.append(UIImage(named: "plus.jpg")!)
            getPictureFromDirectory(prefix: "public/\((oves[i].ove?._name!)!)/", i: i, state: "ovens")
        }
        
    }
    func populatePicturesAtIndex(i: Int){
        
        if(i < recies.count && recies[i].picures.count == 0){
            recies[i].picures.append(UIImage(named: "plus.jpg")!)
            getPictureFromDirectory(prefix: "public/\((recies[i].recie?._name!)!)/", i: i, state: "recipes")
        }
        
    }
    func addRefresherToCollectionView(){
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(userSettingsViewController.refresherReload(_:)), for: UIControlEvents.valueChanged)
        userRecipesCollectionView.addSubview(refresher)
    }
    func refresherReload(_ sender: UIRefreshControl){
        var tempRecies = [recipe]()
        //self.recies.removeAll()
        let completionHandler = {(response: AWSDynamoDBPaginatedOutput?, error: Error?) -> Void in
            if let error = error {
                let errorMessage = "Failed to retrieve items. \(error.localizedDescription)"
                self.showAlertWithTitle(title: "Error", message: errorMessage)
            }
            else if response!.items.count == 0 {
                self.showAlertWithTitle(title: "Not Found", message: "No items match your criteria. Insert more sample data and try again.")
            }
            else {
                //it all worked out:
                let paginatedOutput = response as? AWSDynamoDBPaginatedOutput!
                
                
                for item in paginatedOutput?.items as! [DBRecipe] {
                    let newRecie = recipe(recip: item)
                    tempRecies.append(newRecie)
                    print(tempRecies)
                }
                DispatchQueue.main.async(execute: {
                    self.recies = tempRecies
                    self.userRecipesCollectionView.reloadData()
                    sender.endRefreshing()
                })
            }
        }
        glblQueryHandler.queryRecipeData(completionHandler: completionHandler)
        /*
         self.userRecipesCollectionView.performBatchUpdates({
         glblQueryHandler.queryRecipeData(completionHandler: completionHandler)
         }) { (completed) in
         DispatchQueue.main.async(execute: {
         self.userRecipesCollectionView.reloadData()
         sender.endRefreshing()
         })
         }*/
        
    }
    func getOvenData(){
        self.oves.removeAll()
        let x = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        x.center = self.view.center
        x.startAnimating()
        self.view.addSubview(x)
        let completionHandler = {(response: AWSDynamoDBPaginatedOutput?, error: Error?) -> Void in
            if let error = error {
                let errorMessage = "Failed to retrieve items. \(error.localizedDescription)"
                self.showAlertWithTitle(title: "Error", message: errorMessage)
                x.removeFromSuperview()
            }
            else if response!.items.count == 0 {
                self.showAlertWithTitle(title: "No Ovens", message: "The Ovens you created show here. Add ovens by tapping the \"+\" button in the main view")
                x.removeFromSuperview()
            }
            else {
                //it all worked out:
                let paginatedOutput = response as? AWSDynamoDBPaginatedOutput!
                
                
                for item in paginatedOutput?.items as! [DBOven] {
                    let newOven = oven(ov: item)
                    self.oves.append(newOven)
                    print(self.oves)
                }
                DispatchQueue.main.async(execute: {
                    self.userRecipesCollectionView.reloadData()
                    x.removeFromSuperview()
                })
            }
        }
        glblQueryHandler.queryOvenData(completionHandler: completionHandler)
    }
    func getRecipeData(fbid: String){
        self.recies.removeAll()
        let x = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        x.center = self.view.center
        x.startAnimating()
        self.view.addSubview(x)
        let completionHandler = {(response: AWSDynamoDBPaginatedOutput?, error: Error?) -> Void in
            if let error = error {
                let errorMessage = "Failed to retrieve items. \(error.localizedDescription)"
                self.showAlertWithTitle(title: "Error", message: errorMessage)
                x.removeFromSuperview()
            }
            else if response!.items.count == 0 {
                self.showAlertWithTitle(title: "No Recipes", message: "The Recipes you created show here. Add recipes by tapping the \"+\" button in the main view")
                x.removeFromSuperview()
            }
            else {
                //it all worked out:
                let paginatedOutput = response as? AWSDynamoDBPaginatedOutput!
                
                
                for item in paginatedOutput?.items as! [DBRecipe] {
                    let newRecie = recipe(recip: item)
                    self.recies.append(newRecie)
                    //print(self.recies)
                }
                DispatchQueue.main.async(execute: {
                    self.userRecipesCollectionView.reloadData()
                    x.removeFromSuperview()
                })
            }
        }
        glblQueryHandler.scanByFBID(fbid: fbid, completionHandler: completionHandler)
    }
    func getPictureFromDirectory(prefix: String, i:Int, state: String){
        let imgCompletionHandler = {[weak self](content: AWSContent?, data: Data?, error: Error?) -> Void in
            guard self != nil else { return }
            if let error = error {
                print("Failed to download a content from a server. \(error)")
                return
            }
            print("Object download complete.")
            print("downloaded??")
            switch(state){
            case "ovens":
                self?.oves[i].picures.append(UIImage(data: data!)!)
            default:
                self?.recies[i].picures.append(UIImage(data: data!)!)
            }
            DispatchQueue.main.async(execute: {
                
                self?.userRecipesCollectionView.reloadItems(at: [IndexPath(row: i, section: 0)])
            })
            print(content)
        }
        glblImageDownloadHandler.getPicture(prefix: prefix, imgCompletionHandler: imgCompletionHandler)
        
    }
    
    //------------- -------------- ----------- recipe data retrieval stuff ---------- ----------- ------------ ends
    func showDeleteAlertForOven(oven: oven) {//title: "Are you sure?", message: "Do you want to delete this oven?")
        let alertController: UIAlertController = UIAlertController(title: "Are you sure?", message: "Do you want to delete \((oven.ove?._name!)!)?", preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let reloadAction: UIAlertAction = UIAlertAction(title: "Delete", style: .default, handler: {alertController in self.deleteOven(oven: oven)})
        alertController.addAction(cancelAction)
        alertController.addAction(reloadAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func deleteOven(oven: oven){
        print("about to delete \(oven.ove?._name!)")
    }
    func showAlertWithTitle(title: String, message: String) {
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        let reloadAction: UIAlertAction = UIAlertAction(title: "Reload", style: .default, handler: {alertController in self.getRecipeData(fbid: self.FBID)})
        alertController.addAction(cancelAction)
        alertController.addAction(reloadAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
