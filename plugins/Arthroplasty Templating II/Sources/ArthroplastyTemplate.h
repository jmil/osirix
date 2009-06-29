//
//  ArthroplastyTemplate.h
//  Arthroplasty Templating II
//  Created by Joris Heuberger on 04/04/07.
//  Copyright (c) 2007-2009 OsiriX Foundation. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ArthroplastyTemplateFamily;


typedef enum {
	ArthroplastyTemplateAnteriorPosteriorDirection,
	ArthroplastyTemplateLateralDirection
} ArthroplastyTemplateViewDirection;


@interface ArthroplastyTemplate : NSObject {
	NSString* _path;
	ArthroplastyTemplateFamily* _family;
}

@property(readonly) NSString* path;
@property(assign) ArthroplastyTemplateFamily* family;
@property(readonly) NSString *fixation, *group, *manufacturer, *modularity, *name, *placement, *surgery, *type, *size, *referenceNumber;

-(id)initWithPath:(NSString*)path;
-(CGFloat)scale;

@end


@interface ArthroplastyTemplate (Abstract)

-(NSString*)pdfPathForDirection:(ArthroplastyTemplateViewDirection)direction;
-(NSArray*)textualData;

@end
