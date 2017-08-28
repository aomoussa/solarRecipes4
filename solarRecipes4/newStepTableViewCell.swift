//
//  newStepTableViewCell.swift
//  solarRecipes2
//
//  Created by Ahmed Moussa on 4/15/17.
//  Copyright © 2017 Ahmed Moussa. All rights reserved.
//

import UIKit

class newStepTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var contentTextView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
