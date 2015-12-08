//
//  Meme.swift
//  MemeMe
//
//  Created by Carol Chapman on 12/7/15.
//  Copyright © 2015 Carol Chapman. All rights reserved.
//

import Foundation
import UIKit

struct Meme  {
    var topText: String = ""
    var bottomText: String = ""
    var originalImage: UIImage = UIImage()
    var memedImage: UIImage = UIImage()

    init(topText: String, bottomText: String, originalImage: UIImage, memedImage: UIImage) {
        
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memedImage = memedImage
    }
}