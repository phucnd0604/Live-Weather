//
//  AppConstant.swift
//  LiveWeather
//
//  Created by phuc on 9/19/15.
//  Copyright © 2015 phuc nguyen. All rights reserved.
//

import Foundation

let kCurrentWeatherUrlPath = "http://api.openweathermap.org/data/2.5/forecast"

let kDailyUrlPath = "http://api.openweathermap.org/data/2.5/forecast/daily"

let kflickerApiKey = "19280222cd253417aee72f006bdef769"

let flickerSecretKey = "e63b701f6d6da89e"
// flick url: farmid - serverid - photoid - secret key
let kflickerImageUrl = "https://farm%@.staticflickr.com/%@/%@_%@_h.png"

let kMenuItemDidUpdate = "kMenuItemDidUpdate"

typealias WeatherCompletionHanderBlock = (WeatherModel?, LWError?) -> Void

enum tempratureDisplay: Int {
    case C = 0
    case F = 1
}

struct LWError {
    enum Code: Int {
        case invalidUrl = 100000
        case sessionDataTaskError = 100001
        case emptyResponseData = 100002
        case failedWhileParseJson = 100003
    }
    let code: Code
}

let defaultAppSetting = ["displayUnit": tempratureDisplay.C]

let kAppFavoriteCity = "kAppFavoriteCity"