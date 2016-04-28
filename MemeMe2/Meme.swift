//
//  Meme.swift
//
//  Created by Cody Fazio on 4/12/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import Foundation
import UIKit

struct Meme {
    //Create variables to store Meme attributes
    var topText:String!
    var bottomText:String!
    var image: UIImage! 
    var memedImage: UIImage!
    
    //Create individual Meme object
    init(let top: String, let bottom: String, let image: UIImage, let memedImage: UIImage){
        self.topText = top
        self.bottomText = bottom
        self.image = image
        self.memedImage = memedImage
    }
}

