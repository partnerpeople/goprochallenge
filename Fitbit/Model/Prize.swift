//
//  Prize.swift
//  Fitbit
//
//  Created by MOJAVE on 16/09/19.
//  Copyright © 2019 Partnerpeople. All rights reserved.
//

import UIKit

class Prize: NSObject {

    var prize_id : String?
    var campaign_id : String?
    var prize_name : String?
    var prize_type : String?
    var prize_desc : String?
    var prize_icon : String?
    var prize_code : String?
    var prize_amount : String?
    var prize_points : String?
    var prize_quantity : String?
    var prize_status : String?
    var prize_createdate : String?
    
    
    override init()
    {
        
    }
    
    convenience init(data:[String:Any]) {
        
        self.init()
        
        self.prize_id = data["prize_id"] as? String
        self.campaign_id = data["campaign_id"] as? String
        self.prize_name = data["prize_name"] as? String
        self.prize_type = data["prize_type"] as? String
        self.prize_desc = data["prize_desc"] as? String
        self.prize_icon = data["prize_icon"] as? String
        self.prize_code = data["prize_code"] as? String
        self.prize_amount = data["prize_amount"] as? String
        self.prize_points = data["prize_points"] as? String
        self.prize_quantity = data["prize_quantity"] as? String
        self.prize_status = data["prize_status"] as? String
        self.prize_createdate = data["prize_createdate"] as? String
    }
}
