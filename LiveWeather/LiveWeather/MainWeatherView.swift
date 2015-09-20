//
//  MainWeatherView.swift
//  LiveWeather
//
//  Created by phuc on 9/19/15.
//  Copyright © 2015 phuc nguyen. All rights reserved.
//

import UIKit

class MainWeatherView: UIView {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    //MARK - IBInspactable for UI costomize
    
    @IBInspectable var city: String? {
        get {
            return cityLabel.text
        } set {
            cityLabel.text = newValue
        }
    }
    
    @IBInspectable var temperature: String? {
        get {
            return temperatureLabel.text
        } set {
            temperatureLabel.text = newValue
        }
    }
    @IBInspectable var iconText: String? {
        get {
            return iconLabel.text
        } set {
            iconLabel.text = newValue
        }
    }
    @IBInspectable var iconSize: CGFloat {
        get {
            return fontSize
        } set {
            fontSize = newValue
        }
    }
    
    var containerView: UIView!
    var fontSize: CGFloat = 50 {
        didSet{
            iconLabel.font = UIFont(name: "Weather Icons", size: fontSize)
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        containerView = commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        containerView = commonInit()
    }

    func commonInit() -> UIView {
        func nibName() -> String {
            return self.dynamicType.description().componentsSeparatedByString(".").last!
        }
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: nibName(), bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        self.addSubview(view)
        return view
    }
}
