//
//  imageCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Rakesh Kumar on 26/03/17.
//  Copyright © 2017 Rakesh Kumar. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var image:UIImage? {
        didSet{
            if let image = image{
                imageView.image = image
            }else{
                imageView.image = UIImage(named: "placeholder")
            }
        }
    }
    
    override var isSelected: Bool{
        
        didSet{
            if isSelected{
                self.alpha = 0.3
            }else{
                self.alpha = 1.0
            }
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        loadImageCell(loading: false)
        image = nil
    }
    
    func loadImageCell(loading:Bool){
        activity.isHidden = !loading
        if loading{
            activity.startAnimating()
        }else{
            activity.stopAnimating()
        }
    }
    
}
