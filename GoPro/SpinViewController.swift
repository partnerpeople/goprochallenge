//
//  SpinViewController.swift
//  Fitbit
//
//  Created by MOJAVE on 16/09/19.
//  Copyright © 2019 Partnerpeople. All rights reserved.
//

import UIKit
import AudioToolbox
import MBProgressHUD
import Alamofire

class SpinViewController: UIViewController {

    @IBOutlet weak var viewContainerSpin: UIView!
    @IBOutlet weak var spinWheelImgView: UIImageView!
    var totalAngle : CGFloat = 360
    var currentAngle : CGFloat = 60
    var pointsEarned : Int = 0
    var percentageDiscout = 5
    
    var wheelSound = SystemSoundID()
    @IBOutlet weak var spinButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "spin_short", ofType: "mp3", inDirectory: "/")!)
        let baseURL1 : CFURL = url as CFURL
        
        AudioServicesCreateSystemSoundID (baseURL1, &self.wheelSound)
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "\(SharedManager.shared.member.firstName ?? "") \(SharedManager.shared.member.lastName ?? "")"
        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log Out", style: UIBarButtonItem.Style.plain, target: self, action: #selector(logoutButtonClicked))
    }
    
    @objc func logoutButtonClicked()
    {
        ViewController.logoutAction()
        self.navigationController?.popToRootViewController(animated: true)
    }

    func showNumbersOnSpinWheel()
    {
        for i in 0 ..< 6{
            
            let radius : Double = Double(self.viewContainerSpin.frame.size.width/3.25)
            let angle : Double = (60.0 * Double(i)) + 30.0
            let sinT = sin(angle * .pi / 180)
            let cosT = cos(angle * .pi / 180)
            let x1 = radius*sinT
            let y1 = radius*cosT
            
            let cX = self.spinWheelImgView.frame.width/2
            let cY = self.spinWheelImgView.frame.height/2
            
            print("cX = \(cX) , cY = \(cY)")
            
            let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
            lbl.text = "\((i+1)*5)%"
            lbl.textAlignment = NSTextAlignment.center
            lbl.font = UIFont(name: "Seville-Bold", size: 25)
            lbl.textColor = UIColor.white
            lbl.center = CGPoint(x: cX+CGFloat(x1), y: cY+CGFloat(y1) )
            
            print("x = \(CGFloat(x1)), y = \(CGFloat(y1))")
            self.viewContainerSpin.addSubview(lbl)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if self.viewContainerSpin.subviews.count == 1
        {
            self.showNumbersOnSpinWheel()
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewContainerSpin.transform = CGAffineTransform(rotationAngle: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK:ButtonClickEvents
    
    @IBAction func OnSpinButtonClicked(_ sender: Any) {
    
        spinButton.isEnabled = false
        
        self.totalAngle = CGFloat(6*360+(arc4random()%1000))
        self.currentAngle = 60
        
        let pointAngle = Int(self.totalAngle)%360
        self.pointsEarned = pointAngle/60
        
        percentageDiscout = (self.pointsEarned+1)*5
        self.showSpinning()
    }
    
    func showSpinning()
    {
        AudioServicesPlaySystemSound(self.wheelSound)

        let time : TimeInterval = TimeInterval(self.totalAngle > self.currentAngle/5 ? (50.0/self.totalAngle) : (2.0/self.totalAngle))
        
        UIView.animate(withDuration: time, animations: {
            
            let angle : CGFloat = CGFloat(self.totalAngle > self.currentAngle ? self.currentAngle : self.totalAngle)
            self.viewContainerSpin.transform = self.viewContainerSpin.transform.rotated(by: (angle * CGFloat.pi) / 180.0)
        
        }, completion: {
            (value: Bool) in

            self.totalAngle = self.totalAngle - self.currentAngle
            if(self.totalAngle > 0)
            {
                self.showSpinning()
            }
            else
            {
                self.perform(#selector(SpinViewController.UpdateRewardPoints), with: nil, afterDelay: 1.0)
            }
        })
    }
    
    @objc func UpdateRewardPoints()
    {
        spinButton.isEnabled = true
        if let resultVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ResultViewController") as? ResultViewController{
            resultVC.percentageDiscout = self.percentageDiscout
            self.navigationController?.pushViewController(resultVC, animated: true)
        }
        
        /*let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.label.text = "Post Quiz..."
        
        let UrlStr = APIConstants.BasePath + APIPaths.getStoreDetailByGeoCoordinates
        
        var params = [String : String]()
        
        params = ["mid":SharedManager.shared.member.member_id!,"points":"\(self.pointsEarned)"]
        print("params = \(params)")
        
        Alamofire.request(UrlStr, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseJSON { response in
                
                switch response.result {
                case .success:
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")
                        MBProgressHUD.hide(for: self.view, animated: true)
                        
                        let jsonResponse = JSON as! Dictionary<String, Any>
                        if (jsonResponse["status"] as! String) == "success"{
                        
                            let rewards = Int(jsonResponse["rewards_added"] as! String)!
                            let totalRewards = jsonResponse["member_total_rewards"] as! Int
                            self.showResult(rewards: rewards, totalRewards: totalRewards)
                         }
                         else
                         {
                            let msg = (jsonResponse["status"] as! String)
                            let alert = UIAlertController(title: "Opps!", message: msg, preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                         }
                    }
                case .failure(let error):
                    
                    MBProgressHUD.hide(for: self.view, animated: true)
                    print(error.localizedDescription)
                    let alert = UIAlertController(title: "Fail to connect", message: "No internet connectivity.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
        }*/
    }
    
    func showResult(rewards:Int , totalRewards:Int)
    {
//        let resultVC = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ResultViewController") as! ResultViewController
//        resultVC.rewards_added = rewards
//        resultVC.member_total_rewards = totalRewards
//        self.navigationController?.pushViewController(resultVC, animated: true)
        
    }

}
