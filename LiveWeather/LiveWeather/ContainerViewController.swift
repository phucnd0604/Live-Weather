//
//  ContainerViewController.swift
//  LiveWeather
//
//  Created by phuc on 9/19/15.
//  Copyright © 2015 phuc nguyen. All rights reserved.
//

import UIKit
import CoreLocation

class ContainerViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ContentView: UIView!
    @IBOutlet weak var menuContainerView: UIView!
    @IBOutlet weak var detailContainerView: UIView!
    var detailViewController: DetailsViewController?
    
    var showingMenu = false
    var menuItem: NSDictionary? {
        didSet {
            if let detailViewController = detailViewController, item = menuItem {
                let alat = item.objectForKey("lat")?.doubleValue
                let alon = item.objectForKey("lon")?.doubleValue
                let location = CLLocation(latitude: alat!, longitude: alon!)
                detailViewController.currentLocation = location
                hideOrShowMenu(false, animated: true)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hideOrShowMenu(showingMenu, animated: false)
        menuContainerView.layer.anchorPoint = CGPoint(x: 1.0, y: 0.5)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DetailViewSegue" {
            let navigationController = segue.destinationViewController as! UINavigationController
            detailViewController = navigationController.topViewController as? DetailsViewController
        }
    }
    
    func hideOrShowMenu(show: Bool, animated: Bool) {
        showingMenu = show
        let menuOffset = CGRectGetWidth(menuContainerView.bounds)
        scrollView.setContentOffset(show ? CGPointZero : CGPoint(x: menuOffset, y: 0), animated: animated)
    }
    
    private func transformForFraction(fraction:CGFloat) -> CATransform3D {
        var identity = CATransform3DIdentity
        identity.m34 = -1.0 / 1000.0;
        let angle = Double(1.0 - fraction) * -M_PI_2
        let xOffset = CGRectGetWidth(menuContainerView.bounds) * 0.5
        let rotateTransform = CATransform3DRotate(identity, CGFloat(angle), 0.0, 1.0, 0.0)
        let translateTransform = CATransform3DMakeTranslation(xOffset, 0.0, 0.0)
        return CATransform3DConcat(rotateTransform, translateTransform)
    }

}

extension ContainerViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollView.pagingEnabled = scrollView.contentOffset.x < (scrollView.contentSize.width - CGRectGetWidth(scrollView.frame))
        let multiplier = 1.0 / CGRectGetWidth(menuContainerView.bounds)
        let offset = scrollView.contentOffset.x * multiplier
        let fraction = 1.0 - offset
        menuContainerView.layer.transform = transformForFraction(fraction)
        menuContainerView.alpha = fraction
        
        if let detailViewController = detailViewController {
            if let rotatingView = detailViewController.menuBarItemView {
                rotatingView.rotate(fraction)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let menuOffset = CGRectGetWidth(menuContainerView.bounds)
        showingMenu = !CGPointEqualToPoint(CGPoint(x: menuOffset, y: 0), scrollView.contentOffset)
        print("didEndDecelerating showingMenu \(showingMenu)")
    }
}

