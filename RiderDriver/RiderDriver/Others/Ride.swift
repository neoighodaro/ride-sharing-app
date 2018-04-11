//
//  Ride.swift
//  RiderDriver
//
//  Created by Neo Ighodaro on 19/02/2018.
//  Copyright © 2018 CreativityKills Co. All rights reserved.
//

import Foundation

struct Rider {
    let name: String
    let longitude: Double
    let latitude: Double
    
    init(data: [String:AnyObject]) {
        self.name = data["name"] as! String
        self.longitude = data["longitude"] as! Double
        self.latitude = data["latitude"] as! Double
    }
}

enum RideStatus: String {
    case Neutral = "Neutral"
    case Searching = "Searching"
    case FoundRide = "FoundRide"
    case Arrived = "Arrived"
    case OnTrip = "OnTrip"
    case EndedTrip = "EndedTrip"
}
