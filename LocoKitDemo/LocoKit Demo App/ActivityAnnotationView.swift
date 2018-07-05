//
//  ActivityAnnotationView.swift
//  LocoKit Demo App
//
//  Created by Ievgen Pavliuk on 6/30/18.
//  Copyright © 2018 Big Paua. All rights reserved.
//

import MapKit

class ActivityAnnotationView: MKAnnotationView {

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
