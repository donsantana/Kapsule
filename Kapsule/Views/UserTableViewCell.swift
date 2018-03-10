//
//  UserTableViewCell.swift
//  NoIce
//
//  Created by Done Santana on 24/2/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var UserConectedImage: UIImageView!
    @IBOutlet weak var NewMsg: UIView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
