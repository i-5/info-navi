//
//  WebBrowserViewController.h
//  InfoNavi
//
//  Created by Damon Lok on 10/4/11.
//  Copyright 2011 ios-dev.webs.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoNaviAppDelegate.h"

@interface WebBrowserViewController : UIViewController <UIWebViewDelegate>{
    UIWebView *webView;
    UIToolbar *webToolBar;
    UIBarButtonItem *backButton;
    UIBarButtonItem *forwardButton;
    UIBarButtonItem *reloadButton;
    UIBarButtonItem *closeButton;
    UIActivityIndicatorView *spinner; 
    UIBarButtonItem *stopButton;
    InfoNaviAppDelegate *appDelegate;
    GADBannerView *adBanner;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *stopButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *forwardButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *reloadButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *closeButton;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIToolbar *webToolBar;

- (NSURL *)getURL;
@end
