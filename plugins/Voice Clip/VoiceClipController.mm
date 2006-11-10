//
//  VoiceClipController.mm
//  VoiceClip
//
//  Created by Lance Pysher on 11/8/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "VoiceClipController.h"
#import <QTKit/QTKit.h>
#import "browserController.h"
#import"VoiceClipController.h"
#include "DCAudioFileRecorder.h"
#include <sys/param.h>

static Boolean			gIsRecording = false;
DCAudioFileRecorder		*gAudioFileRecorder = NULL;
FSRef					gParentDir;
CFStringRef				gFileName= NULL;
AudioStreamBasicDescription	gAACFormat = {44100.0, kAudioFormatMPEG4AAC, kAudioFormatFlagIsBigEndian, 0, 1024, 0, 2, 0, 0};


@implementation VoiceClipController

- (id)init{
	if (self = [super initWithWindowNibName:@"VoiceClip"]) {
	_recording  = NO;
	_audioExists = NO;
	_recordTitle = @"Record";
	}
	return self;
}

 - (void)reset{
	NSLog (@"reset");
	[self setRecording:NO];
	[self setAudioExists:NO];
	[self setRecordTitle:@"Record"];
	NSArray *currentSelection = [[BrowserController currentBrowser] databaseSelection];
	if ([currentSelection count] > 0) {

		id selection = [currentSelection objectAtIndex:0];
		id study;
		if ([[[selection entity] name] isEqualToString:@"Study"]) 
			study = selection;				
		else
			study = [selection valueForKey:@"study"];
			
		NSString *studyInstanceUID = [study valueForKeyPath:@"studyInstanceUID"];
		NSString *patientName = [study valueForKeyPath:@"name"];
		NSString *path = [[NSString stringWithFormat:@"%@-%@", patientName, studyInstanceUID] stringByAppendingPathExtension:@"m4a"];;
		NSString *dir = [[[BrowserController currentBrowser] documentsDirectory] stringByAppendingPathComponent:@"VoiceClips"];

		if ([[NSFileManager defaultManager] fileExistsAtPath:dir] == NO)
			[[NSFileManager defaultManager] createDirectoryAtPath:dir attributes:nil];
		
		[self path:dir toFSRef:&gParentDir];
		
		[_moviePath release];
		_moviePath = [[dir stringByAppendingPathComponent:path] retain];
		if ([[NSFileManager defaultManager] fileExistsAtPath:_moviePath]) {
			NSError *error;
			[self setAudioExists:YES];
			[self setMovie:[QTMovie movieWithFile:_moviePath error:&error]];
		}
		
		if(gFileName)
			CFRelease(gFileName);
		//create a temp File. Move when done recording
		gFileName = CFStringCreateCopy( NULL, (CFStringRef) [NSString stringWithFormat:@".%@", path] );

			
	}
 }
 
 - (BOOL)path:(NSString *)path toFSRef:(FSRef *)ref{
	NSURL  *url = [NSURL fileURLWithPath:path];
	CFURLGetFSRef((CFURLRef) url, ref);
	return YES;
	
 }

- (void)record{
	NSLog(@"record");
	OSStatus err = noErr;
	
	if(gIsRecording)
		return;
	
	if(gAudioFileRecorder)
		delete gAudioFileRecorder; gAudioFileRecorder = NULL;
	
	gAudioFileRecorder = new DCAudioFileRecorder;
	err = gAudioFileRecorder->Configure(gParentDir, gFileName, &gAACFormat);
	if(err != noErr)
	{
		delete gAudioFileRecorder; gAudioFileRecorder = NULL;
		return;
	}
	
	err = gAudioFileRecorder->Start();
	if(err != noErr)
	{
		delete gAudioFileRecorder; gAudioFileRecorder = NULL;
		return;
	}
	[self setRecordTitle:@"Stop"];
	gIsRecording = true;
	_recording = YES;
	
}

- (void)stopRecording{
	QTMovie *movie;
	OSStatus err = noErr;
	NSError *error;
	if(!gIsRecording)
		return;
	
	err = gAudioFileRecorder->Stop();

	// delete the object here so the async file I/O flushs
	delete gAudioFileRecorder; gAudioFileRecorder = NULL;
	gIsRecording = false;
	
	_recording = NO;
	[self setRecordTitle:@"Record"];
	// move temp file to path
	NSFileManager *defaultManager = [NSFileManager defaultManager];
	NSString *fname = [NSString stringWithFormat: @".%@", [_moviePath lastPathComponent]];
	NSString *tempPath = [[_moviePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:fname];
	if ([defaultManager fileExistsAtPath:tempPath]) {
		//remove old
		if ([defaultManager fileExistsAtPath:_moviePath]) {
			[self setMovie:nil];
			[defaultManager removeFileAtPath:_moviePath handler:nil];
		}
		[defaultManager movePath:tempPath toPath:_moviePath handler:nil];
		if ([defaultManager fileExistsAtPath:_moviePath])
			movie = [QTMovie movieWithFile:_moviePath error:&error];
		if (movie) {
			[self setMovie:movie];
			[self setAudioExists:YES];
		}
		//NSLog(@"Moved Audio: %@", [error description]);
	}
	return;
}


- (IBAction)recordAudio:(id)sender{
	NSLog(@"Record Audio");
	if (_recording)
		[self stopRecording];
	else
		[self record];
}


- (BOOL)recording{
	return _recording;
}


- (void)setRecording:(BOOL)recording{
	_recording = recording;
}

- (BOOL)audioExists{
	return _audioExists;
}

- (void)setAudioExists:(BOOL)audioExists{
	_audioExists = audioExists;
	[self setHidePlayerControls:YES];
}

- (BOOL)hidePlayerControls{
	return !_audioExists;
}

- (void)setHidePlayerControls:(BOOL)hide{
	//don't do anything just call to let Binding know of change
}

- (NSString *)recordTitle{
	return _recordTitle;
}

- (void)setRecordTitle:(NSString *)recordTitle{
	[_recordTitle release];
	_recordTitle = [recordTitle retain];
}

- (QTMovie *)movie{
	return _movie;
}
- (void)setMovie:(QTMovie *)movie{
	[_movie release];
	_movie = [movie retain];
}




@end
