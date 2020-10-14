//
//  FirstViewController.h
//  InfoNavi
//
//  Created by Damon Lok on 9/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSON.h"
#import "InfoNaviAppDelegate.h"

#define kUITag1 1
#define kUITag2 2

@interface FirstViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, 
    NSXMLParserDelegate>{
    UITableView *displayDataTable;
    NSMutableData *receivedData;
    NSMutableArray *displayDataArray;       
    NSMutableArray *displayDataTitleArray;    
    NSMutableString *currentStringValue; 
    NSString *currentStringType;
    UIActivityIndicatorView *spinner;  
    GADBannerView *adBanner;    
    InfoNaviAppDelegate *appDelegate;    
}

@property (nonatomic, retain) IBOutlet UITableView *displayDataTable;

@end
