//
//  ovenDetailsViewController.swift
//  solarRecipes2
//
//  Created by Ahmed Moussa on 6/14/17.
//  Copyright © 2017 Ahmed Moussa. All rights reserved.
//

import UIKit
import FacebookCore
import AWSCore
import AWSDynamoDB


class ovenDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate {
    
    var oven1 = oven()
    
    var pictures = [UIImage]()
    @IBOutlet weak var picturesCollectionView: UICollectionView!
    
    @IBOutlet weak var partsStepsTableView: UITableView!
    
    @IBOutlet weak var ovenTitleLabel: UILabel!
    
    @IBOutlet weak var ovenTypeLabel: UILabel!
    
    @IBOutlet weak var creatorNameLabel: UILabel!
    
    @IBOutlet weak var difficultyLabel: UILabel!
    
    /*
     @IBOutlet weak var durationLabel: UILabel!
     @IBOutlet weak var toDurationLabel: UILabel!
     
     @IBOutlet weak var temperatureLabel: UILabel!
     @IBOutlet weak var toTemperatureLabel: UILabel!
     */
    
    @IBOutlet weak var partsButton: UIButton!
    
    @IBOutlet weak var stepsButton: UIButton!
    
    @IBOutlet weak var commentsButton: UIButton!
    
    var tableViewState = "parts"//"steps" "comments"
    let yellowColor = UIColor(red: 218/255, green: 205/255, blue: 0, alpha: 1)
    let redColor = UIColor(red: 255/255, green: 86/255, blue: 87/255, alpha: 1)//255 86 87
    
    @IBAction func partsClicked(_ sender: UIButton) {
        partsButton.backgroundColor = yellowColor
        stepsButton.backgroundColor = redColor
        commentsButton.backgroundColor = redColor
        tableViewState = "parts"
        partsStepsTableView.reloadData()
    }
    
    @IBAction func stepsClicked(_ sender: UIButton) {
        partsButton.backgroundColor = redColor
        stepsButton.backgroundColor = yellowColor
        commentsButton.backgroundColor = redColor
        tableViewState = "steps"
        partsStepsTableView.reloadData()
    }
    
    @IBAction func commentsClicked(_ sender: UIButton) {
        partsButton.backgroundColor = redColor
        stepsButton.backgroundColor = redColor
        commentsButton.backgroundColor = yellowColor
        tableViewState = "comments"
        partsStepsTableView.reloadData()
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setOvenStuff(oven1: oven1)
        partsStepsTableView.delegate = self
        partsStepsTableView.dataSource = self
        
        picturesCollectionView.delegate = self
        picturesCollectionView.dataSource = self
        
    }
    func setOvenStuff(oven1: oven){
        if(oven1.picures.count > 1){
            pictures = oven1.picures
        }
        ovenTitleLabel.text = oven1.ove?._name
        ovenTypeLabel.text = "A \((oven1.ove?._ovenType)!) Oven"
        creatorNameLabel.text = "By \((oven1.ove?._creatorName)!)"
        let difficulties = ["Hard","Medium","Easy"]
        difficultyLabel.text = difficulties[Int((oven1.ove?._difficulty!)!) - 1]
        
        /*durationLabel.text = "\(String(describing: (oven1.ove?._duration)!))"
         toDurationLabel.text = "\(String(describing: (oven1.ove?._toDuration)!))min"
         temperatureLabel.text = "\(String(describing: (oven1.ove?._temperature)!))"
         toTemperatureLabel.text = "\(String(describing: (oven1.ove?._toTemperature)!))F"
         */
        steps = [String]((oven1.ove?._steps)!)
        parts = [String]((oven1.ove?._parts)!)
        parts.sort()
        steps.sort()
        parts = sortAndClipList(list: parts)
        steps = sortAndClipList(list: steps)
        //comments = ["cool story bro"]//[String]((oven1.ove?._comments)!)
        getCommentsForID(id: (oven1.ove?._id)!)
    }
    func getCommentsForID(id: String){
        self.comments.removeAll()
        let x = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        x.center = self.partsStepsTableView.center
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
                        self.partsStepsTableView.reloadData()
                    }
                    x.removeFromSuperview()
                })
            }
        }
        glblQueryHandler.scanCommentsByID(aboutID: id, completionHandler: completionHandler)
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
    var parts = ["parts"]
    var steps = ["steps"]
    var comments = [Comments]()
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(tableViewState){
        case "parts":
            return parts.count
        case "steps":
            return steps.count
        case "comments":
            return comments.count + 1
        default:
            return 1
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch(tableViewState){
        case "steps":
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
        comment?._aboutID = (oven1.ove?._id)!
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
                self.getCommentsForID(id: (self.oven1.ove?._id)!)
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
        
        cell?.ingredientTitleLabel?.text = "\( parts[row])"
        
        return cell!
    }
    func makeInstructionDisplayCell(tableView: UITableView, row: Int) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "stepDisplayCell") as! newStepTableViewCell!
        
        cell?.titleLabel.text = "Step \(row + 1)"
        cell?.contentTextView.text = steps[row]
        cell?.contentTextView.isEditable = false
        cell?.editButton.alpha = 0
        cell?.deleteButton.alpha = 0
        
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch(tableViewState){
        case "parts":
            return 50
            break
        default:
            return 100
        }
    }
    //--------------- -------------- --------- tableView (ing/ins) stuff ------------- -------------- --------- ends
    //--------------- -------------- --------- images stuff ------------- -------------- --------- starts
    //----------------------------- COLLECTIONVIEW CODE -------------------------------- starts
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(pictures.count - 1 >= 0){
            return pictures.count - 1
        }
        else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pictureCell", for: indexPath)
        let pictureView = UIImageView(frame: CGRect(x: 0, y: 0, width: collectionView.frame.width, height: collectionView.frame.height))
        
        //if((indexPath as NSIndexPath).row - 1 >= 0){
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
    
    //----------------------------- COLLECTIONVIEW CODE -------------------------------- ends
    //--------------- -------------- --------- images stuff ------------- -------------- --------- ends
    
}
