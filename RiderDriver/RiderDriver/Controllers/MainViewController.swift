//
//  MainViewController.swift
//  RiderDriver
//
//  Created by Neo Ighodaro on 19/02/2018.
//  Copyright © 2018 CreativityKills Co. All rights reserved.
//

import UIKit
import Alamofire
import GoogleMaps
import PusherSwift

class MainViewController: UIViewController, GMSMapViewDelegate {

    var status: RideStatus!
    var locationMarker: GMSMarker!
    
    var pusher = Pusher(
        withAppKey: AppConstants.PUSHER_KEY,
        options: PusherClientOptions(host: .cluster(AppConstants.PUSHER_CLUSTER))
    )

    @IBOutlet weak var riderName: UILabel!
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var requestView: UIView!
    @IBOutlet weak var noRequestsView: UIView!

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var statusButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        status = .Neutral
        requestView.isHidden = true
        cancelButton.isHidden = true
        noRequestsView.isHidden = false
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(changeStatusFromPushNotification),
            name: Notification.Name("status"),
            object: nil
        )
        
        findNewRequests()

        Timer.scheduledTimer(
            timeInterval: 2,
            target: self,
            selector: #selector(findNewRequests),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc private func changeStatusFromPushNotification(notification: Notification) {
        guard
            let data = notification.userInfo as? [String: RideStatus],
            let status = data["status"] else { return }
        
        sendStatusChange(status) { successful in
            guard successful else { return }
            
            if status == .Neutral {
                self.status = .FoundRide
                self.cancelButtonPressed(UIButton())
            }
            
            if status == .FoundRide {
                self.status = .Searching
                self.statusButtonPressed(UIButton())
            }
        }
    }
    
    private func listenForStatusUpdates() {
        let channel = pusher.subscribe(channelName: "cabs")
        
        let _ = channel.bind(eventName: "status-update") { data in
            if let data = data as? [String: AnyObject] {
                if let status = data["status"] as? String, let rideStatus = RideStatus(rawValue: status) {
                    if rideStatus == .Neutral {
                        self.status = .Neutral
                        self.cancelButtonPressed(UIButton())
                    }
                }
            }
        }
        
        pusher.connect()
    }
    
    @objc private func findNewRequests() {
        guard status == .Neutral else { return }
        
        Alamofire.request(AppConstants.API_URL + "/pending-rider")
            .validate()
            .responseJSON { response in
                guard response.result.isSuccess,
                    let data = response.result.value as? [String:AnyObject] else { return }
                
                self.loadRequestForRider(Rider(data: data))
            }
    }
    
    private func loadRequestForRider(_ rider: Rider) {
        mapView.camera = GMSCameraPosition.camera(withLatitude:rider.latitude, longitude:rider.longitude, zoom:15.0)
        mapView.delegate = self
        
        locationMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: rider.latitude, longitude: rider.longitude))
        locationMarker.map = mapView
        
        status = .Searching
        cancelButton.isHidden = false
        statusButton.setTitle("Accept Trip", for: .normal)
        
        riderName.text = rider.name
        requestView.isHidden = false
        noRequestsView.isHidden = true
    }
    
    private func sendStatusChange(_ status: RideStatus, handler: @escaping(Bool) -> Void) {
        Alamofire.request(AppConstants.API_URL + "/status", method: .post, parameters: ["status": status.rawValue])
            .validate()
            .responseJSON { response in
                guard response.result.isSuccess,
                    let data = response.result.value as? [String: Bool] else { return handler(false) }
                
                handler(data["status"]!)
            }
    }
    
    private func getNextStatus(after status: RideStatus) -> RideStatus {
        switch self.status! {
        case .Neutral,
             .Searching: return .FoundRide
        case .FoundRide: return .OnTrip
        case .OnTrip: return .EndedTrip
        case .EndedTrip: return .Neutral
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        if status == .FoundRide || status == .Searching {
            sendStatusChange(.Neutral) { successful in
                if successful {
                    self.status = .Neutral
                    self.requestView.isHidden = true
                    self.noRequestsView.isHidden = false
                }
            }
        }
    }
    
    @IBAction func statusButtonPressed(_ sender: Any) {
        let nextStatus = getNextStatus(after: self.status)

        sendStatusChange(nextStatus) { successful in
            self.status = self.getNextStatus(after: nextStatus)

            switch self.status! {
            case .Neutral, .Searching:
                self.cancelButton.isHidden = true
            case .FoundRide:
                self.cancelButton.isHidden = false
                self.statusButton.setTitle("Start Trip", for: .normal)
            case .OnTrip:
                self.cancelButton.isHidden = true
                self.statusButton.setTitle("End Trip", for: .normal)
            case .EndedTrip:
                self.status = .Neutral
                self.noRequestsView.isHidden = false
                self.requestView.isHidden = true
                self.statusButton.setTitle("Accept Trip", for: .normal)
            }
        }
    }
}
