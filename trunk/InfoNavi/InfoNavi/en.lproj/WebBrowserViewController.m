//
//  WebBrowserViewController.m
//  InfoNavi
//
//  Created by Damon Lok on 10/4/11.
//  Copyright 2011 ios-dev.webs.com. All rights reserved.
//

#import "WebBrowserViewController.h"

@implementation WebBrowserViewController
@synthesize stopButton;
@synthesize backButton;
@synthesize forwardButton;
@synthesize reloadButton;
@synthesize closeButton;
@synthesize webView;
@synthesize webToolBar;

- (void)setWebViewSpinner
{ 
    double screenWidth, screenHeight;
    if (!spinner)
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    if ([InfoNaviAppDelegate isiPad]) {
        screenWidth = kiPad_width; 
        screenHeight = 1000;          
    } else {
        screenWidth = kiPhone_width; 
        screenHeight = 460;                
    }    
    
    if ( self.interfaceOrientation == UIInterfaceOrientationPortrait )
        [spinner setCenter:CGPointMake(screenWidth/2.0, screenHeight)];
    else
        [spinner setCenter:CGPointMake(screenHeight, screenWidth/2.0)];    
}

- (void)startSpinner
{   
    [self setWebViewSpinner];
    [webView addSubview:spinner]; 
    [spinner startAnimating];   
}

- (void)stopSpinner
{
    [spinner stopAnimating];
    [spinner removeFromSuperview];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;    
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
    [self stopSpinner];
    NSLog(@"Successfully finished loading of Google Search at the end of method: %s",__PRETTY_FUNCTION__);
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self startSpinner];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (IBAction)closeButtonPressed
{
    self.webToolBar.hidden = TRUE;
    [appDelegate urlFlipAction:nil flipActionOn:@"Flip Back To Data Tab"];  
}

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

#pragma mark - View lifecy

- (NSURL *)getURL
{
    NSString *googleSearchURLFront = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"Google Search URL Front"];
    NSString *googleSearchURLMiddle = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"Google Search URL Middle"];
    NSString *googleSearchURLEnd = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"Google Search URL End"];
    NSString *inSearchURLCriteria = [InfoNaviAppDelegate getSearchCriteria]; 
    NSString *searchCriteriaString = [InfoNaviAppDelegate encodeURI:inSearchURLCriteria];
    NSString *googleSearchURL = [InfoNaviAppDelegate getGoogleSearchURL:[NSString stringWithFormat:@"%@%@%@%@%@", 
                                 googleSearchURLFront, 
                                 searchCriteriaString, 
                                 googleSearchURLMiddle, 
                                 searchCriteriaString,
                                 googleSearchURLEnd]];
    NSURL *url = [NSURL URLWithString:googleSearchURL];    
    return url;
    NSLog(@"Successfully constructed URL to google search page: %@ at the end of method: %s", googleSearchURL, __PRETTY_FUNCTION__);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSURLRequest *request = [NSURLRequest requestWithURL:[self getURL]];
    [webView loadRequest:request];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!appDelegate) appDelegate = (((InfoNaviAppDelegate *) [UIApplication sharedApplication].delegate));
    [self loadAdBanner];
    self.closeButton.title = [InfoNaviAppDelegate getCloseButtonTitle];
    self.closeButton.target = self;
    self.closeButton.action = @selector(closeButtonPressed); 
    NSLog(@"Successfully loaded the Google Search view at the end of method: %s",__PRETTY_FUNCTION__);
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setBackButton:nil];
    [self setForwardButton:nil];
    [self setReloadButton:nil];
    [self setCloseButton:nil];
    [self setWebToolBar:nil];
    [self setStopButton:nil];
    [super viewDidUnload];
    NSLog(@"Successfully unloaded the Google Search view at the end of method: %s",__PRETTY_FUNCTION__);
}

- (void)changeBannerOrientation:(UIInterfaceOrientation)toOrientation 
{
    [adBanner removeFromSuperview];
    [adBanner release];   
    CGRect adBannerFrame;
    
    if ([InfoNaviAppDelegate isiPad]) {
        CGRect landscapeFrame = webView.frame;
        landscapeFrame.origin.y = 90.0;
        webView.frame = landscapeFrame;
        adBannerFrame = CGRectMake(0, 0, GAD_SIZE_728x90.width, GAD_SIZE_728x90.height);       
    } else {
        if (UIInterfaceOrientationIsLandscape(toOrientation)) {
            CGRect landscapeFrame = webView.frame;
            landscapeFrame.origin.y = 60.0;
            webView.frame = landscapeFrame;
            adBannerFrame = CGRectMake(0, 0, GAD_SIZE_468x60.width, GAD_SIZE_468x60.height);
        }  else {
            CGRect portraitFrame = webView.frame;
            portraitFrame.origin.y = 50.0;
            webView.frame = portraitFrame;
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

- (void)dealloc {
    self.webView.delegate = nil;
    if (adBanner) [adBanner release];
    [webView release];
    [backButton release];
    [forwardButton release];
    [reloadButton release];
    [closeButton release];
    [webToolBar release];
    [stopButton release];
    [super dealloc];
    NSLog(@"Successfully deallocated all Google Search instance variables' memories at the end of method: %s",__PRETTY_FUNCTION__); 
}
@end
