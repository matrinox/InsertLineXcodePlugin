//
//  SublimeShortcuts-ObjC.m
//  SublimeShortcuts-ObjC
//
//  Created by Geoff on 07-18-2015.
//  Copyright © 2015 matrinox. All rights reserved.
//

#import "SublimeShortcuts-ObjC.h"
#import "DTXcodeHeaders.h"
#import "DTXcodeUtils.h"

@interface SublimeShortcutsObjC()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation SublimeShortcutsObjC

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
  //removeObserver
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:NSApplicationDidFinishLaunchingNotification
                                                object:nil];
  
  // Create menu items, initialize UI, etc.
  // Sample Menu Item:
  NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
  if (menuItem != nil) {
    [self createMenuItems:menuItem];
  }
}

- (void)createMenuItems:(NSMenuItem *)menuItem {
  [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
  unichar enterChar = NSNewlineCharacter;
  NSString *enterKey = [NSString stringWithCharacters:&enterChar length:1];
  // Insert Line Before
  NSMenuItem *insertLineBeforeActionItem = [[NSMenuItem alloc] initWithTitle:@"Insert Line Before" action:@selector(insertLineBefore) keyEquivalent:enterKey];
  [insertLineBeforeActionItem setKeyEquivalentModifierMask:(NSAlphaShiftKeyMask | NSCommandKeyMask)];
  [insertLineBeforeActionItem setTarget:self];
  [[menuItem submenu] addItem:insertLineBeforeActionItem];
  // Insert Line Before (In Place)
  NSMenuItem *insertLineBeforeActionItemInPlace = [[NSMenuItem alloc] initWithTitle:@"Insert Line Before (In Place)" action:@selector(insertLineBeforeInPlace) keyEquivalent:@""];
  [insertLineBeforeActionItemInPlace setTarget:self];
  [[menuItem submenu] addItem:insertLineBeforeActionItemInPlace];
  // Insert Line After
  NSMenuItem *insertLineAfterActionItem = [[NSMenuItem alloc] initWithTitle:@"Insert Line After" action:@selector(insertLineAfter) keyEquivalent:enterKey];
  [insertLineAfterActionItem setKeyEquivalentModifierMask:NSCommandKeyMask];
  [insertLineAfterActionItem setTarget:self];
  [[menuItem submenu] addItem:insertLineAfterActionItem];
  // Insert Line After (In Place)
  NSMenuItem *insertLineAfterActionItemInPlace = [[NSMenuItem alloc] initWithTitle:@"Insert Line After (In Place)" action:@selector(insertLineAfterInPlace) keyEquivalent:@""];
  [insertLineAfterActionItemInPlace setTarget:self];
  [[menuItem submenu] addItem:insertLineAfterActionItemInPlace];
}

- (void)insertLineBefore {
  [self insertLineBefore:NO];
}

- (void)insertLineBeforeInPlace {
  [self insertLineBefore:YES];
}

- (void)insertLineBefore:(BOOL)inPlace {
  NSRange linesRange = [self getLinesRange];
  if (linesRange.location == NSNotFound) {
    return;
  }
  DVTSourceTextView *sourceTextView = [DTXcodeUtils currentSourceTextView];
  // Insert at the beginning of the line
  NSRange begginingLineRange = NSMakeRange(linesRange.location, 0);
  // Find out how many spaces for indentation of the first line
  NSString *startingString = [sourceTextView.string substringFromIndex:linesRange.location];
  NSUInteger numberOfSpaces = [startingString rangeOfCharacterFromSet:[NSCharacterSet alphanumericCharacterSet]].location;

  // Insert text with a new line plus spaces multiplied by the # of indentation spaces
  NSString *indentationSpaces = [self stringByRepeatingSpacesBy:numberOfSpaces];
  NSString *insertText = [@"\n" stringByAppendingString:indentationSpaces];
  NSRange insertPointRange = NSMakeRange(begginingLineRange.location + numberOfSpaces, 0);
  [sourceTextView insertText:insertText replacementRange:insertPointRange];

  // Select previous line (if not in place)
  if (!inPlace) {
    NSRange newSelectionRange = insertPointRange;
    [sourceTextView setSelectedRange:newSelectionRange];
  }
}

- (void)insertLineAfter {
  [self insertLineAfter:NO];
}

- (void)insertLineAfterInPlace {
  [self insertLineAfter:YES];
}

- (void)insertLineAfter:(BOOL)inPlace {
  NSRange linesRange = [self getLinesRange];
  if (linesRange.location == NSNotFound) {
    return;
  }
  DVTSourceTextView *sourceTextView = [DTXcodeUtils currentSourceTextView];
  // Insert at the beginning of the line
  NSRange endLineRange = NSMakeRange(linesRange.location + linesRange.length, 0);
  // Find out how many spaces for indentation of the first line
  NSString *startingString = [sourceTextView.string substringFromIndex:linesRange.location];
  NSUInteger numberOfSpaces = [startingString rangeOfCharacterFromSet:[NSCharacterSet alphanumericCharacterSet]].location;

  // Insert text with a new line plus spaces multiplied by the # of indentation spaces
  NSString *indentationSpaces = [self stringByRepeatingSpacesBy:numberOfSpaces];
  NSString *insertText = [indentationSpaces stringByAppendingString:@"\n"];
  NSRange insertPointRange = NSMakeRange(endLineRange.location, 0);
  [sourceTextView insertText:insertText replacementRange:insertPointRange];

  // Select previous line (if not in place)
  if (!inPlace) {
    NSRange newSelectionRange = NSMakeRange(insertPointRange.location + numberOfSpaces, 0);
    [sourceTextView setSelectedRange:newSelectionRange];
  }
}

- (NSRange)getLinesRange {
  DVTSourceTextView *sourceTextView = [DTXcodeUtils currentSourceTextView];
  // Get the range of the selected text within the source code editor.
  // Get the selected text using the range from above.
  NSTextStorage *textStorage = sourceTextView.textStorage;
  if (textStorage == nil) {
    return NSMakeRange(NSNotFound, 0);
  }
  NSRange selectedRange = sourceTextView.selectedRange;
  if (selectedRange.location == NSNotFound) {
    return NSMakeRange(NSNotFound, 0);
  }
  // same with line range of course
  NSRange linesRange = [sourceTextView.string lineRangeForRange:selectedRange];
  return linesRange;
}

- (NSString *)stringByRepeatingSpacesBy:(NSUInteger)number {
  NSMutableString *string = [NSMutableString new];
  for (NSUInteger i = 0; i < number; i++) {
    [string appendString:@" "];
  }
  return string;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
