//
//  AuthViewController.swift
//  Diagnosix
//
//  Created by Aron Gates on 1/26/17.
//  Copyright © 2017 Aron Gates. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSpinner
import SwiftyJSON
import KeychainSwift
import SideMenu

public class AuthViewController: UIViewController, UITextFieldDelegate {
    
    let transitionColor = UIColor(hex: "0F9EDE")
    let normColor = UIColor(hex: "E6E6E6")
    
    @IBOutlet weak var registerView: UIView!
    @IBOutlet weak var loginView: UIView!
    
    @IBOutlet weak var usernameLoginField: UITextField!
    @IBOutlet weak var passwordLoginField: UITextField!
    @IBOutlet weak var usernameLoginSubline: UIView!
    @IBOutlet weak var passwordLoginSubline: UIView!
    
    @IBOutlet weak var usernameRegisterField: UITextField!
    @IBOutlet weak var usernameRegisterSubline: UIView!
    @IBOutlet weak var passwordRegisterField: UITextField!
    @IBOutlet weak var passwordRegisterSubline: UIView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var emailSubline: UIView!
    
    @IBOutlet weak var insuranceField: UITextField!
    @IBOutlet weak var insuranceSubline: UIView!
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if checkToken()
        {
            authenticated()
        }
        
        usernameLoginField.delegate = self
        passwordLoginField.delegate = self
        usernameRegisterField.delegate = self
        passwordRegisterField.delegate = self
        emailField.delegate = self
        insuranceField.delegate = self
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    let duration : TimeInterval = 0.5
    public func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == usernameLoginField {
            UIView.animate(withDuration: duration) {
                self.usernameLoginSubline.backgroundColor = self.normColor
            }
        }
        else if textField == passwordLoginField {
            UIView.animate(withDuration: duration) {
                self.passwordLoginSubline.backgroundColor = self.normColor
            }
        }
        else if textField == usernameRegisterField {
            UIView.animate(withDuration: duration) {
                self.usernameRegisterSubline.backgroundColor = self.normColor
            }
        }
        else if textField == passwordRegisterField {
            UIView.animate(withDuration: duration) {
                self.passwordRegisterSubline.backgroundColor = self.normColor
            }
        }
        else if textField == emailField {
            UIView.animate(withDuration: duration) {
                self.emailSubline.backgroundColor = self.normColor
            }
        }
        else if textField == insuranceField {
            UIView.animate(withDuration: duration) {
                self.insuranceSubline.backgroundColor = self.normColor
            }
        }
    }
    public func textFieldDidBeginEditing(_ textField: UITextField) {    //delegate method
        
        if textField == usernameLoginField {
            UIView.animate(withDuration: duration) {
                self.usernameLoginSubline.backgroundColor = self.transitionColor
            }
        }
        else if textField == passwordLoginField {
            UIView.animate(withDuration: duration) {
                self.passwordLoginSubline.backgroundColor = self.transitionColor
            }
        }
        else if textField == usernameRegisterField {
            UIView.animate(withDuration: duration) {
                self.usernameRegisterSubline.backgroundColor = self.transitionColor
            }
        }
        else if textField == passwordRegisterField {
            UIView.animate(withDuration: duration) {
                self.passwordRegisterSubline.backgroundColor = self.transitionColor
            }
        }
        else if textField == emailField {
            UIView.animate(withDuration: duration) {
                self.emailSubline.backgroundColor = self.transitionColor
            }
        }
        else if textField == insuranceField {
            UIView.animate(withDuration: duration) {
                self.insuranceSubline.backgroundColor = self.transitionColor
            }
        }
    }
    
    @IBAction func unwindToAuth(segue: UIStoryboardSegue){
        (navigationController as! AuthNavController).disableSideMenu()
    }
    
    @IBAction func switchScreen()
    {
        if registerView.isHidden
        {
            UIView.transition(with: self.view, duration: 0.3, options: .transitionFlipFromRight, animations: { () -> Void in
                self.registerView.isHidden = false
                self.loginView.isHidden = true
            }, completion: nil)
        }
        else
        {
            UIView.transition(with: self.view, duration: 0.3, options: .transitionFlipFromLeft, animations: { () -> Void in
                self.registerView.isHidden = true
                self.loginView.isHidden = false
            }, completion: nil)
        }
    }
    
    @IBAction func login()
    {
        if(!usernameLoginField.text!.isEmpty && !passwordLoginField.text!.isEmpty)
        {
            SwiftSpinner.show("Logging in...")
            let parameters: Parameters = [
                "Username": usernameLoginField.text!,
                "Password": passwordLoginField.text!
                ]
            Alamofire.request("https://geczy.tech/plaindoc/endpoint/login_user.php", method: .post, parameters: parameters, encoding: JSONEncoding(options: [])).responseJSON { (responseData) -> Void in
                if((responseData.result.value) != nil)
                {
                    let responseJSON = JSON(responseData.result.value!)
                    if (!responseJSON["token"].stringValue.isEmpty && !responseJSON["user_id"].stringValue.isEmpty)
                    {
                        print("handling token")
                        self.handleToken(token: responseJSON["token"].stringValue, user_id: responseJSON["user_id"].stringValue, username: responseJSON["username"].stringValue)
                        if self.checkToken()
                        {
                            SwiftSpinner.show("Welcome to PlainDoc!")
                            self.authenticated()
                        }
                        else {
                            SwiftSpinner.show("Failed!")
                        }
                    }
                    else {
                        SwiftSpinner.show("Failed!")
                    }
                }
                else {
                    SwiftSpinner.show("Failed!")
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8) {
                    SwiftSpinner.hide()
                }
            }
        }
    }
    
    @IBAction func register()
    {
        if(usernameRegisterField.hasText && passwordRegisterField.hasText && emailField.hasText && insuranceField.hasText)
        {
            SwiftSpinner.show("Authenticating...")
            let parameters: Parameters = [
                "Username": usernameRegisterField.text!,
                "Email": emailField.text!,
                "Password": passwordRegisterField.text!,
                "Insurance": insuranceField.text!
            ]
            Alamofire.request("https://geczy.tech/plaindoc/endpoint/register_user.php", method: .post, parameters: parameters, encoding: JSONEncoding(options: [])).responseJSON { (responseData) -> Void in
                if((responseData.result.value) != nil)
                {
                    let responseJSON = JSON(responseData.result.value!)
                    if (!responseJSON["token"].stringValue.isEmpty && !responseJSON["user_id"].stringValue.isEmpty)
                    {
                        print("handling token")
                        self.handleToken(token: responseJSON["token"].stringValue, user_id: responseJSON["user_id"].stringValue, username: responseJSON["username"].stringValue)
                        if self.checkToken()
                        {
                            SwiftSpinner.show("Welcome to PlainDoc!")
                            self.authenticated()
                        }
                        else {
                            SwiftSpinner.show("Failed!")
                        }
                    }
                    else {
                        SwiftSpinner.show("Failed!")
                    }
                }
                else {
                    SwiftSpinner.show("Failed!")
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8) {
                    SwiftSpinner.hide()
                }
            }
        }
    }
    
    fileprivate func checkToken() -> Bool
    {
        print("checking token")
        let keychain = KeychainSwift()
        keychain.synchronizable = true
        let token = keychain.get("token")
        if(token != nil)
        {
            print("token valid")
            return true
        }
        return false
    }
    
    fileprivate func handleToken(token : String, user_id : String, username : String)
    {
        let keychain = KeychainSwift()
        keychain.synchronizable = true
        keychain.clear()
        if(!token.isEmpty && !user_id.isEmpty)
        {
            keychain.set(token, forKey: "token")
            keychain.set(user_id, forKey: "user_id")
            keychain.set(username, forKey: "username")
            print("set token")
        }
    }
    
    fileprivate func authenticated()
    {
        print("authenticated")
        setupSideMenu()
        let homeVC = storyboard!.instantiateViewController(withIdentifier: "RecordViewController") as! MenuItem
        navigationController?.pushViewController(homeVC, animated: false)
    }
    
    // Setting up our required options for our side menu.
    fileprivate func setupSideMenu()
    {
        // Define the menu
        SideMenuManager.menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? UISideMenuNavigationController
        SideMenuManager.menuRightNavigationController = nil
        SideMenuManager.menuPresentMode = .menuSlideIn
        
        // Enable gestures and customize view and functionality
        SideMenuManager.menuFadeStatusBar = false
        SideMenuManager.menuPushStyle = .defaultBehavior
    }
    
}

