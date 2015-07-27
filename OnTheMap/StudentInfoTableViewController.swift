//
//  StudentInfoTableViewController.swift
//  OnTheMap
//
//  Created by Keng Siang Lee on 24/7/15.
//  Copyright (c) 2015 KSL. All rights reserved.
//

import Foundation
import UIKit

class StudentInfoTableViewController: UITableViewController {
    
    //================================================
    // LIFECYLE METHODS
    //================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add right bar buttons dynamically (so that we can put two buttons)
        let rightAddBarButtonItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "location"), style: UIBarButtonItemStyle.Plain, target: self, action: "addButtonClicked:")
        let rightRefreshBarButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshButtonClicked:")
        self.navigationItem.setRightBarButtonItems([rightRefreshBarButtonItem, rightAddBarButtonItem], animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //force reload of data every time view is about to show
        performRefresh()
    }
    
    //================================================
    // DELEGATE METHODS FOR TABLE
    //================================================
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ParseClient.sharedInstance().studentInfos.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //dequeue a reusable cell
        let cell = tableView.dequeueReusableCellWithIdentifier("studentInfoTableViewCell", forIndexPath: indexPath) as! UITableViewCell
        
        //get the pin
        let studentInfo = ParseClient.sharedInstance().studentInfos[indexPath.row]
        
        //set appropriate data in the cell
        cell.textLabel!.text = "\(studentInfo.firstName) \(studentInfo.lastName)"
        cell.imageView!.image = UIImage(named: "location")
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //get the pin
        let studentInfo = ParseClient.sharedInstance().studentInfos[indexPath.row]
        
        //open link in browser
        HttpHelper.openUrl(studentInfo.mediaUrl)
    }

    //================================================
    // ACTIONS
    //================================================
    
    func performLogout() {
        
        //show activity indicator
        UiHelper.showActivityIndicator(view: self.view)
        
        //logout
        UdacityClient.sharedInstance().logout({ success, errorMsg in
            
            //hide activity indicator
            dispatch_async(dispatch_get_main_queue(), {
                UiHelper.hideActivityIndicator()
            })
            
            if success {
                
                //show login screen again
                dispatch_async(dispatch_get_main_queue(), {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                
            } else {
                
                //show error msg
                UiHelper.showAlertAsync(view: self, title: "Logout Failed", msg: errorMsg)
            }
            
        })
        
    }
    
    func performAdd() {
        //show add view controller as a modal
        let controller = storyboard?.instantiateViewControllerWithIdentifier("studentInfoAddViewController") as! StudentInfoAddViewController
        presentViewController(controller, animated: true, completion: nil)

    }
    
    func performRefresh() {
        
        //show activity indicator
        UiHelper.showActivityIndicator(view: self.view)
        
        //fetch info
        ParseClient.sharedInstance().fetchStudentsInfo({ (success: Bool, errorMsg: String) -> Void in
            
            //hide activity indicator
            dispatch_async(dispatch_get_main_queue(), {
                UiHelper.hideActivityIndicator()
            })
            
            if success {
                
                //force refresh of table
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
                
            } else {
                
                //show error msg
                UiHelper.showAlertAsync(view: self, title: "Fetch Student Info Failed", msg: errorMsg)
            }
            
        })
        
    }
    
    @IBAction func logoutButtonClicked(sender: UIBarButtonItem) {
        performLogout()
    }
    
    func addButtonClicked(sender: UIButton) {
        performAdd()
    }
    
    func refreshButtonClicked(sender: UIButton) {
        performRefresh()
    }
    
}