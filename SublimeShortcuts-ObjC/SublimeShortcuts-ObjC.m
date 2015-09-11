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
    [self createInsertLineMenu:menuItem];
  }
}

- (void)createInsertLineMenu:(NSMenuItem *)menuItem {
  NSMenuItem *insertLineMenuItem = [[NSMenuItem alloc] initWithTitle:@"Insert Line" action:nil keyEquivalent:@""];
  NSMenu *insertLineSubmenu = [[NSMenu alloc] initWithTitle:@"Insert Line"];
  insertLineMenuItem.submenu = insertLineSubmenu;
  [self createMenuItemsInMenu:insertLineSubmenu];
  [menuItem.submenu addItem:insertLineMenuItem];
}

- (void)createMenuItemsInMenu:(NSMenu *)menu {
  [menu addItem:[NSMenuItem separatorItem]];
  unichar enterChar = NSNewlineCharacter;
  NSString *enterKey = [NSString stringWithCharacters:&enterChar length:1];
  // Insert Line Before
  NSMenuItem *insertLineBeforeActionItem = [[NSMenuItem alloc] initWithTitle:@"Insert Line Before" action:@selector(insertLineBefore) keyEquivalent:enterKey];
  [insertLineBeforeActionItem setKeyEquivalentModifierMask:(NSAlphaShiftKeyMask | NSCommandKeyMask)];
  [insertLineBeforeActionItem setTarget:self];
  [menu addItem:insertLineBeforeActionItem];
  // Insert Line Before (In Place)
  NSMenuItem *insertLineBeforeActionItemInPlace = [[NSMenuItem alloc] initWithTitle:@"Insert Line Before (In Place)" action:@selector(insertLineBeforeInPlace) keyEquivalent:@""];
  [insertLineBeforeActionItemInPlace setTarget:self];
  [menu addItem:insertLineBeforeActionItemInPlace];
  // Insert Line After
  NSMenuItem *insertLineAfterActionItem = [[NSMenuItem alloc] initWithTitle:@"Insert Line After" action:@selector(insertLineAfter) keyEquivalent:enterKey];
  [insertLineAfterActionItem setKeyEquivalentModifierMask:NSCommandKeyMask];
  [insertLineAfterActionItem setTarget:self];
  [menu addItem:insertLineAfterActionItem];
  // Insert Line After (In Place)
  NSMenuItem *insertLineAfterActionItemInPlace = [[NSMenuItem alloc] initWithTitle:@"Insert Line After (In Place)" action:@selector(insertLineAfterInPlace) keyEquivalent:@""];
  [insertLineAfterActionItemInPlace setTarget:self];
  [menu addItem:insertLineAfterActionItemInPlace];
  // Mark Line
  NSMenuItem *markLine = [[NSMenuItem alloc] initWithTitle:@"Mark Line" action:@selector(markLine) keyEquivalent:@"k"];
  [markLine setKeyEquivalentModifierMask:(NSCommandKeyMask | NSAlternateKeyMask)];
  [markLine setTarget:self];
  [menu addItem:markLine];
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
  NSUInteger begginingPoint = linesRange.location;
  // Find out how many spaces for indentation of the first line
  NSUInteger numberOfSpaces = [self numberOfSpacesInString:sourceTextView.string fromIndex:linesRange.location];
  [self insertSpaces:numberOfSpaces inTextView:sourceTextView atPoint:begginingPoint inPlace:inPlace];
}

- (void)insertLineAfter {
  [self insertLineAfter:NO];
}

- (void)insertLineAfterInPlace {
  [self insertLineAfter:YES];
}

- (void)insertLineAfter:(BOOL)inPlace {
  NSRange linesRange = [self getLinesRange:true];
  if (linesRange.location == NSNotFound) {
    return;
  }
  DVTSourceTextView *sourceTextView = [DTXcodeUtils currentSourceTextView];
  // Insert at the beginning of the line
  NSUInteger endPoint = linesRange.location + linesRange.length;
  // Find out how many spaces for indentation of the first line
  NSUInteger numberOfSpaces = [self numberOfSpacesInString:sourceTextView.string fromIndex:linesRange.location];
  [self insertSpaces:numberOfSpaces inTextView:sourceTextView atPoint:endPoint inPlace:inPlace];
}

- (void)insertSpaces:(NSUInteger)numberOfSpaces inTextView:(NSTextView *)textView atPoint:(NSUInteger)point inPlace:(BOOL)inPlace {
  // Insert text with a new line plus spaces multiplied by the # of indentation spaces
  NSString *indentationSpaces = [self stringByRepeatingSpacesBy:numberOfSpaces];
  NSString *insertText = [indentationSpaces stringByAppendingString:@"\n"];
  NSRange insertPointRange = NSMakeRange(point, 0);
  [textView insertText:insertText replacementRange:insertPointRange];

  // Select previous line (if not in place)
  if (!inPlace) {
    [textView setSelectedRange:NSMakeRange(point + numberOfSpaces, 0)];
  }
}

- (NSUInteger)numberOfSpacesInString:(NSString *)string fromIndex:(NSUInteger)index {
  NSRange spaceRange = [string rangeOfString:@" *" options:NSRegularExpressionSearch range:NSMakeRange(index, string.length - index)];
  NSUInteger numberOfSpaces = spaceRange.length;
  return numberOfSpaces;
}

- (NSRange)getLinesRange {
  return [self getLinesRange:false];
}

- (NSRange)getLinesRange:(BOOL)atEnd {
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
  // There's a bit of usability bug when at the end and the range is a selection (length > 0)
  // selecting the end will go to the next line instead of right at that line
  // this just accounts for that by checking if the last selected character is a new line
  if (atEnd && selectedRange.length > 0) {
    // Only search the last character
    NSRange newLineRange = [sourceTextView.string rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch range:NSMakeRange(selectedRange.location + selectedRange.length - 1, 1)];
    // If not found, then choose the end
    if (newLineRange.location == NSNotFound) {
      selectedRange = NSMakeRange(selectedRange.location + selectedRange.length, 0);
    }
    // Otherwise, choose the one right before
    else {
      selectedRange = NSMakeRange(selectedRange.location + selectedRange.length - 1, 0);
    }
  }
  // same with line range of course
  NSRange linesRange = [sourceTextView.string lineRangeForRange:selectedRange];
  return linesRange;
}

- (void)markLine {
  NSRange linesRange = [self getLinesRange];
  if (linesRange.location == NSNotFound) {
    return;
  }
  DVTSourceTextView *sourceTextView = [DTXcodeUtils currentSourceTextView];
  [sourceTextView insertText:@"|>" replacementRange:NSMakeRange(linesRange.location, 0)];
  [sourceTextView insertText:@"<|" replacementRange:NSMakeRange(linesRange.location + linesRange.length, 0)];
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
