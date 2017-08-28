//
//  recipeCollectionViewCell.swift
//  solarRecipes2
//
//  Created by Ahmed Moussa on 11/9/16.
//  Copyright © 2016 Ahmed Moussa. All rights reserved.
//

import UIKit

class recipeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var creatorNameLabel: UILabel!
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var tempValueLabel: UILabel!
    @IBOutlet weak var durValueLabel: UILabel!
    @IBOutlet weak var thirdThingValueLabel: UILabel!
    @IBOutlet weak var diffValueLabel: UILabel!
    @IBOutlet weak var ovenTypeLabel: UILabel!
}
