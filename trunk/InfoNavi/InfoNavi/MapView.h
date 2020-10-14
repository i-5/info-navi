//
//  MapView.h
//  InfoNavi
//
//  Created by Damon Lok on 7/1/12.
//  Copyright (c) 2012 ios-dev.webs.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "InfoNaviAppDelegate.h"
#import "GoogleLocalConnection.h"  
#import "MapPoint.h"
#import "CityAndLocalSearch.h"

#define kSearchWord @"ネイルサロン"

@class GoogleLocalObject;

@interface MapView : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, GoogleLocalConnectionDelegate> {
	MKMapView *mapView;
    CLLocationManager *locationManager;
	GoogleLocalConnection *googleLocalConnection;
    CityAndLocalSearch *cityAndLocalSearch;
    CLLocationCoordinate2D currentCentre;
    int currenDist;
    GADBannerView *adBanner;    
    InfoNaviAppDelegate *appDelegate; 
    CLGeocoder *geoCoder;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

@end