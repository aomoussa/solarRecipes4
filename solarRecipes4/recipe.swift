//
//  recipe.swift
//  solarRecipes2
//
//  Created by Ahmed Moussa on 11/9/16.
//  Copyright © 2016 Ahmed Moussa. All rights reserved.
//

import Foundation
import UIKit
import AWSDynamoDB

class recipe {
    var creatorPP = UIImage(named: "plus.jpg")
    var picures = [UIImage]()
    var recie = DBRecipe()
    
    init(id: String, name: String, insts: [String], desc: String, temp: NSNumber, dur: NSNumber, toTemp: NSNumber, toDur: NSNumber, difficulty: NSNumber, creatorFBID: String, creatorName: String, numOfPics: Int, ingredients: [String], tmstmp: String, ovenType: String){
        recie?._id = id
        recie?._name = name
        recie?._instructions = Set<String>(insts)
        recie?._description = desc
        recie?._temperature = temp
        recie?._duration = dur
        recie?._toTemperature = toTemp
        recie?._toDuration = toDur
        recie?._creatorFBID = creatorFBID
        recie?._creatorName = creatorName
        recie?._numberOfPictures = numOfPics as NSNumber
        recie?._ingredients = Set<String>(ingredients)
        recie?._timestamp = tmstmp
        recie?._difficulty = difficulty
        recie?._comments = Set<String>(["Hey nice recipe!"])
        recie?._ovenType = ovenType
        
    }
    init(recip: DBRecipe){
        recie = recip
    }
    
    init(){
        recie?._id = ""
        recie?._name = ""
        recie?._instructions = [""]
        recie?._ingredients = [""]
        recie?._description = ""
        recie?._temperature = 0 as NSNumber
        recie?._duration = 0 as NSNumber
        recie?._creatorFBID = ""
        recie?._creatorName = ""
        recie?._numberOfPictures = 0 as NSNumber
        recie?._difficulty = 0 as NSNumber
        recie?._timestamp = String(NSDate().timeIntervalSince1970)
    }
    
}
