//
//  DetailsViewController.swift
//  LiveWeather
//
//  Created by phuc on 9/19/15.
//  Copyright © 2015 phuc nguyen. All rights reserved.
//

import UIKit
import CoreLocation
import ImageIO
import MapKit

class DetailsViewController: UIViewController {
    
    
    /// IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topBanner: MainWeatherView!
    @IBOutlet weak var backGroundImageView: UIImageView!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    
    private var isUpdatingLocation = false
    private var isUpdating = false
    private var isAnimating = false
    private var images = [String]() {
        didSet {
            self.loadBackGroundImage()
        }
    }
    private lazy var queue: NSOperationQueue = {
        let queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
        }()
    var menuBarItemView: MenuBarView?
    let locationManager = LocationManager.shareManager
    var currentLocation: CLLocation? {
        didSet {
            if let location = currentLocation {
                // reload data
                updateWeather(location)
            }
        }
    }
    
    var currentWeatherModel: WeatherModel? {
        didSet {
            if let aWeather = currentWeatherModel, location = currentLocation {
                // update UI
                updateUI(aWeather)
                // get background image
                updateBackground(location)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // init bar item
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "didTapMenuBarItem")
        menuBarItemView = MenuBarView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        menuBarItemView!.addGestureRecognizer(tapGestureRecognizer)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuBarItemView!)
        // start update location
        locationManager.delegate = self
        requestUpdateLocation()
        // add swipe to refresh
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: "swipeDown:")
        swipeGesture.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(swipeGesture);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didTapMenuBarItem() {
        let navigationController = parentViewController as! UINavigationController
        let containerViewController = navigationController.parentViewController as! ContainerViewController
        containerViewController.hideOrShowMenu(!containerViewController.showingMenu, animated: true)
    }
    
    func requestUpdateLocation() {
        if isUpdatingLocation {
            return
        }
        currentWeatherModel = nil
        isUpdatingLocation = true
        locationManager.requesNewLocation()
    }
    
    //MARK: - action handler
    func swipeDown(swipe: UISwipeGestureRecognizer) {
        if swipe.direction == UISwipeGestureRecognizerDirection.Down {
            if let location = currentLocation {
                updateWeather(location)
            }
        }
    }
    
    @IBAction func favoriteButtonPress(sender: AnyObject) {
        guard let city = currentWeatherModel?.convertToDictionary() else {
            return
        }
        
        if isExitInFavoriteList(city, actionHandler: {[unowned self] (acity) -> Void in
            let alert = UIAlertController(title: "Do you want to remove this city?", message: nil, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: { [unowned self](action) -> Void in
                self.favoriteButton.setBackgroundImage(UIImage(named: "unstar"), forState: UIControlState.Normal)
                AppmenuItems.removeObject(acity)
                NSUserDefaults.standardUserDefaults().setObject(AppmenuItems, forKey: kAppFavoriteCity)
                NSNotificationCenter.defaultCenter().postNotificationName(kMenuItemDidUpdate, object: nil)
                })
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }) {
            return
        } else {
            AppmenuItems.append(city)
            self.favoriteButton.setBackgroundImage(UIImage(named: "star"), forState: UIControlState.Normal)
            NSUserDefaults.standardUserDefaults().setObject(AppmenuItems, forKey: kAppFavoriteCity)
            NSNotificationCenter.defaultCenter().postNotificationName(kMenuItemDidUpdate, object: nil)
        }
    }
    
    @IBAction func saveBackroundButtonPress(sender: AnyObject) {
        
        // show action sheet
        
        let actionSheet = UIAlertController(title: "Option", message: nil, preferredStyle: .ActionSheet)
        let saveImageAction = UIAlertAction(title: "Save to camera roll", style: .Default) {[unowned self] (action) -> Void in
            guard let image = self.backGroundImageView.image else {
                return
            }
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        let showInMapAction = UIAlertAction(title: "View on map", style: .Default) { (action) -> Void in
            let mapviewcontroller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MapviewController") as! MapviewControllerViewController
            self.presentViewController(mapviewcontroller, animated: true, completion: {
                let annotation = MKPointAnnotation()
                annotation.title = self.currentWeatherModel?.iconText
                annotation.subtitle = self.currentWeatherModel?.description
                annotation.coordinate = self.currentLocation!.coordinate
                mapviewcontroller.anotation = annotation
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        actionSheet.addAction(saveImageAction)
        actionSheet.addAction(showInMapAction)
        actionSheet.addAction(cancelAction)
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    
    func isExitInFavoriteList(dict: NSDictionary, actionHandler: ((NSDictionary) -> Void)?) -> Bool {
        let cityName = dict["city"] as? String ?? ""
        for city in AppmenuItems {
            let aCityName = city["city"] as? String ?? ""
            if aCityName.characters.count > 0 && aCityName == cityName {
                if actionHandler != nil {
                    actionHandler!(city)
                }
                return true
            }
        }
        return false
    }
    
    func updateWeather(location: CLLocation) {
        if isUpdating {
            return
        }
        isUpdating = true
        topBanner.alpha = 0
        subTitle.alpha = 0
        favoriteButton.alpha = 0
        title = "Updating..."
        tableView.hidden = true
        tableView.reloadData()
        RequestManager.sharedManager.requestWeatherData(location) { [unowned self](aWeatherModel, anError) -> Void in
            self.isUpdating = false
            if anError == nil {
                self.currentWeatherModel = aWeatherModel!
            }
        }
    }
    
    // MARK: - Private method
    
    private func updateUI(weather: WeatherModel) {
        dispatch_async(dispatch_get_main_queue()) { [unowned self]() -> Void in
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.topBanner.city = weather.description
                self.title = weather.location
                self.topBanner.iconText = weather.iconText
                self.topBanner.temperature = weather.temperature
                // set alpha
                self.favoriteButton.alpha = 1
                self.tableView.hidden = false
                self.topBanner.alpha = 1
                self.subTitle.alpha = 1
            })
            self.tableView.reloadData()
            self.animationTableView()
            self.updateFavoriteButtonState()
        }
    }
    
    func updateFavoriteButtonState() {
        guard let city = currentWeatherModel?.convertToDictionary() else {
            favoriteButton.setBackgroundImage(UIImage(named: "unstar"), forState: UIControlState.Normal)
            return
        }
        
        if isExitInFavoriteList(city, actionHandler: nil) {
            favoriteButton.setBackgroundImage(UIImage(named: "star"), forState: UIControlState.Normal)
        } else {
            favoriteButton.setBackgroundImage(UIImage(named: "unstar"), forState: UIControlState.Normal)
        }
    }
    
    private func animationTableView() {
        if isAnimating {return}
        isAnimating = true
        let cells = tableView.visibleCells
        let tableViewWidth = tableView.frame.width
        
        for cell in cells {
            cell.transform = CGAffineTransformMakeTranslation(-tableViewWidth, 0)
        }
        var index = 0
        var total = 0
        for cell in cells {
            UIView.animateWithDuration(1.5,
                delay: 0.05 * Double(index),
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0,
                options: UIViewAnimationOptions.CurveEaseIn,
                animations: {
                    cell.transform = CGAffineTransformMakeTranslation(0, 0);
                }, completion:{ _ in
                    total++
                    if total == cells.count {
                        self.isAnimating = false
                    }
                    
            })
            
            index += 1
        }
    }
    
    private func updateBackground(location: CLLocation) {
        RequestManager.sharedManager.requestPhoto(currentWeatherModel!.location, location: location) { [unowned self](json, error) -> Void in
            if error == nil {
                self.images = json!
            }
        }
    }
    
    private func loadBackGroundImage() {
        queue.cancelAllOperations()
        for url in images {
            let operation = NSBlockOperation { () -> Void in
                guard let data = NSData(contentsOfURL: NSURL(string: url)!) else {
                    print("failed load backgournd image")
                    return
                }
                guard let image = UIImage(data: data) else {
                    print("failed init image")
                    return
                }
                dispatch_async(dispatch_get_main_queue(), {[unowned self] () -> Void in
                    self.backGroundImageView.image = image
                    let transition = CATransition()
                    transition.duration = 1.0
                    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    transition.type = kCATransitionFade
                    self.backGroundImageView.layer.addAnimation(transition, forKey: nil)
                    })
                NSThread.sleepForTimeInterval(10)
            }
            queue.addOperation(operation)
        }
        let doneOp = NSBlockOperation { [unowned self]() -> Void in
            self.loadBackGroundImage()
        }
        queue.addOperation(doneOp)
    }
}

// MARK: - LocationManagerDelegate
extension DetailsViewController: LocationManagerDelegate {
    func locationManagerDidUpdate(locationManager: LocationManager, location: CLLocation) {
        isUpdatingLocation = false
        self.currentLocation = location
    }
}
// MARK: - UITableViewDataSource
extension DetailsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentWeatherModel == nil {
            return 0
        } else {
            return currentWeatherModel!.forecasts.count
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let hourly = currentWeatherModel?.forecasts[indexPath.row],
            cell = tableView.dequeueReusableCellWithIdentifier("DetailCell"),
            label = cell.viewWithTag(101) as? UILabel,
            iconLabel = cell.viewWithTag(102) as? UILabel else {
                return UITableViewCell()
        }
        label.text = "      \(hourly.time) - \(hourly.temperature)"
        iconLabel.text = "\(hourly.iconText)"
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
}

extension DetailsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
}
// MARK: Color extend
extension UIColor {
    convenience init(colorArray array: NSArray) {
        let r = array[0] as! CGFloat
        let g = array[1] as! CGFloat
        let b = array[2] as! CGFloat
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha:1.0)
    }
}

// MARK: - UIImage Extend

extension UIImage {
    func imageScaletoSize(asize: CGSize) ->UIImage {
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        self.drawInRect(CGRect(origin: CGPointZero, size: asize))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
}

extension RangeReplaceableCollectionType where Generator.Element : Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func removeObject(object : Generator.Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}

extension Array
{
    /** Randomizes the order of an array's elements. */
    mutating func shuffle()
    {
        for _ in 0..<10
        {
            sortInPlace { (_,_) in arc4random() < arc4random() }
        }
    }
}

// class for bar button item

class MenuBarView: UIView {
    let imageView: UIImageView! = UIImageView(image: UIImage(named: "menuIcon"))
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        configure()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    // MARK: Private
    
    private func configure() {
        imageView.frame = frame
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        addSubview(imageView)
    }
    
    func rotate(fraction: CGFloat) {
        let angle = Double(fraction) * M_PI_2
        imageView.transform = CGAffineTransformMakeRotation(CGFloat(angle))
    }
}