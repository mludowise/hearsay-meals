//
//  Util.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 11/8/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import Foundation

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

func loadImageFromURL(url: String) -> UIImage? {
    var imageUrl = NSURL(string: url)
    if (imageUrl == nil) {
        return nil
    }
    var imageData = NSData(contentsOfURL: imageUrl!)
    if (imageData == nil) {
        return nil
    }
    return UIImage(data: imageData!)
}