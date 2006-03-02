//
//  MIRCQuestionWindowController.h
//  TeachingFile
//
//  Created by Lance Pysher on 8/20/05.
//  Copyright 2005 Macrad, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MIRCAnswerArrayController;
@interface MIRCQuestionWindowController : NSWindowController {
	NSXMLElement *_question;
	IBOutlet MIRCAnswerArrayController *answerController;
}

- (id) initWithQuestion:(NSXMLElement *)question;
- (NSXMLElement *)question;
- (NSArray *)answers;
- (void)setAnswers:(NSArray *)answers;
- (IBAction)closeWindow:(id)sender;
- (IBAction)answerAction:(id)sender;
- (IBAction)addAnswer:(id)sender;
- (IBAction)modifyAnswer:(id)sender;
- (IBAction)deleteAnswer:(id)sender;



@end
