//
//  NJOutputKeyPress.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

#import "NJOutputKeyPress.h"

#import "NJKeyInputField.h"

@implementation NJOutputKeyPress

+ (NSString *)serializationCode {
    return @"key press";
}

- (NSDictionary *)serialize {
    return _keyCode != NJKeyInputFieldEmpty && _modifierKeyCode != NJKeyInputFieldEmpty
        ? @{@"type": self.class.serializationCode, @"key": @(_keyCode), @"modifier": @(_modifierKeyCode)}
        : _keyCode != NJKeyInputFieldEmpty
            ? @{@"type": self.class.serializationCode, @"key": @(_keyCode)}
            : nil;
}

+ (NJOutput *)outputWithSerialization:(NSDictionary *)serialization {
	NSLog(@"keypress outputw");
    NJOutputKeyPress *output = [[NJOutputKeyPress alloc] init];
    output.keyCode = [serialization[@"key"] unsignedShortValue];
    output.modifierKeyCode = [serialization[@"modifier"] unsignedShortValue];
    return output;
}

- (void)trigger {
	NSLog(@"trig");
    if (_keyCode != NJKeyInputFieldEmpty) {
		NSLog(@"not empty");
        CGEventRef keyDown = CGEventCreateKeyboardEvent(NULL, _keyCode, YES);
        CGEventFlags modifierFlag = [self getModifierFlag];
        if (modifierFlag != 0) {CGEventSetFlags(keyDown, modifierFlag);}
        CGEventPost(kCGHIDEventTap, keyDown);
		NSLog(@"event keydown sent");
        CFRelease(keyDown);
    }
}

- (void)untrigger {
	NSLog(@"untrig");
    if (_keyCode != NJKeyInputFieldEmpty) {
        CGEventRef keyUp = CGEventCreateKeyboardEvent(NULL, _keyCode, NO);
        CGEventFlags modifierFlag = [self getModifierFlag];
        if (modifierFlag != 0) {CGEventSetFlags(keyUp, modifierFlag);}
        CGEventPost(kCGHIDEventTap, keyUp);
        CFRelease(keyUp);
    }
}

- (CGEventFlags)getModifierFlag {
  if (_modifierKeyCode != NJKeyInputFieldEmpty) {
    switch (_modifierKeyCode) {
      case 55: return kCGEventFlagMaskCommand;
      case 56: return kCGEventFlagMaskShift;
      case 58: return kCGEventFlagMaskAlternate;
      case 59: return kCGEventFlagMaskControl;
      case 60: return kCGEventFlagMaskShift;
      case 61: return kCGEventFlagMaskAlternate;
      case 62: return kCGEventFlagMaskControl;
      case 63: return kCGEventFlagMaskSecondaryFn;
    }
  }
  
  return 0;
}
@end
