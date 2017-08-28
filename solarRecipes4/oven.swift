//
//  oven.swift
//  solarRecipes2
//
//  Created by Ahmed Moussa on 6/11/17.
//  Copyright © 2017 Ahmed Moussa. All rights reserved.
//


import Foundation
import UIKit
import AWSDynamoDB

class oven {
    var creatorPP = UIImage(named: "plus.jpg")
    var picures = [UIImage]()
    var ove = DBOven()
    
    
    var _userId: String?
    var _timestamp: String?
    var _creatorName: String?
    var _difficulty: NSNumber?
    var _id: String?
    var _name: String?
    var _numberOfPictures: NSNumber?
    var _ovenType: String?
    var _parts: Set<String>?
    var _steps: Set<String>?
    
    init(id: String, name: String, steps: [String], difficulty: NSNumber, creatorFBID: String, creatorName: String, numOfPics: Int, parts: [String], tmstmp: String, ovenType: String){
        ove?._userId = creatorFBID
        ove?._name = name
        ove?._steps = Set<String>(steps)
        ove?._id = "\(creatorFBID) \(tmstmp)"
        ove?._creatorName = creatorName
        ove?._numberOfPictures = numOfPics as NSNumber
        ove?._parts = Set<String>(parts)
        ove?._timestamp = tmstmp
        ove?._difficulty = difficulty
        //ove?._comments = Set<String>(["Hey nice recipe!"])
        ove?._ovenType = ovenType
        
    }
    init(ov: DBOven){
        ove = ov
    }
    
    init(){
        ove?._userId = ""
        ove?._name = ""
        ove?._steps = [""]
        ove?._id = ""
        ove?._creatorName = ""
        ove?._numberOfPictures = 0 as NSNumber
        ove?._parts = [""]
        ove?._timestamp = String(NSDate().timeIntervalSince1970)
        ove?._difficulty = 0 as NSNumber
        //ove?._comments = Set<String>(["Hey nice recipe!"])
        ove?._ovenType = ""
    }
    
}
