//
//  addOvenViewController.swift
//  solarRecipes2
//
//  Created by Ahmed Moussa on 5/20/17.
//  Copyright © 2017 Ahmed Moussa. All rights reserved.
//

import UIKit

class addOvenViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    var state = "new"//"edit"
    var ovenToEdit = oven()
    var nameString = "enter title here"
    var descString = "enter description here"
    //var duration = 10
    var pictures = [UIImage]()
    
    @IBOutlet weak var stateTitleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var difficultySegmentedView: UISegmentedControl!
    
    //@IBOutlet weak var temperaturePickerView: UIPickerView!
    
    //@IBOutlet weak var toTemperaturePickerView: UIPickerView!
    
    //@IBOutlet weak var durationPicker: UIDatePicker!
    //@IBOutlet weak var toDurationPicker: UIDatePicker!
    
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    @IBOutlet weak var partsAndstepsTableView: UITableView!
    
    @IBOutlet weak var stepsButton: UIButton!
    
    @IBOutlet weak var partsButton: UIButton!
    
    @IBOutlet weak var ovenTypePicker: UIPickerView!
    
    
    var cellHeight = 100
    var tableViewState = "parts"//"steps"
    let yellowColor = UIColor(red: 218/255, green: 205/255, blue: 0, alpha: 1)
    let maroonColor = UIColor(red: 167/255, green: 49/255, blue: 46/255, alpha: 1)
    
    @IBAction func partsButtonTapped(_ sender: UIButton) {
        activeTextView.resignFirstResponder()
        partsButton.backgroundColor = yellowColor
        stepsButton.backgroundColor = maroonColor
        tableViewState = "parts"
        partsAndstepsTableView.reloadData()
    }
    
    @IBAction func stepsButtonTapped(_ sender: UIButton) {
        activeTextView.resignFirstResponder()
        partsButton.backgroundColor = maroonColor
        stepsButton.backgroundColor = yellowColor
        tableViewState = "steps"
        partsAndstepsTableView.reloadData()
    }
    
    @IBAction func submitButtonTapped() {
        steps = orderList(list: steps)
        parts = orderList(list: parts)
        
        let id = "12"
        let name = nameTextField.text!
        let stps = steps
        //let temp = temperatures[temperaturePickerView.selectedRow(inComponent: 0)] as NSNumber
        //let dur = Int(durationPicker.countDownDuration)/60 as NSNumber
        //let toTemp = temperatures[toTemperaturePickerView.selectedRow(inComponent: 0)] as NSNumber
        //let toDur = Int(toDurationPicker.countDownDuration)/60 as NSNumber
        let diff = difficultySegmentedView.selectedSegmentIndex + 1 as NSNumber
        let fbid = "sample person's fbid"
        let crtrName = "sample person's name"
        let picsCnt = pictures.count
        let prts = parts
        let tmstmp = String(NSDate().timeIntervalSince1970)
        let ovenType = ovenTypes[ovenTypePicker.selectedRow(inComponent: 0)] as String
        
        let newOven = oven(id: id, name: name, steps: stps, difficulty: diff, creatorFBID: fbid, creatorName: crtrName, numOfPics: picsCnt, parts: prts, tmstmp: tmstmp, ovenType: ovenType)
        glblQueryHandler.getFBProfileAndUploadOvenAndPics(oven: newOven, pictures: pictures)
        //let newRecie = recipe(id: id, name: name, insts: insts, desc: desc, temp: temp, dur: dur, toTemp: toTemp, toDur: toDur, difficulty: diff, creatorFBID: fbid, creatorName: crtrName, numOfPics: picsCnt, parts: ingrdnts, tmstmp: tmstmp, ovenType: ovenType)
        //print("new recipe to submit looks like this: \n name: \(name) \ndesc: \(desc)\ndifficulty: \(diff)\ntemperature:\(temp)\nduration:\(newRecie.recie?._duration)\n")
        //glblQueryHandler.getFBProfileAndUploadRecipeAndPics(recipe: newRecie, pictures: pictures)
    }/*
     func dismissKeyboard(){
     view.endEditing(true)
     }*/
    override func viewDidLoad() {
        super.viewDidLoad()
        //let tap = UIGestureRecognizer(target: self, action: #selector(addRecipeViewController.dismissKeyboard))
        //view.addGestureRecognizer(tap)
        
        ovenTypePicker.delegate = self
        ovenTypePicker.dataSource = self
        /*toTemperaturePickerView.delegate = self
         toTemperaturePickerView.dataSource = self
         temperaturePickerView.delegate = self
         temperaturePickerView.dataSource = self
         */
        imagesCollectionView.delegate = self
        imagesCollectionView.dataSource = self
        partsAndstepsTableView.delegate = self
        partsAndstepsTableView.dataSource = self
        partsAndstepsTableView.isEditing = true
        setupSegmentedControls()
        if(state == "edit"){
            fillEverythingOut()
            stateTitleLabel.text = "Edit Oven"
        }
    }
    func fillEverythingOut(){
        self.nameTextField.text = ovenToEdit.ove?._name
        self.pictures = ovenToEdit.picures
        self.steps = [String]((ovenToEdit.ove?._steps!)!)
        self.parts = [String]((ovenToEdit.ove?._parts!)!)
        
        self.ovenTypePicker.selectRow(ovenToEdit.ove?._difficulty as! Int, inComponent: 0, animated: false)
        var index = 0
        while(index < ovenTypes.count){
            if(ovenTypes[index] == ovenToEdit.ove?._ovenType){
                break
            }
            index += 1
        }
        self.ovenTypePicker.selectRow(index, inComponent: 0, animated: false)
    }
    override func viewDidLayoutSubviews() {
        //scrollView.contentOffset = CGPoint.init(x: 0, y: 0)
        //scrollView.frame = view.frame
        
        cellHeight = Int(Double(self.view.frame.height)*0.1)
        let width = self.view.frame.width
        
        var y = ovenTypePicker.frame.minY
        imagesCollectionView.frame = CGRect(x: 0, y: y, width: width/2, height: width/2)
        
        /*
        y = imagesCollectionView.frame.maxY
        stepsButton.frame = CGRect(x: stepsButton.frame.minX, y: y, width: stepsButton.frame.width, height: stepsButton.frame.height)
        partsButton.frame = CGRect(x: partsButton.frame.minX, y: y, width: partsButton.frame.width, height: partsButton.frame.height)
        */
        y = stepsButton.frame.maxY
        partsAndstepsTableView.frame = CGRect(x: 0, y: y, width: width, height: 500)
        //y = durationPicker.frame.maxY + 20
        scrollView.contentSize = CGSize(width: view.frame.width, height: 2*view.frame.height)
        scrollView.isScrollEnabled = true
    }
    let difficulties = ["Hard", "Medium", "Easy"]
    func setupSegmentedControls(){
        difficultySegmentedView.setTitle("Hard", forSegmentAt: 0)
        difficultySegmentedView.setTitle("Medium", forSegmentAt: 1)
        difficultySegmentedView.setTitle("Easy", forSegmentAt: 2)
        
    }
    //---------- ----------- ----------- ---------- pickerView stuff ---------- ------------ ----------- -------- starts
    let ovenTypes = ["parabolic", "box", "panel", "tube", "other"]
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ovenTypes.count
        
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ovenTypes[row]
        
    }
    //---------- ----------- ----------- ---------- pickerView stuff ---------- ------------ ----------- -------- ends
    
    //--------------- -------------- --------- images stuff ------------- -------------- --------- starts
    //----------------------------- COLLECTIONVIEW CODE -------------------------------- starts
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictures.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let screenHeight = self.view.frame.height
        let cellHeight =  screenHeight/3
        let screenWidth = self.view.frame.width
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pictureCell", for: indexPath)
        let pictureView = UIImageView(frame: CGRect(x: 0, y: 0, width: (screenHeight/4)*0.9, height: (screenHeight/4)*0.9))
        if((indexPath as NSIndexPath).row == 0){
            pictureView.image = UIImage(named: "addImage.jpg")
        }
        else{
            pictureView.image = pictures[(indexPath as NSIndexPath).row - 1]
        }
        pictureView.contentMode = UIViewContentMode.scaleToFill
        cell.addSubview(pictureView)
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if((indexPath as NSIndexPath).row == 0){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenHeight = self.view.frame.height
        let cellHeight =  (screenHeight/4)*0.9
        return CGSize(width: cellHeight, height: cellHeight)
    }
    
    //----------------------------- COLLECTIONVIEW CODE -------------------------------- ends
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        //addPictureButton.setBackgroundImage(image, forState: UIControlState.Normal)
        pictures.append(image)
        //uploadProgresses.append(0.0)
        self.dismiss(animated: true, completion: nil)
        let ind = IndexPath(row: 1, section: 0)
        imagesCollectionView.reloadData()
        //recipeDataTableView.reloadData()// (, withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    //--------------- -------------- --------- images stuff ------------- -------------- --------- ends
    //--------------- -------------- --------- tableView (ing/ins) stuff ------------- -------------- --------- begins
    var parts = ["New Part"]
    var steps = ["New Step"]
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(tableViewState){
        case "parts":
            return parts.count
        case "steps":
            return steps.count
        default:
            return 1
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return makeStepCell(row: indexPath.row, tableView: tableView)
    }
    func makeStepCell(row: Int, tableView: UITableView) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "editCell") as! newStepTableViewCell!
        
        cell?.contentTextView.delegate = self
        cell?.contentTextView.tag = row
        cell?.editButton.alpha = 0
        cell?.deleteButton.addTarget(self, action: #selector(self.cellDeleteClicked(sender:)), for: UIControlEvents.touchUpInside)
        cell?.deleteButton.tag = row
        switch(tableViewState){
        case "parts":
            var tempString = parts[row]
            if(tempString == "New Part"){
                cell?.contentTextView.textColor = UIColor.lightGray
            }
            cell?.contentTextView.text = tempString
            cell?.titleLabel.text = "Part \(row + 1)"
            
        default:
            var tempString = steps[row]
            if(tempString == "New Step"){
                cell?.contentTextView.textColor = UIColor.lightGray
            }
            cell?.contentTextView.text = tempString
            cell?.titleLabel.text = "Step \(row + 1)"
        }
        cell?.backgroundColor = UIColor.lightGray
        return cell!
    }
    func cellDeleteClicked(sender: UIButton){
        if(activeTextView.isFirstResponder){
            activeTextView.resignFirstResponder()
        }
        switch(tableViewState){
        case "steps":
            steps.remove(at: sender.tag)
        default:
            parts.remove(at: sender.tag)
            
        }
        partsAndstepsTableView.reloadData()
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if(activeTextView.isFirstResponder){
            activeTextView.resignFirstResponder()
        }
        
        switch(tableViewState){
        case "parts":
            if(sourceIndexPath.row != parts.count - 1 && destinationIndexPath.row != parts.count - 1){
                let temp = parts[sourceIndexPath.row]
                parts.remove(at: sourceIndexPath.row)
                parts.insert(temp, at: destinationIndexPath.row)
            }
            //parts = orderList(list: parts)
            break
        default:
            if(sourceIndexPath.row != steps.count - 1 && destinationIndexPath.row != steps.count - 1){
                let temp = steps[sourceIndexPath.row]
                steps.remove(at: sourceIndexPath.row)
                steps.insert(temp, at: destinationIndexPath.row)
                //steps = orderList(list: steps)
            }
        }
        tableView.reloadData()
    }
    func orderList(list: [String]) -> [String]{
        var newList = list
        var i = 0
        while(i<list.count){
            newList[i] = "\(newList[i]) \(String(format: "%02d", i))"
            i += 1
        }
        return newList
    }
    var activeTextView = UITextView()
    func textViewDidBeginEditing(_ textView: UITextView) {
        // if(activeTextView != nil){
        //    activeTextView.resignFirstResponder()
        // }
        //self.view.keyboa
        activeTextView = textView
        if(textView.textColor == UIColor.lightGray){
            textView.text = ""
            textView.textColor = UIColor.black
        }
        //textView.becomeFirstResponder()
        var offsetPastTableView = 0
        switch(tableViewState){
        case "parts":
            if(textView.tag == parts.count - 1){
                parts.append("New Part")
                if(parts.count>3){
                    offsetPastTableView = 2*cellHeight
                }
                if(parts.count > 5){
                    partsAndstepsTableView.contentOffset.y = CGFloat(parts.count*cellHeight)
                }
                partsAndstepsTableView.reloadData()
                textView.becomeFirstResponder()
            }
            break
        default:
            if(steps.count>3){
                offsetPastTableView = 2*cellHeight
            }
            if(textView.tag == steps.count - 1){
                steps.append("New Step")
                if(steps.count > 5){
                    partsAndstepsTableView.contentOffset.y = CGFloat(steps.count*cellHeight)
                }
                partsAndstepsTableView.reloadData()
                textView.becomeFirstResponder()
            }
        }
        scrollView.contentOffset.y = stepsButton.frame.minY + CGFloat(offsetPastTableView)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(cellHeight)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        
        switch(tableViewState){
        case "parts":
            parts[textView.tag] = textView.text
        default:
            
            steps[textView.tag] = textView.text
        }
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    //--------------- -------------- --------- tableView (ing/ins) stuff ------------- -------------- --------- ends
    
    
}
