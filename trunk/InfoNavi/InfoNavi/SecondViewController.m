//
//  SecondViewController.m
//  InfoNavi
//
//  Created by Damon Lok on 9/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SecondViewController.h"
#import "UIButton+Property.h"

@implementation SecondViewController
@synthesize twitterTable;

- (NSString *)getLocalTimeStamp:(NSString *)foreignTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
    [formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss"];
    NSDate *sourceDate = [formatter dateFromString:foreignTime];
    
    NSTimeZone *sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone *destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate *destinationDate = [[[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate] autorelease];  
    NSString *returnDateString = [formatter stringFromDate:destinationDate];     
    //NSLog(@"Successfully converted to the foreign time: %@ to the local time: %@ at the end of method: %s", foreignTime, returnDateString, __PRETTY_FUNCTION__);
    return returnDateString;
}

- (void)startSpinner
{    
    spinner = [appDelegate getSpinner];
    [twitterTable addSubview:spinner]; 
    [spinner startAnimating];   
}

- (void)stopSpinner
{
    [spinner stopAnimating];
    [spinner removeFromSuperview];
}

- (void)loadTwitterSearchResult
{
    receivedData = [[NSMutableData alloc] initWithLength:0];
    displayDataArray = [[NSMutableArray alloc] init];
    displayDataTitleArray = [[NSMutableArray alloc] init];
    updatedTimeDataArray = [[NSMutableArray alloc] init];
    urlDataArray = [[NSMutableArray alloc] init];
     
    NSString *twitterSearchURL = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"Twitter Search URL"];
    NSString *urlString = [InfoNaviAppDelegate getTwitterURL:twitterSearchURL];    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    
    if (conn == nil) {
        return; 
    } 
    NSLog(@"Successfully launached the HTTP request to Twitter Search at the end of method: %s",__PRETTY_FUNCTION__);
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadAdBanner];
    [twitterTable flashScrollIndicators];
    
    CGRect labelFrame;
    if ([InfoNaviAppDelegate isiPad]) labelFrame = CGRectMake(0, 80, 650, 50);
    else labelFrame = CGRectMake(0, 70, 280, 33);
    
    NSString *spaceString = @" ";
    NSString *dashString = @"-";
    NSString *themeTitle = [InfoNaviAppDelegate getSearchCriteria]; 
    NSString *titleString = [InfoNaviAppDelegate getTableTitle:2]; 
    NSString *tableHeaderText = [NSString stringWithFormat:@"%@%@%@%@%@", themeTitle, spaceString, dashString, spaceString, titleString];
    
    UILabel *label = [[[UILabel alloc] initWithFrame:labelFrame] autorelease];
    label.backgroundColor = [UIColor groupTableViewBackgroundColor];
    if ([InfoNaviAppDelegate isiPad]) {
        label.font = [UIFont systemFontOfSize:20];
    } else {
        label.font = [UIFont systemFontOfSize:16];    
    }
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.8];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor orangeColor];
    label.text = tableHeaderText;
    twitterTable.tableHeaderView = label;
    
    CGRect refreshButtonFrame = CGRectMake(5, 5, 30, 30);
    UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];  
    refreshButton.frame = refreshButtonFrame;
    [refreshButton setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    UIImage *refreshButtonImage = [UIImage imageNamed:@"refreshN30.png"];
    UIImage *refreshPressedButtonImage = [UIImage imageNamed:@"refreshP30.png"];
    [refreshButton setImage:refreshButtonImage forState:UIControlStateNormal];
    [refreshButton setImage:refreshPressedButtonImage forState:UIControlStateHighlighted];
    [refreshButton addTarget:self action:@selector(viewWillAppear:) forControlEvents: UIControlEventTouchUpInside];
    [twitterTable addSubview:refreshButton];
    
    NSLog(@"Successfully loaded the Twitter table view at the end of method: %s",__PRETTY_FUNCTION__);
}

- (void)viewWillAppear:(BOOL)animated
{
    receivedData = nil;
    displayDataArray = nil;
    displayDataTitleArray = nil;    
    updatedTimeDataArray = nil;
    
    [super viewWillAppear:animated];
    if ([InfoNaviAppDelegate isiPad]) {
        self.view.frame =  CGRectMake(0, 0, 768, 1028);
        twitterTable.frame = CGRectMake(0, 90, 768, 950);
    } else {
        twitterTable.frame = CGRectMake(0, 50, 320, 411);
    }
    appDelegate = (((InfoNaviAppDelegate*) [UIApplication sharedApplication].delegate));
    [self startSpinner];
    [self performSelector:@selector(loadTwitterSearchResult) withObject:nil afterDelay:0];    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{
    NSString *incomingSearchResultData = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    
    NSDictionary *result = [incomingSearchResultData JSONValue];
    
    NSArray *items = (NSArray *)[result objectForKey:@"results"];
    
    if (items) {    
        for (NSDictionary* item in items) {
            NSString *atString = @"@";
            NSString *source = [NSString stringWithString:[item objectForKey:@"source"]];
            NSArray *stringChunks = [source componentsSeparatedByString: @";"];
            NSString *sourceUrl = [NSString stringWithString:[stringChunks objectAtIndex:2]];
            sourceUrl = [sourceUrl stringByReplacingOccurrencesOfString:@"&quot" withString:@""];
            [urlDataArray addObject:sourceUrl];
            
            NSString *user = [NSString stringWithString:[item objectForKey:@"from_user"]];
            NSString *userLocation = [NSString stringWithFormat:@"%@%@%@", user, atString, sourceUrl];
            [displayDataArray addObject:userLocation];
            
            NSString *updatedString = [[item objectForKey:@"created_at"] stringByReplacingOccurrencesOfString:@"+0000" withString:@""];
            updatedString = [NSString stringWithFormat:@"updated on: %@", [self getLocalTimeStamp:updatedString]];
            [updatedTimeDataArray addObject:updatedString];
            
            NSString *text = [NSString stringWithString:[item objectForKey:@"text"]];           
            [displayDataTitleArray addObject:text];
        }
    } else {
        [self loadTwitterSearchResult];
    }
    
    [incomingSearchResultData release];
    [connection release];
    [twitterTable reloadData];
    [self stopSpinner];
    NSLog(@"Successfully received HTTP returning Twitter data at the end of method: %s",__PRETTY_FUNCTION__);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [connection release];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [displayDataArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (IBAction)userLocationClicked:(id)sender
{
    UIButton *userLocationButton = (UIButton *)sender;
    NSString *userLocation = (NSString *)userLocationButton.property; 
    [appDelegate urlFlipAction:[NSURL URLWithString:userLocation] flipActionOn:@"Flip To Homepage"];
}

- (UITableViewCell *)getCellContentView:(NSString *)cellIdentifier
{     
    CGRect CellFrame;
    CGRect userLocationDataFrame; 
    CGRect updatedTimeFrame;
    CGRect contentDataFrame;
    
    if ([InfoNaviAppDelegate isiPad]) {
        CellFrame = CGRectMake(0, 0, 700, 140);
        userLocationDataFrame = CGRectMake(15, 2, 650, 24); 
        updatedTimeFrame = CGRectMake(20, 30, 260, 17);
        contentDataFrame = CGRectMake(20, 55, 510, 80);        
    } else {    
        CellFrame = CGRectMake(0, 0, 300, 140);
        userLocationDataFrame = CGRectMake(15, 2, 260, 24); 
        updatedTimeFrame = CGRectMake(20, 29, 260, 17);
        contentDataFrame = CGRectMake(10, 47, 290, 84);
    }    
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CellFrame reuseIdentifier:cellIdentifier] autorelease];
    
    UIButton *userLocation = [[UIButton alloc] initWithFrame:userLocationDataFrame];
    userLocation.backgroundColor = [UIColor whiteColor];
    [userLocation setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    userLocation.titleLabel.font = [UIFont systemFontOfSize:12];
    userLocation.tag = kUITag2;   
    [cell.contentView addSubview:userLocation];
    [userLocation release];
    
    UITextView *updatedTimeTextView = [[UITextView alloc] initWithFrame:updatedTimeFrame];
    updatedTimeTextView.backgroundColor = [UIColor whiteColor];
    updatedTimeTextView.editable = NO;
    updatedTimeTextView.tag = kUITag3;   
    [cell.contentView addSubview:updatedTimeTextView];
    [updatedTimeTextView release];    
    
    UITextView *titleTextView = [[UITextView alloc] initWithFrame:contentDataFrame];
    titleTextView.backgroundColor = [UIColor whiteColor];
    titleTextView.editable = NO;
    titleTextView.dataDetectorTypes = UIDataDetectorTypeLink; 
    titleTextView.tag = kUITag1;
    titleTextView.scrollsToTop = TRUE;
    [titleTextView flashScrollIndicators];
    [cell.contentView addSubview:titleTextView];
    [titleTextView release];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 140;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"displayDataCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [self getCellContentView:cellID];       
        if ([InfoNaviAppDelegate isiPad]) {
            cell.textLabel.font = [UIFont systemFontOfSize:16];
        }   else {  
            cell.textLabel.font = [UIFont systemFontOfSize:12];
        }
        cell.textLabel.numberOfLines = 2;
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    UITextView *titleText = (UITextView *)[cell viewWithTag:kUITag1];
    UIButton *userLocation = (UIButton *)[cell viewWithTag:kUITag2];   
    UITextView *updatedTimeText = (UITextView *)[cell viewWithTag:kUITag3];
    
    @try {
        titleText.text = [displayDataTitleArray objectAtIndex:indexPath.row];
        [userLocation setTitle:[displayDataArray objectAtIndex:indexPath.row] forState:UIControlStateNormal];
        userLocation.property = [urlDataArray objectAtIndex:indexPath.row];
    } @catch (NSException *ex) { 
        [self viewWillAppear:TRUE];
    }
    
    [userLocation addTarget:self action:@selector(userLocationClicked:) forControlEvents:UIControlEventTouchUpInside];    
    updatedTimeText.text = [updatedTimeDataArray objectAtIndex:indexPath.row]; 
    NSLog(@"Successfully populated Twitter cell data for title: %@ at row index %d at the end of method: %s", titleText.text, indexPath.row, __PRETTY_FUNCTION__);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter words"
                                                    message:[displayDataTitleArray objectAtIndex:indexPath.row]
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    [alert release];
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

- (void)changeBannerOrientation:(UIInterfaceOrientation)toOrientation {
    [adBanner removeFromSuperview];
    [adBanner release];
    CGRect adBannerFrame;
    
    if ([InfoNaviAppDelegate isiPad]) {
        CGRect landscapeFrame = twitterTable.frame;
        landscapeFrame.origin.y = 90.0;
        twitterTable.frame = landscapeFrame;
        adBannerFrame = CGRectMake(0, 0, GAD_SIZE_728x90.width, GAD_SIZE_728x90.height);       
    } else {
        if (UIInterfaceOrientationIsLandscape(toOrientation)) {
            CGRect landscapeFrame = twitterTable.frame;
            landscapeFrame.origin.y = 60.0;
            twitterTable.frame = landscapeFrame;
            adBannerFrame = CGRectMake(0, 0, GAD_SIZE_468x60.width, GAD_SIZE_468x60.height);
        }  else {
            CGRect portraitFrame = twitterTable.frame;
            portraitFrame.origin.y = 50.0;
            twitterTable.frame = portraitFrame;
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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
    receivedData = nil;
    displayDataArray = nil;
    displayDataTitleArray = nil;    
    updatedTimeDataArray = nil;
    [self setTwitterTable:nil];
    [super viewDidUnload];
    NSLog(@"Successfully unloaded the Twitter view at the end of method: %s",__PRETTY_FUNCTION__);
}

- (void)dealloc {
    if (adBanner)[adBanner release];
    [twitterTable release];
    [receivedData release];
    [updatedTimeDataArray release];
    [urlDataArray release];
    [displayDataArray release];
    [displayDataTitleArray release];
    [super dealloc];
    NSLog(@"Successfully deallocated all Twitter instance variables' memories at the end of method: %s",__PRETTY_FUNCTION__); 
}
@end
