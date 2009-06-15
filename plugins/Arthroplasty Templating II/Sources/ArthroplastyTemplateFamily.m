//
//  ArthroplastyTemplateFamily.m
//  Arthroplasty Templating II
//  Created by Alessandro Volz on 6/4/09.
//  Copyright (c) 2007-2009 OsiriX Foundation. All rights reserved.
//

#import "ArthroplastyTemplateFamily.h"
#import "ArthroplastyTemplate.h"


@implementation ArthroplastyTemplateFamily
@synthesize templates = _templates;

-(id)initWithTemplate:(ArthroplastyTemplate*)template {
	self = [super init];
	_templates = [[NSMutableArray arrayWithCapacity:8] retain];
	[self add:template];
	return self;
}

-(void)dealloc {
	[_templates release]; _templates = NULL;
	[super dealloc];
}

-(BOOL)matches:(ArthroplastyTemplate*)template {
	if (![[template valueForKey:@"IMPLANT_MANUFACTURER"] isEqualToString:[self valueForKey:@"IMPLANT_MANUFACTURER"]]) return NO;
	if (![[template valueForKey:@"PRODUCT_FAMILY_NAME"] isEqualToString:[self valueForKey:@"PRODUCT_FAMILY_NAME"]]) return NO;
	return YES;
}

-(void)add:(ArthroplastyTemplate*)template {
	[_templates addObject:template];
	[template setFamily:self];
}

-(id)valueForKey:(NSString*)key {
	return [[_templates objectAtIndex:0] valueForKey:key];
}

-(ArthroplastyTemplate*)template:(NSInteger)index {
	return [_templates objectAtIndex:index];
}

@end
