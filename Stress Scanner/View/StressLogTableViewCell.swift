//
//  StressLogTableViewCell.swift
//  Stress Scanner
//
//  Created by Fauzan Achmad on 20/09/19.
//  Copyright © 2019 Fauzan Achmad. All rights reserved.
//

import UIKit

class StressLogTableViewCell: UITableViewCell {
    @IBOutlet weak var healthRate: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var stressLevel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
