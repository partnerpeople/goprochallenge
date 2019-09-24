//
//  ResultViewController.swift
//  Fitbit
//
//  Created by MOJAVE on 16/09/19.
//  Copyright © 2019 Partnerpeople. All rights reserved.
//

import UIKit
import MBProgressHUD
import Alamofire

class ResultViewController: UIViewController {

    var percentageDiscout = 5
    @IBOutlet weak var resultLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print(SharedManager.shared.store.store_id ?? "")
        resultLabel.text = "You’ve earned an \(percentageDiscout)% discount. We hope it helps you find your perfect fit. "
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "\(SharedManager.shared.member.firstName ?? "") \(SharedManager.shared.member.lastName ?? "")"
        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log Out", style: UIBarButtonItem.Style.plain, target: self, action: #selector(logoutButtonClicked))
        self.doSavePrizeProcess()
    }
    
    @objc func logoutButtonClicked()
    {
        ViewController.logoutAction()
        self.navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func savePrizeButtonClicked(_ sender: Any) {
        
        if var viewControllers = self.navigationController?.viewControllers{
            viewControllers.removeLast()
            viewControllers.removeLast()
            self.navigationController?.setViewControllers(viewControllers, animated: true)
        }
    }
    func doSavePrizeProcess()
    {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.label.text = "Saving Prize..."
        
        let UrlStr = APIConstants.BasePath + APIPaths.saveLocation
        var params = [String : String]()
        params["member_id"] = SharedManager.shared.member.member_id
        params["store_id"] = SharedManager.shared.store.store_type_id
        params["prize_id"] = "0"
        params["beacon_udid"] = "BCN23456"
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
                                
                                let msg = "Your prize has been saved successfully."//(jsonResponse["message"] as? String)
                                let alert = UIAlertController(title: "Congratulations!", message: msg, preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
    
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
