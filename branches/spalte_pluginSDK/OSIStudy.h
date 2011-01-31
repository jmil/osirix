//
//  OSIStudy.h
//  OsiriX
//
//  Created by Joël Spaltenstein on 1/25/11.
//  Copyright 2011 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// implementation detail, this represents a series.study.studyInstanceUID

@interface OSIStudy : NSObject {

}

- (NSString *)studyInstanceUID;
- (NSArray *)volumeWindows; // volume windows in which are currently displaying images belonging to this study

@end
