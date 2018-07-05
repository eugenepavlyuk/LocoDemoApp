//
//  ViewController.swift
//  LocoKit Demo App
//
//  Created by Matt Greenfield on 10/07/17.
//  Copyright © 2017 Big Paua. All rights reserved.
//

import LocoKit
import SwiftNotes
import Cartography
import CoreLocation
import CoreMotion

class ViewController: UIViewController {

    var currentActivity: CMMotionActivity?
    var activities: [Activity] = [Activity]()
    
    /**
     The recording manager for Timeline Items (Visits and Paths)

     - Note: Use a plain TimelineManager() instead if you don't require persistent SQL storage
    **/
    let timeline: TimelineManager = PersistentTimelineManager()

    lazy var mapView = { return MapView(timeline: self.timeline) }()

    // MARK: controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIDevice.current.isBatteryMonitoringEnabled = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(tappedStart))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logs", style: .plain, target: self, action: #selector(showLogs))
        
        // the CoreLocation / CoreMotion recording singleton
        let loco = LocomotionManager.highlander

        /** EXAMPLE SETTINGS **/

        // enable this if you have an API key and want to determine activity types
        timeline.activityTypeClassifySamples = false

        // this accuracy level is excessive, and is for demo purposes only.
        // the default value (30 metres) best balances accuracy with energy use.
        loco.maximumDesiredLocationAccuracy = kCLLocationAccuracyNearestTenMeters

        // this is independent of the user's setting, and will show a blue bar if user has denied "always"
        loco.locationManager.allowsBackgroundLocationUpdates = true

        /** TIMELINE STARTUP **/

        // restore the active timeline items from local db
        if let timeline = timeline as? PersistentTimelineManager {
            timeline.bootstrapActiveItems()
        }

        /** EXAMPLE OBSERVERS **/

        // observe new timeline items
        when(timeline, does: .newTimelineItem) { _ in
            onMain {
                let items = self.itemsToShow
                self.mapView.update(with: items)
                self.mapView.update(with: self.activities)
            }
        }

        // observe timeline item updates
        when(timeline, does: .updatedTimelineItem) { _ in
            
            if loco.locomotionSample().location != nil {
                NSLog("coordinates: \(String(describing: loco.locomotionSample().location!))")
            }
            
            let device = UIDevice.current
            let level = device.batteryLevel * 100
            NSLog("battery level : \(level) %")
            
            onMain {
                let items = self.itemsToShow
                self.mapView.update(with: items)
                self.mapView.update(with: self.activities)
            }
        }

        // observe incoming location / locomotion updates
        when(loco, does: .locomotionSampleUpdated) { _ in
            self.locomotionSampleUpdated()
        }

        // observe changes in the recording state (recording / sleeping)
        when(loco, does: .recordingStateChanged) { _ in
            // don't log every type of state change, because it gets noisy
            if loco.recordingState == .recording || loco.recordingState == .off {
                NSLog(".recordingStateChanged (\(loco.recordingState.rawValue))")
            }
            self.mapView.update(with: self.itemsToShow)
            self.mapView.update(with: self.activities)
        }

        // observe changes in the moving state (moving / stationary)
        when(loco, does: .movingStateChanged) { _ in
            NSLog(".movingStateChanged (\(loco.movingState.rawValue))")
        }

        when(loco, does: .startedSleepMode) { _ in
            NSLog(".startedSleepMode")
        }

        when(loco, does: .stoppedSleepMode) { _ in
            NSLog(".stoppedSleepMode")
        }
        
        when(loco, does: .activityDetected) { notification in
            let userInfo = notification.userInfo
            if let activity = userInfo?["activity"] as? CMMotionActivity {
                if activity.stationary == false {
                
                    let location = loco.locomotionSample().location
                    
                    if let location = location {
                        let newActivity = Activity(activity: activity, location: location)
                        
                        if self.currentActivity == nil {
                            self.currentActivity = activity
                            self.activities.append(newActivity)
                        } else {
                            
                            if self.currentActivity!.automotive != activity.automotive || self.currentActivity!.cycling != activity.cycling ||
                            self.currentActivity!.walking != activity.walking || self.currentActivity!.running != activity.running {
                                
                                self.currentActivity = activity
                                self.activities.append(newActivity)
                            }
                            
                        }
                    }
                }
            }
        }

        when(.UIApplicationDidReceiveMemoryWarning) { _ in
            
        }

        // view tree stuff
        view.backgroundColor = .white
        buildViewTree()

        // get things started by asking permission
        loco.requestLocationPermission()
    }
    
    @objc func showLogs() {
        let viewController: UIViewController? = (SuperLogger.sharedInstance().getListView() as? UIViewController)
        if let viewController = viewController {
            let navigationController = UINavigationController(rootViewController: viewController)
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return mapView.mapType == .standard ? .default : .lightContent
    }
  
    // MARK: process incoming locations
    
    func locomotionSampleUpdated() {

    }

    // MARK: tap actions
    
    @objc func tappedStart() {
        NSLog("tappedStart()")

        timeline.startRecording()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Stop", style: .plain, target: self, action: #selector(tappedStop))
    }
    
    @objc func tappedStop() {
        NSLog("tappedStop()")

        timeline.stopRecording()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(tappedStart))
    }
    
    @objc func tappedClear() {
        DebugLog.deleteLogFile()
    }
    
    // MARK: view tree building
    
    func buildViewTree() {        
        view.addSubview(mapView)
        constrain(mapView) { map in
            map.top == map.superview!.top
            map.left == map.superview!.left
            map.right == map.superview!.right
            map.height == map.superview!.height
        }
    }

    func update() {
        let items = itemsToShow
        mapView.update(with: items)
        mapView.update(with: self.activities)
    }

    var itemsToShow: [TimelineItem] {
        if timeline is PersistentTimelineManager { return persistentItemsToShow }

        guard let currentItem = timeline.currentItem else { return [] }

        // collect the linked list of timeline items
        var items: [TimelineItem] = [currentItem]
        var workingItem = currentItem
        while let previous = workingItem.previousItem {
            items.append(previous)
            workingItem = previous
        }

        return items
    }

    var persistentItemsToShow: [TimelineItem] {
        guard let timeline = timeline as? PersistentTimelineManager else { return [] }

        // make sure the db is fresh
        timeline.store.save()

        // feth all items in the past 24 hours
        let boundary = Date(timeIntervalSinceNow: -60 * 60 * 24)
        return timeline.store.items(where: "deleted = 0 AND endDate > ? ORDER BY endDate DESC", arguments: [boundary])
    }
}

