//
//  StudentInfoMapViewController.swift
//  OnTheMap
//
//  Created by Keng Siang Lee on 24/7/15.
//  Copyright (c) 2015 KSL. All rights reserved.
//

import Foundation

import UIKit
import MapKit

class StudentInfoMapViewController: UIViewController, MKMapViewDelegate {

    //outlets
    @IBOutlet weak var mapView: MKMapView!
    
    //================================================
    // LFIECYLE METHODS
    //================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add right bar buttons dynamically
        let rightAddBarButtonItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "location"), style: UIBarButtonItemStyle.Plain, target: self, action: "addButtonClicked:")
        let rightRefreshBarButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshButtonClicked:")
        self.navigationItem.setRightBarButtonItems([rightRefreshBarButtonItem, rightAddBarButtonItem], animated: true)
        
        //assign delegate
        mapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //force reload of data every time view is about to show
        performRefresh()
    }
    
    //================================================
    // DELEGATE METHODS FOR MAP
    //================================================
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if let annotation = annotation as? StudentInfoAnnotation {
            
            let identifier = "studentInfoAnnotation"
            
            var view: MKPinAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
            }
            
            return view
            
        }
        
        return nil
        
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        
        let pin = view.annotation as! StudentInfoAnnotation
        
        //open link in browser
        HttpHelper.openUrl(NSURL(string: pin.mediaUrl)!)
        
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
        ParseClient.sharedInstance().fetchAnnotations({ (success: Bool, errorMsg: String) -> Void in
            
            //hide activity indicator
            dispatch_async(dispatch_get_main_queue(), {
                UiHelper.hideActivityIndicator()
            })
            
            if success {
                
                //force refresh of map
                dispatch_async(dispatch_get_main_queue(), {
                    self.mapView.showAnnotations(ParseClient.sharedInstance().annotations, animated: true)
                })
                
            } else {
                
                //show error msg
                UiHelper.showAlertAsync(view: self, title: "Retrieve Student Info Failed", msg: errorMsg)
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

