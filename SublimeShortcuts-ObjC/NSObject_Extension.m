//
//  NSObject_Extension.m
//  SublimeShortcuts-ObjC
//
//  Created by Geoff on 07-18-2015.
//  Copyright © 2015 matrinox. All rights reserved.
//


#import "NSObject_Extension.h"
#import "SublimeShortcuts-ObjC.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[SublimeShortcutsObjC alloc] initWithBundle:plugin];
        });
    }
}
@end
