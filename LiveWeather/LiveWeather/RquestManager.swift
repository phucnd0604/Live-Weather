//
//  RquestManager.swift
//  LiveWeather
//
//  Created by phuc on 9/19/15.
//  Copyright © 2015 phuc nguyen. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class RequestManager {
    static let sharedManager = RequestManager()
    
    func requestWeatherData(location: CLLocation, complationHandler: WeatherCompletionHanderBlock) {
        
        // create session
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig)
        // create url
        guard let url = createRequestUrl(location, baseUrl: kCurrentWeatherUrlPath) else {
            let error = LWError(code: .invalidUrl)
            complationHandler(nil, error)
            return
        }
        // create request
        let request = NSURLRequest(URL: url)
        // create data task
        let task = session.dataTaskWithRequest(request) { (data, response, taskError) -> Void in
            if taskError != nil {
                let error = LWError(code: .sessionDataTaskError)
                complationHandler(nil, error)
                return
            }
            guard let responseData = data else {
                let error = LWError(code: .emptyResponseData)
                complationHandler(nil, error)
                return
            }
            
            let json = JSON(data: responseData)
            // parse current weather
            guard let tempDegrees = json["list"][0]["main"]["temp"].double,
                city: String = json["city"]["name"].stringValue,
                weatherCondition: Int = json["list"][0]["weather"][0]["id"].intValue,
                description: String = json["list"][0]["weather"][0]["description"].stringValue,
                iconString: String = json["list"][0]["weather"][0]["icon"].stringValue else {
                    let error = LWError(code: .failedWhileParseJson)
                    complationHandler(nil, error)
                    return
            }
            let temprature = Temprature(displayType: .C, inDegrees: tempDegrees)
            let weatherIcon = WeatherIcon(condition: weatherCondition, iconString: iconString)
            
            // parse hourlyWeather
            var forecastEveryHour = [HourlyWeather]()
            for index in 0...7 {
                guard let forecastTempDegrees = json["list"][index]["main"]["temp"].double,
                    rawDateTime: Double =  json["list"][index]["dt"].doubleValue,
                    forecastCondition: Int = json["list"][index]["weather"][0]["id"].intValue,
                    forecastIcon: String = json["list"][index]["weather"][0]["icon"].stringValue else {
                        break
                }
                
                let forecastTemperature = Temprature(displayType: defaultAppSetting["displayUnit"]!, inDegrees: forecastTempDegrees)
                let forecastTimeString = ForecastDateTime(rawDateTime).shortTime
                let weatherIcon = WeatherIcon(condition: forecastCondition, iconString: forecastIcon)
                let forcastIconText = weatherIcon.iconText
                
                let hourWeather = HourlyWeather(time: forecastTimeString,
                    iconText: forcastIconText,
                    temperature: forecastTemperature.degrees)
                
                forecastEveryHour.append(hourWeather)
            }
            let weather = WeatherModel(aLocation: city, aiconText: weatherIcon.iconText, atemperature: temprature.degrees, aforecasts: forecastEveryHour, alat: location.coordinate.latitude, alon: location.coordinate.longitude, des: description)
            complationHandler(weather, nil)
        }
        task.resume()
    }
    
    func requestPhoto(text: String, location: CLLocation, completionHandler: ([String]?, LWError?) -> Void) {
        // create session
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig)
        // create url
        //        var urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(kflickerApiKey)&lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&text=\(text)&in_gallery=&is_getty=&accuracy=11&format=json&nojsoncallback=1"
        var urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(kflickerApiKey)&text=\(text)&in_gallery=&is_getty=&accuracy=11&format=json&nojsoncallback=1"
        urlString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let url = NSURL(string: urlString)
        // create request
        let request = NSURLRequest(URL: url!)
        
        let task = session.dataTaskWithRequest(request) { (data, response, taskError) -> Void in
            if taskError != nil {
                let error = LWError(code: .sessionDataTaskError)
                completionHandler(nil, error)
                return
            }
            guard let responseData = data else {
                let error = LWError(code: .emptyResponseData)
                completionHandler(nil, error)
                return
            }
            var result = [String]()
            let json = JSON(data: responseData)
            if let dict = json["photos"]["photo"].array {
                for subjson in dict {
                    if let url = self.createImageUrl(subjson) {
                        result.append(url)
                    }
                }
                result.shuffle()
                completionHandler(result, nil)
            } else {
                let error = LWError(code: .failedWhileParseJson)
                completionHandler(nil, error)
                return
            }
            
            
        }
        task.resume()
    }
    
    private func createRequestUrl(location: CLLocation, baseUrl: String) -> NSURL? {
        guard let components: NSURLComponents = NSURLComponents(string:baseUrl) else {
            return nil
        }
        components.queryItems = [NSURLQueryItem(name:"lat", value:String(location.coordinate.latitude)),
            NSURLQueryItem(name:"lon", value:String(location.coordinate.longitude))]
        return components.URL
    }
    
    private func createImageUrl(json: JSON?) -> String? {
        guard let json = json,
            farmid = json["farm"].int,
            serverid = json["server"].string,
            photoid = json["id"].string,
            secret = json["secret"].string else {
                return nil
        }
        let url = "https://farm\(farmid).staticflickr.com/\(serverid)/\(photoid)_\(secret)_h.jpg"
        return url
    }
}