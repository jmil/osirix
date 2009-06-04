//
//  ArthroplastyTemplate.h
//  Arthroplasty Templating II
//  Created by Joris Heuberger on 04/04/07.
//  Copyright (c) 2007-2009 OsiriX Foundation. All rights reserved.
//

#import <Cocoa/Cocoa.h>


typedef enum {
	ArthroplastyTemplateAnteriorPosteriorDirection,
	ArthroplastyTemplateLateralDirection
} ArthroplastyTemplateViewDirection;


@interface ArthroplastyTemplate : NSObject {
	NSString* _directoryName;
	NSMutableDictionary* _properties;
	NSImage* _image;
	NSString* _name;
	NSArray* _textualData;
	NSString* _referenceFilePath;
}

@property(readonly) NSString* directoryName;
@property(readonly) NSString* manufacturerName;
@property(readonly) NSString* name;
@property(readonly) NSString* referenceFilePath;
@property(readonly) NSString* size;
@property(readonly) NSMutableDictionary* properties;
@property(readonly) NSImage* image;
@property(readonly) NSArray* textualData;

-(id)initFromFileAtPath:(NSString*)path;
-(NSString*)pdfPathForDirection:(ArthroplastyTemplateViewDirection)direction;
-(id)valueForKey:(NSString*)key;

@end
