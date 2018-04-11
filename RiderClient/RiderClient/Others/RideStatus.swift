//
//  RideStatus.swift
//  RiderClient
//
//  Created by Neo Ighodaro on 13/02/2018.
//  Copyright © 2018 CreativityKills Co. All rights reserved.
//x

import Foundation

enum RideStatus: String {
    case Neutral = "Neutral"
    case Searching = "Searching"
    case FoundRide = "FoundRide"
    case Arrived = "Arrived"
    case OnTrip = "OnTrip"
    case EndedTrip = "EndedTrip"
}
