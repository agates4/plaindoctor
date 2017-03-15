//
//  SlideView.swift
//  Diagnosix
//
//  Created by Aron Gates on 2/21/17.
//  Copyright © 2017 Aron Gates. All rights reserved.
//

import UIKit

@objc protocol SlideViewDelegate {
    func chooseButton(button: String)
}

class SlideView: UIView {
    weak var delegate: SlideViewDelegate?
    
    @IBAction func color1WasTapped() {
        self.delegate?.chooseButton(button: "Transcript")
    }
    
    @IBAction func color2WasTapped() {
        self.delegate?.chooseButton(button: "TLDR")
    }
    
    @IBAction func color3WasTapped() {
        self.delegate?.chooseButton(button: "Symptoms")
    }
    
    @IBAction func color4WasTapped() {
        self.delegate?.chooseButton(button: "Prescriptions")
    }
    
    @IBAction func color5WasTapped() {
        self.delegate?.chooseButton(button: "Treatment")
    }
}
