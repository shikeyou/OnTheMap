//
//  StudentInfo.swift
//  OnTheMap
//
//  Created by Keng Siang Lee on 24/7/15.
//  Copyright (c) 2015 KSL. All rights reserved.
//

import Foundation

struct StudentInfo {
    
    var uniqueKey: String  //user id
    var firstName: String
    var lastName: String
    var latitude: Float
    var longitude: Float
    var mapString: String  //text string used to search for this coordinate
    var mediaUrl: NSURL
    
    //main initializer
    init(uniqueKey: String, firstName: String, lastName: String, latitude: Float, longitude: Float, mapString: String, mediaUrl: NSURL!) {
        self.uniqueKey = uniqueKey
        self.firstName = firstName
        self.lastName = lastName
        self.latitude = latitude
        self.longitude = longitude
        self.mapString = mapString
        self.mediaUrl = mediaUrl!
    }
    
    //initializer that takes in a dictionary obtained from parsing data obtained from server
    init(dict: [String: AnyObject]) {
        self.uniqueKey = dict["uniqueKey"] as! String
        self.firstName = dict["firstName"] as! String
        self.lastName = dict["lastName"] as! String
        self.mediaUrl = NSURL(string: dict["mediaURL"] as! String)!
        self.mapString = dict["mapString"] as! String
        self.latitude = dict["latitude"] as! Float
        self.longitude = dict["longitude"] as! Float
    }
    
}
