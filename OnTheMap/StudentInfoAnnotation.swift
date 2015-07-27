//
//  StudentInfoAnnotation.swift
//  OnTheMap
//
//  Created by Keng Siang Lee on 27/7/15.
//  Copyright (c) 2015 KSL. All rights reserved.
//

import Foundation
import MapKit

//This class is specifically for storing student info as an annotation for placing on map
class StudentInfoAnnotation: NSObject, MKAnnotation {
    
    var title: String
    var subtitle: String
    var coordinate: CLLocationCoordinate2D
    var mediaUrl: String
    
    //main initializer
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, mediaUrl: String) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.mediaUrl = mediaUrl
    }
    
    //convenience initializer that takes in a StudentInfo
    convenience init(studentInfo: StudentInfo) {
        self.init(
            title: "\(studentInfo.firstName) \(studentInfo.lastName)",
            subtitle: studentInfo.mediaUrl.absoluteString!,
            coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(studentInfo.latitude), longitude: CLLocationDegrees(studentInfo.longitude)),
            mediaUrl: studentInfo.mediaUrl.absoluteString!
        )
    }
    
}