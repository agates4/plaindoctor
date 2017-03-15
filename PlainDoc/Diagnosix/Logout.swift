//
//  segue.swift
//  Diagnosix
//
//  Created by Aron Gates on 2/7/17.
//  Copyright © 2017 Aron Gates. All rights reserved.
//

import UIKit
import SideMenu

class LogoutAnimation: UIStoryboardSegue {
    override func perform()
    {
        let source = self.source
        
        if let nav = source.navigationController as? UISideMenuNavigationController, let presentingNav = nav.presentingViewController as? UINavigationController
        {
            presentingNav.dismiss(animated: true, completion: nil)
            
            presentingNav.popToRootViewController(animated: false)
        }
    }
}
