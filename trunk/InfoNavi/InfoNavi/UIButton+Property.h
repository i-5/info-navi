//
//  UIButton+Property.h
//  InfoNavi
//
//  Created by Damon Lok on 9/28/11.
//  Copyright 2011 ios-dev.webs.com. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    OBJC_ASSOCIATION_ASSIGN = 0,
    OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1,
    OBJC_ASSOCIATION_COPY_NONATOMIC = 3,
    OBJC_ASSOCIATION_RETAIN = 01401,
    OBJC_ASSOCIATION_COPY = 01403
};
typedef uintptr_t objc_AssociationPolicy;

void objc_setAssociatedObject(id object, void *key, id value, objc_AssociationPolicy policy);
id objc_getAssociatedObject(id object, void *key);
void objc_removeAssociatedObjects(id object);

@interface UIButton (UIButton_Property)
@property (nonatomic, retain) NSObject *property;
- (void)drawRect:(CGRect)rect;
@end
