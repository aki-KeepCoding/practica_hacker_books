//
//  BookViewCell.swift
//  HackerBooks
//
//  Created by Akixe on 17/7/16.
//  Copyright © 2016 AOA. All rights reserved.
//

import UIKit

class BookViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var authors: UILabel!
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var tags: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    //MARK: - Class Methods
    static func cellId() -> String {
        return String(self)
        //return "BookCell"
    }
    
    static func cellHeight() -> CGFloat {
        return 80.0
    }

}
