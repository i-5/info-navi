//
//  UIApplication+URLUtil.m
//  InfoNavi
//
//  Created by Damon Lok on 10/10/11.
//  Copyright 2011 ios-dev.webs.com. All rights reserved.
//

#import "UIApplication+URLUtil.h"
#import "InfoNaviAppDelegate.h"

@implementation UIApplication (UIApplication_URLUtil)

- (BOOL)openURL:(NSURL *)url
{
    InfoNaviAppDelegate *appDelegate = (((InfoNaviAppDelegate*) [UIApplication sharedApplication].delegate)); 
    [appDelegate urlFlipAction:url flipActionOn:@"Flip To Homepage"];    
    
    return TRUE;
}

@end
