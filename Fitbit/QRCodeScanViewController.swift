//
//  QRCodeScanViewController.swift
//  Fitbit
//
//  Created by MOJAVE on 12/09/19.
//  Copyright © 2019 Partnerpeople. All rights reserved.
//

import UIKit
import AVFoundation
import QRCodeReader
import MBProgressHUD
import Alamofire

class QRCodeScanViewController: UIViewController,QRCodeReaderViewControllerDelegate {

    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            
            // Configure the view controller (optional)
            $0.showTorchButton        = false
            $0.showSwitchCameraButton = false
            $0.showCancelButton       = false
            $0.showOverlayView        = true
            $0.rectOfInterest         = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    

    @IBAction func scanAction(_ sender: AnyObject) {
        // Retrieve the QRCode content
        // By using the delegate pattern
        readerVC.delegate = self
        
        // Or by using the closure pattern
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            print(result ?? "default value")
        }
        
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        
        present(readerVC, animated: true, completion: nil)
    }
    
    // MARK: - QRCodeReaderViewController Delegate Methods
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        self.getStoreDetail()
        dismiss(animated: true, completion: nil)
        
    }
    
    //This is an optional delegate method, that allows you to be notified when the user switches the cameraName
    //By pressing on the switch camera button
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        let cameraName = newCaptureDevice.device.localizedName
        print("Switching capture to: \(cameraName)")
        
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }
    
    func getStoreDetail()
    {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.label.text = "Fetching Store..."
        
        let UrlStr = APIConstants.BasePath + APIPaths.getStoreDetailByGeoCoordinates
        var params = [String : String]()
        params["lat"] = "33.683319"
        params["lon"] = "-117.8701257"
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
    
    func showGameView()
    {
        
        if let gameVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SpinViewController") as? SpinViewController{
            self.navigationController?.pushViewController(gameVC, animated: true)
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
