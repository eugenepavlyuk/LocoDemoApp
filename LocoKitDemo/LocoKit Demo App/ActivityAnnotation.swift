//
//  ActivityAnnotation.swift
//  LocoKit Demo App
//
//  Created by Ievgen Pavliuk on 6/30/18.
//  Copyright © 2018 Big Paua. All rights reserved.
//

import MapKit
import LocoKit

class ActivityAnnotation: NSObject, MKAnnotation {

    var coordinate: CLLocationCoordinate2D
    var activity: Activity
    
    init(coordinate: CLLocationCoordinate2D, activity: Activity) {
        self.coordinate = coordinate
        self.activity = activity
        super.init()
    }
    
    var view: ActivityAnnotationView {
        let annotationView = ActivityAnnotationView(annotation: self, reuseIdentifier: nil)
        
        if self.activity.activity.automotive {
            annotationView.image = UIImage(named: "auto")
        } else if self.activity.activity.walking {
            annotationView.image = UIImage(named: "walking")
        } else if self.activity.activity.running {
            annotationView.image = UIImage(named: "running")
        } else if self.activity.activity.cycling {
            annotationView.image = UIImage(named: "cycling")
        }
        
        return annotationView
    }
    
}
