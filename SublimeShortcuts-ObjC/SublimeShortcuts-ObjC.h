//
//  SublimeShortcuts-ObjC.h
//  SublimeShortcuts-ObjC
//
//  Created by Geoff on 07-18-2015.
//  Copyright © 2015 matrinox. All rights reserved.
//

#import <AppKit/AppKit.h>

@class SublimeShortcutsObjC;

static SublimeShortcutsObjC *sharedPlugin;

@interface SublimeShortcutsObjC : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end