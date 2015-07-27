//
//  HelperFunctions.swift
//  OnTheMap
//
//  Created by Keng Siang Lee on 26/7/15.
//  Copyright (c) 2015 KSL. All rights reserved.
//

import Foundation
import UIKit

//helper class for HTTP requests
class HttpHelper {
    
    //class method that makes a HTTP request
    class func makeHttpRequest(#requestUrl: String, requestMethod: String, requestAddValues: [(String, String)]? = nil, requestBody: NSData? = nil, requestRemoveXsrfToken: Bool = false, requestDataHandler: (data: NSData!, response: NSURLResponse!, error: NSError!)->Void) {
        
        //create the request object
        let request = NSMutableURLRequest(URL: NSURL(string: requestUrl)!)
        request.HTTPMethod = requestMethod
        if requestAddValues != nil {
            for (requestAddValue1, requestAddValue2) in requestAddValues! {
                request.addValue(requestAddValue1, forHTTPHeaderField: requestAddValue2)
            }
            
        }
        request.HTTPBody = requestBody
        
        //add removal of cross-site request forgery token from request object if requested
        if requestRemoveXsrfToken {
            var xsrfCookie: NSHTTPCookie? = nil
            let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
            for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
                if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
            }
            if let xsrfCookie = xsrfCookie {
                request.addValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
            }
        }
        
        //get shared session
        let session = NSURLSession.sharedSession()
        
        //create task
        let task = session.dataTaskWithRequest(request, completionHandler: requestDataHandler)
        
        //execute the task
        task.resume()
        
    }
    
    //method that parses raw JSON data into an NSDictionary
    class func parseJsonData(data: NSData) -> (NSDictionary, NSError?) {
        
        var parsingError: NSError? = nil
        
        //parse json data
        let jsonData: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        if parsingError != nil {
            return (NSDictionary(), parsingError)
        }
        
        return (jsonData as! NSDictionary, parsingError)
    }
    
    //method that opens URLs
    class func openUrl(url: NSURL) {
        
        //add http to start of url if it is not already there
        var newUrl: NSURL = url
        if let urlString = url.absoluteString {
            if urlString.substringToIndex(advance(urlString.startIndex, 4)) != "http" {
                newUrl = NSURL(string: "http://\(urlString)")!
            }
        }
        
        //open the url with default browser
        UIApplication.sharedApplication().openURL(newUrl)
    }
    
}

//helper class for UI-related stuff
class UiHelper {
    
    static var activityIndicator = UIActivityIndicatorView()
    
    //method that shows the activity indicator
    class func showActivityIndicator(#view: UIView) {
        activityIndicator.frame = CGRect(x: view.frame.midX - 25, y: view.frame.midY - 25, width: 50, height: 50)
        activityIndicator.layer.cornerRadius = 10
        activityIndicator.backgroundColor = UIColor.grayColor()
        activityIndicator.alpha = 0.5
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    //method that hides the activity indicator
    class func hideActivityIndicator() {
        activityIndicator.removeFromSuperview()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
    }
    
    //method that shows an alert asynchronously on the main UI thread
    class func showAlertAsync(#view: UIViewController, title: String, msg: String) {
        dispatch_async(dispatch_get_main_queue(), {
            self.showAlert(view: view, title: title, msg: msg)
        })
    }
    
    //method that shows an alert
    class func showAlert(#view: UIViewController, title: String, msg: String) {
        let alertController = UIAlertController()
        alertController.title = title
        alertController.message = msg
        alertController.addAction(
            UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
                action in
                alertController.dismissViewControllerAnimated(true, completion: nil)
            })
        )
        view.presentViewController(alertController, animated: true, completion: nil)
    }
    
}
