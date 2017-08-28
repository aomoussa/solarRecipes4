//
//  recipeDetailsViewController.swift
//  solarRecipes2
//
//  Created by Ahmed Moussa on 11/13/16.
//  Copyright © 2016 Ahmed Moussa. All rights reserved.
//

import UIKit
import FacebookCore
import AWSCore
import AWSDynamoDB
import AWSMobileHubHelper

class recipeDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate {
    
    var recie1 = recipe()
    
    var pictures = [UIImage]()
    @IBOutlet weak var picturesCollectionView: UICollectionView!
    
    @IBOutlet weak var ingredientsTableView: UITableView!
    
    @IBOutlet weak var recipeTitleLabel: UILabel!
    
    @IBOutlet weak var ovenTypeLabel: UILabel!
    
    @IBOutlet weak var creatorNameLabel: UILabel!
    
    @IBOutlet weak var difficultyLabel: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var toDurationLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var toTemperatureLabel: UILabel!
    
    @IBOutlet weak var ingredientsButton: UIButton!
    
    @IBOutlet weak var directionsButton: UIButton!
    
    @IBOutlet weak var commentsButton: UIButton!
    
    var tableViewState = "ingredients"//"instructions" "comments"
    let yellowColor = UIColor(red: 218/255, green: 205/255, blue: 0, alpha: 1)
    let redColor = UIColor(red: 255/255, green: 86/255, blue: 87/255, alpha: 1)//255 86 87
    
    @IBAction func ingredientsClicked(_ sender: UIButton) {
        
        ingredientsButton.backgroundColor = yellowColor
        directionsButton.backgroundColor = redColor
        commentsButton.backgroundColor = redColor
        tableViewState = "ingredients"
        ingredientsTableView.reloadData()
    }
    
    @IBAction func directionsClicked(_ sender: UIButton) {
        ingredientsButton.backgroundColor = redColor
        directionsButton.backgroundColor = yellowColor
        commentsButton.backgroundColor = redColor
        tableViewState = "instructions"
        ingredientsTableView.reloadData()
    }
    
    @IBAction func commentsClicked(_ sender: UIButton) {
        ingredientsButton.backgroundColor = redColor
        directionsButton.backgroundColor = redColor
        commentsButton.backgroundColor = yellowColor
        tableViewState = "comments"
        ingredientsTableView.reloadData()
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRecipeStuff(recie1: recie1)
        ingredientsTableView.delegate = self
        ingredientsTableView.dataSource = self
        
        picturesCollectionView.delegate = self
        picturesCollectionView.dataSource = self
        
        getCommentsForID(id: (recie1.recie?._id)!)
        setupPictures()
    }
    func setupPictures(){
        if(recie1.picures.count > 1){
            pictures = recie1.picures
        }
        if(Int((recie1.recie?._numberOfPictures)!) >= 2 ){
        for  index in 2...Int((recie1.recie?._numberOfPictures)!){
            pictures.append(UIImage(named: "plus.jpg")!)
        }
        }
    }
    func getCommentsForID(id: String){
        self.comments.removeAll()
        let x = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        x.center = self.ingredientsTableView.center
        x.startAnimating()
        self.view.addSubview(x)
        let completionHandler = {(response: AWSDynamoDBPaginatedOutput?, error: Error?) -> Void in
            if let error = error {
                let errorMessage = "Failed to retrieve comments. \(error.localizedDescription)"
                glblQueryHandler.showAlertWithTitle(title: "Error", message: errorMessage)
                x.removeFromSuperview()
            }
            else if response!.items.count == 0 {
                glblQueryHandler.showAlertWithTitle(title: "Not Found", message: "No comments for this recipe/oven")
                x.removeFromSuperview()
            }
            else {
                //it all worked out:
                let paginatedOutput = response as? AWSDynamoDBPaginatedOutput!
                
                
                for item in paginatedOutput?.items as! [Comments] {
                    self.comments.append(item)
                }
                DispatchQueue.main.async(execute: {
                    if(self.tableViewState == "comments"){
                        self.ingredientsTableView.reloadData()
                    }
                    x.removeFromSuperview()
                })
            }
        }
        glblQueryHandler.scanCommentsByID(aboutID: id, completionHandler: completionHandler)
    }

    func setRecipeStuff(recie1: recipe){
        recipeTitleLabel.text = recie1.recie?._name
        ovenTypeLabel.text = "For \((recie1.recie?._ovenType)!) Ovens"
        creatorNameLabel.text = "By \((recie1.recie?._creatorName)!)"
        let difficulties = ["Hard","Medium","Easy"]
        difficultyLabel.text = difficulties[Int((recie1.recie?._difficulty!)!) - 1]
        durationLabel.text = "\(String(describing: (recie1.recie?._duration)!))"
        toDurationLabel.text = "\(String(describing: (recie1.recie?._toDuration)!))min"
        temperatureLabel.text = "\(String(describing: (recie1.recie?._temperature)!))"
        toTemperatureLabel.text = "\(String(describing: (recie1.recie?._toTemperature)!))F"
        instructions = [String]((recie1.recie?._instructions)!)
        ingredients = [String]((recie1.recie?._ingredients)!)
        ingredients.sort()
        instructions.sort()
        ingredients = sortAndClipList(list: ingredients)
        instructions = sortAndClipList(list: instructions)
    }
    
    func sortAndClipList(list: [String]) -> [String]{
        //list.sort()
        var newList = list
        var temp2: String
        for temp in list{
            let numberStart = temp.index(temp.endIndex, offsetBy: -2)
            let range = numberStart..<temp.endIndex
            
            let x = temp.substring(with: range)
            let i = Int(x)
            temp2 = temp.substring(with: temp.startIndex..<numberStart)
            newList[i!] = temp2
        }
        return newList
    }
    //--------------- -------------- --------- tableView (ing/ins) stuff ------------- -------------- --------- begins
    var ingredients = ["ingredients"]
    var instructions = ["instructions"]
    var comments = [Comments]()
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(tableViewState){
        case "ingredients":
            return ingredients.count
        case "instructions":
            return instructions.count
        case "comments":
            return comments.count + 1
        default:
            return 1
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch(tableViewState){
        case "instructions":
            return makeInstructionDisplayCell(tableView: tableView, row: indexPath.row)
        case "comments":
            if(indexPath.row == comments.count){
                return makeNewCommentCell(tableView: tableView, row: indexPath.row)
            }
            else{
                return makeCommentDisplayCell(tableView: tableView, row: indexPath.row)
            }
            
        default:
            return makeIngredientDisplayCell(tableView: tableView, row: indexPath.row)
        }
    }
    var newCommentText = "not ready yet"
    var textViewTemp = UITextView()
    func makeNewCommentCell(tableView: UITableView, row: Int) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "newCommentCell") as! newCommentTableViewCell!
        cell?.contentTextView.text = "Write a comment..."
        cell?.contentTextView.textColor = UIColor.lightGray
        cell?.contentTextView.delegate = self
        textViewTemp = (cell?.contentTextView)!
        
        //if(glblFBHandler.accessToken.current){
        cell?.newCommentorImage.image = glblFBHandler.FBProfilePicture
        //}
        cell?.submitCommentButton.addTarget(self, action: #selector(submitComment), for: .touchUpInside)
        return cell!
    }
    func submitComment(sender: UIButton){
        textViewTemp.endEditing(true)
        let tmstmp = String(NSDate().timeIntervalSince1970)
        let content = newCommentText
        //print("\(glblFBHandler.FBID)")
        //print("\(oven1.ove?._id)!")
        //print("\(tmstmp)")
        //print("\(content)")
        let comment = Comments()
        comment?._aboutID = (recie1.recie?._id)!
        comment?._userId = glblFBHandler.FBID
        comment?._creatorName = glblFBHandler.FBName
        comment?._content = content
        comment?._timestamp = tmstmp
        comment?._commentID = "c\(glblFBHandler.FBID)\(tmstmp)"
        
        glblQueryHandler.uploadComment(comment!).continue({
            (task: AWSTask!) -> AWSTask<AnyObject>! in
            
            if (task.error != nil) {
                print(task.error!)
                glblQueryHandler.showAlertWithTitle(title: "problem!", message: "error uploading comment")
                
            } else {
                NSLog("DynamoDB save succeeded")
                self.getCommentsForID(id: (self.recie1.recie?._id)!)
                //self.textViewTemp.text = "Write a new comment..."
                //self.textViewTemp.textColor = UIColor.lightGray
            }
            return nil
        })
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.textColor = UIColor.black
        self.view.frame = CGRect(x: view.frame.minX, y: view.frame.minY - 300, width: view.frame.width, height: view.frame.height)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        newCommentText = textView.text
        
        self.view.frame = CGRect(x: view.frame.minX, y: view.frame.minY + 300, width: view.frame.width, height: view.frame.height)
        /*
         let tmstmp = String(NSDate().timeIntervalSince1970)
         let content = textView.text
         print("\(glblFBHandler.FBID)")
         print("\(oven1._id)")
         print("\(tmstmp)")
         print("\(content)")*/
    }

    func makeCommentDisplayCell(tableView: UITableView, row: Int) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "stepDisplayCell") as! newStepTableViewCell!
        
        cell?.titleLabel.text = comments[row]._creatorName!
        cell?.contentTextView.text = comments[row]._content!
        cell?.contentTextView.isEditable = false
        cell?.editButton.alpha = 0
        cell?.deleteButton.alpha = 0
        return cell!
    }
    func makeIngredientDisplayCell(tableView: UITableView, row: Int) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "ingredientDisplayCell") as! newIngredientTableViewCell!
        
        cell?.ingredientTitleLabel?.text = "\( ingredients[row])"
        
        return cell!
    }
    func makeInstructionDisplayCell(tableView: UITableView, row: Int) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "stepDisplayCell") as! newStepTableViewCell!
        
        cell?.titleLabel.text = "Step \(row + 1)"
        cell?.contentTextView.text = instructions[row]
        cell?.contentTextView.isEditable = false
        cell?.editButton.alpha = 0
        cell?.deleteButton.alpha = 0
        
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch(tableViewState){
        case "ingredients":
            return 50
            break
        default:
            return 100
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.textViewTemp.endEditing(true)
    }
    //--------------- -------------- --------- tableView (ing/ins) stuff ------------- -------------- --------- ends
    //--------------- -------------- --------- images stuff ------------- -------------- --------- starts
    //----------------------------- COLLECTIONVIEW CODE -------------------------------- starts
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(pictures.count - 1 > 0){
            return pictures.count - 1
        }
        else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pictureCell", for: indexPath)
        let pictureView = UIImageView(frame: CGRect(x: 0, y: 0, width: collectionView.frame.width, height: collectionView.frame.height))
        
        //if((indexPath as NSIndexPath).row +1 >= 0){
            pictureView.image = pictures[(indexPath as NSIndexPath).row + 1]
        //}
        pictureView.contentMode = UIViewContentMode.scaleToFill
        cell.addSubview(pictureView)
        
        return cell
    }
    var picturesAtFront = false
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(!picturesAtFront){
            self.view.bringSubview(toFront: picturesCollectionView)
            collectionView.frame = self.view.frame
        }
        else{
            self.view.sendSubview(toBack: picturesCollectionView)
            collectionView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.width)
        }
        picturesAtFront = !picturesAtFront
        /*let imgView = UIImageView(frame: self.view.frame)
         imgView.image = pictures[indexPath.row]
         //imgView.
         view.addSubview(imgView)*/
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenHeight = self.view.frame.width
        let cellHeight =  self.view.frame.width
        return CGSize(width: cellHeight, height: cellHeight)
    }
    var downloadedPicturesCount = 1
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if(indexPath.row < Int((recie1.recie?._numberOfPictures)!) && downloadedPicturesCount < Int((recie1.recie?._numberOfPictures)!)){
            downloadedPicturesCount += 1
            getPictureFromDirectory(prefix: "public/\((recie1.recie?._name!)!)/", i: indexPath.row )
            
        }
    }
    
    //----------------------------- COLLECTIONVIEW CODE -------------------------------- ends
    
    func getPictureFromDirectory(prefix: String, i:Int){
        let imgCompletionHandler = {[weak self](content: AWSContent?, data: Data?, error: Error?) -> Void in
            guard self != nil else { return }
            if let error = error {
                print("Failed to download a content from a server. \(error)")
                return
            }
            print("Object download complete.")
            print("downloaded??")
                self?.pictures[i] = UIImage(data: data!)!
            DispatchQueue.main.async(execute: {
                
                self?.picturesCollectionView.reloadItems(at: [IndexPath(row: i, section: 0)])
            })
            print(content)
        }
        glblImageDownloadHandler.getPicture(prefix: prefix, imgCompletionHandler: imgCompletionHandler)
        
    }
    //--------------- -------------- --------- images stuff ------------- -------------- --------- ends
    
}
