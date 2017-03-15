//
//  ListViewController.swift
//  Diagnosix
//
//  Created by Aron Gates on 10/22/16.
//  Copyright © 2016 Aron Gates. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner
import SideMenu
import FoldingCell

class ListViewController: MenuItem, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
//    let backviewColor = UIColor(hex: "FFF0F5")
    let backviewColor = UIColor(hex: "E2E7EA")

    var arrRes = [[String:AnyObject]]() //Array of dictionary
    
    let ColorSelection = [
        UIColor(hex: "4ABDAC"),
        UIColor(hex: "FC4A1A"),
        UIColor(hex: "F7B733")
    ]
    var colorIndex = 0
    func chooseColor() -> UIColor {
        colorIndex += 1
        if colorIndex >= 3 {
            colorIndex = 0
        }
        return ColorSelection[colorIndex]
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.addSubview(refreshControl)
        self.tableView.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
    }
    
    lazy var refreshControl: UIRefreshControl =
    {
        let refreshControl = UIRefreshControl()
        
        let handle : Selector = #selector(ListViewController.handleRefresh(refreshControl:))
        refreshControl.addTarget(self, action: handle, for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    public func handleRefresh(refreshControl: UIRefreshControl)
    {
        DispatchQueue.main.async {
            let parameters: Parameters = [
                "user_id": self.userID
            ]
            
            Alamofire.request("https://geczy.tech/plaindoc/endpoint/get_every_diagnosis.php", method: .post, parameters: parameters, encoding: JSONEncoding(options: [])).responseJSON { (responseData) -> Void in
                
                if((responseData.result.value) != nil) {
                    
                    let swiftyJsonVar = JSON(responseData.result.value!)
                    if let resData = swiftyJsonVar.arrayObject {
                        self.arrRes = resData as! [[String:AnyObject]]
                    }
                    self.tableView.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.tableView.fadeIn()
                        SwiftSpinner.hide()
                    }
                }
                else
                {
                    SwiftSpinner.show("Failed! Check your internet connection.")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.tableView.fadeIn()
                        SwiftSpinner.hide()
                    }
                }
            }
        }

        refreshControl.endRefreshing()
    }
    
    override public func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        SwiftSpinner.show("Updating History...", animated: true)
        (navigationItem.titleView?.subviews[0] as! UIImageView).image = UIImage(named: "Treatment Plan.png")
    }
    
    override public func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        self.tableView.alpha = 0
        
        self.handleRefresh(refreshControl: self.refreshControl)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return cellHeights[indexPath.row]
    }
    
    var cellHeights = (0..<30).map { _ in C.CellHeight.close }
    fileprivate struct C
    {
        struct CellHeight {
            static let close: CGFloat = 108 // equal or greater foregroundView height
            static let open: CGFloat = 237 // equal or greater containerView height
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        guard case let cell as ListCell = tableView.cellForRow(at: indexPath) else {
            return
        }
        
        var duration = 0.0
        if cellHeights[indexPath.row] == C.CellHeight.close { // open cell
            cellHeights[indexPath.row] = C.CellHeight.open
            cell.selectedAnimation(true, animated: true, completion: nil)
            duration = 0.5
        } else {// close cell
            cellHeights[indexPath.row] = C.CellHeight.close
            cell.selectedAnimation(false, animated: true, completion: nil)
            duration = 1.1
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { _ in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if case let cell as ListCell = cell {
            cell.backViewColor = backviewColor
            
            if cellHeights[indexPath.row] == C.CellHeight.close {
                cell.selectedAnimation(false, animated: false, completion:nil)
            } else {
                cell.selectedAnimation(true, animated: false, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : ListCell = tableView.dequeueReusableCell(withIdentifier: "ListCell")! as! ListCell
        let dict = arrRes[(indexPath as NSIndexPath).row]
        let textInt : Int = Int((dict["ID"] as! NSString).intValue)
        
        cell.ID = Int(textInt)
        cell.diagnosisDate.text = dict["Date"] as? String
        cell.diagnosisLoc.text = dict["Location"] as? String
        cell.leftHighlight.backgroundColor = chooseColor()
        cell.appointmentNum.text = "#\(arrRes.count - indexPath.row)"
        cell.sumDate.text = dict["Date"] as? String
        cell.address = dict["Location"] as! String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrRes.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "toDiagnosis" {
            if let destination = segue.destination as? DiagnosisViewController {
                let indexPath = self.tableView.indexPathForSelectedRow!
                if let cell = self.tableView.cellForRow(at: indexPath) as! ListCell!
                {
                    destination.appointmentID = cell.ID
                    tableView.deselectSelectedRowAnimated(animated: true)
                    navigationItem.titleView?.fadeOut()
                }
            }
        }
    }
}



