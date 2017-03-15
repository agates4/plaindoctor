//
//  ListView.swift
//  Diagnosix
//
//  Created by Aron Gates on 2/8/17.
//  Copyright © 2017 Aron Gates. All rights reserved.
//

import UIKit
import SideMenu

class ListSegue: UIStoryboardSegue {
    override func perform()
    {
        let source = self.source
        let destination = self.destination
        
        if let nav = source.navigationController as? UISideMenuNavigationController, let presentingNav = nav.presentingViewController as? UINavigationController
        {
            presentingNav.dismiss(animated: true, completion: nil)
            
            presentingNav.pushViewController(destination, animated: false)
        }
    }
}
