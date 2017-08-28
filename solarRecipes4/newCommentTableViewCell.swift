//
//  newCommentTableViewCell.swift
//  solarRecipes2
//
//  Created by Ahmed Moussa on 6/17/17.
//  Copyright © 2017 Ahmed Moussa. All rights reserved.
//

import UIKit

class newCommentTableViewCell: UITableViewCell {

    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var newCommentorImage: UIImageView!
    @IBOutlet weak var submitCommentButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
