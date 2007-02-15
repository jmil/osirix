//
//  MIRCController.m
//  
//
//  Created by Lance Pysher July 22, 2005
//  Copyright (c) 2005 Macrad, LLC. All rights reserved.
//

#import "MIRCController.h"
#import "MIRCFilter.h"
#import "DCMView.h"
#import <QuartzCore/QuartzCore.h>
#import "MIRCXMLController.h"
#import "MIRCWebController.h"
#import "MIRCImage.h"
#import "browserController.h"
 #import <OsiriX/DCM.h>

//enum { annotNone = 0, annotGraphics = 1, annotBase = 2, annotFull = 3};

@implementation MIRCController

//extern short annotations;

//Core Data Managed Objects
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) return _managedObjectModel;
	
	NSMutableSet *allBundles = [[NSMutableSet alloc] init];
	[allBundles addObject: [NSBundle mainBundle]];
	[allBundles addObjectsFromArray: [NSBundle allFrameworks]];
    
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: [NSURL fileURLWithPath: [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingString:@"/TeachingFile.mom"]]];
    [allBundles release];
    
    return _managedObjectModel;
}

- (NSManagedObjectContext *) managedObjectContext
{
    NSError *error = 0L;
    NSString *localizedDescription;
	NSFileManager *fileManager;

	
    if (_managedObjectContext) return _managedObjectContext;
		
	fileManager = [NSFileManager defaultManager];
	
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator: coordinator];
	
	NSString *dbPath = [[self path] stringByAppendingPathComponent:@"teachingFile.sql"];
	//NSLog(@"PATH TO TEAHCING FILE SQL FILE	: %@, TF path: %@", dbPath, _path);
    NSURL *url = [NSURL fileURLWithPath: dbPath];

	if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error])
	{	// NSSQLiteStoreType - NSXMLStoreType
      localizedDescription = [error localizedDescription];
		error = [NSError errorWithDomain:@"OsiriXDomain" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:error, NSUnderlyingErrorKey, [NSString stringWithFormat:@"Store Configuration Failure: %@", ((localizedDescription != nil) ? localizedDescription : @"Unknown Error")], NSLocalizedDescriptionKey, nil]];
    }
	
	[coordinator release];
	
	[_managedObjectContext setStalenessInterval: 1200];
	
    return _managedObjectContext;
}

- (void)save{
//	NSManagedObjectModel *model = [self managedObjectModel];
	NSManagedObjectContext *context = [self managedObjectContext];
	NSError *error = nil;
			
	[context save: &error];
	if (error)
	{
		NSLog(@"error saving DB: %@", [[error userInfo] description]);
		NSLog( @"saveDatabase ERROR: %@", [error localizedDescription]);
	}
	else
		NSLog(@"MIRC TF saved");
		
		
	//[context unlock];
	//[context release];
}


- (id) initWithFilter:(id)filter
{
	self = [super initWithWindowNibName:@"MIRC"];
	//NSLog(@"init MIRC filter");
	_filter = filter;
	[[self window] setDelegate:self];   //In order to receive the windowWillClose notification!
	_path = [[[NSUserDefaults standardUserDefaults] stringForKey:@"MIRCFolderPath"] retain];
	if ([[NSUserDefaults standardUserDefaults] stringForKey:@"MIRCurl"])
		[self setUrl:[[NSUserDefaults standardUserDefaults] stringForKey:@"MIRCurl"]];
	if (!_path)
		_path = [[_filter teachingFileFolder] retain];
	[titleField setStringValue:_path];
	
	//Get Cases
	NSError *error = nil;	
	NSPredicate * predicate = [NSPredicate predicateWithValue:YES];
	NSFetchRequest *dbRequest = [[[NSFetchRequest alloc] init] autorelease];
	[dbRequest setEntity: [[[self managedObjectModel] entitiesByName] objectForKey:@"teachingFile"]];
	[dbRequest setPredicate:predicate];
	_teachingFiles = [[[self managedObjectContext] executeFetchRequest:dbRequest error:&error] retain];
	if( [_teachingFiles count]) {
		NSEnumerator *enumerator = [_teachingFiles objectEnumerator];
		id tf;
		while (tf = [enumerator nextObject])
			NSLog(@"images %@", [tf valueForKey:@"images"]);
		
	}
	
	return self;
}

- (void)windowDidLoad{
}

- (void)windowWillClose:(NSNotification *)note{
	NSLog(@"window Will Close");
	[self save];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification{
	NSLog(@"terminate MIRC");
	[self save];
}



- (void) dealloc
{	
	[self save];
	[_teachingFiles release];
	[_xmlController release];
	[_webController release];
	[_caseName release];
	[_path release];
	[_url release];
	[super dealloc];
}

- (IBAction)controlAction: (id)sender {
	if ([sender selectedSegment] == 0) 
	{
		//[self selectCurrentImage:nil];
	}
	else if ([sender selectedSegment] == 1) 
		[self createCase:nil];
	else if ([sender selectedSegment] == 2)
		[self createArchive:sender];
	else
		[self connectToMIRC:nil]; 
}



- (IBAction)selectCurrentImage:(id)sender{
	NSString *path = [[[[_filter viewerController] fileList] objectAtIndex:[[[_filter viewerController] imageView] curImage]] valueForKey:@"completePath"];	
	NSString *lastPathComponent = [path lastPathComponent];
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel beginSheetForDirectory:[self folder] 
		file:lastPathComponent 
		modalForWindow:[self window]
		modalDelegate:self 
		didEndSelector:@selector(selectCurrentImageDidEnd:returnCode:contextInfo:)
		contextInfo:nil];

}

- (void)selectCurrentImageDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo{
	//NSLog(@"save current files");
	if (returnCode == NSOKButton){
		//delete archive is present
		NSString *filename = [[[sheet filename] lastPathComponent]  stringByDeletingPathExtension];
		//NSLog(@"fileName: %@", filename);
		//short currentAnnotation = annotNone;
		NSString *path = [[[[_filter viewerController] fileList] objectAtIndex:[[[_filter viewerController] imageView] curImage]] valueForKey:@"completePath"];	
		NSString *lastPathComponent = [path lastPathComponent];
		NSString *extension = [lastPathComponent pathExtension];
		//copy original
		NSString *jpegPath = [[[self folder] stringByAppendingPathComponent:filename] stringByDeletingPathExtension];
		//NSLog(@"jpegPath; %@", jpegPath);
		// Need to anonymize DICOMs
		
		//create xml image
		NSXMLElement  *image = [NSXMLElement image];
		
		NSString *newJpegPath = [jpegPath stringByAppendingPathExtension:extension];
		
		if ([[path pathExtension] isEqualToString:@"dcm"]) {
			
			NSMutableArray *tags = [NSMutableArray array];
			[tags addObject:[NSArray arrayWithObject:[DCMAttributeTag tagWithName:@"PatientsName"]]];
			[tags addObject:[NSArray arrayWithObject:[DCMAttributeTag tagWithName:@"PatientsBirthDate"]]];
			[tags addObject:[NSArray arrayWithObject:[DCMAttributeTag tagWithName:@"InstitutionName"]]];
			[tags addObject:[NSArray arrayWithObject:[DCMAttributeTag tagWithName:@"StudyDate"]]];
			[tags addObject:[NSArray arrayWithObject:[DCMAttributeTag tagWithName:@"SeriesDate"]]];
			[tags addObject:[NSArray arrayWithObject:[DCMAttributeTag tagWithName:@"InstanceDate"]]];
			[tags addObject:[NSArray arrayWithObject:[DCMAttributeTag tagWithName:@"ContentDate"]]];
			[tags addObject:[NSArray arrayWithObject:[DCMAttributeTag tagWithName:@"AcquisitionDate"]]];
			[DCMObject anonymizeContentsOfFile:path  tags:(NSArray *)tags  writingToFile:newJpegPath];
				
			
		}
		else		
			[[NSFileManager defaultManager] copyPath:path toPath:newJpegPath handler:nil];
			
		//add orignal format Alt image	
		[image setOriginalFormatImagePath:[newJpegPath lastPathComponent]];
		
			
		// Load an image
		NSImage    *sourceImage    = [[[_filter viewerController] imageView] nsimage:YES];
		//NSLog(@"sourceImage %@", [sourceImage description]);
		NSData *tiff = [sourceImage TIFFRepresentation];
		
		//make full size jpeg
		NSImage *jpegImage = [[[NSImage alloc] initWithData:tiff] autorelease];
		NSBitmapImageRep *rep = [jpegImage bestRepresentationForDevice:nil];
		NSData *jpegData = [rep representationUsingType:NSJPEGFileType properties:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.9] forKey:NSImageCompressionFactor]];
		NSString *fullSizePath = [jpegPath stringByAppendingPathExtension:@"jpg"] ;
		if ([jpegData writeToFile:fullSizePath atomically:YES]) {
			NSLog(@"Wrote JPEG: %@:", fullSizePath);
			//add orignal fSize Alt image	
			[image setOriginalDimensionImagePath:[fullSizePath lastPathComponent]];
		}

		// Convert to a CIImage
		CIImage  *ciImage    = [[CIImage alloc] initWithData:tiff];
		float width = [sourceImage size].width;
		float scale = 256.0/width;
		
		//create filter
		CIFilter *myFilter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
		[myFilter setDefaults];
		[myFilter setValue: ciImage forKey: @"inputImage"];  
		[myFilter setValue: [NSNumber numberWithFloat: scale]  
						forKey: @"inputScale"];
						
		//get scaled image
		CIImage *result = [myFilter valueForKey:@"outputImage"];
		NSCIImageRep *ciRep = [NSCIImageRep imageRepWithCIImage:result];
		NSImage *newImage = [[[NSImage alloc] init] autorelease];
		[newImage addRepresentation:ciRep];
		//convert to Tiff to get Bipmap and convert to jpeg
		NSImage *tn = [[[NSImage alloc] initWithData:[newImage TIFFRepresentation]] autorelease];
		rep = (NSBitmapImageRep *)[tn bestRepresentationForDevice:nil];
		jpegData = [rep representationUsingType:NSJPEGFileType properties:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.9] forKey:NSImageCompressionFactor]];
		NSString *tnPath = [[jpegPath stringByAppendingString:@"_tn"] stringByAppendingPathExtension:@"jpg"];
		if ([jpegData writeToFile:tnPath atomically:YES]) {
			NSLog(@"Wrote JPeg: %@:", tnPath );
			//path for the orginal image
			[image setPath:[tnPath lastPathComponent]];
		}
			
				
			
		//annotated image
		sourceImage    = [[[_filter viewerController] imageView] nsimage:NO];
		tiff = [sourceImage TIFFRepresentation];
		jpegImage = [[[NSImage alloc] initWithData:tiff] autorelease];
		rep = (NSBitmapImageRep *)[jpegImage bestRepresentationForDevice:nil];
		jpegData = [rep representationUsingType:NSJPEGFileType properties:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.9] forKey:NSImageCompressionFactor]];
		NSString *annotPath = [[jpegPath stringByAppendingString:@"_annot"] stringByAppendingPathExtension:@"jpg"];
		if ([jpegData writeToFile:annotPath atomically:YES]) {
			NSLog(@"Wrote JPeg: %@:", annotPath);
			//add annotated format Alt image	
			[image setAnnotationImagePath:[annotPath lastPathComponent]];
		}
		

		
		[tableView reloadData];
		
		//add image to xml 
		if (!_xmlController)
			_xmlController = [[MIRCXMLController alloc] initWithPath:[self folder]];
		NSMutableArray *images = [NSMutableArray arrayWithArray:[_xmlController  images]];
		[images makeObjectsPerformSelector:@selector(detach)];
		[images addObject:image];
		[_xmlController setImages:images];
		[_xmlController saveWithAlert:NO];
	}
}

- (IBAction)createCase:(id)sender{
	if (_xmlController)
		[_xmlController release];
	_xmlController = [[MIRCXMLController alloc] initWithPath:[self folder]];
	[_xmlController showWindow:nil];
	
}

- (IBAction)connectToMIRC:(id)sender{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:_url]];
/*
	if (_url) {		
		if (!_webController)
			_webController = [[MIRCWebController alloc] initWithURL:[NSURL URLWithString:_url]];
		else
			[_webController setURL:[NSURL URLWithString:_url]];
		[_webController showWindow:nil];
		
		}
	else {
		NSRunAlertPanel(@"OsiriX",
                        @"No URL for connection",
                        nil, nil, nil);
	}
*/
}

- (NSString *)url{
//	NSLog(@"url: %@", _url);
	return _url;
}

- (void)setUrl:(NSString *)url{
	[_url release];
	if ([url hasPrefix:@"http://"])
		_url = [url retain];
	else
		_url = [[NSString stringWithFormat:@"http://%@", url] retain];
//	NSLog(@"set url: %@", _url);
	[[NSUserDefaults standardUserDefaults] setObject:_url forKey:@"MIRCurl"];
}


- (IBAction)chooseFolder:(id)sender{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setMessage:NSLocalizedString(@"Select folder for Teaching File.", nil)];
	[openPanel setCanCreateDirectories:YES];
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];
	NSString *directory = [_filter teachingFileFolder];
	if ([openPanel runModalForDirectory:directory file:nil types:nil] == NSOKButton){
		[_path release];
		_path = [[openPanel filename] retain];
		[[NSUserDefaults standardUserDefaults] setObject:_path forKey:@"MIRCFolderPath"];
	}
}

- (IBAction)createArchive:(id)sender{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel beginSheetForDirectory:[self folder] 
		file:@"archive.zip" 
		modalForWindow:[self window]
		modalDelegate:self 
		didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:)
		contextInfo:nil];
}
	
- (void)savePanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo{
	if (returnCode == NSOKButton){
		//delete archive is present
		NSString *path = [sheet filename];
		if (![[path pathExtension] isEqualToString:@"zip"]) {
			path = [path stringByDeletingPathExtension];
			path = [path stringByAppendingPathExtension:@"zip"];
		}
			
		NSFileManager *manager = [NSFileManager defaultManager];
		if ([manager fileExistsAtPath:path])
			[manager removeFileAtPath:path handler:nil];
		//create Zip with NSTask
		NSTask *task = [[NSTask alloc] init];
		[task setCurrentDirectoryPath:[self folder]];
		[task setLaunchPath:@"/usr/bin/zip/"];
		NSMutableArray*args = [NSMutableArray arrayWithObject:path];
		[args addObjectsFromArray:[[NSFileManager defaultManager] directoryContentsAtPath:[self folder]]];
		[task setArguments:args];
		//NSLog(@"Create archive args: %@ path: %@", [args description], [self folder]);
		[task  launch];
		[task waitUntilExit];
		[task release];
	}
}

- (NSString *)caseName{
	return _caseName;
}

- (void) setCaseName: (NSString *)caseName{
//	NSLog(@"setCaseName: %@", caseName);
	[_caseName release];
	_caseName = [caseName retain];
	[tableView reloadData];
}

- (NSString *)path{
	if (!_path)
	_path = [[[NSUserDefaults standardUserDefaults] stringForKey:@"MIRCFolderPath"] retain];
	if (!_path)
		_path = [[_filter teachingFileFolder] retain];
	return _path;
}

- (NSString *)folder{
	return [_path stringByAppendingPathComponent:_caseName];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTable{
	return [[self directoryContents] count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex{
	return [[[self directoryContents] objectAtIndex:rowIndex] lastPathComponent];
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)operation{
		//NSLog(@"Dragging validate");
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    sourceDragMask = [info draggingSourceOperationMask];
    pboard = [info draggingPasteboard];
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        if (sourceDragMask & NSDragOperationLink) {
            return NSDragOperationLink;
        } else if (sourceDragMask & NSDragOperationCopy) {
            return NSDragOperationCopy;
        }
    }
    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation {
	//NSLog(@"perform drop");
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    sourceDragMask = [info draggingSourceOperationMask];
    pboard = [info draggingPasteboard];
	if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        // Depending on the dragging source and modifier keys,
        // the file data may be copied or linked
        if (sourceDragMask & NSDragOperationLink) {
            [self addFiles:files];
        }
    }
    return YES;
}

- (void)addFiles:(NSArray *)files{
	
	NSEnumerator *enumerator = [files objectEnumerator];
	NSString *file;
	while (file = [enumerator nextObject]){
		NSString *lastPathComponent = [file lastPathComponent];
		if ([self folder])
			[[NSFileManager defaultManager] copyPath:file toPath:[[self folder] stringByAppendingPathComponent:lastPathComponent] handler:nil];		
	}
	//[tableView reloadData];
}



- (NSArray *)directoryContents{
	return [[NSFileManager defaultManager] directoryContentsAtPath:[self folder]];
}

-(void)setDirectoryContents:(id)contents{
}

- (IBAction)getInfo:(id)sender{
	NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.macrad.mircplugin"];
	NSString *path = [bundle pathForResource:@"TheMIRCdocumentSchema" ofType:@"htm"];
	[[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:path]];
	/*
	if (!_webController)
		_webController = [[MIRCWebController alloc] initWithURL:[NSURL fileURLWithPath:path]];
	else
		[_webController setURL:[NSURL fileURLWithPath:path]];
	[_webController showWindow:nil];
	*/
}

- (NSArray *)teachingFiles{
	return _teachingFiles;
}
- (void)setTeachingFiles:(NSArray *)teachingFiles{
	[_teachingFiles release];
	_teachingFiles = [teachingFiles retain];
}


@end
