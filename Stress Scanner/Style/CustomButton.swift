//
//  CustomButton.swift
//  Stress Scanner
//
//  Created by Fauzan Achmad on 19/09/19.
//  Copyright © 2019 Fauzan Achmad. All rights reserved.
//
import UIKit

class CustomButton : UIButton {
    override func didMoveToWindow() {
        self.layer.borderWidth = 1
        self.layer.borderColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        self.layer.cornerRadius = 8
    }
}
