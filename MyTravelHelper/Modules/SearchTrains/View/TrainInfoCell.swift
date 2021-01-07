//
//  TrainInfoCell.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import UIKit

class TrainInfoCell: UITableViewCell {
    @IBOutlet weak var destinationTimeLabel: UILabel!
    @IBOutlet weak var sourceTimeLabel: UILabel!
    @IBOutlet weak var destinationInfoLabel: UILabel!
    @IBOutlet weak var souceInfoLabel: UILabel!
    @IBOutlet weak var trainCode: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    
    weak var delegate: FavouriteDelegate?
  
    @IBAction func btnCloseTapped(sender: AnyObject) {
        delegate?.btnFavouriteTapped(cell: self)
    }
}
