//
//  ArthroplastyTemplateFamily.h
//  Arthroplasty Templating II
//  Created by Alessandro Volz on 6/4/09.
//  Copyright (c) 2007-2009 OsiriX Foundation. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ArthroplastyTemplate.h";


@interface ArthroplastyTemplateFamily : NSObject {
	NSMutableArray* _templates;
}

@property(readonly) NSArray* templates;

-(id)initWithTemplate:(ArthroplastyTemplate*)templat;
-(BOOL)matches:(ArthroplastyTemplate*)templat;
-(void)add:(ArthroplastyTemplate*)templat;
-(ArthroplastyTemplate*)template:(NSInteger)index;

@end
