//
//  SecondViewController.h
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
#define kUITag3 3

@interface SecondViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
    UITableView *twitterTable;
    NSMutableData *receivedData;
    NSMutableArray *displayDataArray;       
    NSMutableArray *displayDataTitleArray;   
    NSMutableArray *updatedTimeDataArray;  
    NSMutableArray *urlDataArray;  
    UIActivityIndicatorView *spinner;
    GADBannerView *adBanner; 
    InfoNaviAppDelegate *appDelegate;
}

@property (nonatomic, retain) IBOutlet UITableView *twitterTable;

@end
