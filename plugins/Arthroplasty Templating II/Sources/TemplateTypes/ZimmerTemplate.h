//
//  ZimmerTemplate.h
//  Arthroplasty Templating II
//  Created by Joris Heuberger on 19/03/07.
//  Copyright (c) 2007-2009 OsiriX Foundation. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ArthroplastyTemplate.h"

@interface ZimmerTemplate : ArthroplastyTemplate {
	NSString* _anteriorPosteriorPDFFileName;
	NSString* _lateralPDFFileName;
}

+(NSArray*)bundledTemplates;
-(id)initFromFileAtPath:(NSString*)path;

@end
