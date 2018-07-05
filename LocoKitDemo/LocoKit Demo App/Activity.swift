//
//  Activity.swift
//  LocoKit Demo App
//
//  Created by Ievgen Pavliuk on 6/30/18.
//  Copyright © 2018 Big Paua. All rights reserved.
//

import UIKit
import CoreMotion
import CoreLocation

class Activity: NSObject {
    
    var activity: CMMotionActivity
    var location: CLLocation
    
    init(activity: CMMotionActivity, location: CLLocation) {
        self.activity = activity
        self.location = location
    }
    
}
