//
//  SharedManager.swift
//  Fitbit
//
//  Created by MOJAVE on 13/09/19.
//  Copyright © 2019 Partnerpeople. All rights reserved.
//

import UIKit
import Reachability
import CoreLocation

class SharedManager : NSObject {

    static let shared = SharedManager()
    var currentLocation = CLLocationCoordinate2D(latitude: 33.683319, longitude: -117.8701257)
    var member = Member(params: [:])
    var store = Store(params: [:])
    var fbFirstName = ""
    var fbLastName = ""
    var fbEmail = ""
}
