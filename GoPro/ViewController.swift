//
//  ViewController.swift
//  Fitbit
//
//  Created by MOJAVE on 12/09/19.
//  Copyright © 2019 Partnerpeople. All rights reserved.
//

import UIKit
import MBProgressHUD
import Alamofire
import FBSDKLoginKit
import FBSDKCoreKit
import Reachability


class ViewController: UIViewController,LoginButtonDelegate {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    var loginButton = FBLoginButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        loginButton = FBLoginButton(type: .custom)
        loginButton.delegate = self
        loginButton.frame.size.height = 44
        loginButton.center = CGPoint(x: view.center.x, y: view.center.y*1.7)
        loginButton.permissions = ["public_profile", "email"]
        self.view.addSubview(loginButton)
        
        //if the user is already logged in
        if AccessToken.current != nil{
            loginButton.isHidden = true
            
            if let memberData  = UserDefaults.standard.object(forKey: "member") as? Data{
                if #available(iOS 11.0, *) {
                    do {
                        SharedManager.shared.member = try NSKeyedUnarchiver.unarchivedObject(ofClass: Member.self, from: memberData)!
                    }
                    catch
                    {}
                }
                else
                {
                    SharedManager.shared.member = NSKeyedUnarchiver.unarchiveObject(with: memberData) as! Member
                }
                
                self.showBeaconViewWithoutAnimation()
            }
            else{
                
                getFBUserData()
            }
        }
    }
    
    static func logoutAction()
    {
        let loginManager = LoginManager()
        loginManager.logOut()
    }
    

    @objc func hideProgressView(){
        
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    @IBAction func loginButtonClicked(_ sender: Any) {
    
        if (self.validateTextFields())
        {
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.mode = MBProgressHUDMode.indeterminate
            hud.label.text = "Sign Up..."
            
            let UrlStr = APIConstants.BasePath + APIPaths.signUp
            var params = [String : String]()
            params["email"] = self.emailTextField.text
            params["firstname"] = self.firstNameTextField.text
            params["lastname"] = self.lastNameTextField.text
            params["mobile"] = "+919913328925"
            
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
                                    
                                    SharedManager.shared.member.member_id = jsonResponse["member_id"] as? String
                                    
                                    SharedManager.shared.member.firstName = SharedManager.shared.fbFirstName
                                    SharedManager.shared.member.lastName = SharedManager.shared.fbLastName
                                    SharedManager.shared.member.email = SharedManager.shared.fbEmail
                                    
                                    if #available(iOS 11.0, *) {
                                        do {
                                            let encodedData = try NSKeyedArchiver.archivedData(withRootObject: SharedManager.shared.member, requiringSecureCoding: false)
                                            UserDefaults.standard.set(encodedData, forKey: "member")
                                            UserDefaults.standard.synchronize()
                                        } catch {
                                            print("Couldn't save member locally")
                                        }
                                    } else {
                                        
                                        // or use some work around
                                        let encodedData = NSKeyedArchiver.archivedData(withRootObject: SharedManager.shared.member)
                                        UserDefaults.standard.set(encodedData, forKey: "member")
                                        UserDefaults.standard.synchronize()
                                    }
                                    print("Id = " + (SharedManager.shared.member.member_id ?? "Nil"))
                                    
                                   // self.showQRCodeScanView()
                                    self.showBeaconView()
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
    }
    
    func getFBUserData() {
        if NetworkManager.isConnected(){
            
            let graphRequest : GraphRequest = GraphRequest(graphPath: "me", parameters: ["fields":"email,first_name,last_name"])
            graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                if ((error) != nil) {
                    // Process error
                    print("\n\n Error: \(String(describing: error))")
                    
                } else {
                    let resultDic = result as! NSDictionary
                    print("\n\n  fetched user: \(String(describing: result))")
                    
                    if let firstName = resultDic.value(forKey:"first_name") as? String {
                        SharedManager.shared.fbFirstName = firstName
                    }
                    if let lastName = resultDic.value(forKey:"last_name") as? String {
                        SharedManager.shared.fbLastName = lastName
                    }
                    if let userEmail = resultDic.value(forKey:"email") as? String {
                        SharedManager.shared.fbEmail = userEmail
                    }
                    
                    self.firstNameTextField.text = SharedManager.shared.fbFirstName
                    self.lastNameTextField.text = SharedManager.shared.fbLastName
                    self.emailTextField.text = SharedManager.shared.fbEmail
                    
                    self.loginButtonClicked(self.loginButton)
                }
            })
        }
        else
        {
            let alert = UIAlertController(title: "Fail to connect", message: "No internet connectivity. Please check your internet connetion and restart the app.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @objc func showQRCodeScanView()
    {
        MBProgressHUD.hide(for: self.view, animated: true)
        if let qrCodeScanVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QRCodeScanViewController") as? QRCodeScanViewController{
            self.navigationController?.pushViewController(qrCodeScanVC, animated: true)
        }
        
    }
    @objc func showBeaconView()
    {
        MBProgressHUD.hide(for: self.view, animated: true)
        if let beaconVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BeaconViewController") as? BeaconViewController{
            self.navigationController?.pushViewController(beaconVC, animated: true)
        }
        
    }
    
    func showBeaconViewWithoutAnimation()
    {
        if let beaconVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BeaconViewController") as? BeaconViewController{
            self.navigationController?.pushViewController(beaconVC, animated: false)
        }
        
    }
    
    //MARK: Validation
    func validateTextFields() -> Bool{
        
        if !self.validateEmail(emailTextField.text!, alertText: "Please enter a valid email address.")
        {
            return false
        }
        else if !self.validateText(firstNameTextField.text!, alertText: "Please enter a valid First Name")
        {
            return false
        }
        else if !self.validateText(firstNameTextField.text!, alertText: "Please enter a valid Last Name")
        {
            return false
        }
        
        return true
    }
    
    //dismiss keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    //hide navigation bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        if AccessToken.current != nil{
            loginButton.isHidden = true
        }
        else {
            loginButton.isHidden = false
        }
        
    }
    //show navigation bar
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Sets background to a blank/empty image
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        // Sets shadow (line below the bar) to a blank image
        UINavigationBar.appearance().shadowImage = UIImage()
        // Sets the translucent background color
        UINavigationBar.appearance().backgroundColor = .clear
        // Set translucent. (Default value is already true, so this can be removed if desired.)
        UINavigationBar.appearance().isTranslucent = true
        return true
    }
    
    
    //MARK:-
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        if (error == nil) {
            let fbloginresult : LoginManagerLoginResult = result!
            if(fbloginresult.isCancelled) {
                //Show Cancel alert
            } else if(fbloginresult.grantedPermissions.contains("email")) {
                self.loginButton.isHidden = true
                self.getFBUserData()
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
        self.loginButton.isHidden = false
        SharedManager.shared.fbFirstName = ""
        SharedManager.shared.fbLastName = ""
        SharedManager.shared.fbEmail = ""
        
        SharedManager.shared.member.member_id = nil
        SharedManager.shared.member.firstName = nil
        SharedManager.shared.member.lastName = nil
        SharedManager.shared.member.email = nil
    }
}

public struct MyCustomEncoding : ParameterEncoding {
    private let data: Data
    init(data: Data) {
        self.data = data
    }
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        
        var urlRequest = try urlRequest.asURLRequest()
        do {
            urlRequest.httpBody = data
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
        }
        return urlRequest
    }
}
