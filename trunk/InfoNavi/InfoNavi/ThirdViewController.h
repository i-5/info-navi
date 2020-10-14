//
//  ThirdViewController.h
//  InfoNavi
//
//  Created by Damon Lok on 9/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoNaviAppDelegate.h"

#define kUITag1 1
#define kUITag2 2
#define kUITag3 3

typedef enum
{
    UNKNOWN,
    LOGIN,
    GET_TOKEN,
    LOAD_ALERTS,
    CREATE_ALERT
    
} httpSessionType;

@interface ThirdViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSXMLParserDelegate>{
    NSMutableString *currentStringValue; 
    NSString *currentStringType;    
    UITableView *alertTable;
    NSMutableData *receivedData;
    NSMutableArray *displayDataArray;       
    NSMutableArray *displayDataTitleArray;  
    NSMutableArray *urlDataArray;
    NSMutableArray *updatedDataArray;
    NSMutableDictionary* token;
    httpSessionType httpSession;
    UIActivityIndicatorView *spinner;
    InfoNaviAppDelegate *appDelegate;
    GADBannerView *adBanner; 
    BOOL canReadTitle;
    BOOL canReadLink;
}

@property (nonatomic, retain) IBOutlet UITableView *alertTable;

@end
