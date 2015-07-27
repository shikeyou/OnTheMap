//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Keng Siang Lee on 26/7/15.
//  Copyright (c) 2015 KSL. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {
    
    //store user info after logging in
    var firstName: String? = nil
    var lastName: String? = nil
    var uniqueKey: String? = nil
    var sessionId: String? = nil
    
    //singleton class function
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
    //login method
    func login(#email: String, password: String, completionHandler: (success: Bool, errorMsg: String)->Void) {
        
        //make http POST request to udacity's rest api
        HttpHelper.makeHttpRequest(
            requestUrl: "https://www.udacity.com/api/session",
            requestMethod: "POST",
            requestAddValues: [("application/json", "Accept"), ("application/json", "Content-Type")],
            requestBody: "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding),
            requestDataHandler: { data, response, error in
                
                //check for request error
                if error != nil {
                    completionHandler(success: false, errorMsg: error.localizedDescription)
                    return
                }
                
                //get subset of raw response (format of udacity response)
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                
                //check status code to determine success or failure
                let httpResponse = response as! NSHTTPURLResponse
                if httpResponse.statusCode == 200 {  //success
                    
                    //parse json data
                    let (jsonData, jsonParseError) = HttpHelper.parseJsonData(newData)
                    if jsonParseError != nil {
                        completionHandler(success: false, errorMsg: jsonParseError!.localizedDescription)
                        return
                    }
                    
                    //store user id
                    if let account = jsonData["account"] as? [String: AnyObject] {
                        if let key = account["key"] as? String {
                            self.uniqueKey = key
                        } else {
                            completionHandler(success: false, errorMsg: "Unable to get login details from server: key")
                            return
                        }
                    } else {
                        completionHandler(success: false, errorMsg: "Unable to get login details from server: account")
                        return
                    }
                    
                    //store session id
                    if let session = jsonData["session"] as? [String: AnyObject] {
                        if let id = session["id"] as? String {
                            self.sessionId = id
                        } else {
                            completionHandler(success: false, errorMsg: "Unable to get login details from server: id")
                            return
                        }
                    } else {
                        completionHandler(success: false, errorMsg: "Unable to get login details from server: session")
                        return
                    }
                    
                    //store necessary udacity user info
                    self._fetchAndStoreUserDetail(uniqueKey: self.uniqueKey!, completionHandler: completionHandler)
                    
                    
                    //return true to callback to indicate success
                    completionHandler(success: true, errorMsg: "")
                    
                } else {  //failure
                    
                    //parse json data which contains an error message on failure
                    let (jsonData, jsonParseError) = HttpHelper.parseJsonData(newData)
                    if jsonParseError != nil {
                        completionHandler(success: false, errorMsg: jsonParseError!.localizedDescription)
                        return
                    }
                    
                    //get error message from server response
                    if let jsonDataError = jsonData["error"] as? String {
                        completionHandler(success: false, errorMsg: jsonDataError)
                    } else {
                        completionHandler(success: false, errorMsg: "Unable to login: status code \(httpResponse.statusCode)")
                    }
                    
                    return
                    
                }
            }
        )
        
    }
    
    //logout method
    func logout(completionHandler: (success: Bool, errorMsg: String)->Void) {
        
        //make http DELETE request to udacity's rest api
        HttpHelper.makeHttpRequest(
            requestUrl: "https://www.udacity.com/api/session",
            requestMethod: "DELETE",
            requestRemoveXsrfToken: true,
            requestDataHandler: { data, response, error in
                
                //check for request error
                if error != nil {
                    completionHandler(success: false, errorMsg: error.localizedDescription)
                    return
                }
                
                //check status code to determine success or failure
                let httpResponse = response as! NSHTTPURLResponse
                if httpResponse.statusCode == 200 {  //success
                    
                    //remove stored info
                    self.firstName = nil
                    self.lastName = nil
                    self.uniqueKey = nil
                    self.sessionId = nil
                    
                    //return true to callback to indicate sucess
                    completionHandler(success: true, errorMsg: "")
                    return
                    
                } else {  //failure
                    
                    //return false to callback to indicate failure
                    completionHandler(success: false, errorMsg: "Unable to logout: status code \(httpResponse.statusCode)")
                    return
                    
                }
            }
        )
        
    }
    
    //helper method to fetch and store necessary user details
    private func _fetchAndStoreUserDetail(#uniqueKey: String, completionHandler: (success: Bool, errorMsg: String)->Void) {
        
        //make http GET request to udacity's rest api
        HttpHelper.makeHttpRequest(
            requestUrl: "https://www.udacity.com/api/users/\(uniqueKey)",
            requestMethod: "GET",
            requestDataHandler: { data, response, error in
                
                //check for request error
                if error != nil {
                    completionHandler(success: false, errorMsg: error.localizedDescription)
                    return
                }
                
                //get subset of raw response (format of udacity response)
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                
                //parse json data
                let (jsonData, jsonParseError) = HttpHelper.parseJsonData(newData)
                if jsonParseError != nil {
                    completionHandler(success: false, errorMsg: jsonParseError!.localizedDescription)
                    return
                }
                
                //extract user from parsed json data
                if let userInfo = jsonData["user"] as? [String: AnyObject] {
                    
                    //extract first name
                    if let firstName = userInfo["first_name"] as? String {
                        self.firstName = firstName
                    } else {
                        completionHandler(success: false, errorMsg: "Unable to get user details from server: firstName")
                        return
                    }
                    
                    //extract last name
                    if let lastName = userInfo["last_name"] as? String {
                        self.lastName = lastName
                    } else {
                        completionHandler(success: false, errorMsg: "Unable to get user details from server: lastName")
                        return
                    }

                } else {
                    
                    completionHandler(success: false, errorMsg: "Unable to get user details from server: user")
                    return
                    
                }
                
            }
        )
        
    }
    
}