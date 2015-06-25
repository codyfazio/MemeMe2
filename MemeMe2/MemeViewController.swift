//
//  MemeViewController.swift
//
//  Created by Cody Clingan on 4/12/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import Foundation
import UIKit

class MemeViewController: UIViewController {
    
    //Display the selected Sent meme passed in from the other view
    var meme: Meme!
    @IBOutlet weak var memeDetailImage: UIImageView!
    
    override func viewDidLoad() {
        self.memeDetailImage.image = meme.memedImage
    }
}
