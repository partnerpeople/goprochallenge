//
//  Store.swift
//  Fitbit
//
//  Created by MOJAVE on 13/09/19.
//  Copyright © 2019 Partnerpeople. All rights reserved.
//

import UIKit

class Store: NSObject {
    
    var modifydate:String?
    var store_id:String?
    var store_lat:String?
    var store_type_id:String?
    var store_zip:String?
    var createdate:String?
    var store_long:String?
    var store_type_name:String?
    var store_address:String?
    var store_country:String?
    var store_city:String?
    var store_state:String?
    var store_name:String?
    var store_status:String?
    
    init(params:[String:Any])
    {
        self.modifydate = params["modifydate"] as? String
        self.store_id = params["store_id"] as? String
        self.store_lat = params["store_lat"] as? String
        self.store_type_id = params["store_type_id"] as? String
        self.store_zip = params["store_zip"] as? String
        self.createdate = params["createdate"] as? String
        self.store_long = params["store_long"] as? String
        self.store_type_name = params["store_type_name"] as? String
        self.store_address = params["store_address"] as? String
        self.store_country = params["store_country"] as? String
        self.store_city = params["store_city"] as? String
        self.store_state = params["store_state"] as? String
        self.store_name = params["store_name"] as? String
        self.store_status = params["store_status"] as? String
        
    }
}
