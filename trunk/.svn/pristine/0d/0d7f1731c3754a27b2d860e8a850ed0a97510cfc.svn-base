//
//  NSString+HTMLUtil.m
//  InfoNavi
//
//  Created by Damon Lok on 9/27/11.
//  Copyright 2011 ios-dev.webs.com. All rights reserved.
//

#import "NSString+HTMLUtil.h"

@implementation NSString (Category)

-(NSString *) stringByStrippingHTML 
{
    NSRange r;
    NSString *s = [[self copy] autorelease];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s; 
}

-(NSString *) fixURLInComment
{
    NSRange r1;
    NSRange r2;
    NSString *h = @"http://";
    BOOL found = FALSE;
    NSString *s = [[self copy] autorelease];
    NSMutableString *n = [NSMutableString stringWithString:s];
    NSString *p1 = @"[A-Za-z0-9-]+\\.[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *p2 = @"[A-Za-z0-9-]+\\.[A-Za-z]{2,4}";  
    
    if ((r1 = [s rangeOfString:p2 options:NSRegularExpressionSearch]).length > 0) {
        if ((r2 = [s rangeOfString:h]).length == 0) {
            [n insertString:h atIndex:r1.location];    
            found = TRUE;
        }
    }
        
    if (!found) {
        if ((r1 = [s rangeOfString:p1 options:NSRegularExpressionSearch]).length > 0) {
            if ((r2 = [s rangeOfString:h]).length == 0) {
                [n insertString:h atIndex:r1.location];    
            }  
        }
    }
        
    NSString *result = [NSString stringWithString:n];
    return result;
}

-(NSString *) fixHomepageURL
{
    NSRange r;
    NSString *stringPatternToChop;
    NSString *s = [[self copy] autorelease];
    NSArray *stringToChop = [NSArray arrayWithObjects:
                                @"atom.xml",
                                @"index.xml",
                                @"?feed=rss2",
                                @"ror.xml",
                                @"rss.xml",
                                @"feed/",
                                @"rss",    
                                @"rss/ellie",    
                                @"feed",
                                @"rssfeed.php",
                                @"dailyhealth.xml",
                                @"new/",
                                @"ops?action=rss_rc",
                                nil]; 
    
    NSEnumerator *e = [stringToChop objectEnumerator];    
    while (stringPatternToChop = [e nextObject]) {
        if ((r = [s rangeOfString:stringPatternToChop]).length > 0) {
            s = [s stringByReplacingOccurrencesOfString:stringPatternToChop withString:@""];    
            break;
        }
    }
    
    return s;
}

@end
