//
//  ZimmerTemplate.m
//  XRayTemplatesPlugin
//
//  Created by joris on 19/03/07.
//  Copyright 2007 OsiriX Team. All rights reserved.
//

#import "ZimmerTemplate.h"

@implementation ZimmerTemplate

+ (NSMutableDictionary*)propertiesFromFileInfoAtPath:(NSString*)path;
{
	// check file extension and name
	NSString *extension = [path pathExtension];
	BOOL extensionIsOK = [extension isEqualToString:@"txt"];
	
	NSString *nameWithoutExtension = [[path lastPathComponent] stringByDeletingPathExtension];
	BOOL isInfoFile = [nameWithoutExtension hasSuffix:@"_info"];

	if(!extensionIsOK || !isInfoFile)
		return nil;
		
	// read the info file
	NSError *error;
	NSString *fileContent = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];

	if(!fileContent) 
	{
		fileContent = [NSString stringWithContentsOfFile:path encoding:NSISOLatin1StringEncoding error:&error];
		if(!fileContent) 
		{
			NSLog(@"error : %@", error);
			return nil;
		}
	}
	
	NSScanner *infoFileScanner = [NSScanner scannerWithString:fileContent];
	[infoFileScanner setCharactersToBeSkipped:[NSCharacterSet whitespaceCharacterSet]];
	
	NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithCapacity:0];

	NSMutableString *key, *value, *temp;
	while(![infoFileScanner isAtEnd])
	{
		[infoFileScanner scanUpToString:@":=:" intoString:&key];
		[infoFileScanner scanString:@":=:" intoString:&temp];
		[infoFileScanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"] intoString:&value];
		value = [NSMutableString stringWithString:value];
		[value deleteCharactersInRange:NSMakeRange([value length]-1, 1)];
		[infoFileScanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&temp];
		[properties setObject:value forKey:key];
	}
	
	return properties;
}

- (id)initFromFileAtPath:(NSString*)path
{
	[super initFromFileAtPath:path];
		
	// properties
	NSMutableDictionary* templateProperties = [ZimmerTemplate propertiesFromFileInfoAtPath:path];
	if(!templateProperties)
		return nil;
	properties = [[NSMutableDictionary dictionaryWithDictionary:templateProperties] retain];

	infoFilePath = [path retain];

	directoryName = [[path stringByDeletingLastPathComponent] retain];
	anteriorPosteriorPDFFileName = [[properties objectForKey:@"PDF_FILE_AP"] retain];
	lateralPDFFileName = [[properties objectForKey:@"PDF_FILE_ML"] retain];
	textualData = nil;
	
	return self;
}

- (void)dealloc;
{
	if(infoFilePath)[infoFilePath release];
	if(anteriorPosteriorPDFFileName)[anteriorPosteriorPDFFileName release];
	if(lateralPDFFileName)[lateralPDFFileName release];
	if(textualData)[textualData release];
	[super dealloc];
}

- (XRayTemplateManufacturer)manufacturer;
{
	return Zimmer;
}

- (NSString*)manufacturerName;
{
	return [properties objectForKey:@"IMPLANT_MANUFACTURER"];
}

- (NSString*)PDFPreviewPath;
{
	
	NSString *pdfFileName;
	if(viewDirection == XRayTemplateAnteriorPosteriorDirection)
		pdfFileName = anteriorPosteriorPDFFileName;
	else
		pdfFileName = lateralPDFFileName;

	NSString *pdfPath = [NSString stringWithString:directoryName];
	pdfPath = [[pdfPath stringByAppendingPathComponent:pdfFileName] retain];
	return pdfPath;
}

- (NSImage*)image;
{
	if(image) return image;
	
	image = [[[NSImage alloc] initWithContentsOfFile:[self PDFPreviewPath]] retain];
	return image;
}

- (NSString*)name;
{
	if(name) return name;
	
//	NSString *componentType = [properties objectForKey:@"COMPONENT_TYPE"];
//	NSString *referenceNumber = [properties objectForKey:@"REF_NO"];
//	name = [[NSMutableString stringWithFormat:@"%@: %@", componentType, referenceNumber] retain];
	name = [[properties objectForKey:@"PRODUCT_FAMILY_NAME"] retain];
	return name;
}

- (NSArray*)textualData;
{
	NSLog(@"textualData?");
	if(textualData) return textualData;
	NSLog(@"NO textualData");	
	name = [self name];
	NSString *size = [NSString stringWithFormat:@"Size: %@", [properties objectForKey:@"SIZE"]];
	NSString *manufacturer = [properties objectForKey:@"IMPLANT_MANUFACTURER"];
	NSString *line4 = @"";
	NSString *line5 = @"";
	
	textualData = [[NSArray arrayWithObjects:name, size, manufacturer, line4, line5, nil] retain];
	return textualData;
}

- (NSString*)size;
{
	return [properties objectForKey:@"SIZE"];
}

- (float)sizeValue;
{
	NSString *size = [properties objectForKey:@"SIZE"];
	NSArray *pathComponents = [size pathComponents];
	if([pathComponents count]>1)
		return [[pathComponents objectAtIndex:0] floatValue];
	else
		return [size floatValue];
}

- (NSString*)reference;
{
	return [properties objectForKey:@"REF_NO"];
}

@end