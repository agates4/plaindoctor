//
//  SideNavController.swift
//  Diagnosix
//
//  Created by Aron Gates on 2/7/17.
//  Copyright © 2017 Aron Gates. All rights reserved.
//

import UIKit
import SideMenu

class AuthNavController: UINavigationController {
    
    var panGesture  = UIPanGestureRecognizer()
    var edgeGesture = [UIScreenEdgePanGestureRecognizer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // add gesture recognizer
        panGesture = SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationBar)
        edgeGesture = SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.view)
    }
    
    // disable side menu
    func disableSideMenu() {
        panGesture.isEnabled = false
        edgeGesture.forEach{$0.isEnabled = false}
    }
    
    // enable side menu
    func enableSideMenu() {
        panGesture.isEnabled = true
        edgeGesture.forEach{$0.isEnabled = true}
    }
    
}
