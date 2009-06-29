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
	if (![[template manufacturer] isEqualToString:[self manufacturer]]) return NO;
	if (![[template name] isEqualToString:[self name]]) return NO;
	return YES;
}

-(void)add:(ArthroplastyTemplate*)template {
	[_templates addObject:template];
	[template setFamily:self];
}

-(ArthroplastyTemplate*)template:(NSInteger)index {
	return [_templates objectAtIndex:index];
}

-(NSString*)fixation {
	return [[self template:0] fixation];
}

-(NSString*)group {
	return [[self template:0] group];
}

-(NSString*)manufacturer {
	return [[self template:0] manufacturer];
}

-(NSString*)modularity {
	return [[self template:0] modularity];
}

-(NSString*)name {
	return [[self template:0] name];
}

-(NSString*)placement {
	return [[self template:0] placement];
}

-(NSString*)surgery {
	return [[self template:0] surgery];
}

-(NSString*)type {
	return [[self template:0] type];
}

@end
