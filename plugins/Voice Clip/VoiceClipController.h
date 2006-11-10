//
//  VoiceClipController.h
//  VoiceClip
//
//  Created by Lance Pysher on 11/8/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class QTMovie;

@interface VoiceClipController : NSWindowController {
	BOOL _recording;
	BOOL _audioExists;
	NSString *_recordTitle; 
	NSString *_moviePath;
	QTMovie *_movie;
}


- (void)record;
- (void)reset;
- (void)stopRecording;
- (BOOL)path:(NSString *)path toFSRef:(FSRef *)ref;

- (void)setRecordTitle:(NSString *)recordTitle;

- (BOOL)recording;
- (void)setRecording:(BOOL)recording;
- (BOOL)audioExists;
- (void)setAudioExists:(BOOL)audioExists;
- (NSString *)recordTitle;
- (void)setRecordTitle:(NSString *)recordTitle;
- (QTMovie *)movie;
- (void)setMovie:(QTMovie *)movie;
- (BOOL)hidePlayerControls;
- (void)setHidePlayerControls:(BOOL)hide;

- (IBAction) recordAudio: (id)sender;



@end
