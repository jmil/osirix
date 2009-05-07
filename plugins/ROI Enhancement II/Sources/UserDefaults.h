//
//  UserDefaults.h
//  ROI Enhancement II
//
//  Created by Alessandro Volz on 5/6/09.
//  Copyright 2009 HUG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface UserDefaults : NSObject {
	NSMutableDictionary* _dictionary;
}

-(id)init;
-(void)save;
-(BOOL)bool:(NSString*)key otherwise:(BOOL)otherwise;
-(void)setBool:(BOOL)value forKey:(NSString*)key;
-(int)int:(NSString*)key otherwise:(int)otherwise;
-(void)setInt:(int)value forKey:(NSString*)key;
-(float)float:(NSString*)key otherwise:(float)otherwise;
-(void)setFloat:(float)value forKey:(NSString*)key;
-(NSColor*)color:(NSString*)key otherwise:(NSColor*)otherwise;
-(void)setColor:(NSColor*)value forKey:(NSString*)key;

@end
