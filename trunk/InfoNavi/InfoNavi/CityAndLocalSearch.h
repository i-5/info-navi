//
//  CityAndLocalSearch.h
//  InfoNavi
//
//  Created by Damon Lok on 8/1/12.
//  Copyright (c) 2012 ios-dev.webs.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSON.h"

#define kCitySearch @"citySearch"
#define kLocalSearch @"localSearch"

@interface CityAndLocalSearch : NSObject {
    NSMutableArray *citiesArray;
    NSMutableArray *salonArray;
    NSMutableDictionary *salonDetails;
}

- (void)cityNameSearch;
- (void)yahooLocalSearch;
- (void)ParseJSONString:(NSString *)JSONString action:(NSString *)actionString;
@end
