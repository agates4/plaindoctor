//
//  MenuItem.swift
//  Diagnosix
//
//  Created by Aron Gates on 1/9/17.
//  Copyright © 2017 Aron Gates. All rights reserved.
//

import SideMenu
import UIKit

class MenuItem: UIViewController {
    
    var navBar: UINavigationBar = UINavigationBar()
    
    var userID: String!
    
    var username: String!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        let chain = keychainHelper()
        self.userID = chain.getUserID()
        self.username = chain.getUsername()
        
        initNavBar()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (navigationController as! AuthNavController).enableSideMenu()
    }
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if UIDevice.current.orientation.isLandscape {
            navBar.removeFromSuperview()
            initNavBar(optionalWidth: size.width)
        } else {
            navBar.removeFromSuperview()
            initNavBar(optionalWidth: size.width)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override public var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func initNavBar(optionalWidth: CGFloat = -1) {
        var width = optionalWidth
        if optionalWidth == -1 {
            width = self.view.frame.width
        }
        self.navBar.frame = CGRect(x: 0, y: 0, width: width, height: 56)
        navBar.isTranslucent = false
        navBar.barTintColor = UIColor.init(hex: "FC5847")
        navBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navBar.shadowImage = UIImage()
        
        var logo = UIImage(named: "Microphone.png")
        logo = logo!.resizeImage(image: logo!, newWidth: 18)
        let imageView = UIImageView(image:logo)
        imageView.frame.size = logo!.size
        
        let logoTextAttr = [NSForegroundColorAttributeName:UIColor.white, NSFontAttributeName: UIFont(name: "Arial", size: 15)!]
        let plainDocText = NSAttributedString(string: "PlainDoc", attributes: logoTextAttr)
        let plainDocLabel = UILabel(frame: CGRect(x: imageView.frame.width, y: 0, width: plainDocText.widthWithConstrainedHeight(height: imageView.frame.height), height: imageView.frame.height))
        
        plainDocLabel.attributedText = plainDocText
        let logoSubview = UIView(frame: CGRect(x: 0, y: 0, width: plainDocLabel.frame.width + imageView.frame.width, height: imageView.frame.height))
        logoSubview.addSubview(imageView)
        logoSubview.addSubview(plainDocLabel)
        navigationItem.titleView = logoSubview
        
        self.view.addSubview(navBar)
        
        let menuBtn = UIButton(type: .custom)
        menuBtn.setImage(UIImage(named: "list.png"), for: .normal)
        menuBtn.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        menuBtn.addTarget(self, action: #selector(MenuItem.presentSideMenu), for: .touchUpInside)
        let menuBarBtn = UIBarButtonItem(customView: menuBtn)
        
        navigationItem.leftBarButtonItem = menuBarBtn
        navBar.items = [navigationItem]
    }
    
    @IBAction func presentSideMenu()
    {
        present(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
}
