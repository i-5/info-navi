//
//  InfoNaviAppDelegate.h
//  InfoNavi
//
//  Created by Damon Lok on 9/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"

#define kiPhone_height 480
#define kiPhone_width 320
#define kiPad_height 1028
#define kiPad_width 768
#define kFIRST_TAB 1
#define kSECOND_TAB 2
#define kTHIRD_TAB 3
#define kFORTH_TAB 4

@class WebBrowserViewController;

@interface InfoNaviAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> 
{
    UIActivityIndicatorView *spinner_;
    int currentViewTag;
    int previousViewTag;
    int screenWidth;
    int screenHeight;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) WebBrowserViewController *webBrowserViewController;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;  

+ (BOOL) isiPad;
+ (NSString *)encodeURI:(NSString *)uri; 
+ (NSString *)getSearchCriteria;
+ (NSString *)getReaderURL;
+ (NSString *)getTableTitle:(int)tableNumber;
+ (NSString *)getGoogleSearchURL:(NSString *)urlString;
+ (NSString *)getCloseButtonTitle;
+ (NSString *)getTwitterURL:(NSString *)urlString;
+ (NSString *)getYahooSearchURL:(NSString *)urlString;
- (void)urlFlipAction:(NSURL *)url flipActionOn:(NSString *)actionOn;
- (UIActivityIndicatorView *)getSpinner;

@end
