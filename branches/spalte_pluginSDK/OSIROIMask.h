//
//  OSIROIMask.h
//  OsiriX
//
//  Created by Joël Spaltenstein on 1/25/11.
//  Copyright 2011 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>

struct OSIROIMaskRun {
	NSRange widthRange;
    NSUInteger heightIndex;
    NSUInteger depthIndex;
};
typedef struct OSIROIMaskRun OSIROIMaskRun;

struct OSIROIMaskIndex {
	NSUInteger x;
	NSUInteger y;
	NSUInteger z;
};
typedef struct OSIROIMaskIndex OSIROIMaskIndex;

CF_EXTERN_C_BEGIN

BOOL OSIROIMaskIndexInRun(OSIROIMaskIndex maskIndex, OSIROIMaskRun maskRun);
NSArray *OSIROIMaskIndexesInRun(OSIROIMaskRun maskRun); // should this be a function, or a static method on OSIROIMask?

CF_EXTERN_C_END

// masks are stored in Width direction run lengths

@interface OSIROIMask : NSObject {
	NSArray *_maskRuns;
}

// create the thing, maybe we should really be working with C arrays.... or at least give the option
- (id)initWithMaskRuns:(NSArray *)maskRuns;

// returns the mask as a set of runs
- (NSArray *)maskRuns;

// returns the mask as a set of indexes
- (NSArray *)maskIndexes;

// returns whether or not the index is in the mask
- (BOOL)indexInMask:(OSIROIMaskIndex)index;

@end


@interface NSValue (OSIROIMaskRun)
+ (NSValue *)valueWithOSIROIMaskRun:(OSIROIMaskRun)volumeRun;
- (OSIROIMaskRun)OSIROIMaskRunValue;
+ (NSValue *)valueWithOSIROIMaskIndex:(OSIROIMaskIndex)maskIndex;
- (OSIROIMaskIndex)OSIROIMaskIndexValue;
@end


