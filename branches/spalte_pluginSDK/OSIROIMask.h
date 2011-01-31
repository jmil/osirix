//
//  OSIROIMask.h
//  OsiriX
//
//  Created by Joël Spaltenstein on 1/25/11.
//  Copyright 2011 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>

struct OSIMaskRun {
	NSRange widthRange;
    NSUInteger heightIndex;
    NSUInteger depthIndex;
};
typedef struct OSIMaskRun OSIMaskRun;

struct OSIMaskIndex {
	NSUInteger x;
	NSUInteger y;
	NSUInteger z;
}
typedef struct OSIMaskIndex OSIMaskIndex;

// masks are stored in Width direction run lengths

@interface OSIROIMask : NSObject {

}

- (id)initWithMaskRuns:(NSArray *)maskRuns;

- (NSArray *)maskRuns;
- (NSArray *)maskIndexes;

- (BOOL)indexInMask:(OSIMaskIndex);

@end


@interface NSValue (OSIMaskRun)
+ (NSValue)valueWithOSIMaskRun:(OSIMaskRun)volumeRun;
- (OSIMaskRun)OSIMaskRunValue;
+ (NSValue)valueWithOSIMaskIndex:(OSIMaskIndex)maskIndex;
- (OSIMaskIndex)OSIMaskIndexValue;
@end


