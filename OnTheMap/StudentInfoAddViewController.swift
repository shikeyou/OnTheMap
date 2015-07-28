//
//  StudentInfoAddViewController.swift
//  OnTheMap
//
//  Created by Keng Siang Lee on 26/7/15.
//  Copyright (c) 2015 KSL. All rights reserved.
//

import Foundation

import UIKit
import MapKit

class StudentInfoAddViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    
    //outlets
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var findOnMapButton: UIButton!
    @IBOutlet weak var selectedLocationLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    
    //gesture recognizers
    var tapRecognizer: UITapGestureRecognizer!
    
    //variables to store user selection/actions for this view controller
    var searchResults: [MKMapItem] = []
    var selectedLocationName: String = ""
    var selectedLocationLatitude: Float!
    var selectedLocationLongitude: Float!
    
    //================================================
    // LIFECYLE METHODS
    //================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //assign delegates
        locationTextField.delegate = self
        urlTextField.delegate = self
        mapView.delegate = self

        //init tap recognizer
        tapRecognizer = UITapGestureRecognizer(target: self, action: "singleTapCallback:")
        tapRecognizer.numberOfTapsRequired = 1
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addKeyboardDismissRecognizer()
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeKeyboardDismissRecognizer()
        
        unsubscribeToKeyboardNotifications()
    }
    
    //================================================
    // METHODS FOR HANDLING UI/KEYBOARD ISSUES
    //================================================
    
    func singleTapCallback(recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func addKeyboardDismissRecognizer() {
        view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func keyboardWillShow(notification: NSNotification) {
        //shift frame up only if the bottom text field is activated
        if urlTextField.isFirstResponder() {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //shift frame back down only if it is the bottom text field
        if urlTextField.isFirstResponder() {
            view.frame.origin.y = 0
        }
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //================================================
    // DELEGATE METHODS FOR TEXT FIELDS
    //================================================
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        //finish editing and dismiss keyboard
        textField.resignFirstResponder()
        
        //process the return based on which text field it is
        if textField == locationTextField {
            performFindOnMap()
        } else if textField == urlTextField {
            performSubmit()
        }
        
        return true
    }
    
    //================================================
    // DELEGATE METHODS FOR MAP VIEW
    //================================================
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        
        //update label after user has selected an item
        setSelectedMapItem(name: view.annotation.title!, latitude: Float(view.annotation.coordinate.latitude), longitude: Float(view.annotation.coordinate.longitude))
    }
    
    //updates selected map item label
    func setSelectedMapItem(#name: String, latitude: Float, longitude: Float) {
        
        //store selected location
        selectedLocationName = name
        selectedLocationLatitude = latitude
        selectedLocationLongitude = longitude
        
        //update label
        selectedLocationLabel.text = "Selected: \(selectedLocationName) (" + String(format: "%.1f", arguments: [selectedLocationLatitude]) + ", " + String(format: "%.1f", arguments: [selectedLocationLongitude]) + ")"
        
    }
    
    //================================================
    // ACTIONS
    //================================================
    
    func performFindOnMap() {
        
        //check that text field has been filled in
        if locationTextField.text == "" {
            UiHelper.showAlert(view: self, title: "Error", msg: "Please enter a location first")
            return
        }
        
        //start search using string from text field
        findLocationOnMap(locationTextField.text)
    }
    
    func findLocationOnMap(searchString: String) {
        
        //create a geocoder instance
        let geocoder = CLGeocoder()
        
        //show activity indicator
        UiHelper.showActivityIndicator(view: self.view)
        
        //start forward geocoding
        geocoder.geocodeAddressString(searchString, completionHandler: { placemarks, error in
            
            //hide activity indicator
            dispatch_async(dispatch_get_main_queue(), {
                UiHelper.hideActivityIndicator()
            })
            
            //check for search errors
            if error != nil {
                
                //show custom error messages for those events that I have tested for
                if error.domain == "kCLErrorDomain" && error.code == 8 {
                    UiHelper.showAlertAsync(view: self, title: "Search failed", msg: "No matches found")
                } else if error.domain == "kCLErrorDomain" && error.code == 2 {
                    UiHelper.showAlertAsync(view: self, title: "Search failed", msg: "No internet connection")
                } else {
                    //show the generic error message
                    UiHelper.showAlertAsync(view: self, title: "Search failed", msg: error.localizedDescription)
                }
                
                return
            }
            
            //check if there are any results
            if placemarks.count == 0 {
                UiHelper.showAlertAsync(view: self, title: "Search failed", msg: "No matches found")
                return
            }
            
            //remove all existing annotations first
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            //loop through the results and mark them on the map
            var annotations: [MKPointAnnotation] = []
            for placemark in placemarks {
                
                let p = placemark as! CLPlacemark
                
                var annotation = MKPointAnnotation()
                annotation.coordinate = p.location.coordinate
                annotation.title = p.name
                annotations.append(annotation)
                
            }
            
            //if there's only one result, set selection automatically without user manually selecting
            if placemarks.count == 1 {
                let placemark = placemarks[0] as! CLPlacemark
                let coordinate = placemark.location.coordinate
                self.setSelectedMapItem(name: placemark.name, latitude: Float(coordinate.latitude), longitude: Float(coordinate.longitude))
            }

            //update map ui
            dispatch_async(dispatch_get_main_queue(), {
                self.mapView.showAnnotations(annotations, animated: true)
            })
            
        })
        
    }
    
    func performSubmit() {
        
        //get inputs
        let enteredUrlText = urlTextField.text
        
        //check for inputs
        if selectedLocationName == ""{
            UiHelper.showAlert(view: self, title: "Error", msg: "Select a location first")
            return
        }
        if enteredUrlText == "" {
            UiHelper.showAlert(view: self, title: "Error", msg: "Please enter a website URL")
            return
        }
        let enteredUrl = NSURL(string: enteredUrlText)
        if enteredUrl == nil || !UIApplication.sharedApplication().canOpenURL(enteredUrl!){
            UiHelper.showAlert(view: self, title: "Error", msg: "Please enter a valid URL")
            return
        }
        
        //query for user name
        let uniqueKey = UdacityClient.sharedInstance().uniqueKey!
        let userFirstName = UdacityClient.sharedInstance().firstName!
        let userLastName = UdacityClient.sharedInstance().lastName!
        
        //create StudentInfo to prepare for posting
        let studentInfo = StudentInfo(
            uniqueKey: uniqueKey,
            firstName: userFirstName,
            lastName: userLastName,
            latitude: selectedLocationLatitude,
            longitude: selectedLocationLongitude,
            mapString: selectedLocationName,
            mediaUrl: enteredUrlText
        )
        
        //show activity indicator
        UiHelper.showActivityIndicator(view: self.view)
        
        //post to server
        ParseClient.sharedInstance().postStudentInfo(studentInfo, completionHandler: { success, errorMsg in
            
            //hide activity indicator
            dispatch_async(dispatch_get_main_queue(), {
                UiHelper.hideActivityIndicator()
            })
            
            if success {
                
                //dimiss modal
                dispatch_async(dispatch_get_main_queue(), {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                
            } else {
                UiHelper.showAlertAsync(view: self, title: "Add Pin Failed", msg: errorMsg)
            }
            
        })
        
    }
    
    @IBAction func cancelButtonClicked(sender: UIBarButtonItem) {
        
        //dismiss the modal (itself)
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func findOnMapButtonClicked(sender: UIButton) {
        
        //dismiss keyboard first
        view.endEditing(true)
        
        //start search
        performFindOnMap()
    }
    
    @IBAction func submitButtonClicked(sender: UIButton) {
        
        //dismiss keyboard first
        view.endEditing(true)
        
        //submit
        performSubmit()
    }
    
}