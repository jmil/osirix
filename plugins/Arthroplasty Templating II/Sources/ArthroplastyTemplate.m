//
//  ArthroplastyTemplate.m
//  Arthroplasty Templating II
//  Created by Joris Heuberger on 04/04/07.
//  Copyright (c) 2007-2009 OsiriX Foundation. All rights reserved.
//

#import "ArthroplastyTemplate.h"


@implementation ArthroplastyTemplate
@synthesize directoryName = _directoryName, name = _name, family = _family;
@synthesize referenceFilePath = _referenceFilePath, size = _size, properties = _properties, image = _image, textualData = _textualData;

-(id)initFromFileAtPath:(NSString*)path {
	[self init];
	_referenceFilePath = [path retain];
	return self;
}

-(void)dealloc {
	if (_directoryName) [_directoryName release]; _directoryName = NULL;
	if (_properties) [_properties release]; _properties = NULL;
	if (_image) [_image release]; _image = NULL;
	if (_name) [_name release]; _name = NULL;
	if (_textualData) [_textualData release]; _textualData = NULL;
	if (_referenceFilePath) [_referenceFilePath release]; _referenceFilePath = NULL;
	[super dealloc];
}

-(NSString*)manufacturerName {
	NSLog(@"Warning: [ArthroplastyTemplate manufacturerName] must be overridden");
	return @"Unknown";
}

-(NSString*)size {
	NSLog(@"Warning: [ArthroplastyTemplate size] must be overridden");
	return @"";
}

-(NSString*)pdfPathForDirection:(ArthroplastyTemplateViewDirection)direction {
	NSLog(@"Warning: [ArthroplastyTemplate pdfPathForDirection:] must be overridden");
	return @"";
}

-(id)valueForKey:(NSString*)key {
	return [_properties valueForKey:key];
}


@end
