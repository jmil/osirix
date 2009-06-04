//
//  ZimmerTemplate.m
//  Arthroplasty Templating II
//  Created by Joris Heuberger on 19/03/07.
//  Copyright (c) 2007-2009 OsiriX Foundation. All rights reserved.
//

#import "ZimmerTemplate.h"
#import "NSString+Trim.h"

@implementation ZimmerTemplate

+(NSArray*)templatesAtPath:(NSString*)path {
	NSMutableArray* templates = [NSMutableArray array];
	
	BOOL isDirectory, exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
	if (exists)
		if (isDirectory) {
			NSDirectoryEnumerator* e = [[NSFileManager defaultManager] enumeratorAtPath:path];
			NSString* sub; while (sub = [e nextObject])
				[templates addObjectsFromArray:[ZimmerTemplate templatesAtPath:[path stringByAppendingPathComponent:sub]]];
		} else
			if ([[path pathExtension] isEqualToString:@"txt"] && [[path stringByDeletingPathExtension] hasSuffix:@"_info"])
				[templates addObject:[[[ZimmerTemplate alloc] initFromFileAtPath:path] autorelease]];
	
	return templates;
}

+(NSArray*)bundledTemplates {
	return [ZimmerTemplate templatesAtPath:[[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"Contents/Resources/ZimmerTemplates"]];
}

+(NSMutableDictionary*)propertiesFromInfoFileAtPath:(NSString*)path {
	NSError* error;
	NSString* fileContent = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
	if (!fileContent) {
		fileContent = [NSString stringWithContentsOfFile:path encoding:NSISOLatin1StringEncoding error:&error];
		if(!fileContent) {
			NSLog(@"[ZimmerTemplate propertiesFromFileInfoAtPath]: %@", error);
			return NULL;
		}
	}
	
	NSScanner* infoFileScanner = [NSScanner scannerWithString:fileContent];
	[infoFileScanner setCharactersToBeSkipped:[NSCharacterSet whitespaceCharacterSet]];
	
	NSMutableDictionary* properties = [NSMutableDictionary dictionaryWithCapacity:0];
	while (![infoFileScanner isAtEnd]) {
		NSString *key, *value;
		[infoFileScanner scanUpToString:@":=:" intoString:&key];
		[infoFileScanner scanString:@":=:" intoString:NULL];
		[infoFileScanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&value];
		[properties setObject:[value stringByTrimmingStartAndEnd] forKey:[key stringByTrimmingStartAndEnd]];
	}
	
	return properties;
}

-(id)initFromFileAtPath:(NSString*)path {
	[super initFromFileAtPath:path];
	
	// properties
	_properties = [[ZimmerTemplate propertiesFromInfoFileAtPath:path] retain];
	if(!_properties)
		return NULL; // TODO: is self released?

	_directoryName = [[path stringByDeletingLastPathComponent] retain];
	_anteriorPosteriorPDFFileName = [[_properties objectForKey:@"PDF_FILE_AP"] retain];
	_lateralPDFFileName = [[_properties objectForKey:@"PDF_FILE_ML"] retain];
	
	return self;
}

-(void)dealloc {
	if (_anteriorPosteriorPDFFileName) [_anteriorPosteriorPDFFileName release]; _anteriorPosteriorPDFFileName = NULL;
	if (_lateralPDFFileName) [_lateralPDFFileName release]; _lateralPDFFileName = NULL;
	[super dealloc];
}

-(NSString*)manufacturerName {
	return [_properties objectForKey:@"IMPLANT_MANUFACTURER"];
}

-(NSString*)pdfPathForDirection:(ArthroplastyTemplateViewDirection)direction {
	return [[[NSString stringWithString:_directoryName] stringByAppendingPathComponent:direction==ArthroplastyTemplateAnteriorPosteriorDirection? _anteriorPosteriorPDFFileName : _lateralPDFFileName] retain];
}

-(NSImage*)imageForDirection:(ArthroplastyTemplateViewDirection)direction {
	return [[[NSImage alloc] initWithContentsOfFile:[self pdfPathForDirection:direction]] autorelease];
}

-(NSString*)name {
	if (!_name) {
		//	NSString *componentType = [properties objectForKey:@"COMPONENT_TYPE"];
		//	NSString *referenceNumber = [properties objectForKey:@"REF_NO"];
		//	name = [[NSMutableString stringWithFormat:@"%@: %@", componentType, referenceNumber] retain];
		_name = [[_properties objectForKey:@"PRODUCT_FAMILY_NAME"] retain];
	}
	
	return _name;
}

-(NSArray*)textualData {
	if (!_textualData)
		_textualData = [[NSArray arrayWithObjects:[self name], [NSString stringWithFormat:@"Size: %@", [self size]], [self manufacturerName], @"", @"", NULL] retain];
	return _textualData;
}

-(NSString*)size {
	return [_properties objectForKey:@"SIZE"];
}

@end
