//
//  ThirdViewController.m
//  InfoNavi
//
//  Created by Damon Lok on 9/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ThirdViewController.h"
#import "NSString+HTMLUtil.h"
#import "UIButton+Property.h"

@implementation ThirdViewController
@synthesize alertTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)startSpinner
{   
    spinner = [appDelegate getSpinner];
    [alertTable addSubview:spinner]; 
    [spinner startAnimating];   
}

- (void)stopSpinner
{
    [spinner stopAnimating];
    [spinner removeFromSuperview];
}

- (NSString *) getSID
{
    return [NSString stringWithFormat: @"SID=%@", [token objectForKey:@"SID"] ];
}

- (NSString *) getToken
{
    return [NSString stringWithFormat: @"T=%@",[token objectForKey:@"Token"]];
}

- (NSString *) getAuth
{
    return [NSString stringWithFormat: @"Auth=%@",[token objectForKey:@"Auth"]];
}

- (void)createAlert
{    
    NSString *alertSearchUrl = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"Alert Creation URL"]; 
    NSString *alertParamString = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"Alert Parameter String"]; 
    NSString *inSearchURLCriteria = [InfoNaviAppDelegate getSearchCriteria];     
    NSString *email = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"I Parameter String"]; 
    NSString *paramPartString = @"&q=";
    NSString *paramString = [NSString stringWithFormat:@"%@%@%@%@", alertParamString, email, paramPartString, inSearchURLCriteria]; 
        
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:alertSearchUrl]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-type"];
    [request setValue:[NSString stringWithFormat:@"%d",[paramString length]] forHTTPHeaderField:@"Content-length"];
    [request setHTTPBody:[paramString dataUsingEncoding:NSUTF8StringEncoding]];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];    
    
    [request release];    
    httpSession = CREATE_ALERT;
    NSLog(@"Successfully created Google Alert at the end of method: %s", __PRETTY_FUNCTION__);
}

- (void)getTokenWithSID
{
    NSString *tokenRequestString = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"Token URL"];
    
    NSURL *tokenAuthUrl = [NSURL URLWithString:tokenRequestString];
    
    NSMutableURLRequest *tokenAuthRequest = [[NSMutableURLRequest alloc] initWithURL:tokenAuthUrl];
    
    [tokenAuthRequest setHTTPMethod:@"GET"];
    
    [tokenAuthRequest addValue:[self getSID] forHTTPHeaderField:@"Cookie"];
    
    NSHTTPURLResponse *authResponse;
    
    NSError *authError;
    
    NSData *tokenData = [NSURLConnection sendSynchronousRequest:tokenAuthRequest returningResponse:&authResponse error:&authError];      
    
    NSString *tokenString = [[NSString alloc] initWithData:tokenData encoding:NSASCIIStringEncoding];     
    
    if (tokenString.length >0)
        [token setObject:tokenString forKey:@"Token"];
    else
        NSLog(@"Failed to obtain token");
    
    [tokenAuthRequest release];
    [tokenString release];
    httpSession = GET_TOKEN;
    NSLog(@"Successfully obtained token via SID at the end of method: %s", __PRETTY_FUNCTION__);
}   

- (void)loadAlertSearchResult
{
    NSString *alertSearchURL = [InfoNaviAppDelegate getReaderURL];
    NSString *extraGoogleProperties = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"Extra Google Properties"];
    NSURL *url = [NSURL URLWithString:alertSearchURL];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    NSString *cookie = [NSString stringWithFormat:@"%@%@", [self getAuth], extraGoogleProperties];
    [req setHTTPMethod:@"GET"];
    [req addValue:cookie forHTTPHeaderField:@"Cookie" ];   
    NSHTTPURLResponse *authResponse;
    NSError *authError;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&authResponse error:&authError];    
    
    if (responseData.length > 0) {
        NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData: responseData];
        [xmlParser setDelegate: self];
        [xmlParser setShouldResolveExternalEntities:YES];
        [xmlParser parse];  
        [xmlParser release];
    } else {
        NSLog(@"Failed to obtain Google reader's alert result.");
    }
    
    httpSession = LOAD_ALERTS;
    NSLog(@"Successfully loaded google alerts at the end of method: %s", __PRETTY_FUNCTION__);
}

- (void)loginToObtainSID
{
    NSString *content = [NSString stringWithFormat:@"accountType=%@&Email=%@&Passwd=%@&service=%@&source=%@", 
                         [[[NSBundle mainBundle] infoDictionary] valueForKey:@"A Parameter String"], 
                         [[[NSBundle mainBundle] infoDictionary] valueForKey:@"I Parameter String"], 
                         [[[NSBundle mainBundle] infoDictionary] valueForKey:@"IS Parameter String"],
                         [[[NSBundle mainBundle] infoDictionary] valueForKey:@"S Parameter String"],
                         [[[NSBundle mainBundle] infoDictionary] valueForKey:@"SU Parameter String"]];
    
    NSURL *authUrl = [NSURL URLWithString:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"Login URL"]];
    
    NSMutableURLRequest *authRequest = [[NSMutableURLRequest alloc] initWithURL:authUrl];
    
    [authRequest setHTTPMethod:@"POST"];
    [authRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    [authRequest setHTTPBody:[content dataUsingEncoding:NSASCIIStringEncoding]];
    
    NSHTTPURLResponse *authResponse;
    NSError *authError;
    NSData *authData = [NSURLConnection sendSynchronousRequest:authRequest returningResponse:&authResponse error:&authError];      
    
    NSString *authResponseBody = [[NSString alloc] initWithData:authData encoding:NSASCIIStringEncoding];
    
    NSArray *lines = [authResponseBody componentsSeparatedByString:@"\n"];
    token = [NSMutableDictionary dictionary];
    
    for (NSString *s in lines) {
        NSArray *kvpair = [s componentsSeparatedByString:@"="];
        if ([kvpair count]>1)
            [token setObject:[kvpair objectAtIndex:1] forKey:[kvpair objectAtIndex:0]];
    }
    
    if ([token objectForKey:@"Error"]) {
        NSLog(@"Error with response code: %d", [authResponse statusCode]);
        NSLog(@"Error description: %@", [token objectForKey:@"Error"]);
    };  
   
    [authRequest release];
    [authResponseBody release];

    httpSession = LOGIN;
    NSLog(@"Successfully logged in via ClientLogin from google at the end of method: %s", __PRETTY_FUNCTION__);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
	NSLog(@"Http response code: %d at method: %s", [res statusCode], __PRETTY_FUNCTION__);
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{
    NSString *incomingSearchResultData = [[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding];
    
    switch (httpSession) {
        case UNKNOWN:
        case LOGIN:
        case GET_TOKEN:     
        case LOAD_ALERTS:    
            break;
            
        case CREATE_ALERT:
            
            NSLog(@"Create Google Alert's HTTP response data is %@", incomingSearchResultData);
            
            break;         
            
        default:
            break;
    }
    
    [incomingSearchResultData release];
    
    [connection release];
}

-(void) parser:(NSXMLParser *) parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if( [elementName isEqualToString:@"Error"]) {
        NSLog(@"Error returned from Google reader's http response.");
        return;
    } else if ([elementName isEqualToString:@"entry"]) {
        canReadTitle = TRUE;
        canReadLink = TRUE;
    } else if ([elementName isEqualToString:@"content"]) {
        currentStringValue = [[NSMutableString alloc] initWithCapacity:60];
        currentStringType = [[NSString alloc] initWithString:@"content"];
    } else if ([elementName isEqualToString:@"updated"]) {
        currentStringValue = [[NSMutableString alloc] initWithCapacity:60];
        currentStringType = [[NSString alloc] initWithString:@"updated"];
    } else if (([elementName isEqualToString:@"title"]) && (canReadTitle)) {
        currentStringValue = [[NSMutableString alloc] initWithCapacity:60];
        currentStringType = [[NSString alloc] initWithString:@"title"];
    } else if (([elementName isEqualToString:@"link"]) && (canReadLink)) {
        NSString *hyperlink = [attributeDict objectForKey:@"href"];
        if (hyperlink) {
            hyperlink = [hyperlink fixHomepageURL];
            [urlDataArray addObject:hyperlink];
        }
    } else {
        currentStringType = @"Unwant";
    }
    //NSLog(@"XML parsing at element: %@ at the end of method: %s", elementName, __PRETTY_FUNCTION__);
}   

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (currentStringType == @"content") {
        [currentStringValue appendString:string];    
    } else if (currentStringType == @"title") {
        [currentStringValue appendString:string];  
    } else if (currentStringType == @"updated") {
        [currentStringValue appendString:string];  
    }
   // NSLog(@"XML parsing and scanning at tag value: %@ at the end of method: %s", string, __PRETTY_FUNCTION__);
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
    if ([elementName isEqualToString:@"content"]) {
        
        NSString *content = [NSString stringWithString:currentStringValue];
        content = [content stringByStrippingHTML];
        [displayDataArray addObject:[content fixURLInComment]];
        
    } else if (([elementName isEqualToString:@"title"]) && (canReadTitle)) {    
        
        NSString *title = [NSString stringWithString:currentStringValue];         
        [displayDataTitleArray addObject:[title stringByStrippingHTML]];
        canReadTitle = FALSE;
        
    } else if ([elementName isEqualToString:@"updated"]) {
        
        NSString *updatedString = [NSString stringWithFormat:@"updated on: %@", currentStringValue];
        updatedString = [updatedString stringByReplacingOccurrencesOfString:@"Z" withString:@""];
        [updatedDataArray addObject:updatedString];      
        
    } else if ([elementName isEqualToString:@"entry"]) {   
        canReadTitle = TRUE;
    }
    //NSLog(@"XML parsing and ending process on element: %@ at the end of method: %s", elementName, __PRETTY_FUNCTION__);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)loadData
{    
    receivedData = [[NSMutableData alloc] initWithLength:0];
    displayDataArray = [[NSMutableArray alloc] init];
    displayDataTitleArray = [[NSMutableArray alloc] init];
    updatedDataArray = [[NSMutableArray alloc] init];
    urlDataArray = [[NSMutableArray alloc] init]; 
    
    [self loginToObtainSID];
    [self loadAlertSearchResult];
    [alertTable reloadData];
    [self stopSpinner];
    NSLog(@"Successfully populated Google Alert data at the end of method: %s", __PRETTY_FUNCTION__);
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    receivedData = nil;
    displayDataArray = nil;
    displayDataTitleArray = nil;
    urlDataArray = nil;
    updatedDataArray = nil;
    httpSession = UNKNOWN;
    canReadTitle = FALSE;
    canReadLink = FALSE;
    
    [super viewWillAppear:animated];
    if ([InfoNaviAppDelegate isiPad]) {
        self.view.frame =  CGRectMake(0, 0, 768, 1028);
        alertTable.frame = CGRectMake(0, 90, 768, 950);
    } else {
        alertTable.frame = CGRectMake(0, 50, 320, 411);
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

- (void)viewDidLoad
{
    [super viewDidLoad]; 
    [self loadAdBanner];
    [alertTable flashScrollIndicators];
    
    CGRect labelFrame;
    if ([InfoNaviAppDelegate isiPad]) labelFrame = CGRectMake(0, 80, 650, 50);  
    else labelFrame = CGRectMake(0, 70, 280, 33);
    
    NSString *spaceString = @" ";
    NSString *dashString = @"-";
    NSString *themeTitle = [InfoNaviAppDelegate getSearchCriteria]; 
    NSString *titleString = [InfoNaviAppDelegate getTableTitle:3]; 
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
    alertTable.tableHeaderView = label;

    CGRect refreshButtonFrame = CGRectMake(5, 5, 30, 30);    
    UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];  
    refreshButton.frame = refreshButtonFrame;
    [refreshButton setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    UIImage *refreshButtonImage = [UIImage imageNamed:@"refreshN30.png"];
    UIImage *refreshPressedButtonImage = [UIImage imageNamed:@"refreshP30.png"];
    [refreshButton setImage:refreshButtonImage forState:UIControlStateNormal];
    [refreshButton setImage:refreshPressedButtonImage forState:UIControlStateHighlighted];
    [refreshButton addTarget:self action:@selector(viewWillAppear:) forControlEvents: UIControlEventTouchUpInside];
    [alertTable addSubview:refreshButton];   
    
    NSLog(@"Successfully loaded Google Alert view at the end of method: %s", __PRETTY_FUNCTION__);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [connection release];
}

- (IBAction)titleLinkClicked:(id)sender
{  
    UIButton *clickableTitle = (UIButton *)sender;
    NSString *titleHyperLink = (NSString *)clickableTitle.property; 
    [appDelegate urlFlipAction:[NSURL URLWithString:titleHyperLink] flipActionOn:@"Flip To Homepage"]; 
    NSLog(@"Successfully flipped view to web browser at the end of method: %s", __PRETTY_FUNCTION__);
}

- (UITableViewCell *) getCellContentView:(NSString *)cellIdentifier
{ 
    CGRect CellFrame;
    CGRect titleDataFrame; 
    CGRect updatedDataFrame;
    CGRect contentDataFrame;
    
   if ([InfoNaviAppDelegate isiPad]) {
        CellFrame = CGRectMake(0, 0, 700, 140);
        titleDataFrame = CGRectMake(15, 2, 650, 24); 
        updatedDataFrame = CGRectMake(20, 30, 200, 17);
        contentDataFrame = CGRectMake(20, 55, 510, 80);        
    } else {    
        CellFrame = CGRectMake(0, 0, 300, 140);
        titleDataFrame = CGRectMake(15, 2, 260, 24); 
        updatedDataFrame = CGRectMake(20, 29, 260, 17);
        contentDataFrame = CGRectMake(10, 47, 290, 87);
    }
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CellFrame reuseIdentifier:cellIdentifier] autorelease];
    
    UIButton *clickableTitle = [[UIButton alloc] initWithFrame:titleDataFrame];
    [clickableTitle setBackgroundColor:[UIColor whiteColor]];
    [clickableTitle setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    if ([InfoNaviAppDelegate isiPad]) {
        clickableTitle.titleLabel.font = [UIFont systemFontOfSize:16];
    } else {
        clickableTitle.titleLabel.font = [UIFont systemFontOfSize:12]; 
    }
    clickableTitle.tag = kUITag1;
    [clickableTitle drawRect:titleDataFrame];
    [cell.contentView addSubview:clickableTitle];
    [clickableTitle release];
    
    UITextView *updatedTextView = [[UITextView alloc] initWithFrame:updatedDataFrame];
    updatedTextView.backgroundColor = [UIColor whiteColor];
    updatedTextView.editable = NO;
    updatedTextView.tag = kUITag2;
    [updatedTextView flashScrollIndicators];
    [cell.contentView addSubview:updatedTextView];
    [updatedTextView release];    
    
    UITextView *contentTextView = [[UITextView alloc] initWithFrame:contentDataFrame];
    contentTextView.backgroundColor = [UIColor whiteColor];
    contentTextView.editable = NO;
    contentTextView.dataDetectorTypes = UIDataDetectorTypeLink; 
    contentTextView.tag = kUITag3;   
    [cell.contentView addSubview:contentTextView];
    [contentTextView release];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [displayDataArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return 150;
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
    UIButton *titleLink = (UIButton *)[cell viewWithTag:kUITag1];    
    @try {
        titleLink.property = [urlDataArray objectAtIndex:indexPath.row];
        [titleLink setTitle:[displayDataTitleArray objectAtIndex:indexPath.row] forState:UIControlStateNormal];
        [titleLink addTarget:self action:@selector(titleLinkClicked:) forControlEvents:UIControlEventTouchUpInside];
        [(UITextView *)[cell viewWithTag:kUITag2] setText:[updatedDataArray objectAtIndex:indexPath.row]];
        [(UITextView *)[cell viewWithTag:kUITag3] setText:[displayDataArray objectAtIndex:indexPath.row]];
    } @catch (NSException *ex) { 
        [self viewWillAppear:TRUE];
    }
    NSLog(@"Successfully populated Google Alert cell data for title: %@ at row index %d at the end of method: %s", titleLink.titleLabel.text, indexPath.row, __PRETTY_FUNCTION__);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Google alert"
                                                    message:[displayDataTitleArray objectAtIndex:indexPath.row]
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

- (void)changeBannerOrientation:(UIInterfaceOrientation)toOrientation 
{
    [adBanner removeFromSuperview];
    [adBanner release];   
    CGRect adBannerFrame;
    
    if ([InfoNaviAppDelegate isiPad]) {
        CGRect landscapeFrame = alertTable.frame;
        landscapeFrame.origin.y = 90.0;
        alertTable.frame = landscapeFrame;
        adBannerFrame = CGRectMake(0, 0, GAD_SIZE_728x90.width, GAD_SIZE_728x90.height);       
    } else {
        if (UIInterfaceOrientationIsLandscape(toOrientation)) {
            CGRect landscapeFrame = alertTable.frame;
            landscapeFrame.origin.y = 60.0;
            alertTable.frame = landscapeFrame;
            adBannerFrame = CGRectMake(0, 0, GAD_SIZE_468x60.width, GAD_SIZE_468x60.height);
        }  else {
            CGRect portraitFrame =alertTable.frame;
            portraitFrame.origin.y = 50.0;
            alertTable.frame = portraitFrame;
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration 
{
    if (adBanner) {
        [self changeBannerOrientation:toInterfaceOrientation];
    }
}

- (void)viewDidUnload
{
    receivedData = nil;
    displayDataArray = nil;
    displayDataTitleArray = nil;
    urlDataArray = nil;
    updatedDataArray = nil;
    httpSession = UNKNOWN;
    canReadTitle = FALSE;
    canReadLink = FALSE; 
    
    [self setAlertTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    NSLog(@"Successfully unloaded the Google Alert view at the end of method: %s",__PRETTY_FUNCTION__);
}

- (void)dealloc 
{
    if (adBanner) [adBanner release];
    [currentStringValue release]; 
    [currentStringType release];    
    [token release];
    [urlDataArray release];
    [alertTable release];
    [receivedData release];
    [displayDataArray release];
    [updatedDataArray release];
    [displayDataTitleArray release];    
    [super dealloc];
    NSLog(@"Successfully deallocated all Google Alert instance variables' memories at the end of method: %s",__PRETTY_FUNCTION__);
}
@end
