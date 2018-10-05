//
//  TemplatesTableCell.swift
//  Reter
//
//  Created by apple on 2/5/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import UIKit

class TemplatesTableCell: UITableViewCell {

    @IBOutlet weak var lblTemplateName: UILabel!
    @IBOutlet weak var lblTemplateDescription: UILabel!
    @IBOutlet weak var viewOutline: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
