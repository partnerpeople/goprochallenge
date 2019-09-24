//
//  Member.swift
//  Fitbit
//
//  Created by MOJAVE on 13/09/19.
//  Copyright © 2019 Partnerpeople. All rights reserved.
//

import UIKit

class Member: NSObject,NSCoding {
    
    var member_id:String?
    var firstName:String?
    var lastName:String?
    var email:String?
    var password:String?
    var mobile:String?
    var member_status:String?
    var modifydate:String?
    var createdate:String?
    
    init(params:[String:Any])
    {
        self.member_id = params["member_id"] as? String
        self.firstName = params["firstName"] as? String
        self.lastName = params["lastName"] as? String
        self.email = params["email"] as? String
        self.password = params["password"] as? String
        self.mobile = params["mobile"] as? String
        self.member_status = params["member_status"] as? String
        self.modifydate = params["modifydate"] as? String
        self.createdate = params["createdate"] as? String
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.member_id, forKey: "member_id")
        aCoder.encode(self.firstName, forKey: "firstName")
        aCoder.encode(self.lastName, forKey: "lastName")
        aCoder.encode(self.email, forKey: "email")
        aCoder.encode(self.password, forKey: "password")
        aCoder.encode(self.mobile, forKey: "mobile")
        aCoder.encode(self.member_status, forKey: "member_status")
        aCoder.encode(self.modifydate, forKey: "modifydate")
        aCoder.encode(self.createdate, forKey: "createdate")
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        self.member_id = aDecoder.decodeObject(forKey: "member_id") as? String
        self.firstName = aDecoder.decodeObject(forKey: "firstName") as? String
        self.lastName = aDecoder.decodeObject(forKey: "lastName") as? String
        self.email = aDecoder.decodeObject(forKey: "email") as? String
        self.password = aDecoder.decodeObject(forKey: "password") as? String
        self.mobile = aDecoder.decodeObject(forKey: "mobile") as? String
        self.member_status = aDecoder.decodeObject(forKey: "member_status") as? String
        self.modifydate = aDecoder.decodeObject(forKey: "modifydate") as? String
        self.createdate = aDecoder.decodeObject(forKey: "createdate") as? String
    }
}
