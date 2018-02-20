//
//  MainViewController.swift
//  RiderClient
//
//  Created by Neo Ighodaro on 12/02/2018.
//  Copyright © 2018 CreativityKills Co. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import PusherSwift

class MainViewController: UIViewController, GMSMapViewDelegate {

    let pusher = Pusher(
        key: AppConstants.PUSHER_KEY,
        options: PusherClientOptions(host: .cluster(AppConstants.PUSHER_CLUSTER))
    )

    var latitude = 37.388064
    var longitude = -122.088426

    var locationMarker: GMSMarker!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingOverlay: UIView!

    @IBOutlet weak var orderButton: UIButton!
    @IBOutlet weak var orderStatusView: UIView!
    @IBOutlet weak var orderStatus: UILabel!
    @IBOutlet weak var cancelButton: UIButton!

    @IBOutlet weak var driverDetailsView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.camera = GMSCameraPosition.camera(withLatitude:latitude, longitude:longitude, zoom:15.0)
        mapView.delegate = self
        locationMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        locationMarker.map = mapView

        orderStatusView.layer.cornerRadius = 5
        orderStatusView.layer.shadowOffset = CGSize(width: 0, height: 0)
        orderStatusView.layer.shadowColor = UIColor.black.cgColor
        orderStatusView.layer.shadowOpacity = 0.3
        
        updateView(status: .Neutral, msg: nil)
        listenForUpdates()
    }
    
    @IBAction func orderButtonPressed(_ sender: Any) {
        updateView(status: .Searching, msg: nil)
        
        sendRequest(.post) { successful in
            guard successful else {
                return self.updateView(status: .Neutral, msg: "😔 No drivers available.")
            }
        }
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        sendRequest(.delete) { successful in
            guard successful == false else {
                return self.updateView(status: .Neutral, msg: nil)
            }
        }
    }
    
    private func updateView(status: RideStatus, msg: String?) {
        switch status {
        case .Neutral:
            driverDetailsView.isHidden = true
            loadingOverlay.isHidden = true
            orderStatus.text = msg != nil ? msg! : "💡 Tap the button below to get a cab."
            orderButton.setTitleColor(UIColor.white, for: .normal)
            orderButton.isHidden = false
            cancelButton.isHidden = true
            loadingIndicator.stopAnimating()
            
        case .Searching:
            loadingOverlay.isHidden = false
            orderStatus.text = msg != nil ? msg! : "🚕 Looking for a cab close to you..."
            orderButton.setTitleColor(UIColor.clear, for: .normal)
            loadingIndicator.startAnimating()

        case .FoundRide:
            driverDetailsView.isHidden = false
            loadingOverlay.isHidden = true
            orderStatus.text = msg != nil ? msg! : "😎 Found a ride, your ride is on it's way"
            orderButton.isHidden = true
            cancelButton.isHidden = false
            loadingIndicator.stopAnimating()

        case .OnTrip:
            orderStatus.text = msg != nil ? msg! : "🙂 Your ride is in progress. Enjoy."
            cancelButton.isEnabled = false

        case .EndedTrip:
            orderStatus.text = msg != nil ? msg! : "🌟 Ride complete. Have a nice day!"
            orderButton.setTitleColor(UIColor.white, for: .normal)
            driverDetailsView.isHidden = true
            cancelButton.isEnabled = true
            orderButton.isHidden = false
            cancelButton.isHidden = true
        }
    }
    
    private func sendRequest(_ method: HTTPMethod, handler: @escaping(Bool) -> Void) {
        Alamofire.request(AppConstants.API_URL + "/request", method: method)
            .validate()
            .responseJSON { response in
                guard response.result.isSuccess,
                    let data = response.result.value as? [String:Bool],
                    let status = data["status"] else { return handler(false) }
                
                handler(status)
            }
    }
    
    private func listenForUpdates() {
        let channel = pusher.subscribe("cabs")
        
        let _ = channel.bind(eventName: "status-update") { data in
            if let data = data as? [String:AnyObject] {
                if let status = data["status"] as? String, let rideStatus = RideStatus(rawValue: status) {
                    self.updateView(status: rideStatus, msg: nil)
                }
            }
        }
        
        pusher.connect()
    }
}
