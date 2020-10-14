//
//  NSString+HTMLUtil.h
//  InfoNavi
//
//  Created by Damon Lok on 9/27/11.
//  Copyright 2011 ios-dev.webs.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Category)
-(NSString *)stringByStrippingHTML;
-(NSString *)fixHomepageURL;
-(NSString *)fixURLInComment;
@end
