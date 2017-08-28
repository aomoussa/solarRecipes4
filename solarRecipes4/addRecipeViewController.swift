//
//  addRecipeViewController.swift
//  solarRecipes2
//
//  Created by Ahmed Moussa on 3/8/17.
//  Copyright © 2017 Ahmed Moussa. All rights reserved.
//

import UIKit

class addRecipeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    var nameString = "enter title here"
    var descString = "enter description here"
    //var duration = 10
    var pictures = [UIImage]()
    
    var state = "new"//"edit"
    @IBOutlet weak var stateTitleLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var difficultySegmentedView: UISegmentedControl!
    
    @IBOutlet weak var temperaturePickerView: UIPickerView!
    
    @IBOutlet weak var toTemperaturePickerView: UIPickerView!
    
    @IBOutlet weak var durationPicker: UIDatePicker!
    @IBOutlet weak var toDurationPicker: UIDatePicker!
    
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    @IBOutlet weak var ingredientsAndInstructionsTableView: UITableView!
    
    @IBOutlet weak var instructionsButton: UIButton!
    
    @IBOutlet weak var ingredientsButton: UIButton!
    
    @IBOutlet weak var ovenTypePicker: UIPickerView!
    
    var tableViewState = "ingredients"//"instructions"
    let yellowColor = UIColor(red: 218/255, green: 205/255, blue: 0, alpha: 1)
    
    
    
    
    @IBAction func ingredientsButtonTapped() {
        activeTextView.resignFirstResponder()
        ingredientsButton.backgroundColor = yellowColor
        instructionsButton.backgroundColor = UIColor.clear
        tableViewState = "ingredients"
        ingredientsAndInstructionsTableView.reloadData()
    }
    
    @IBAction func instructionsButtonTapped(_ sender: UIButton) {
        activeTextView.resignFirstResponder()
        ingredientsButton.backgroundColor = UIColor.clear
        instructionsButton.backgroundColor = yellowColor
        tableViewState = "instructions"
        ingredientsAndInstructionsTableView.reloadData()
    }
    
    @IBAction func submitButtonTapped() {
        instructions = orderList(list: instructions)
        ingredients = orderList(list: ingredients)
        let id = "12"
        let name = nameTextField.text!
        let insts = instructions
        let temp = temperatures[temperaturePickerView.selectedRow(inComponent: 0)] as NSNumber
        let dur = Int(durationPicker.countDownDuration)/60 as NSNumber
        
        let toTemp = temperatures[toTemperaturePickerView.selectedRow(inComponent: 0)] as NSNumber
        let toDur = Int(toDurationPicker.countDownDuration)/60 as NSNumber
        let diff = difficultySegmentedView.selectedSegmentIndex + 1 as NSNumber
        let fbid = "sample person's fbid"
        let crtrName = "sample person's name"
        let picsCnt = pictures.count
        let ingrdnts = ingredients
        let tmstmp = String(NSDate().timeIntervalSince1970)
        let ovenType = ovenTypes[ovenTypePicker.selectedRow(inComponent: 0)] as String
        
        let newRecie = recipe(id: id, name: name, insts: insts, desc: "no more", temp: temp, dur: dur, toTemp: toTemp, toDur: toDur, difficulty: diff, creatorFBID: fbid, creatorName: crtrName, numOfPics: picsCnt, ingredients: ingrdnts, tmstmp: tmstmp, ovenType: ovenType)
        print("new recipe to submit looks like this: \n name: \(name) \ndifficulty: \(diff)\ntemperature:\(temp)\nduration:\(newRecie.recie?._duration)\n")
        glblQueryHandler.getFBProfileAndUploadRecipeAndPics(recipe: newRecie, pictures: pictures)
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
        toTemperaturePickerView.delegate = self
        toTemperaturePickerView.dataSource = self
        temperaturePickerView.delegate = self
        temperaturePickerView.dataSource = self
        imagesCollectionView.delegate = self
        imagesCollectionView.dataSource = self
        ingredientsAndInstructionsTableView.delegate = self
        ingredientsAndInstructionsTableView.dataSource = self
        ingredientsAndInstructionsTableView.isEditing = true
        setupSegmentedControls()
        if(state == "edit"){
            fillEverythingOut()
            stateTitleLabel.text = "Edit Oven"
        }
    }
    func fillEverythingOut(){
        /*
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
        self.ovenTypePicker.selectRow(index, inComponent: 0, animated: false)*/
    }
    override func viewDidLayoutSubviews() {
        //scrollView.contentOffset = CGPoint.init(x: 0, y: 0)
        //scrollView.frame = view.frame
        var y = ingredientsButton.frame.maxY
        let width = self.view.frame.width
        ingredientsAndInstructionsTableView.frame = CGRect(x: 0, y: y, width: width, height: 500)
        y = durationPicker.frame.maxY + 20
        imagesCollectionView.frame = CGRect(x: 0, y: y, width: width/2, height: 200)
        scrollView.contentSize = CGSize(width: view.frame.width, height: 2*view.frame.height)
        scrollView.isScrollEnabled = true
    }
    func setupSegmentedControls(){
        difficultySegmentedView.setTitle("Hard", forSegmentAt: 0)
        difficultySegmentedView.setTitle("Medium", forSegmentAt: 1)
        difficultySegmentedView.setTitle("Easy", forSegmentAt: 2)
        
    }
    
    //---------- ----------- ----------- ---------- duration picker stuff ---------- ------------ ----------- -------- starts
    @IBAction func durationPickerChanged(_ sender: UIDatePicker) {
        if(sender.countDownDuration > toDurationPicker.countDownDuration){
            toDurationPicker.setDate(sender.date, animated: true)
        }
    }
    @IBAction func toDurationPickerChanged(_ sender: UIDatePicker) {
        if(sender.countDownDuration < durationPicker.countDownDuration){
            sender.setDate(durationPicker.date, animated: true)
        }
    }
    
    //---------- ----------- ----------- ---------- duration picker stuff ---------- ------------ ----------- -------- ends
    
    //---------- ----------- ----------- ---------- pickerView stuff ---------- ------------ ----------- -------- starts
    let temperatures = [20,40,60,80,100,120,140,160,180,200,220,240,260,280,300,320,340,360,380,400,420,440,460,480,500]
    let ovenTypes = ["parabolic", "box", "tube", "other"]
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch(pickerView){
        case ovenTypePicker:
            return ovenTypes.count
        default:
            return temperatures.count
            
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch(pickerView){
        case ovenTypePicker:
            return ovenTypes[row]
        default:
            return "\(temperatures[row])"
            
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch(pickerView){
        case toTemperaturePickerView:
            if(row < temperaturePickerView.selectedRow(inComponent: 0)){
                toTemperaturePickerView.selectRow(temperaturePickerView.selectedRow(inComponent: 0), inComponent: 0, animated: true)
            }
        default:
            if(row > toTemperaturePickerView.selectedRow(inComponent: 0)){
                toTemperaturePickerView.selectRow(row, inComponent: 0, animated: true)
            }
        }
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
    var ingredients = ["new ingredient"]
    var instructions = ["new instruction"]
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(tableViewState){
        case "ingredients":
            return ingredients.count
        case "instructions":
            return instructions.count
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
        //cell?.contentTextView.placeHo
        //cell?.editButton.addTarget(self, action: #selector(self.cellEditClicked(sender:)), for: UIControlEvents.touchUpInside)
        cell?.editButton.alpha = 0
        cell?.deleteButton.addTarget(self, action: #selector(self.cellDeleteClicked(sender:)), for: UIControlEvents.touchUpInside)
        cell?.deleteButton.tag = row
        
        
        /*if(ingredientsAndInstructionsTableView.isEditing){
         cell?.editButton.titleLabel?.text = "Done"
         cell?.editButton.backgroundColor = UIColor.darkGray
         }
         else{
         cell?.editButton.titleLabel?.text = "Edit"
         cell?.editButton.backgroundColor = UIColor.clear
         }*/
        switch(tableViewState){
        case "ingredients":
            var tempString = ingredients[row]
            if(tempString == "new ingredient"){
                cell?.contentTextView.textColor = UIColor.lightGray
            }
            //tempString.characters.removeFirst()
            cell?.contentTextView.text = tempString
            cell?.titleLabel.text = "ingr. \(row + 1)"
            
        default:
            var tempString = instructions[row]
            if(tempString == "new instruction"){
                cell?.contentTextView.textColor = UIColor.lightGray
            }
            //tempString.characters.removeFirst()
            cell?.contentTextView.text = tempString
            cell?.titleLabel.text = "step \(row + 1)"
        }
        //if(row%2 != 0){
        cell?.backgroundColor = UIColor.lightGray
        //}
        
        return cell!
    }
    /*
     func cellEditClicked(sender: UIButton){
     ingredientsAndInstructionsTableView.isEditing = !ingredientsAndInstructionsTableView.isEditing //setEditing(true, animated: true)
     ingredientsAndInstructionsTableView.reloadData()
     }*/
    
    func cellDeleteClicked(sender: UIButton){
        if(activeTextView.isFirstResponder){
            activeTextView.resignFirstResponder()
        }
        switch(tableViewState){
        case "instructions":
            instructions.remove(at: sender.tag)
        default:
            ingredients.remove(at: sender.tag)
            
        }
        ingredientsAndInstructionsTableView.reloadData()
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
        case "ingredients":
            if(sourceIndexPath.row != ingredients.count - 1 && destinationIndexPath.row != ingredients.count - 1){
                let temp = ingredients[sourceIndexPath.row]
                ingredients.remove(at: sourceIndexPath.row)
                ingredients.insert(temp, at: destinationIndexPath.row)
            }
            //ingredients = orderList(list: ingredients)
            break
        default:
            if(sourceIndexPath.row != instructions.count - 1 && destinationIndexPath.row != instructions.count - 1){
                let temp = instructions[sourceIndexPath.row]
                instructions.remove(at: sourceIndexPath.row)
                instructions.insert(temp, at: destinationIndexPath.row)
                //instructions = orderList(list: instructions)
            }
        }
        tableView.reloadData()
    }
    func orderList(list: [String]) -> [String]{
        var newList = list
        var i = 0
        while(i<list.count){
            //newList[i].remove(at: newList[i].index(before: newList[i].endIndex)) //characters.count - 1)
            //newList[i].remove(at: newList[i].index(before: newList[i].endIndex))
            //let indexTo = newList[i].index(newList[i].endIndex, offsetBy: -2)
            //newList[i] = String(newList[i].characters.dropLast(2)) // .substring(to: indexTo)
            
            newList[i] = "\(newList[i]) \(String(format: "%02d", i))"
            
            i += 1
        }
        return newList
    }
    let cellHeight = 100
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(cellHeight)
    }
    var activeTextView = UITextView()
    func textViewDidBeginEditing(_ textView: UITextView) {
        // if(activeTextView != nil){
        //    activeTextView.resignFirstResponder()
        // }
        
        activeTextView = textView
        if(textView.textColor == UIColor.lightGray){
            textView.text = ""
            textView.textColor = UIColor.black
        }
        //textView.becomeFirstResponder()
        var offsetPastTableView = 0
        switch(tableViewState){
        case "ingredients":
            if(textView.tag == ingredients.count - 1){
                ingredients.append("new ingredient")
                if(ingredients.count>3){
                    offsetPastTableView = 2*cellHeight
                }
                if(ingredients.count > 5){
                    ingredientsAndInstructionsTableView.contentOffset.y = CGFloat(ingredients.count*cellHeight)
                }
                ingredientsAndInstructionsTableView.reloadData()
                textView.becomeFirstResponder()
            }
            break
        default:
            if(instructions.count>3){
                offsetPastTableView = 2*cellHeight
            }
            if(textView.tag == instructions.count - 1){
                instructions.append("new instruction")
                if(instructions.count > 5){
                    ingredientsAndInstructionsTableView.contentOffset.y = CGFloat(instructions.count*cellHeight)
                }
                ingredientsAndInstructionsTableView.reloadData()
                textView.becomeFirstResponder()
            }
        }
        scrollView.contentOffset.y = instructionsButton.frame.minY + CGFloat(offsetPastTableView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        switch(tableViewState){
        case "ingredients":
            ingredients[textView.tag] = "\(textView.text!)"// \(String(format: "%02d", textView.tag))"
        default:
            
            instructions[textView.tag] = "\(textView.text!)"// \(String(format: "%02d", textView.tag))"
        }
    }
    
    //--------------- -------------- --------- tableView (ing/ins) stuff ------------- -------------- --------- ends
    
    
}
