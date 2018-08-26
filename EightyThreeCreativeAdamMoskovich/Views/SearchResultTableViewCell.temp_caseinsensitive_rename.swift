//
//  searchResultTableViewCell.swift
//  EightyThreeCreativeAdamMoskovich
//
//  Created by Adam on 25/08/2018.
//  Copyright © 2018 Adam Moskovich. All rights reserved.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
    //
    // MARK: - Outlets
    //
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var productNameLabel: UILabel!
    //
    // MARK: - Lifecycle Functions
    //
    override func awakeFromNib() {
        super.awakeFromNib()
        setShadow()
    }
    //
    // MARK: - Methods
    //
    func setShadow() {
        bgView.layer.cornerRadius = 5
        bgView.layer.shadowColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1).cgColor
        bgView.layer.shadowOffset = CGSize(width: 0, height: 1)
        bgView.layer.shadowOpacity = 0.1
        bgView.layer.shadowRadius = 5.0
        //self.contentView.layer.masksToBounds = true
    }

}
