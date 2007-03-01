//
//  CoreDataToMIRCXMLConverter.m
//  TeachingFile
//
//  Created by Lance Pysher on 3/1/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "CoreDataToMIRCXMLConverter.h"
#import "MIRCAuthor.h"
#import "MIRCImage.h"
#import "MIRCQuiz.h"
#import "MIRCQuestion.h"
#import "MIRCAnswer.h"


@implementation CoreDataToMIRCXMLConverter

- (id)initWithTeachingFile:(id)teachingFile{
	if (self = [super init])
		_teachingFile = teachingFile;
	return self;
}


- (NSXMLDocument *)xmlDocument{
	if (!_xmlDocument)
		[self createXMLDocument];
	return _xmlDocument;
}

- (void)createXMLDocument{
	NSXMLElement *root = [[[NSXMLElement alloc] initWithName:@"MIRCdocument"] autorelease];
	_xmlDocument = [[NSXMLDocument alloc] initWithRootElement:root];
	// Display type
	[root addAttribute:[NSXMLNode attributeWithName:@"display" stringValue:@"mstf"]];
	// Title
	if ([_teachingFile valueForKey:@"title"])
		[root addChild:[NSXMLNode elementWithName:@"title" stringValue:[_teachingFile valueForKey:@"title"]]];
	// Alternative Title
	if ([_teachingFile valueForKey:@"altTitle"])
		[root addChild:[NSXMLNode elementWithName:@"alternative-title" stringValue:[_teachingFile valueForKey:@"altTitle"]]];
	// Authors
	NSEnumerator *enumerator = [[_teachingFile valueForKey:@"authors"] objectEnumerator];
	id author;
	while (author = [enumerator nextObject]){
		MIRCAuthor *mircAuthor = [MIRCAuthor author];
		if ([author valueForKey:@"name"])
			[mircAuthor setAuthorName:[author valueForKey:@"name"]];
		if ([author valueForKey:@"phone"])
			[mircAuthor setPhone:[author valueForKey:@"phone"]];
		if ([author valueForKey:@"email"])
			[mircAuthor setEmail:[author valueForKey:@"email"]];
		if ([author valueForKey:@"affiliation"])
			[mircAuthor setAffiliation:[author valueForKey:@"affiliation"]];
		[root addChild:mircAuthor];
	}
	// History
	
	//Abstract
	if ([_teachingFile  valueForKey:@"abstractText"]) {
		NSXMLElement *node = (NSXMLElement *)[self nodeFromXML:[_teachingFile  valueForKey:@"abstractText"] withName:@"abstract"];
		[root addChild:node];
	}

	//Alt Abstract
	if ([_teachingFile  valueForKey:@"altAbstractText"]) {
		NSXMLElement *node = (NSXMLElement *)[self nodeFromXML:[_teachingFile  valueForKey:@"altAbstractText"] withName:@"alternative-abstract"];
		[root addChild:node];
	}

	//keywords
	if ([_teachingFile valueForKey:@"keywords"])
		[root addChild:[NSXMLNode elementWithName:@"keywords" stringValue:[_teachingFile valueForKey:@"keywords"]]];
	
	/********** Sections ************/
	//History;
	[root addChild:[self historySection]];
	[root addChild:[self imageSection]];
	[root addChild:[self discussionSection]];
	[root addChild:[self quizSection]];
}

- (NSXMLNode *)nodeFromXML:(NSData *)xmlData withName:(NSString *)name{
	NSError *error;
	NSAttributedString *attrString = [[NSAttributedString alloc] initWithCoder:[NSUnarchiver unarchiveObjectWithData:xmlData]];
	NSString *xmlString = [NSString stringWithFormat:@"<%@>%@</%@>",name, [attrString string], name];
	[attrString release];
	NSXMLElement *node = [[[NSXMLElement alloc] initWithXMLString:xmlString error:&error] autorelease];
	if (!error)
		return node;
	NSLog(@"Error reading XML: %@", [error description]);
	return nil;
}

- (NSXMLElement *)historySection{
	NSXMLElement *historySection =  [self sectionWithHeading:@"History"];
	NS_DURING
	NSAttributedString *history = [[NSAttributedString alloc] initWithCoder:[NSUnarchiver unarchiveObjectWithData:[_teachingFile valueForKey:@"history"]]];
	NSString *string = [history string];
	// Add history text.  Need to take into account possible embedded html
	if ([string hasPrefix:@"<"]) {
		//should be xml or html"
		NSLog(@"set history as html: %@", [history string]);
		NSXMLElement *node = (NSXMLElement *)[self nodeFromXML:[_teachingFile valueForKey:@"history"]withName:@"history"];
		[self insertNode:(NSXMLElement *)node  intoNode:historySection atIndex:0];
	}
	// probably no HTML. treat it as plain text.
	else  if (history){
		NSLog(@"set history: %@", [history string]);
		NSXMLElement *node = nil;
		NSXMLNode *textNode = [NSXMLNode textWithStringValue:[history string]];
		node = [NSXMLNode elementWithName:@"history"];
		[self insertNode:(NSXMLElement *)node  intoNode:historySection atIndex:0];
		[node setChildren:[NSArray arrayWithObject:textNode]];
		
	}
	[history release];
	
	// add history movie
	if ([_teachingFile valueForKey:@"historyMovie"]) {
		// Add link text
		NSXMLElement *node = [NSXMLNode elementWithName:@"a" stringValue:@"watch video"];
		// add link to history.mov
		[node addAttribute:[NSXMLNode attributeWithName:@"href" stringValue:@"history.mov"]];
		[historySection  addChild:node];
	}
	
	NS_HANDLER
		NSLog (@"error saving history: %@", [localException name]);
	NS_ENDHANDLER
	
	return historySection;
}


- (NSXMLElement *)discussionSection{
	NSXMLElement *discussionSection =  [self sectionWithHeading:@"Discussion"];
	
	NS_DURING
	//diagnosis
	NSXMLNode *node = [NSXMLNode elementWithName:@"diagnosis" stringValue:[_teachingFile valueForKey:@"diagnosis"]];
	[self insertNode:(NSXMLElement *)node  intoNode:[self discussionSection] atIndex:0];
	
	//findings
	NSAttributedString *findings = [[NSAttributedString alloc] initWithCoder:[NSUnarchiver unarchiveObjectWithData:[_teachingFile valueForKey:@"findings"]]];
	NSString *string = [findings string];
	// Add findings text.  Need to take into account possible embedded html
	if ([string hasPrefix:@"<"]) {
		//should be xml or html"
		NSLog(@"set history as html: %@", [findings string]);
		NSXMLElement *node = (NSXMLElement *)[self nodeFromXML:[_teachingFile valueForKey:@"findings"] withName:@"findings"];
		[self insertNode:(NSXMLElement *)node  intoNode:discussionSection atIndex:1];
	}
	// probably no HTML. treat it as plain text.
	else  if (findings){
		NSLog(@"set findings: %@", [findings string]);
		NSXMLElement *node = nil;
		NSXMLNode *textNode = [NSXMLNode textWithStringValue:[findings string]];
		node = [NSXMLNode elementWithName:@"findings"];
		[self insertNode:(NSXMLElement *)node  intoNode:discussionSection atIndex:1];
		[node setChildren:[NSArray arrayWithObject:textNode]];		
	}
	[findings release];
		
	//ddx
	node = [NSXMLNode elementWithName:@"differential-diagnosis" stringValue:[_teachingFile valueForKey:@"ddx"]];
	[self insertNode:(NSXMLElement *)node  intoNode:[self discussionSection] atIndex:2];	
	
	NSAttributedString *discussion = [[NSAttributedString alloc] initWithCoder:[NSUnarchiver unarchiveObjectWithData:[_teachingFile valueForKey:@"discussion"]]];
	string = [discussion string];
	// Add discussion text.  Need to take into account possible embedded html
	if ([string hasPrefix:@"<"]) {
		//should be xml or html"
		NSLog(@"set history as html: %@", [discussion string]);
		NSXMLElement *node = (NSXMLElement *)[self nodeFromXML:[_teachingFile valueForKey:@"discussion"] withName:@"discussion"];
		[self insertNode:(NSXMLElement *)node  intoNode:discussionSection atIndex:3];
	}
	// probably no HTML. treat it as plain text.
	else  if (discussion){
		NSLog(@"set discussion: %@", [discussion string]);
		NSXMLElement *node = nil;
		NSXMLNode *textNode = [NSXMLNode textWithStringValue:[discussion string]];
		node = [NSXMLNode elementWithName:@"discussion"];
		[self insertNode:(NSXMLElement *)node  intoNode:discussionSection atIndex:3];
		[node setChildren:[NSArray arrayWithObject:textNode]];
		
	}
	[discussion release];
	

	// add discussion movie
	if ([_teachingFile valueForKey:@"discussionMovie"]) {
		// Add link text
		NSXMLElement *node = [NSXMLNode elementWithName:@"a" stringValue:@"watch video"];
		// add link to history.mov
		[node addAttribute:[NSXMLNode attributeWithName:@"href" stringValue:@"discussion.mov"]];
		[discussionSection  addChild:node];
	}
	
	NS_HANDLER
		NSLog (@"error saving discussion: %@", [localException name]);
	NS_ENDHANDLER
	return discussionSection;
}


- (NSXMLElement *)imageSection{
	NSXMLElement *	imageSection = [NSXMLNode elementWithName:@"image-section"];
	[imageSection addAttribute:[NSXMLNode attributeWithName:@"heading" stringValue:@"Images"]];	
	NSEnumerator *enumerator = [[_teachingFile valueForKey:@"images"] objectEnumerator];
	id image;
	while (image = [enumerator nextObject]) {
		NSXMLElement *mircImage = [NSXMLElement image];
		NSString *index = [[image valueForKey:@"index"] stringValue];
		[mircImage addAttribute:[NSXMLNode attributeWithName:@"src" stringValue:[index stringByAppendingPathExtension:@"jpg"]]];
		// original Dimension  Could  be movie or jpeg.  Only jpeg now.
		[mircImage setOriginalDimensionImagePath:[[NSString stringWithFormat:@"%@-OD", index] stringByAppendingPathExtension:[image valueForKey:@"originalDimensionExtension"]]];
		// Annotated Image
		[mircImage setAnnotationImagePath:[[NSString stringWithFormat:@"%@-ANN", index] stringByAppendingPathExtension:@"jpg"]];
		//orignal format
		[mircImage setOriginalFormatImagePath:[[NSString stringWithFormat:@"%@-OF", index] stringByAppendingPathExtension:[image valueForKey:@"originalFormatExtension"]]];
		[imageSection addChild:mircImage];
	}	
				
	return imageSection;
}

- (NSXMLElement *)quizSection{
	NSXMLElement *quizSection =  [self sectionWithHeading:@"Quiz"];
	NSXMLElement *quiz = [NSXMLElement quiz];
	[quizSection addChild:quiz];
	NSEnumerator *enumerator = [[_teachingFile valueForKey:@"questions"] objectEnumerator];
	id question;
	while (question = [enumerator nextObject]) {
		NSXMLElement *node = [NSXMLElement questionWithString:[question valueForKey:@"question"]];
		//add answers
		NSEnumerator *answerEnumerator = [[question valueForKey:@"answers"] objectEnumerator];
		id answer;
		while (answer = [answerEnumerator nextObject]) {
			NSXMLElement *answerNode = [NSXMLElement answerWithString:[answer valueForKey:@"answer"]];
			[answerNode setAnswerIsCorrect:[[answer valueForKey:@"isCorrect"] boolValue]];
			[node addAnswer:answerNode];
		}
		[quiz addQuestion:node];
	}
	return quizSection;
}

- (NSXMLElement *)sectionWithHeading:(NSString *)heading{
	NSXMLElement *node = [NSXMLNode elementWithName:@"section"];
	[node addAttribute:[NSXMLNode attributeWithName:@"heading" stringValue:heading]];
	return node;
}

- (void)insertNode:(NSXMLElement *)node  intoNode:(NSXMLElement *)destination atIndex:(int)index{
	int childCount = [destination childCount];
	if (childCount > index)
		[destination insertChild:node atIndex:index]; 
	else {
		//NSLog(@"add Node: %@", [node description]);
		[destination addChild:node];
	}
}

@end
