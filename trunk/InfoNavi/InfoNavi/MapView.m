//
//  MapView.m
//  InfoNavi
//
//  Created by Damon Lok on 7/1/12.
//  Copyright (c) 2012 ios-dev.webs.com. All rights reserved.
//

#import "MapView.h"
#import "GTMNSString+URLArguments.h"

@implementation MapView
@synthesize mapView;

- (void)loadAdBanner
{
    CGRect adBannerFrame;
    
    if ([InfoNaviAppDelegate isiPad]) {
        adBannerFrame = CGRectMake(0, 0, GAD_SIZE_728x90.width, GAD_SIZE_728x90.height);
    } else {
        if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
            adBannerFrame = CGRectMake(0, 0, GAD_SIZE_468x60.width, GAD_SIZE_468x60.height);
        }  else {
            adBannerFrame = CGRectMake(0, 0, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height);
        }
    }
    adBanner = [[GADBannerView alloc] initWithFrame:adBannerFrame];
    adBanner.adUnitID = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"AdMob Publisher ID"];
    adBanner.rootViewController = self;
    [self.view addSubview:adBanner];
    [adBanner loadRequest:[GADRequest request]];
}

- (void)viewDidLoad { 
    [super viewDidLoad];
    [self loadAdBanner];
	[mapView setShowsUserLocation:YES];
    [mapView setDelegate:self];
    [mapView setRegion:MKCoordinateRegionMake(currentCentre, MKCoordinateSpanMake(1.0, 1.0))];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager startUpdatingLocation];
    cityAndLocalSearch = [[CityAndLocalSearch alloc] init];
    [cityAndLocalSearch cityNameSearch];
    [cityAndLocalSearch yahooLocalSearch];
    /*
	googleLocalConnection = [[GoogleLocalConnection alloc] initWithDelegate:self]; 
    [googleLocalConnection getGoogleObjectsWithQuery:kSearchWord andMapRegion:[mapView region] andNumberOfResults:8 addressesOnly:NO andReferer:@"http://ios-dev.webs.com"];
     */
}

- (void) googleLocalConnection:(GoogleLocalConnection *)conn didFinishLoadingWithGoogleLocalObjects:(NSMutableArray *)objects andViewPort:(MKCoordinateRegion)region
{
    if ([objects count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No matches found near this location" message:@"Try another place name or address (or move the map and try again)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    else {
        id userAnnotation=mapView.userLocation;
        [mapView removeAnnotations:mapView.annotations];
        [mapView addAnnotations:objects];
        if(userAnnotation!=nil)
			[mapView addAnnotation:userAnnotation];
        [mapView setRegion:region];
    }
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated 
{
    //Get the east and west points on the map so you can calculate the distance (zoom level) of the current map view.
    MKMapRect mRect = self.mapView.visibleMapRect;
    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect));
    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect));
    
    //Set your current distance instance variable.
    currenDist = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint);  
    
    //Set your current center point on the map instance variable.
    currentCentre = self.mapView.centerCoordinate;
}

- (void) googleLocalConnection:(GoogleLocalConnection *)conn didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error finding place - Try again" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation 
{    
    //NSString *inSearchURLCriteria = [InfoNaviAppDelegate getSearchCriteria]; 
    NSString *inSearchURLCriteria = @"nail salon"; 
    NSString *searchCriteriaString = [InfoNaviAppDelegate encodeURI:inSearchURLCriteria];
    NSString *appID = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"Yahoo US App ID"];
    NSString *localSearchURL = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"Yahoo Location Search URL"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@&query=%@&results=20&output=json&zip=94306", localSearchURL, appID, searchCriteriaString];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    NSHTTPURLResponse *response;
    
    NSError *error;
    
    NSData *respData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];      
    
    NSString *responseString = [[NSString alloc] initWithData:respData encoding:NSASCIIStringEncoding];     
    
    if (responseString.length >0)
        NSLog(@"%@", responseString);
    else
        NSLog(@"Failed to obtain Yahoo Local Search response data");  
    
    CLLocationCoordinate2D coordinate;
    coordinate = newLocation.coordinate;
    
    [self.mapView setCenterCoordinate:coordinate animated:YES];
    
    MKCoordinateRegion zoom = self.mapView.region;
    zoom.span.latitudeDelta = 1;
    zoom.span.longitudeDelta = 1;
    [self.mapView setRegion:zoom animated:YES];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation 
{
    // Define your reuse identifier.
    static NSString *identifier = @"MapPoint";   
    
    if ([annotation isKindOfClass:[MapPoint class]]) {
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = YES;
        return annotationView;
    }
    return nil;    
}

/*
 - (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views 
 {  
 MKCoordinateRegion region;
 region = MKCoordinateRegionMakeWithDistance(locationManager.location.coordinate,10000,10000);
 
 [mv setRegion:region animated:YES];
 } 
*/

- (void)changeBannerOrientation:(UIInterfaceOrientation)toOrientation {
    [adBanner removeFromSuperview];
    [adBanner release];
    CGRect adBannerFrame;
    
    if ([InfoNaviAppDelegate isiPad]) {
        adBannerFrame = CGRectMake(0, 0, GAD_SIZE_728x90.width, GAD_SIZE_728x90.height);       
    } else {
        if (UIInterfaceOrientationIsLandscape(toOrientation)) {
            adBannerFrame = CGRectMake(0, 0, GAD_SIZE_468x60.width, GAD_SIZE_468x60.height);
        }  else {
            adBannerFrame = CGRectMake(0, 0, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height);
        }
    } 
    adBanner = [[GADBannerView alloc] initWithFrame:adBannerFrame];
    adBanner.adUnitID = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"AdMob Publisher ID"];
    adBanner.rootViewController = self;
    [self.view addSubview:adBanner];
    [adBanner loadRequest:[GADRequest request]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{    
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (adBanner) {
        [self changeBannerOrientation:toInterfaceOrientation];
    }
}

- (void)viewDidUnload {
	[googleLocalConnection release];
}

- (void)dealloc {
    [super dealloc];
	[mapView setDelegate:nil];
	[mapView release];
}

@end