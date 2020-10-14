//
//  CityAndLocalSearch.m
//  InfoNavi
//
//  Created by Damon Lok on 8/1/12.
//  Copyright (c) 2012 ios-dev.webs.com. All rights reserved.
//

#import "CityAndLocalSearch.h"

@implementation CityAndLocalSearch

- (void)ParseJSONString:(NSString *)JSONString action:(NSString *)actionString {
    
    NSDictionary *result = [JSONString JSONValue];

    if (actionString == kCitySearch) {    
        NSArray *cities = (NSArray *)[result objectForKey:@"geonames"];
        if(cities) {
            for (NSDictionary* city in cities) {
                NSString *countryName = [NSString stringWithString:[city objectForKey:@"countryName"]];
                NSString *cityName = [NSString stringWithString:[city objectForKey:@"toponymName"]];
                if (countryName != cityName)
                    [citiesArray addObject:cityName];
            }
        } else {
            NSLog(@"No cities result returned from GeoNames City Search.");
        }
    }
    
    if (actionString == kLocalSearch) {
        NSDictionary *resultSet = (NSDictionary *)[result objectForKey:@"ResultSet"];
        NSArray *salons = (NSArray *)[resultSet objectForKey:@"Result"];
        if (salons) {
            salonDetails = [NSMutableDictionary dictionary];
            for (NSDictionary* salon in salons) {
                NSString *title = [NSString stringWithString:[salon objectForKey:@"Title"]];
                [salonDetails setObject:title forKey:@"title"]; 
                NSString *address = [NSString stringWithString:[salon objectForKey:@"Address"]];
                [salonDetails setObject:address forKey:@"address"]; 
                NSString *city = [NSString stringWithString:[salon objectForKey:@"City"]];
                 [salonDetails setObject:city forKey:@"city"]; 
                NSString *state = [NSString stringWithString:[salon objectForKey:@"State"]];
                 [salonDetails setObject:state forKey:@"state"]; 
                NSString *phone = [NSString stringWithString:[salon objectForKey:@"Phone"]];
                 [salonDetails setObject:phone forKey:@"phone"]; 
                NSString *latitude = [NSString stringWithString:[salon objectForKey:@"Latitude"]];
                 [salonDetails setObject:latitude forKey:@"latitude"]; 
                NSString *longitude = [NSString stringWithString:[salon objectForKey:@"Longitude"]];
                 [salonDetails setObject:longitude forKey:@"longitude"]; 
                NSDictionary *rating = (NSDictionary *) [salon objectForKey:@"Rating"];
                NSString *averageRatings = [NSString stringWithString:[rating objectForKey:@"AverageRating"]];
                [salonDetails setObject:averageRatings forKey:@"averageRatings"]; 
                NSString *totalRatings = [NSString stringWithString:[rating objectForKey:@"TotalRatings"]];
                [salonDetails setObject:totalRatings forKey:@"totalRatings"]; 
                NSString *totalReviews = [NSString stringWithString:[rating objectForKey:@"TotalReviews"]];
                [salonDetails setObject:totalReviews forKey:@"totalReviews"]; 
                NSString *lastReviewIntro = [NSString stringWithString:[rating objectForKey:@"LastReviewIntro"]];
                [salonDetails setObject:lastReviewIntro forKey:@"lastReviewIntro"]; 
                NSString *distance = [NSString stringWithString:[salon objectForKey:@"Distance"]];
                [salonDetails setObject:distance forKey:@"distance"];  
                NSString *url = [NSString stringWithString:[salon objectForKey:@"ClickUrl"]];
                 [salonDetails setObject:url forKey:@"url"]; 
                NSString *mapUrl = [NSString stringWithString:[salon objectForKey:@"MapUrl"]];
                 [salonDetails setObject:mapUrl forKey:@"mapUrl"]; 
                NSString *businessUrl = [NSString stringWithString:[salon objectForKey:@"BusinessUrl"]];
                 [salonDetails setObject:businessUrl forKey:@"businessUrl"]; 
                [salonArray addObject:salonDetails];
            }
            
        } else {
            NSLog(@"No salons result returned from Yahoo Local Search.");
        }
    }
    
    NSLog(@"Finished parsing JSON data at the end of method: %s",__PRETTY_FUNCTION__);
}

- (void)cityNameSearch {
    
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];

    //NSString *countryName = [locale displayNameForKey: NSLocaleCountryCode value: countryCode];

    NSString *cityURLString = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"GeoNames City URL"];
    NSString *cityWithCountryURL = [NSString stringWithFormat:@"%@%@", cityURLString, countryCode];
    NSURL *cityURL = [NSURL URLWithString:cityWithCountryURL];
    NSMutableURLRequest *cityRequest = [[NSMutableURLRequest alloc] initWithURL:cityURL];
    NSHTTPURLResponse *cityResponse;
    NSError *cityError;
    NSData *cityResponseData = [NSURLConnection sendSynchronousRequest:cityRequest returningResponse:&cityResponse error:&cityError];      
    NSString *cityResponseString = [[NSString alloc] initWithData:cityResponseData encoding:NSASCIIStringEncoding];
    
    if (cityResponseString.length >0)
         //NSLog(@"%@", cityResponseString);
        [self ParseJSONString:cityResponseString action:kCitySearch];
    else
        NSLog(@"Failed to obtain GeoNames city names response data");  

    NSLog(@"Processing of City Name Search finished at the end of method: %s", __PRETTY_FUNCTION__);
}

- (void)yahooLocalSearch {
    
    NSString *searchCriteriaString = @"nail%20salon";
    NSString *appID = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"Yahoo US App ID"];
    NSString *localSearchURL = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"Yahoo Location Search URL"];
     NSString *urlString = [NSString stringWithFormat:@"%@%@&query=%@&results=20&output=json&latitude=37.780995&longitude=-122.395528", localSearchURL, appID, searchCriteriaString];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    NSHTTPURLResponse *response;
    
    NSError *error;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];      
    
    NSString *localSearchResponseString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];     
    
    if (localSearchResponseString.length >0)
        //NSLog(@"%@", responseString);
        [self ParseJSONString:localSearchResponseString action:kLocalSearch];
    else
        NSLog(@"Failed to obtain Yahoo Local Search response data");
    
    NSLog(@"Processing of Yahoo Local Search finished at the end of method: %s", __PRETTY_FUNCTION__);
}

@end
