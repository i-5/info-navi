//
//  UIButton+Property.m
//  InfoNavi
//
//  Created by Damon Lok on 9/28/11.
//  Copyright 2011 ios-dev.webs.com. All rights reserved.
//

#import "UIButton+Property.h"

@implementation UIButton (UIButton_Property)

static char UIB_PROPERTY_KEY;

@dynamic property;

-(void)setProperty:(NSObject *)property
{
    objc_setAssociatedObject(self, &UIB_PROPERTY_KEY, property, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSObject*)property
{
    return (NSObject*)objc_getAssociatedObject(self, &UIB_PROPERTY_KEY);
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, 62.0/255.0, 62.0/255.0, 62.0/255.0, 1.0);
    
    // Draw them with a 1.0 stroke width.
    CGContextSetLineWidth(context, 1.0);
    
    // Draw a single line from left to right
    CGContextMoveToPoint(context, 0, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
    CGContextStrokePath(context);
}

@end
