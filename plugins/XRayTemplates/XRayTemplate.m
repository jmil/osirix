//
//  XRayTemplate.m
//  XRayTemplatesPlugin
//
//  Created by joris on 19/03/07.
//  Copyright 2007 OsiriX Team. All rights reserved.
//

#import "XRayTemplate.h"


@implementation XRayTemplate

- (id)initFromFileAtPath:(NSString*)path
{
	[self init];
	properties = nil;
	PDFPreviewPath = nil;
	image = nil;
	name = nil;
	textualData = nil;
	
	referenceFilePath = [path retain];
	
	return self;
}

- (void)dealloc
{
	if(directoryName) [directoryName release];
	if(properties) [properties release];
	if(PDFPreviewPath) [PDFPreviewPath release];
	if(image) [image release];
	if(name) [name release];
	if(textualData) [textualData release];

	if(referenceFilePath)[referenceFilePath release];

	[super dealloc];
}

- (NSString*)directoryName;
{
	return directoryName;
}

- (void)setViewDirection:(XRayTemplateViewDirection)direction;
{
	viewDirection = direction;
}

- (XRayTemplateManufacturer)manufacturer;
{
	return UnknownManufacturer;
}

- (NSString*)manufacturerName;
{
	return @"";
}

- (NSMutableDictionary*)properties;
{
	return properties;
}

- (NSString*)PDFPreviewPath;
{
	return PDFPreviewPath;
}

- (NSImage*)image;
{
	return image;
}

- (NSString*)name;
{
	return name;
}

- (NSArray*)textualData;
{
	return textualData;
}

- (NSString*)referenceFilePath;
{
	return referenceFilePath;
}

- (NSString*)size;
{
	return @"";
}

- (float)sizeValue;
{
	return 0.0;
}

- (NSString*)reference;
{
	return @"";
}

@end
