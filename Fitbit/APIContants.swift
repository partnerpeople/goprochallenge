
//
//  APIContants.swift
//  Fitbit
//
//  Created by MOJAVE on 12/09/19.
//  Copyright © 2019 Partnerpeople. All rights reserved.
//

import Foundation


internal struct APIConstants {
    static let BasePath = "http://54.193.57.167/fitbitchallenge/api/"
}


internal struct APIPaths {
    
    static let signUp = "signup/"
    static let getStoreDetailByGeoCoordinates = "getStoreDetailByGeoCoordinates/"
    static let saveLocation = "SaveLocation/"
}


internal struct FormatParameterKeys{
    static let UserId = "userId"
    static let PageIndex = "pageIndex"
    static let PageSize = "pageSize"
}


internal struct APIParameterConstants {
    struct Product {
        static let RecentSold = [FormatParameterKeys.UserId,FormatParameterKeys.PageIndex,FormatParameterKeys.PageSize]
        static let SubscriptionPacks = [FormatParameterKeys.UserId]

    }
}
