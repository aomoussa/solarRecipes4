//
//  Comments.swift
//  solarRecipes2
//
//  Created by Ahmed Moussa on 6/18/17.
//  Copyright © 2017 Ahmed Moussa. All rights reserved.
//

import Foundation

//
//  Comments.swift
//  MySampleApp
//
//
// Copyright 2017 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.16
//

import UIKit
import AWSDynamoDB

class Comments: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _timestamp: String?
    var _aboutID: String?
    var _content: String?
    var _creatorName: String?
    var _commentID: String?
    
    class func dynamoDBTableName() -> String {
        
        return "solarrecipes-mobilehub-623139932-comments"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_timestamp"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_timestamp" : "timestamp",
            "_aboutID" : "aboutID",
            "_content" : "content",
        ]
    }
}
