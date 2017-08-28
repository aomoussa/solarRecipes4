//
//  homeViewController.swift
//  solaRecipes
//
//  Created by Ahmed Moussa on 11/09/16.
//  Copyright © 2016 Ahmed Moussa. All rights reserved.
//

import UIKit
import AWSDynamoDB
import AWSMobileHubHelper

class homeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    @IBOutlet weak var recipeCollectionView: UICollectionView!
    
    @IBOutlet weak var addRecipeButton: UIButton!
    @IBOutlet weak var addOvenButton: UIButton!
    @IBAction func addClicked(_ sender: UIButton) {
        addRecipeButton.alpha = 1
        addOvenButton.alpha = 1
    }
    
    let yellowColor = UIColor(red: 218/255, green: 205/255, blue: 0, alpha: 1)
    @IBOutlet weak var recipesButton: UIButton!
    @IBAction func recipesButtonClicked(_ sender: UIButton) {
        recipesButton.backgroundColor = yellowColor
        ovensButton.backgroundColor = UIColor.clear
        state = "recipes"
        recipeCollectionView.reloadData()
    }
    @IBOutlet weak var ovensButton: UIButton!
    
    @IBAction func ovensButtonClicked(_ sender: UIButton) {
        ovensButton.backgroundColor = yellowColor
        recipesButton.backgroundColor = UIColor.clear
        state = "ovens"
        recipeCollectionView.reloadData()
        if(oves.count == 0){
            getOvenData()
        }
    }
    
    
    
    //----------- ---------------- -------------- local variables ------------ ----------- ----------- start
    var recies = [recipe]()
    var oves = [oven]()
    var state = "recipes"//"ovens"
    
    var searchMode = false
    
    private var manager: AWSUserFileManager!
    //Users/ahmedmoussa/Desktop/solarRecipes2/solarRecipes2/Info.plist
    //----------- ---------------- -------------- local variables ------------ ----------- ----------- end
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addRecipeButton.alpha = 0
        addOvenButton.alpha = 0
        recipeCollectionView.delegate = self
        recipeCollectionView.dataSource = self
        addRefresherToCollectionView()
        setupSegmentedControls()
        setupTemperaturePickerViews()
        getRecipeData()
    }
    //---------- ----------- ---------- search stuff ----------- --------- ---------- ---------- starts
    @IBOutlet weak var keyTextField: UITextField!
    
    @IBOutlet weak var difficultySegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var durationSegmentedControl: UISegmentedControl!
    
    func setupSegmentedControls(){
        difficultySegmentedControl.setTitle("Any", forSegmentAt: 0)
        difficultySegmentedControl.setTitle("Hard", forSegmentAt: 1)
        difficultySegmentedControl.setTitle("Medium", forSegmentAt: 2)
        difficultySegmentedControl.setTitle("Easy", forSegmentAt: 3)
        
        durationSegmentedControl.setTitle("1 hr", forSegmentAt: 1)
        durationSegmentedControl.setTitle("2 hrs", forSegmentAt: 2)
        durationSegmentedControl.setTitle("3 hrs", forSegmentAt: 3)
        durationSegmentedControl.setTitle("4 hrs", forSegmentAt: 4)
        durationSegmentedControl.setTitle("5+ hrs", forSegmentAt: 5)
        
    }
    
    @IBOutlet weak var ovenTypePickerView: UIPickerView!
    let ovenTypes = ["Any", "parabolic", "box", "tube", "other"]
    
    @IBOutlet weak var fromTempPickerView: UIPickerView!
    @IBOutlet weak var toTempPickerView: UIPickerView!
    
    func setupTemperaturePickerViews(){
        ovenTypePickerView.delegate = self
        ovenTypePickerView.dataSource = self
        fromTempPickerView.delegate = self
        fromTempPickerView.dataSource = self
        toTempPickerView.delegate = self
        toTempPickerView.dataSource = self
        toTempPickerView.selectRow(25, inComponent: 0, animated: false)
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch(pickerView){
        case ovenTypePickerView:
            return ovenTypes.count
        default:
            return 26
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch(pickerView){
        case ovenTypePickerView:
            return ovenTypes[row]
        case fromTempPickerView:
            if(row != 0){
                return "\(row*20)F"
            }
            else{
                return "No min"
            }
        default:
            if(row != 25){
                return "\(row*20+10)F"
            }
            else{
                return "No max"
            }
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch(pickerView){
        case ovenTypePickerView:
            break
        case toTempPickerView:
            if(row < fromTempPickerView.selectedRow(inComponent: 0)){
                toTempPickerView.selectRow(fromTempPickerView.selectedRow(inComponent: 0), inComponent: 0, animated: true)
            }
        default:
            if(row > toTempPickerView.selectedRow(inComponent: 0)){
                toTempPickerView.selectRow(row, inComponent: 0, animated: true)
            }
        }
    }
    
    @IBAction func searchDoneTapped() {
        if(state == "ovens"){
            showAlertWithTitle(title: "Problem.", message: "Oven search is not yet implemented, sorry!")
            return
        }
        let fromTemp = fromTempPickerView.selectedRow(inComponent: 0)*20 as NSNumber
        let toTemp = toTempPickerView.selectedRow(inComponent: 0)*20 + 10 as NSNumber
        let diff = difficultySegmentedControl.selectedSegmentIndex  as NSNumber
        if(fromTempPickerView.selectedRow(inComponent: 0)>toTempPickerView.selectedRow(inComponent: 0)){
            showAlertWithTitle(title: "Try again", message: "from temperature has to be smaller than to temperature")
        }
        let dur = durationSegmentedControl.selectedSegmentIndex*60 as NSNumber
        addRefresherToCollectionView()
        getAdvancedScanRecipeData(keyword: keyTextField.text!, fromTemperature: fromTemp, toTemperature: toTemp, duration: dur, difficulty: diff)
    }
    //---------- ----------- ---------- search stuff ----------- --------- ---------- ---------- ends
    
    //---------- ----------- ---------- search mode activation and deactivation ---------- ---------- starts
    @IBAction func searchClicked(_ sender: UIButton) {
        if(searchMode){
            deactivateSearchMode()
        }
        else{
            activateSearchMode()
        }
    }
    func activateSearchMode(){
        switch(state){
        case "ovens":
            durationSegmentedControl.alpha = 0
            toTempPickerView.alpha = 0
            fromTempPickerView.alpha = 0
        default:
            durationSegmentedControl.alpha = 1
            toTempPickerView.alpha = 1
            fromTempPickerView.alpha = 1
        }
        let screenHeight = self.view.frame.height
        let screenWidth = self.view.frame.width
        self.recipeCollectionView.frame = CGRect(x: 0, y: screenHeight*0.5, width: screenWidth, height: screenHeight*0.4)
        searchMode = true
    }
    func deactivateSearchMode(){
        let screenHeight = self.view.frame.height
        let screenWidth = self.view.frame.width
        self.recipeCollectionView.frame = CGRect(x: 0, y: screenHeight*0.1, width: screenWidth, height: screenHeight*0.8)
        searchMode = false
        self.view.endEditing(true)
    }
    //---------- ----------- ---------- search mode activation and deactivation ---------- ---------- ends
    
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
    
    func makeOvenCell(indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ovenCell", for: indexPath) as! ovenCollectionViewCell
        if(indexPath.row < oves.count){
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
            self.performSegue(withIdentifier: "toOvenDetails", sender: oves[indexPath.row])
        default:
            self.performSegue(withIdentifier: "toRecipeDetails", sender: recies[indexPath.row])
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toRecipeDetails"){
            let destVC = segue.destination as! recipeDetailsViewController
            destVC.recie1 = (sender as? recipe)!
        }
        else if(segue.identifier == "toOvenDetails"){
            let destVC = segue.destination as! ovenDetailsViewController
            destVC.oven1 = (sender as? oven)!
            //print(destVC.oven1._id!)
        }
    }
    //----------------------------- COLLECTIONVIEW CODE -------------------------------- ends
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
        refresher.addTarget(self, action: #selector(homeViewController.refresherReload(_:)), for: UIControlEvents.valueChanged)
        recipeCollectionView.addSubview(refresher)
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
                    self.recipeCollectionView.reloadData()
                    sender.endRefreshing()
                })
            }
        }
        glblQueryHandler.queryRecipeData(completionHandler: completionHandler)
        /*
         self.recipeCollectionView.performBatchUpdates({
         glblQueryHandler.queryRecipeData(completionHandler: completionHandler)
         }) { (completed) in
         DispatchQueue.main.async(execute: {
         self.recipeCollectionView.reloadData()
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
                self.showAlertWithTitle(title: "Not Found", message: "No items match your criteria. Insert more sample data and try again.")
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
                    self.recipeCollectionView.reloadData()
                    x.removeFromSuperview()
                })
            }
        }
        glblQueryHandler.queryOvenData(completionHandler: completionHandler)
    }
    func getRecipeData(){
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
                self.showAlertWithTitle(title: "Not Found", message: "No items match your criteria. Insert more sample data and try again.")
                x.removeFromSuperview()
            }
            else {
                //it all worked out:
                let paginatedOutput = response as? AWSDynamoDBPaginatedOutput!
                
                
                for item in paginatedOutput?.items as! [DBRecipe] {
                    let newRecie = recipe(recip: item)
                    self.recies.append(newRecie)
                    print(self.recies)
                }
                DispatchQueue.main.async(execute: {
                    self.recipeCollectionView.reloadData()
                    x.removeFromSuperview()
                })
            }
        }
        glblQueryHandler.queryRecipeData(completionHandler: completionHandler)
    }
    func getAdvancedScanRecipeData(keyword: String, fromTemperature: NSNumber, toTemperature: NSNumber, duration: NSNumber, difficulty: NSNumber){
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
                self.showAlertWithTitle(title: "Not Found", message: "No items match your criteria. Insert more sample data and try again.")
                x.removeFromSuperview()
            }
            else {
                //it all worked out:
                let paginatedOutput = response as? AWSDynamoDBPaginatedOutput!
                
                
                for item in paginatedOutput?.items as! [DBRecipe] {
                    let newRecie = recipe(recip: item)
                    self.recies.append(newRecie)
                    print(self.recies)
                }
                DispatchQueue.main.async(execute: {
                    self.recipeCollectionView.reloadData()
                    //self.deactivateSearchMode()
                    x.removeFromSuperview()
                })
            }
        }
        
        if(keyword == ""){
            glblQueryHandler.advancedScanNoFilterName(fromTemperature: fromTemperature, toTemperature: toTemperature, duration: duration, difficulty: difficulty, completionHandler: completionHandler)
        }
        else{
        glblQueryHandler.advancedScan(filterName: keyword, fromTemperature: fromTemperature, toTemperature: toTemperature, duration: duration, difficulty: difficulty, completionHandler: completionHandler)
        }
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
                
                self?.recipeCollectionView.reloadItems(at: [IndexPath(row: i, section: 0)])
            })
            print(content)
        }
        glblImageDownloadHandler.getPicture(prefix: prefix, imgCompletionHandler: imgCompletionHandler)
        
    }
    func showAlertWithTitle(title: String, message: String) {
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        let reloadAction: UIAlertAction = UIAlertAction(title: "Reload", style: .default, handler: {alertController in self.getRecipeData()})
        alertController.addAction(cancelAction)
        alertController.addAction(reloadAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
