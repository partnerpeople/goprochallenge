//
//  ViewController.swift
//  Project22
//
//  Created by TwoStraws on 19/08/2016.
//  Copyright © 2016 Paul Hudson. All rights reserved.
//

import CoreLocation
import UIKit
import FBSDKLoginKit
import MBProgressHUD
import Alamofire

class BeaconViewController: UIViewController, CLLocationManagerDelegate, UIScrollViewDelegate {
    @IBOutlet var distanceReading: UILabel!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet weak var signalStrength: SignalStrengthIndicator!
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.delegate = self
        }
    }
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    var slides:[Slide] = []
    
    var locationManager: CLLocationManager!
    
    struct DefaultValues {
        var maxFoundBeaconSeconds:Float = 1.0
        var minSignalLevel: Int = 0
        //var maxPlayButtonSeconds:Float = 10.0
        //var uuid:UUID = uuid_string_t("426C7565-4368-6172-6D42-6561636F6E72")
    }
    var foundBeaconSeconds:Float = DefaultValues().maxFoundBeaconSeconds
    var level: Int = DefaultValues().minSignalLevel
    var isPlayButtonShowed:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        view.backgroundColor = UIColor.gray
        playButton.isHidden = true
        progressView.isHidden = true
        signalStrength.isHidden = true
        
        //playButton.contentEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        self.navigationItem.title = "\(SharedManager.shared.member.firstName ?? "") \(SharedManager.shared.member.lastName ?? "")"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log Out", style: UIBarButtonItem.Style.plain, target: self, action: #selector(logoutButtonClicked))
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: signalStrength)
        //        let imgView = UIImageView(image: UIImage(named: "img_wheel"))
//        imgView.contentMode = .scaleAspectFit
//        self.navigationItem.titleView = imgView
        
        /// for slider
        slides = createSlides()
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        view.bringSubviewToFront(pageControl)
        //end for slider
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupSlideScrollView(slides: slides)
        //self.hideBeaconScanUIelements()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func logoutButtonClicked()
    {
        ViewController.logoutAction()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocationValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(newLocationValue.latitude) \(newLocationValue.longitude)")
        SharedManager.shared.currentLocation = newLocationValue
    }
    
    func startScanning() {
        let uuid = UUID(uuidString: "426C7565-4368-6172-6D42-6561636F6E72")!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 3838, minor: 4949, identifier: "MyBeacon")
        
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    func update(beacon_proximity: CLProximity,beacon_distance: CLLocationAccuracy ) {
        UIView.animate(withDuration: 0.8) { [unowned self] in
            switch beacon_proximity {
            case .unknown:
                self.view.backgroundColor = UIColor.lightGray
                self.updateSignal(value: 0)
                self.distanceReading.text = "Please visit one of our retail locations to play."
                self.resetFoundBeaconTimer()
            case .far:
                self.view.backgroundColor = UIColor.lightGray
                self.updateSignal(value: 2)
                //self.distanceReading.text = "FAR" + ":"+String(format: "%.2f", beacon_distance)+" m"
                self.distanceReading.text = "Please visit one of our retail locations to play."
                self.resetFoundBeaconTimer()
                
            case .near:
                self.view.backgroundColor = UIColor.lightGray
                self.updateSignal(value: 3)
                //self.distanceReading.text = "NEAR" + ":"+String(format: "%.2f", beacon_distance)+" m"
                self.distanceReading.text = "Please step closer to the display to begin the game."
                self.foundBeaconTimer()
                
            case .immediate:
                self.view.backgroundColor = UIColor(red: 71/255, green: 252/255, blue: 165/255, alpha: 1.0)
                self.updateSignal(value: 5)
                //self.distanceReading.text = "HERE" + ":" + String(format: "%.2f", beacon_distance)+" m"
                self.distanceReading.text = "Please step closer to the display to begin the game."
                self.foundBeaconTimer()
            @unknown default: break
                
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            let beacon = beacons[0]
            update(beacon_proximity: beacon.proximity,beacon_distance: beacon.accuracy )
        } else {
            update(beacon_proximity: .unknown, beacon_distance: 0)
        }
    }
    func updateProgressView(foundBeaconSeconds:Float){
        if self.playButton.isHidden{
            self.showBeaconScanUIelements()
            let progress:Float = 1-foundBeaconSeconds/DefaultValues().maxFoundBeaconSeconds
            self.progressView.setProgress(progress, animated: true)
        }
        
    }
    func resetFoundBeaconTimer(){
        if self.playButton.isHidden{
        foundBeaconSeconds = DefaultValues().maxFoundBeaconSeconds
        updateProgressView(foundBeaconSeconds: Float(foundBeaconSeconds))
        self.progressView.isHidden = true
        }
    }
   
    func foundBeaconTimer() {
        if self.playButton.isHidden{
            foundBeaconSeconds -= 1
            updateProgressView(foundBeaconSeconds: foundBeaconSeconds)
            if foundBeaconSeconds <= 0 {
                UIView.transition(with: self.view,
                                  duration: 0.9,
                                  options: [.transitionCrossDissolve, .allowUserInteraction],
                                  animations: {
                                    self.hideBeaconScanUIelements()
                },completion: nil)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) { // Change `2.0` to the desired number of seconds.
                    self.playButton.isHidden = true
                }
            }
        }
    }
    func hideBeaconScanUIelements()
    {
        self.playButton.isHidden = false
        
        self.progressView.isHidden = true
        self.signalStrength.isHidden = true
        self.distanceReading.isHidden = true

    }
    func showBeaconScanUIelements()
    {
        self.progressView.isHidden = false
        self.signalStrength.isHidden = false
        self.distanceReading.isHidden = false
        
        self.playButton.isHidden = true
    }
    func updateSignal(value: Int) {
        if let level = SignalStrengthIndicator.Level(rawValue: value) {
            signalStrength.level = level
            self.level = value
        }
        else
        {
            print("No Value")
        }
    }
    
    func getStoreDetail()
    {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.label.text = "Fetching Store Detail..."
        
        let UrlStr = APIConstants.BasePath + APIPaths.getStoreDetailByGeoCoordinates
        var params = [String : String]()
        params["lat"] = String(SharedManager.shared.currentLocation.latitude)
        params["lon"] = String(SharedManager.shared.currentLocation.longitude)
        print("params = \(params)")
        
        var postString = "{"
        for item in params{
            postString += "\"\(item.key)\":\"\(item.value)\","
        }
        postString.removeLast()
        postString += "}"
        
        print("postString = \(postString)")
        let ajsonData = postString.data(using: .utf8)
        
        let enco : ParameterEncoding = MyCustomEncoding(data: ajsonData!)
        Alamofire.request(UrlStr, method: .post, parameters: [:], encoding: enco, headers: ["Content-Type":"application/json"]).validate()
            .responseJSON { response in
                
                switch response.result {
                case .success:
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")
                        MBProgressHUD.hide(for: self.view, animated: true)
                        
                        if let jsonResponse = JSON as? Dictionary<String, Any>{
                            
                            if (jsonResponse["status"] as? String == "success"){
                                
                                if let storeJsonDict = jsonResponse["store_data"] as? Dictionary<String, Any>{
                                    print(storeJsonDict)
                                    SharedManager.shared.store = Store(params: storeJsonDict)
                                    
                                    self.showGameView()
                                }
                            }
                            else
                            {
                                let msg = (jsonResponse["message"] as? String)
                                let alert = UIAlertController(title: "Opps!", message: msg, preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                case .failure(let error):
                    
                    MBProgressHUD.hide(for: self.view, animated: true)
                    print(error.localizedDescription)
                    let alert = UIAlertController(title: "Fail to connect", message: "No internet connectivity.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
        }
    }
    
    @IBAction func playAction(_ sender: AnyObject) {
        // Retrieve the QRCode content
       //self.showGameView()
        self.getStoreDetail()
    }
    func showGameView()
    {
        
        if let gameVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SpinViewController") as? SpinViewController{
            self.navigationController?.pushViewController(gameVC, animated: true)
        }
    }

    /// below for slider
    func createSlides() -> [Slide] {
        
        let slide1:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide1.imageView.image = UIImage(named: "1")
        slide1.labelTitle.text = ""
        slide1.labelDesc.text = "Welcome to the “Find your Fit” challenge. Embark on your personal fitness journey today!"
        
        let slide2:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide2.imageView.image = UIImage(named: "2")
        slide2.labelTitle.text = ""
        slide2.labelDesc.text = "Join us for our daily challenges at your favorite retailer and earn special prizes."
        
        let slide3:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide3.imageView.image = UIImage(named: "3")
        slide3.labelTitle.text = ""
        slide3.labelDesc.text = "Redeem your winnings right away or stockpile your points for greater rewards."
        
        let slide4:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide4.imageView.image = UIImage(named: "4")
        slide4.labelTitle.text = ""
        slide4.labelDesc.text = "Keep an eye out for our grand prize jackpot"
        
        
        let slide5:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide5.imageView.image = UIImage(named: "5")
        slide5.labelTitle.text = ""
        slide5.labelDesc.text = "Stay in the loop about all our latest news and products"
        
        return [slide1, slide2, slide3, slide4, slide5]
    }
    
    
    func setupSlideScrollView(slides : [Slide]) {
        
        
        while scrollView.subviews.count > 0 {
            scrollView.subviews[0].removeFromSuperview()
        }
        //scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(slides.count), height: scrollView.frame.height)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: scrollView.frame.width * CGFloat(i), y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
            scrollView.addSubview(slides[i])
        }
        print("view.frame.height = \(view.frame.size.height)")
        print("scrollView.frame.height = \(scrollView.frame.size.height)")
        print("scrollView.subviews.count = \(scrollView.subviews.count)")
    }
    
    
    /*
     * default function called when view is scolled. In order to enable callback
     * when scrollview is scrolled, the below code needs to be called:
     * slideScrollView.delegate = self or
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
        
        let maximumHorizontalOffset: CGFloat = scrollView.contentSize.width - scrollView.frame.width
        let currentHorizontalOffset: CGFloat = scrollView.contentOffset.x
        
        // vertical
        let maximumVerticalOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.height
        let currentVerticalOffset: CGFloat = scrollView.contentOffset.y
        
        let percentageHorizontalOffset: CGFloat = currentHorizontalOffset / maximumHorizontalOffset
        let percentageVerticalOffset: CGFloat = currentVerticalOffset / maximumVerticalOffset
        
        
        /*
         * below code changes the background color of view on paging the scrollview
         */
        //        self.scrollView(scrollView, didScrollToPercentageOffset: percentageHorizontalOffset)
        
        
        /*
         * below code scales the imageview on paging the scrollview
         */
        let percentOffset: CGPoint = CGPoint(x: percentageHorizontalOffset, y: percentageVerticalOffset)
        
        if(percentOffset.x > 0 && percentOffset.x <= 0.25) {
            
            slides[0].imageView.transform = CGAffineTransform(scaleX: (0.25-percentOffset.x)/0.25, y: (0.25-percentOffset.x)/0.25)
            slides[1].imageView.transform = CGAffineTransform(scaleX: percentOffset.x/0.25, y: percentOffset.x/0.25)
            
        } else if(percentOffset.x > 0.25 && percentOffset.x <= 0.50) {
            slides[1].imageView.transform = CGAffineTransform(scaleX: (0.50-percentOffset.x)/0.25, y: (0.50-percentOffset.x)/0.25)
            slides[2].imageView.transform = CGAffineTransform(scaleX: percentOffset.x/0.50, y: percentOffset.x/0.50)
            
        } else if(percentOffset.x > 0.50 && percentOffset.x <= 0.75) {
            slides[2].imageView.transform = CGAffineTransform(scaleX: (0.75-percentOffset.x)/0.25, y: (0.75-percentOffset.x)/0.25)
            slides[3].imageView.transform = CGAffineTransform(scaleX: percentOffset.x/0.75, y: percentOffset.x/0.75)
            
        } else if(percentOffset.x > 0.75 && percentOffset.x <= 1) {
            slides[3].imageView.transform = CGAffineTransform(scaleX: (1-percentOffset.x)/0.25, y: (1-percentOffset.x)/0.25)
            slides[4].imageView.transform = CGAffineTransform(scaleX: percentOffset.x, y: percentOffset.x)
        }
    }
    
    
    
    
    func scrollView(_ scrollView: UIScrollView, didScrollToPercentageOffset percentageHorizontalOffset: CGFloat) {
        if(pageControl.currentPage == 0) {
            //Change background color to toRed: 103/255, fromGreen: 58/255, fromBlue: 183/255, fromAlpha: 1
            //Change pageControl selected color to toRed: 103/255, toGreen: 58/255, toBlue: 183/255, fromAlpha: 0.2
            //Change pageControl unselected color to toRed: 255/255, toGreen: 255/255, toBlue: 255/255, fromAlpha: 1
            
            let pageUnselectedColor: UIColor = fade(fromRed: 255/255, fromGreen: 255/255, fromBlue: 255/255, fromAlpha: 1, toRed: 103/255, toGreen: 58/255, toBlue: 183/255, toAlpha: 1, withPercentage: percentageHorizontalOffset * 3)
            pageControl.pageIndicatorTintColor = pageUnselectedColor
            
            
            let bgColor: UIColor = fade(fromRed: 103/255, fromGreen: 58/255, fromBlue: 183/255, fromAlpha: 1, toRed: 255/255, toGreen: 255/255, toBlue: 255/255, toAlpha: 1, withPercentage: percentageHorizontalOffset * 3)
            slides[pageControl.currentPage].backgroundColor = bgColor
            
            let pageSelectedColor: UIColor = fade(fromRed: 81/255, fromGreen: 36/255, fromBlue: 152/255, fromAlpha: 1, toRed: 103/255, toGreen: 58/255, toBlue: 183/255, toAlpha: 1, withPercentage: percentageHorizontalOffset * 3)
            pageControl.currentPageIndicatorTintColor = pageSelectedColor
        }
    }
    
    
    func fade(fromRed: CGFloat,
              fromGreen: CGFloat,
              fromBlue: CGFloat,
              fromAlpha: CGFloat,
              toRed: CGFloat,
              toGreen: CGFloat,
              toBlue: CGFloat,
              toAlpha: CGFloat,
              withPercentage percentage: CGFloat) -> UIColor {
        
        let red: CGFloat = (toRed - fromRed) * percentage + fromRed
        let green: CGFloat = (toGreen - fromGreen) * percentage + fromGreen
        let blue: CGFloat = (toBlue - fromBlue) * percentage + fromBlue
        let alpha: CGFloat = (toAlpha - fromAlpha) * percentage + fromAlpha
        
        // return the fade colour
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
   /// end for slider
}

