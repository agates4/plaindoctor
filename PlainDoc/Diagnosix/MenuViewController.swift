//
//  MenuViewController.swift
//  Diagnosix
//
//  Created by Aron Gates on 2/7/17.
//  Copyright © 2017 Aron Gates. All rights reserved.
//

import UIKit
import SideMenu
import Font_Awesome_Swift

public class MenuViewController: UIViewController {
    
    @IBOutlet weak var recordView: MenuCustomCell!
    @IBOutlet weak var listView: MenuCustomCell!
    @IBOutlet weak var signView: MenuCustomCell!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var funView: UIImageView!
    
    let imageColor = UIColor(hex: "555459")
    
    override public func viewDidLoad()
    {
        super.viewDidLoad()

    }
    
    override public func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        let chain = keychainHelper()
        usernameLabel.text = chain.getUsername()
        profileView.setRounded()
        usernameLabel.frame.origin.x = self.view.frame.midX - usernameLabel.frame.width / 2
        profileView.frame.origin.x = self.view.frame.midX - profileView.frame.width / 2
        funView.frame = CGRect(x: 0, y: funView.frame.origin.y, width: self.view.frame.width, height: self.view.frame.width)
        funView.frame.origin.x = self.view.frame.midX - funView.frame.width / 2
        
        recordView.menuImage.image = UIImage(icon: .FAMicrophone, size: CGSize(width: 30, height: 30), textColor: imageColor, backgroundColor: .clear)
        recordView.menuLabel.text = "R E C O R D"
        let recordAction : Selector = #selector(activateSeque(withSender:))
        recordView.menuTap.addTarget(self, action: recordAction)
        
        listView.menuImage.image = UIImage(icon: .FAList, size: CGSize(width: 30, height: 30), textColor: imageColor, backgroundColor: .clear)
        listView.menuLabel.text = "D I A G N O S I S   L I S T"
        let listAction : Selector = #selector(activateSeque(withSender:))
        listView.menuTap.addTarget(self, action: listAction)
        
        signView.menuImage.image = UIImage(icon: .FASignOut, size: CGSize(width: 30, height: 30), textColor: imageColor, backgroundColor: .clear)
        signView.menuLabel.text = "S I G N   O U T"
        let signAction : Selector = #selector(activateSeque(withSender:))
        signView.menuTap.addTarget(self, action: signAction)
    }
    
    @objc fileprivate func activateSeque(withSender sender: AnyObject)
    {
        if sender === recordView.menuTap {
            let homeVC = storyboard!.instantiateViewController(withIdentifier: "RecordViewController") as! MenuItem
            navigationController?.pushViewController(homeVC, animated: false)
        }
        else if sender === listView.menuTap {
            let homeVC = storyboard!.instantiateViewController(withIdentifier: "ListViewController") as! MenuItem
            navigationController?.pushViewController(homeVC, animated: false)
        }
        else if sender === signView.menuTap {
            let chain = keychainHelper()
            chain.clearChain()
            self.performSegue(withIdentifier: "unwindToAuth", sender: self)
        }
    }
    
}
