//
//  NSApplication+LoginItem.m
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/13/13.
//
//

#import "NSRunningApplication+LoginItem.h"

#import <CoreServices/CoreServices.h>

static const UInt32 RESOLVE_FLAGS = kLSSharedFileListNoUserInteraction
                                  | kLSSharedFileListDoNotMountVolumes;

@implementation NSRunningApplication (LoginItem)

- (BOOL)isLoginItem {
    LSSharedFileListRef loginItems = LSSharedFileListCreate(
        NULL, kLSSharedFileListSessionLoginItems, NULL);
    NSURL *myURL = self.bundleURL;
	BOOL found = NO;
    UInt32 seed = 0;
    NSArray *currentLoginItems = CFBridgingRelease(
        LSSharedFileListCopySnapshot(loginItems, &seed));
    for (id obj in currentLoginItems) {
        LSSharedFileListItemRef item = (__bridge LSSharedFileListItemRef)obj;
        CFURLRef itemURL = LSSharedFileListItemCopyResolvedURL(item, RESOLVE_FLAGS, NULL);
        
        if (itemURL) {
            found = ( CFEqual(itemURL, (__bridge CFURLRef)myURL) != 0);
            CFRelease(itemURL);
        }
        if (found)
            break;
    }
    CFRelease(loginItems);
	return found;
}

- (void)addToLoginItems {
    if (!self.isLoginItem) {
        NSURL *myURL = self.bundleURL;
        LSSharedFileListRef loginItems = LSSharedFileListCreate(
            NULL, kLSSharedFileListSessionLoginItems, NULL);
        LSSharedFileListInsertItemURL(
            loginItems, kLSSharedFileListItemBeforeFirst,
            NULL, NULL, (__bridge CFURLRef)myURL, NULL, NULL);
        CFRelease(loginItems);
    }
}

- (void)removeFromLoginItems {
    LSSharedFileListRef loginItems = LSSharedFileListCreate(
        NULL, kLSSharedFileListSessionLoginItems, NULL);
    NSURL *myURL = self.bundleURL;
    UInt32 seed = 0;
    NSArray *currentLoginItems = CFBridgingRelease(
        LSSharedFileListCopySnapshot(loginItems, &seed));
    for (id obj in currentLoginItems) {
        LSSharedFileListItemRef item = (__bridge LSSharedFileListItemRef)obj;
        CFURLRef itemURL = LSSharedFileListItemCopyResolvedURL(item, RESOLVE_FLAGS, NULL);
        if (itemURL) {
            if (CFEqual(itemURL, (__bridge CFURLRef)myURL))
                LSSharedFileListItemRemove(loginItems, item);
            CFRelease(itemURL);
        }
    }
    CFRelease(loginItems);
}

// old version of code to figure out whether we were launched by hand

//- (BOOL)wasLaunchedAsLoginItemOrResume {
//    ProcessSerialNumber psn = { 0, kCurrentProcess };
//    NSDictionary *processInfo = CFBridgingRelease(
//        ProcessInformationCopyDictionary(
//            &psn, (UInt32)kProcessDictionaryIncludeAllInformationMask));
//    long long parent = [processInfo[@"ParentPSN"] longLongValue];
//    ProcessSerialNumber parentPsn = {
//        (parent >> 32) & 0x00000000FFFFFFFFLL,
//        parent & 0x00000000FFFFFFFFLL
//    };
//
//    NSDictionary *parentInfo = CFBridgingRelease(
//        ProcessInformationCopyDictionary(
//            &parentPsn, (UInt32)kProcessDictionaryIncludeAllInformationMask));
//    return [parentInfo[@"FileCreator"] isEqualToString:@"lgnw"];
//}


@end
