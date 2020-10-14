//
//  FirstViewController.m
//  InfoNavi
//
//  Created by Damon Lok on 9/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FirstViewController.h"
#import "NSString+HTMLUtil.h"
#import "UIButton+Property.h"

@implementation FirstViewController
@synthesize displayDataTable;

- (void)loadJPSearchResult
{
    NSString *yahooJPSearchURL = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"Yahoo JP Search URL"];
    NSString *inSearchURLCriteria = [InfoNaviAppDelegate getSearchCriteria]; 
    NSString *searchCriteriaString = [InfoNaviAppDelegate encodeURI:inSearchURLCriteria];
    NSString *urlString = [InfoNaviAppDelegate getYahooSearchURL:[NSString stringWithFormat:@"%@%@", yahooJPSearchURL, searchCriteriaString]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    
    if (conn == nil) {
        return;
    }   
    NSLog(@"Successfully launached the HTTP request to Yahoo JP Web API at the end of method: %s",__PRETTY_FUNCTION__);
}

- (void)loadGoogleFeedAjaxSearchResult
{
    NSString *googleFeedAjaxSearchURL = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"Google Feed Ajax Search URL"];
    NSString *inSearchURLCriteria = [InfoNaviAppDelegate getSearchCriteria];  
    NSString *searchCriteriaString = [InfoNaviAppDelegate encodeURI:inSearchURLCriteria];
    NSString *urlString = [InfoNaviAppDelegate getGoogleSearchURL:[NSString stringWithFormat:@"%@%@", googleFeedAjaxSearchURL, searchCriteriaString]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    
    if (conn == nil) {
        return;
    }
    NSLog(@"Successfully launached the HTTP request to Google Ajax Feed at the end of method: %s",__PRETTY_FUNCTION__);
}

- (void)loadGoogleCustomAPISearchResult
{
    NSString *googleCustomAPISearchURL = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"Google Custom API Search URL"];
    NSString *inSearchURLCriteria = [InfoNaviAppDelegate getSearchCriteria]; 
    NSString *searchCriteriaString = [InfoNaviAppDelegate encodeURI:inSearchURLCriteria];
    NSString *urlString = [InfoNaviAppDelegate getGoogleSearchURL:[NSString stringWithFormat:@"%@%@", googleCustomAPISearchURL, searchCriteriaString]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    
    if (conn == nil) {
        return;
    }    
    NSLog(@"Successfully launached the HTTP request to Google Custom API Search at the end of method: %s",__PRETTY_FUNCTION__);
}

- (void)startSpinner
{   
    spinner = [appDelegate getSpinner];
    [displayDataTable addSubview:spinner]; 
    [spinner startAnimating];   
}

- (void)stopSpinner
{
    [spinner stopAnimating];
    [spinner removeFromSuperview];
}

- (void)loadData
{    
    receivedData = [[NSMutableData alloc] initWithLength:0];
    displayDataArray = [[NSMutableArray alloc] init];
    displayDataTitleArray = [[NSMutableArray alloc] init];
    
    [self loadGoogleCustomAPISearchResult];
    [self loadGoogleFeedAjaxSearchResult];
    [self loadJPSearchResult];
    NSLog(@"Successfully populated Homepage data at the end of method: %s", __PRETTY_FUNCTION__);
}

- (void)viewWillAppear:(BOOL)animated
{
    receivedData = nil;
    displayDataArray = nil;
    displayDataTitleArray = nil;
    
    [super viewWillAppear:animated];
    if ([InfoNaviAppDelegate isiPad]) {
        self.view.frame =  CGRectMake(0, 0, 768, 1028);
        displayDataTable.frame = CGRectMake(0, 90, 768, 950);
    } else {
        displayDataTable.frame = CGRectMake(0, 50, 320, 411);
    }
    appDelegate = (((InfoNaviAppDelegate*) [UIApplication sharedApplication].delegate));
    [self startSpinner];
    [self performSelector:@selector(loadData) withObject:nil afterDelay:0];   
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadAdBanner];
    [displayDataTable flashScrollIndicators];
    
    CGRect labelFrame;
    if ([InfoNaviAppDelegate isiPad]) labelFrame = CGRectMake(0, 80, 650, 50);
    else labelFrame = CGRectMake(0, 70, 280, 33);
    
    NSString *spaceString = @" ";
    NSString *dashString = @"-";
    NSString *themeTitle = [InfoNaviAppDelegate getSearchCriteria]; 
    NSString *titleString = [InfoNaviAppDelegate getTableTitle:1]; 
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
    displayDataTable.backgroundColor = [UIColor groupTableViewBackgroundColor];
    displayDataTable.tableHeaderView = label;
    [displayDataTable flashScrollIndicators];
    
    CGRect refreshButtonFrame = CGRectMake(5, 5, 30, 30);
    UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];  
    refreshButton.frame = refreshButtonFrame;
    [refreshButton setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    UIImage *refreshButtonImage = [UIImage imageNamed:@"refreshN30.png"];
    UIImage *refreshPressedButtonImage = [UIImage imageNamed:@"refreshP30.png"];
    [refreshButton setImage:refreshButtonImage forState:UIControlStateNormal];
    [refreshButton setImage:refreshPressedButtonImage forState:UIControlStateHighlighted];
    [refreshButton addTarget:self action:@selector(viewWillAppear:) forControlEvents: UIControlEventTouchUpInside];
    [displayDataTable addSubview:refreshButton];
    NSLog(@"Successfully loaded Homepage view at the end of method: %s", __PRETTY_FUNCTION__);
}

-(void) parser:(NSXMLParser *) parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if( [elementName isEqualToString:@"Error"]) {
        [self loadJPSearchResult]; 
        return;
    } else if ([elementName isEqualToString:@"ClickUrl"]) {
        currentStringValue = [[NSMutableString alloc] initWithCapacity:60];
        currentStringType = [[NSString alloc] initWithString:@"ClickUrl"];
    } else if ([elementName isEqualToString:@"Title"]) {
        currentStringValue = [[NSMutableString alloc] initWithCapacity:60];
        currentStringType = [[NSString alloc] initWithString:@"Title"];
    } else {
        currentStringType = @"Unwant";
    }
    //NSLog(@"XML parsing at element: %@ at the end of method: %s", elementName, __PRETTY_FUNCTION__);
}   

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (currentStringType == @"ClickUrl") {
        [currentStringValue appendString:string];    
    } else if (currentStringType == @"Title") {
        [currentStringValue appendString:string];  
    }
    //NSLog(@"XML parsing and scanning at tag value: %@ at the end of method: %s", string, __PRETTY_FUNCTION__);
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
    if ([elementName isEqualToString:@"ClickUrl"]) {
        NSString *url = (NSString *)currentStringValue;      
        [displayDataArray addObject:[url fixHomepageURL]];    
    } else if ([elementName isEqualToString:@"Title"]) {    
        [displayDataTitleArray addObject:[currentStringValue stringByStrippingHTML]];          
    }
    //NSLog(@"XML parsing and ending process on element: %@ at the end of method: %s", elementName, __PRETTY_FUNCTION__);
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
    
    NSDictionary *responseData = (NSDictionary *)[result objectForKey:@"responseData"];
    NSArray *items = (NSArray *)[result objectForKey:@"items"];
    
    if (responseData) {   
        NSArray *entries = (NSArray *)[responseData objectForKey:@"entries"];  
        for (NSDictionary* item in entries) {
            NSString *url = [item objectForKey:@"link"];
            [displayDataArray addObject:[url fixHomepageURL]];
            NSString *title = [item objectForKey:@"title"];            
            [displayDataTitleArray addObject:[title stringByStrippingHTML]];
        }  
    } else if (items) {      
        for (NSDictionary* item in items) {
            NSString *url = [item objectForKey:@"link"];    
            [displayDataArray addObject:[url fixHomepageURL]];
            NSString *title = [item objectForKey:@"title"];            
            [displayDataTitleArray addObject:[title stringByStrippingHTML]];
        }
    } else {
        NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData: receivedData];
        [xmlParser setDelegate: self];
        [xmlParser setShouldResolveExternalEntities:YES];
        [xmlParser parse];        
    }
    
    [displayDataTable reloadData];
    [self stopSpinner];
    [incomingSearchResultData release];
    [connection release];
    NSLog(@"Successfully received HTTP returning Homepage data at the end of method: %s",__PRETTY_FUNCTION__);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [connection release];
}

- (IBAction)urlClicked:(id)sender
{
    UIButton *urlButton = (UIButton *)sender;
    NSString *urlLink = (NSString *)urlButton.property; 
    [appDelegate urlFlipAction:[NSURL URLWithString:urlLink] flipActionOn:@"Flip To Homepage"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [displayDataArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)getCellContentView:(NSString *)cellIdentifier
{
    CGRect CellFrame;
    CGRect frontImageDataFrame; 
    CGRect urlDataFrame;
    CGRect contentDataFrame;
    
    if ([InfoNaviAppDelegate isiPad]) {
        CellFrame = CGRectMake(0, 0, 700, 120);
        frontImageDataFrame = CGRectMake(20, 10, 30, 30);
        urlDataFrame = CGRectMake(20, 20, 600, 25);
        contentDataFrame = CGRectMake(20, 60, 510, 50);        
    } else {    
        CellFrame = CGRectMake(0, 0, 300, 100);
        frontImageDataFrame = CGRectMake(10, 10, 20, 20);
        urlDataFrame = CGRectMake(30, 5, 250, 25);
        contentDataFrame = CGRectMake(20, 33, 270, 60);
    }
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
    
    UITextView *titleTextView = [[UITextView alloc] initWithFrame:contentDataFrame];
    titleTextView.editable = NO;
    titleTextView.backgroundColor = [UIColor whiteColor];
    titleTextView.dataDetectorTypes = UIDataDetectorTypeLink; 
    titleTextView.tag = kUITag1;
    titleTextView.scrollEnabled = FALSE;
    [cell.contentView addSubview:titleTextView];
    [titleTextView release];
    
    UIButton *hyperLink = [[UIButton alloc] initWithFrame:urlDataFrame];
    if ([InfoNaviAppDelegate isiPad]) {
        hyperLink.titleLabel.font = [UIFont systemFontOfSize:20];
    } else { 
        hyperLink.titleLabel.font = [UIFont systemFontOfSize:15];
    }
    hyperLink.backgroundColor = [UIColor whiteColor];
    [hyperLink setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    hyperLink.tag = kUITag2;
    [cell.contentView addSubview:hyperLink];
    [hyperLink release];
    
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    cell.frame = CellFrame;
    UIImageView *frontImageView = [[UIImageView alloc] initWithFrame:frontImageDataFrame];
    frontImageView.backgroundColor = [UIColor whiteColor];
    [frontImageView setImage:[UIImage imageNamed:@"nail_small.png"]];
    [cell.contentView addSubview:frontImageView];
    [frontImageView release];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([InfoNaviAppDelegate isiPad]) {
        return 120;
    } else {
        return 100;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"displayDataCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [self getCellContentView:cellID];       
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        cell.textLabel.numberOfLines = 2;
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    UITextView *titleText = (UITextView *)[cell viewWithTag:kUITag1];
    UIButton *urlText = (UIButton *)[cell viewWithTag:kUITag2];
    @try {
        titleText.text = [displayDataTitleArray objectAtIndex:indexPath.row];
        [urlText setTitle:[displayDataArray objectAtIndex:indexPath.row] forState:UIControlStateNormal];
        urlText.property = [displayDataArray objectAtIndex:indexPath.row];
    } @catch (NSException *ex) { 
        [self viewWillAppear:TRUE];
    }
    [urlText addTarget:self action:@selector(urlClicked:) forControlEvents:UIControlEventTouchUpInside]; 
    NSLog(@"Successfully populated Homepage cell data for title: %@ at row index %d at the end of method: %s", titleText.text, indexPath.row, __PRETTY_FUNCTION__);
   
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Web Places"
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
        CGRect landscapeFrame = displayDataTable.frame;
        landscapeFrame.origin.y = 90.0;
        displayDataTable.frame = landscapeFrame;
        adBannerFrame = CGRectMake(0, 0, GAD_SIZE_728x90.width, GAD_SIZE_728x90.height);       
    } else {
        if (UIInterfaceOrientationIsLandscape(toOrientation)) {
            CGRect landscapeFrame = displayDataTable.frame;
            landscapeFrame.origin.y = 60.0;
            displayDataTable.frame = landscapeFrame;
            adBannerFrame = CGRectMake(0, 0, GAD_SIZE_468x60.width, GAD_SIZE_468x60.height);
        }  else {
            CGRect portraitFrame = displayDataTable.frame;
            portraitFrame.origin.y = 50.0;
            displayDataTable.frame = portraitFrame;
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
}

- (void)viewDidUnload
{   
    receivedData = nil;
    displayDataArray = nil;
    displayDataTitleArray = nil;
    [self setDisplayDataTable:nil];
    [super viewDidUnload];
    NSLog(@"Successfully unloaded the Homepage view at the end of method: %s",__PRETTY_FUNCTION__);
}

- (void)dealloc {
    if (adBanner) [adBanner release];
    [currentStringType release];
    [currentStringValue release];
    [displayDataTable release];
    [receivedData release];
    [displayDataArray release];
    [displayDataTitleArray release];
    [super dealloc];
    NSLog(@"Successfully deallocated all Homepage instance variables' memories at the end of method: %s",__PRETTY_FUNCTION__); 
}
@end
