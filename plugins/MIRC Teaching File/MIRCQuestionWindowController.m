//
//  MIRCQuestionWindowController.m
//  TeachingFile
//
//  Created by Lance Pysher on 8/20/05.
//  Copyright 2005 Macrad, LLC. All rights reserved.
//

#import "MIRCQuestionWindowController.h"
#import "MIRCAnswerArrayController.h"
#import "MIRCQuestion.h"
#import "MIRCAnswer.h"


@implementation MIRCQuestionWindowController

- (id) initWithQuestion:(NSXMLElement *)question{
	if (self = [super initWithWindowNibName:@"MIRCQuestion"])
		_question = [question retain];
	return self;
}

- (void)dealloc{
	[_question release];
	[super dealloc];
}

- (NSXMLElement *)question{
	return _question;
}

- (NSAttributedString *)questionString{
	return [[[NSAttributedString alloc] initWithString:[_question questionString]] autorelease];
}

- (void)setQuestionString:(NSAttributedString *)questionString{
	[_question setQuestionString:[questionString string]];
}

- (NSArray *)answers{
	return [_question answers];
}

- (void)setAnswers:(NSArray *)answers{	
	[_question setAnswers:answers];
	
}

- (IBAction)closeWindow:(id)sender{
	
	[NSApp endSheet:[self window]];
	[[self window]  orderOut:self];
}

- (IBAction)answerAction:(id)sender{
	if ([sender isKindOfClass:[NSSegmentedControl class]]) {
		switch ([sender selectedSegment]) {
			case 0: [self addAnswer:sender];
					break;
			//case 1: [self modifyAnswer:sender];
			//		break;
			case 1: [self deleteAnswer:sender];
					break;
		}
	}
}

- (IBAction)addAnswer:(id)sender{
	
	NSXMLElement *answer = [NSXMLElement answerWithString:@"The Answer is:"];
	[answer setAnswerIsCorrect:NO];
	//[_question addChild:answer];
	NSMutableArray *answers = [NSMutableArray arrayWithArray:[_question answers]];
	//[answers makeObjectsPerformSelector:@selector(detach)];
	[answers addObject:answer];
	[self setAnswers:answers];
}

- (IBAction)modifyAnswer:(id)sender{
/*
	NSArray *selectedObjects = [answerController selectedObjects];
	if ([selectedObjects count]) {
		NSXMLElement *answer = [selectedObjects objectAtIndex:0];
		[[self quiz] addChild:question];
		if (questionController)
			[questionController release];
		questionController = [[MIRCQuestionWindowController alloc] initWithQuestion:question];
		[NSApp beginSheet:[questionController window] modalForWindow:[self window] modalDelegate:self  didEndSelector:nil contextInfo:nil];
		//[questionController release];
	}
*/
}

- (IBAction)deleteAnswer:(id)sender{

	NSArray *selectedObjects = [answerController selectedObjects];
	if ([selectedObjects count]) {
		NSXMLElement *answer = [selectedObjects objectAtIndex:0];
		[answer detach];
	 }
	[self setAnswers:[self answers]];
	
}


@end
