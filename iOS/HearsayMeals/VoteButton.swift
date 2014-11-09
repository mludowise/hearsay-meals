//
//  SomeView.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 11/9/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import Foundation


class VoteButton: UIButton {
    
    override func drawRect(rect: CGRect) {

        if(self.selected == false) {
            
            let color = UIColor(red: 0.659, green: 0.623, blue: 0.662, alpha: 1.000)
            
            //// Rectangle Drawing
            let rectanglePath = UIBezierPath(roundedRect: frame, cornerRadius: 4)
            color.setFill()
            rectanglePath.fill()


        }
        else {
            
            //// Color Declarations
            let color = UIColor(red: 0.858, green: 0.002, blue: 0.924, alpha: 1.000)
            
            //// Rectangle Drawing
            let rectanglePath = UIBezierPath(roundedRect: frame, cornerRadius: 4)
            color.setFill()
            rectanglePath.fill()
   
        }
        
        
        
    }
}