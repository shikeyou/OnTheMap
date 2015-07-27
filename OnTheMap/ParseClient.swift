//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Keng Siang Lee on 26/7/15.
//  Copyright (c) 2015 KSL. All rights reserved.
//

import Foundation
import MapKit

class ParseClient: NSObject {
    
    //constants
    let PARSE_REQUEST_LIMIT = 100
    
    //store parsed data as arrays of structs/objects
    var studentInfos: [StudentInfo] = []
    var annotations: [StudentInfoAnnotation] = []
    
    //singleton class function
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
    
    //method that posts student info to the server
    func postStudentInfo(studentInfo: StudentInfo, completionHandler: (success: Bool, errorMsg: String)->Void) {
        
        //make http POST request to parse's rest api
        HttpHelper.makeHttpRequest(
            requestUrl: "https://api.parse.com/1/classes/StudentLocation",
            requestMethod: "POST",
            requestAddValues: [("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", "X-Parse-Application-Id"), ("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", "X-Parse-REST-API-Key"), ("application/json", "Content-Type")],
            requestBody: "{\"uniqueKey\": \"\(studentInfo.uniqueKey)\", \"firstName\": \"\(studentInfo.firstName)\", \"lastName\": \"\(studentInfo.lastName)\",\"mapString\": \"\(studentInfo.mapString)\", \"mediaURL\": \"\(studentInfo.mediaUrl)\",\"latitude\": \(studentInfo.latitude), \"longitude\": \(studentInfo.longitude)}".dataUsingEncoding(NSUTF8StringEncoding),
            requestDataHandler: { data, response, error in
                
                //check for request error
                if error != nil {
                    completionHandler(success: false, errorMsg: error.localizedDescription)
                    return
                }
                
                //check status code to determine success or failure
                let httpResponse = response as! NSHTTPURLResponse
                if httpResponse.statusCode == 201 {  //success
                    completionHandler(success: true, errorMsg: "")
                } else {  //failure
                    completionHandler(success: false, errorMsg: "Unable to post: status code \(httpResponse.statusCode)")
                }
                
            }
        )
        
    }
    
    //method that fetches student info from the server
    func fetchStudentsInfo(completionHandler: (success: Bool, errorMsg: String)->Void) {
        
        //make http GET request from parse's rest api
        HttpHelper.makeHttpRequest(
            requestUrl: "https://api.parse.com/1/classes/StudentLocation?limit=\(PARSE_REQUEST_LIMIT)",
            requestMethod: "GET",
            requestAddValues: [("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", "X-Parse-Application-Id"), ("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", "X-Parse-REST-API-Key")],
            requestDataHandler: { data, response, error in
                
                //check for request error
                if error != nil {
                    completionHandler(success: false, errorMsg: error.localizedDescription)
                    return
                }
                
                //parse json data
                let (jsonData, jsonParseError) = HttpHelper.parseJsonData(data)
                if jsonParseError != nil {
                    completionHandler(success: false, errorMsg: jsonParseError!.localizedDescription)
                    return
                }
                
                //extract json data into StudentInformation array
                if let results = jsonData["results"] as? [AnyObject] {
                    
                    //clear the studentInfos array first
                    self.studentInfos.removeAll()
                    
                    //populate studentInfos array with StudentInfo that uses parsed data
                    for result in results {
                        let studentInfo = StudentInfo(dict: result as! [String: AnyObject])
                        self.studentInfos.append(studentInfo)
                        
                    }
                    
                    //return true to callback to indicate success
                    completionHandler(success: true, errorMsg: "")
                    
                } else {
                    
                    //return false to callback to indicate failure
                    completionHandler(success: false, errorMsg: "Unable to get student info details from server: results")
                }
                
            }
        )

    }
    
    //method that fetches student info from the server in the form of annotations for map
    func fetchAnnotations(completionHandler: (success: Bool, errorMsg: String)->Void) {
     
        //fetch student info first
        fetchStudentsInfo({ (success: Bool, errorMsg: String) -> Void in
            
            if success {
                
                //remove existing annotations first
                self.annotations.removeAll()
                
                //extract annotations from fetched student info
                for studentInfo in self.studentInfos {
                    let annotation = StudentInfoAnnotation(studentInfo: studentInfo)
                    self.annotations.append(annotation)
                }
                
                //return true to callback to indicate success
                completionHandler(success: true, errorMsg: "")
                
            } else {
                
                //return false to callback to indicate failure
                completionHandler(success: false, errorMsg: errorMsg)
                
            }
            
        })
    }
    
}