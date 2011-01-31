/*=========================================================================
 Program:   OsiriX
 
 Copyright (c) OsiriX Team
 All rights reserved.
 Distributed under GNU - LGPL
 
 See http://www.osirix-viewer.com/copyright.html for details.
 
 This software is distributed WITHOUT ANY WARRANTY; without even
 the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 PURPOSE.
 =========================================================================*/

#import "DicomDatabase.h"
#import "NSString+N2.h"
#import "NSUserDefaults+OsiriX.h"
#import "NSFileManager+N2.h"
#import "DicomAlbum.h"
#import "DicomFile.h"
#import "DicomSeries.h"
#import "DicomStudy.h"
#import "DicomImage.h"
#import "DCMObject.h"
#import "DCMTransferSyntax.h"
#import "AppController.h"
#import "NSException+N2.h"
#import "NSError+OsiriX.h"
#import "DCMAbstractSyntaxUID.h"
#import "Notifications.h"
#import "SRAnnotation.h"
#import "WaitRendering.h"
#import "ViewerController.h"

#undef verify
#include "osconfig.h" /* make sure OS specific configuration is included first */
#include "djdecode.h"  /* for dcmjpeg decoders */
#include "djencode.h"  /* for dcmjpeg encoders */
#include "dcrledrg.h"  /* for DcmRLEDecoderRegistration */
#include "dcrleerg.h"  /* for DcmRLEEncoderRegistration */
#include "djrploss.h"
#include "djrplol.h"
#include "dcpixel.h"
#include "dcrlerp.h"

#include "dcdatset.h"
#include "dcmetinf.h"
#include "dcfilefo.h"
#include "dcdebug.h"
#include "dcuid.h"
#include "dcdict.h"
#include "dcdeftag.h"

#import "Wait.h"


@implementation DicomDatabase

#define DATABASEVERSION @"2.5"

+(DicomDatabase*)defaultDatabase {
	@synchronized(self) {
		static DicomDatabase* database = NULL;
		if (!database)
			database = [[self alloc] initWithPath:NSUserDefaults.defaultDicomDatabasePath];
		return database;
	}
}

+(NSString*)baseDirectoryPathForMode:(NSInteger)mode path:(NSString*)path {
	NSError* err;
	
	switch (mode) {
		case 0:
			path = [NSFileManager.defaultManager findSystemFolderOfType:kDocumentsFolderType forDomain:kUserDomain];
			// no break
		case 1:
			path = [path stringByAppendingPathComponent:@"OsiriX Data"];
			break;
	}

	if (!path)
		NSLog(@"Warning: [DicomDatabase dicomDatabasePathForMode:%d path:%@] path is NULL", mode, path);

	if (path)
		[NSFileManager.defaultManager confirmDirectoryAtPath:path];
	
	return path;
	
}

+(NSManagedObjectModel*)model {
	static NSManagedObjectModel* model = NULL;
	if (!model)
		model = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:@"OsiriXDB_DataModel.momd"]]];
    return model;
}

-(NSManagedObjectModel*)model {
	return [DicomDatabase model];
}

-(NSMutableDictionary*)persistentStoreCoordinatorsDictionary {
	static NSMutableDictionary* dict = NULL;
	if (!dict)
		dict = [[NSMutableDictionary alloc] initWithCapacity:4];
	return dict;
}

-(NSString*)sqlFilePath {
	return [self.basePath stringByAppendingPathComponent:@"Database.sql"];
}

-(NSString*)versionFilePath {
	return [self.basePath stringByAppendingPathComponent:@"DB_VERSION"];
}

-(NSString*)databaseDirectoryPath {
	return [self.basePath stringByAppendingPathComponent:@"DATABASE.noindex"];
}

-(NSString*)decompressionDirectoryPath {
	return [self.basePath stringByAppendingPathComponent:@"DECOMPRESSION.noindex"];
}

-(NSString*)incomingDirectoryPath {
	return [self.basePath stringByAppendingPathComponent:@"INCOMING.noindex"];
}

-(NSString*)toBeIndexedDirectoryPath {
	return [self.basePath stringByAppendingPathComponent:@"TOBEINDEXED.noindex"];
}

-(NSString*)temporaryDirectoryPath {
	return [self.basePath stringByAppendingPathComponent:@"TEMP.noindex"];
}

-(NSString*)errDirectoryPath {
	return [self.basePath stringByAppendingPathComponent:@"NOT READABLE"];
}

-(NSString*)reportsDirectoryPath {
	return [self.basePath stringByAppendingPathComponent:@"REPORTS"];
}

-(NSString*)dumpDirectoryPath {
	return [self.basePath stringByAppendingPathComponent:@"DUMP"];
}

-(NSString*)htmlTemplatesDirectoryPath {
	return [self.basePath stringByAppendingPathComponent:@"HTML_TEMPLATES"];
}

-(NSString*)pagesTemplatesDirectoryPath {
	return [self.basePath stringByAppendingPathComponent:@"PAGES TEMPLATES"];
}

#pragma mark Initialization

-(BOOL)updateDatabaseModel :(NSString*)sqlFilePath :(NSString*)version {
	NSString* momFilename = [NSString stringWithFormat:@"OsiriXDB_Previous_DataModel%@.mom", version];
	if ([version isEqualToString:DATABASEVERSION]) 
		momFilename = [NSString stringWithFormat:@"OsiriXDB_DataModel.momd/OsiriXDB_DataModel.mom"];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:momFilename]]) {
		Wait* splash = [[Wait alloc] initWithString:NSLocalizedString(@"Updating database model...", nil)];
		[splash showWindow:self];
		@try {
	//		displayEmptyDatabase = YES;
	//		[self outlineViewRefresh];
	//		[self refreshMatrix: self];
			
	//		[checkIncomingLock lock];
			
	//		[managedObjectContext lock];
	//		[managedObjectContext retain];
			
			
			
			NSManagedObjectContext* currentContext = [[NSManagedObjectContext alloc] init];
			currentContext.persistentStoreCoordinator = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self model]] autorelease];
			currentContext.undoManager = NULL;
			
			NSManagedObjectModel* oldModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL: [NSURL fileURLWithPath: [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: momFilename]]] autorelease];
			NSManagedObjectContext* oldContext = [[NSManagedObjectContext alloc] init];
			oldContext.persistentStoreCoordinator = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: oldModel] autorelease];
			oldContext.undoManager = NULL;
			
			NSString* tempSqlFilePath = [sqlFilePath stringByAppendingPathExtension:@".transition"];
			[[NSFileManager defaultManager] removeItemAtPath:tempSqlFilePath error:NULL];
			[[NSFileManager defaultManager] removeItemAtPath:[tempSqlFilePath stringByAppendingString:@"-journal"] error: nil]; // ??
			
			NSFetchRequest* req;
			NSMutableString* updatingProblems = [NSMutableString string];
			NSError* error = NULL;
			
			if ([oldContext.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:sqlFilePath] options:nil error:&error] == nil)
				NSLog( @"****** previousSC addPersistentStoreWithType error: %@", error);
			
			if ([currentContext.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:tempSqlFilePath] options:nil error:&error] == nil)
				NSLog( @"****** currentSC addPersistentStoreWithType error: %@", error);
			
//			NSArray *albumProperties, *studyProperties, *seriesProperties, *imageProperties;
			
			// Albums
			
			NSArray* oldAlbumPropertyNames = [[[NSEntityDescription entityForName:@"Album" inManagedObjectContext:oldContext] attributesByName] allKeys];
			for (NSManagedObject* oldAlbum in [DicomDatabase albumsInContext:oldContext]) {
				DicomAlbum* currentAlbum = [NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext:currentContext];
				for (NSString* name in oldAlbumPropertyNames)
					[currentAlbum setValue:[oldAlbum valueForKey:name] forKey:name];
			}
			
			[currentContext save:NULL];
			
			// Studies
			
			req = [[[NSFetchRequest alloc] init] autorelease];
			req.entity = [NSEntityDescription entityForName:@"Study" inManagedObjectContext:oldContext];
			req.predicate = [NSPredicate predicateWithValue:YES];
			NSMutableArray* studies = [[[[oldContext executeFetchRequest:req error:NULL] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"patientID" ascending:YES] autorelease]]] mutableCopy] autorelease];
			
			[[splash progress] setMaxValue:studies.count];

			NSArray* oldStudyPropertyNames = [[[NSEntityDescription entityForName:@"Study" inManagedObjectContext:oldContext] attributesByName] allKeys];
			NSArray* oldSeriesPropertyNames = [[[NSEntityDescription entityForName:@"Series" inManagedObjectContext:oldContext] attributesByName] allKeys];
			NSArray* oldImagePropertyNames = [[[NSEntityDescription entityForName:@"Image" inManagedObjectContext:oldContext] attributesByName] allKeys];
			
			NSArray* currentAlbums = nil;
			NSArray* currentAlbumsNames = nil;

			int counter = 0;
			while (counter < studies.count) {
				NSAutoreleasePool* poolLoop = [[NSAutoreleasePool alloc] init];
				
				NSManagedObject *currentStudyTable, *currentSeriesTable, *currentImageTable;
				NSString* studyName = nil;
				
				@try
				{
					NSManagedObject *previousStudy = [studies lastObject];
					
					[studies removeLastObject];
					
					currentStudyTable = [NSEntityDescription insertNewObjectForEntityForName:@"Study" inManagedObjectContext: currentContext];
					
					for (NSString *name in oldStudyPropertyNames)
					{
						if( [name isEqualToString: @"isKeyImage"] || 
						   [name isEqualToString: @"comment"] ||
						   [name isEqualToString: @"comment2"] ||
						   [name isEqualToString: @"comment3"] ||
						   [name isEqualToString: @"comment4"] ||
						   [name isEqualToString: @"reportURL"] ||
						   [name isEqualToString: @"stateText"])
						{
							[currentStudyTable setPrimitiveValue: [previousStudy primitiveValueForKey: name] forKey: name];
						}
						else [currentStudyTable setValue: [previousStudy primitiveValueForKey: name] forKey: name];
						
						if( [name isEqualToString: @"name"])
							studyName = [previousStudy primitiveValueForKey: name];
					}
					
					// SERIES
					NSArray *series = [[previousStudy valueForKey:@"series"] allObjects];
					for( NSManagedObject *previousSeries in series)
					{
						NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
						
						@try
						{
							currentSeriesTable = [NSEntityDescription insertNewObjectForEntityForName:@"Series" inManagedObjectContext: currentContext];
							
							for( NSString *name in oldSeriesPropertyNames)
							{
								if( [name isEqualToString: @"xOffset"] || 
								   [name isEqualToString: @"yOffset"] || 
								   [name isEqualToString: @"scale"] || 
								   [name isEqualToString: @"rotationAngle"] || 
								   [name isEqualToString: @"displayStyle"] || 
								   [name isEqualToString: @"windowLevel"] || 
								   [name isEqualToString: @"windowWidth"] || 
								   [name isEqualToString: @"yFlipped"] || 
								   [name isEqualToString: @"xFlipped"])
								{
									
								}
								else if(  [name isEqualToString: @"isKeyImage"] || 
										[name isEqualToString: @"comment"] ||
										[name isEqualToString: @"comment2"] ||
										[name isEqualToString: @"comment3"] ||
										[name isEqualToString: @"comment4"] ||
										[name isEqualToString: @"reportURL"] ||
										[name isEqualToString: @"stateText"])
								{
									[currentSeriesTable setPrimitiveValue: [previousSeries primitiveValueForKey: name] forKey: name];
								}
								else [currentSeriesTable setValue: [previousSeries primitiveValueForKey: name] forKey: name];
							}
							[currentSeriesTable setValue: currentStudyTable forKey: @"study"];
							
							// IMAGES
							NSArray *images = [[previousSeries valueForKey:@"images"] allObjects];
							for ( NSManagedObject *previousImage in images)
							{
								@try
								{
									currentImageTable = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext: currentContext];
									
									for( NSString *name in oldImagePropertyNames)
									{
										if( [name isEqualToString: @"xOffset"] || 
										   [name isEqualToString: @"yOffset"] || 
										   [name isEqualToString: @"scale"] || 
										   [name isEqualToString: @"rotationAngle"] || 
										   [name isEqualToString: @"windowLevel"] || 
										   [name isEqualToString: @"windowWidth"] || 
										   [name isEqualToString: @"yFlipped"] || 
										   [name isEqualToString: @"xFlipped"])
										{
											
										}
										else if( [name isEqualToString: @"isKeyImage"] || 
												[name isEqualToString: @"comment"] ||
												[name isEqualToString: @"comment2"] ||
												[name isEqualToString: @"comment3"] ||
												[name isEqualToString: @"comment4"] ||
												[name isEqualToString: @"reportURL"] ||
												[name isEqualToString: @"stateText"])
										{
											[currentImageTable setPrimitiveValue: [previousImage primitiveValueForKey: name] forKey: name];
										}
										else [currentImageTable setValue: [previousImage primitiveValueForKey: name] forKey: name];
									}
									[currentImageTable setValue: currentSeriesTable forKey: @"series"];
								}
								
								@catch (NSException *e)
								{
									NSLog(@"IMAGE LEVEL: Problems during updating: %@", e);
									[e printStackTrace];
								}
							}
						}
						
						@catch (NSException *e)
						{
							NSLog(@"SERIES LEVEL: Problems during updating: %@", e);
							[e printStackTrace];
						}
						[pool release];
					}
					
					NSArray		*storedInAlbums = [[previousStudy valueForKey: @"albums"] allObjects];
					
					if( [storedInAlbums count])
					{
						if( currentAlbums == nil)
						{
							// Find all current albums
							NSFetchRequest *r = [[[NSFetchRequest alloc] init] autorelease];
							[r setEntity: [NSEntityDescription entityForName:@"Album" inManagedObjectContext:currentContext]];
							[r setPredicate: [NSPredicate predicateWithValue:YES]];
							
							currentAlbums = [currentContext executeFetchRequest:r error:NULL];
							currentAlbumsNames = [currentAlbums valueForKey:@"name"];
							
							[currentAlbums retain];
							[currentAlbumsNames retain];
						}
						
						@try
						{
							for( NSManagedObject *sa in storedInAlbums)
							{
								NSString *name = [sa valueForKey:@"name"];
								NSMutableSet *studiesStoredInAlbum = [[currentAlbums objectAtIndex: [currentAlbumsNames indexOfObject: name]] mutableSetValueForKey:@"studies"];
								
								[studiesStoredInAlbum addObject: currentStudyTable];
							}
						}
						
						@catch (NSException *e)
						{
							NSLog(@"ALBUM : %@", e);
							[e printStackTrace];
						}
					}
				}
				
				@catch (NSException * e)
				{
					NSLog(@"STUDY LEVEL: Problems during updating: %@", e);
					NSLog(@"Patient Name: %@", studyName);
					if( updatingProblems == nil) updatingProblems = [[NSMutableString stringWithString:@""] retain];
					
					[updatingProblems appendFormat:@"%@\r", studyName];
					
					[e printStackTrace];
				}
				
				[splash incrementBy:1];
				counter++;
				// NSLog(@"%d", counter);
				
				if (counter%100 == 0) { // free some memory
					[currentContext save:NULL];
					
					[currentContext reset];
					[oldContext reset];
					
					[currentAlbums release]; currentAlbums = nil;
					[currentAlbumsNames release]; currentAlbumsNames = nil;
					
			//		[studies release];
					
			//		studies = [NSMutableArray arrayWithArray: [oldContext executeFetchRequest:dbRequest error:NULL]];
					
			//		[[splash progress] setMaxValue:[studies count]];
					
			//		studies = [NSMutableArray arrayWithArray: [studies sortedArrayUsingDescriptors: [NSArray arrayWithObject: [[[NSSortDescriptor alloc] initWithKey:@"patientID" ascending:YES] autorelease]]]];
			//		if ([studies count] > 100) {
			//			int max = studies.count - chunk*100;
			//			if( max>100) max = 100;
			//			studies = [NSMutableArray arrayWithArray: [studies subarrayWithRange: NSMakeRange( chunk*100, max)]];
			//			chunk++;
			//		}
					
			//		[studies retain];
				}
				
				[poolLoop release];
			}
			
			[currentAlbums release];
			[currentAlbumsNames release];
			
			[currentContext save:NULL];
			
			[currentContext release];
			[oldContext release];

			[[NSFileManager defaultManager] removeItemAtPath:sqlFilePath error:NULL];
			[[NSFileManager defaultManager] moveItemAtPath:tempSqlFilePath toPath:sqlFilePath error:NULL];
			
			if (updatingProblems.length) {
				NSRunAlertPanel( NSLocalizedString(@"Database Update", nil), [NSString stringWithFormat:NSLocalizedString(@"Database updating generated errors. The corrupted studies have been removed:\r\r%@", nil), updatingProblems], nil, nil, nil);
				//NSRunAlertPanel( NSLocalizedString(@"Database Update", nil), NSLocalizedString(@"Database updating generated errors... The corrupted studies have been removed.", nil), nil, nil, nil);
			}
			
		//	[oldModel release];
			
			
		//	[currentContext release];
		//	[oldContext release];
			
			
//			displayEmptyDatabase = NO;
//			needDBRefresh = YES;
			
//			[managedObjectContext unlock];
//			[managedObjectContext release]; // For our local retain
			
//			[managedObjectContext release]; // For the global retain
//			managedObjectContext = nil;
			
//			[checkIncomingLock unlock];
			
			return YES;
		}
		
		@catch (NSException *e)
		{
			NSLog( @"updateDatabaseModel failed: %@", [e description]);
			[e printStackTrace];
//			NEEDTOREBUILD = YES;
//			COMPLETEREBUILD = YES;
			NSRunAlertPanel( NSLocalizedString(@"Database Update", nil), NSLocalizedString(@"Database updating failed... The database SQL index file is probably corrupted... The database will be reconstructed.", nil), nil, nil, nil);
		}
		@finally {
			[splash close];
			[splash release];
		}
	}
	else
	{
		int r = NSRunAlertPanel( NSLocalizedString(@"OsiriX Database", nil), NSLocalizedString(@"OsiriX cannot understand the model of current saved database... The database index will be deleted and reconstructed (no images are lost).", nil), NSLocalizedString(@"OK", nil), NSLocalizedString(@"Quit", nil), nil);
		if( r == NSAlertAlternateReturn)
		{
			// To avoid the crash message during next startup
			[NSFileManager.defaultManager removeItemAtPath:[self.basePath stringByAppendingString:@"/Loading"] error:NULL];
			[NSApplication.sharedApplication terminate:NULL];
		}
//		[[NSFileManager defaultManager] removeFileAtPath:sqlFilePath handler:nil];
//		NEEDTOREBUILD = YES;
//		COMPLETEREBUILD = YES;
	}
	
	return NO;
}

- (void) recomputePatientUIDs
{
//	NSLog(@"recomputePatientUIDs");
	
	NSFetchRequest* req = [[[NSFetchRequest alloc] init] autorelease];
	[req setEntity: [NSEntityDescription entityForName:@"Study" inManagedObjectContext:self.context]];
	[req setPredicate: [NSPredicate predicateWithValue:YES]];
	
	[self lock];

	for (NSManagedObject* study in [self.context executeFetchRequest:req error:NULL]) {
		@try {
			NSManagedObject* o = [[[[study valueForKey:@"series"] anyObject] valueForKey:@"images"] anyObject];
			DicomFile* dcm = [[DicomFile alloc] init: [o valueForKey:@"completePath"]];
			
			if( dcm)
			{
				if( [dcm elementForKey:@"patientUID"])
					[study setValue: [dcm elementForKey:@"patientUID"] forKey:@"patientUID"];
			}
			
			[dcm release];
		}
		@catch (NSException* e)
		{
			NSLog( @"recomputePatientUIDs exception : %@", e);
			[e printStackTrace];
		}
	}
	
	[self unlock];
}


-(id)initWithPath:(NSString*)p {
	self = [super initWithPath:p];
	
	[NSFileManager.defaultManager confirmNoIndexDirectoryAtPath:self.databaseDirectoryPath];
	[NSFileManager.defaultManager confirmNoIndexDirectoryAtPath:self.decompressionDirectoryPath];
	[NSFileManager.defaultManager confirmNoIndexDirectoryAtPath:self.incomingDirectoryPath];
	[NSFileManager.defaultManager confirmNoIndexDirectoryAtPath:self.toBeIndexedDirectoryPath];
	[NSFileManager.defaultManager confirmNoIndexDirectoryAtPath:self.temporaryDirectoryPath];
	[NSFileManager.defaultManager confirmDirectoryAtPath:self.errDirectoryPath];
	[NSFileManager.defaultManager confirmDirectoryAtPath:self.reportsDirectoryPath];
	[NSFileManager.defaultManager confirmDirectoryAtPath:self.dumpDirectoryPath];
	[NSFileManager.defaultManager confirmDirectoryAtPath:self.htmlTemplatesDirectoryPath];
	
	[NSFileManager.defaultManager moveItemAtPath:self.toBeIndexedDirectoryPath toPath:[self.incomingDirectoryPath stringByAppendingPathComponent:@"TOBEINDEXED.noindex"] error:NULL];
	
	// check for report templates
	for (NSString* reportFilename in [NSArray arrayWithObjects: @"ReportTemplate.doc", @"ReportTemplate.rtf", @"ReportTemplate.odt", NULL]) {
		NSString* reportFilepath = [self.basePath stringByAppendingPathComponent:reportFilename];
		if (![NSFileManager.defaultManager fileExistsAtPath:reportFilepath])
			[NSFileManager.defaultManager copyItemAtPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:reportFilename] toPath:reportFilepath error:NULL];
	}
	
	// check for HTML templates
	for (NSString* templateFilename in [NSArray arrayWithObjects: @"QTExportPatientsTemplate.html", @"QTExportStudiesTemplate.html", @"QTExportSeriesTemplate.html", NULL]) {
		NSString* templateFilepath = [self.htmlTemplatesDirectoryPath stringByAppendingPathComponent:templateFilename];
		if (![NSFileManager.defaultManager fileExistsAtPath:templateFilepath])
			[NSFileManager.defaultManager copyItemAtPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:templateFilename] toPath:templateFilepath error:NULL];
	}
	NSString* htmlExtraDirectoryPath = [NSFileManager.defaultManager confirmDirectoryAtPath:[self.htmlTemplatesDirectoryPath stringByAppendingPathComponent:@"html-extra"]];
	NSString* cssFilepath = [htmlExtraDirectoryPath stringByAppendingPathComponent:@"style.css"];
	if (![NSFileManager.defaultManager fileExistsAtPath:cssFilepath])
		[NSFileManager.defaultManager copyItemAtPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"QTExportStyle.css"] toPath:cssFilepath error:NULL];
	
	// cherk for pages templates - creation of the alias to the iWork template folder if needed
	if(![NSFileManager.defaultManager fileExistsAtPath:self.pagesTemplatesDirectoryPath])
		[NSFileManager.defaultManager createSymbolicLinkAtPath:self.pagesTemplatesDirectoryPath pathContent:AppController.pagesEnglishOsirixTemplatesDirectoryPath];
	
	return self;
}

-(void)dealloc {
	NSString* temp;
	
	temp = [self temporaryDirectoryPath];
	[NSFileManager.defaultManager removeItemAtPath:temp error:NULL];
	[NSFileManager.defaultManager removeItemAtPath:[temp stringByDeletingPathExtension] error:NULL];
	temp = [self dumpDirectoryPath];
	[NSFileManager.defaultManager removeItemAtPath:temp error:NULL];
	temp = [self decompressionDirectoryPath];
	[NSFileManager.defaultManager removeItemAtPath:temp error:NULL];
	[NSFileManager.defaultManager removeItemAtPath:[temp stringByDeletingPathExtension] error:NULL];
	
	[super dealloc];
}



#pragma mark Albums

+(NSPredicate*)predicateForSmartAlbumFilter:(NSString*)string {
	if (!string.length)
		return [NSPredicate predicateWithValue:YES];
	
	NSMutableString* pred = [NSMutableString stringWithString: string];
	
	// DATES
	NSCalendarDate* now = [NSCalendarDate calendarDate];
	NSCalendarDate* start = [NSCalendarDate dateWithYear:[now yearOfCommonEra] month:[now monthOfYear] day:[now dayOfMonth] hour:0 minute:0 second:0 timeZone: [now timeZone]];
	NSDictionary* sub = [NSDictionary dictionaryWithObjectsAndKeys:
						 [NSString stringWithFormat:@"\"%@\"", [now addTimeInterval: -60*60*1] ],			@"$LASTHOUR",
						 [NSString stringWithFormat:@"\"%@\"", [now addTimeInterval: -60*60*6] ],			@"$LAST6HOURS",
						 [NSString stringWithFormat:@"\"%@\"", [now addTimeInterval: -60*60*12] ],			@"$LAST12HOURS",
						 [NSString stringWithFormat:@"\"%@\"", start ],										@"$TODAY",
						 [NSString stringWithFormat:@"\"%@\"", [start addTimeInterval: -60*60*24] ],		@"$YESTERDAY",
						 [NSString stringWithFormat:@"\"%@\"", [start addTimeInterval: -60*60*24*2] ],		@"$2DAYS",
						 [NSString stringWithFormat:@"\"%@\"", [start addTimeInterval: -60*60*24*7] ],		@"$WEEK",
						 [NSString stringWithFormat:@"\"%@\"", [start addTimeInterval: -60*60*24*31] ],		@"$MONTH",
						 [NSString stringWithFormat:@"\"%@\"", [start addTimeInterval: -60*60*24*31*2] ],	@"$2MONTHS",
						 [NSString stringWithFormat:@"\"%@\"", [start addTimeInterval: -60*60*24*31*3] ],	@"$3MONTHS",
						 [NSString stringWithFormat:@"\"%@\"", [start addTimeInterval: -60*60*24*365] ],	@"$YEAR",
						 nil];
	
	for (NSString* key in sub)
		[pred replaceOccurrencesOfString:key withString:[sub valueForKey:key] options:NSCaseInsensitiveSearch range:pred.range];
	
	return [NSPredicate predicateWithFormat:pred];
}

+(NSArray*)albumsInContext:(NSManagedObjectContext*)context {
	NSFetchRequest* req = [[[NSFetchRequest alloc] init] autorelease];
	req.entity = [NSEntityDescription entityForName:@"Album" inManagedObjectContext:context];
	req.predicate = [NSPredicate predicateWithValue:YES];
	return [context executeFetchRequest:req error:NULL];	
}

-(NSArray*)albums {
	[context lock];
	@try {
		NSArray* albums = [DicomDatabase albumsInContext:self.context];
		
		NSSortDescriptor* sd = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)] autorelease];
		albums = [albums sortedArrayUsingDescriptors:[NSArray arrayWithObject: sd]];
		
		return [[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:NSLocalizedString(@"Database", nil) forKey:@"name"]] arrayByAddingObjectsFromArray:albums];
	} @catch (NSException* e) {
		NSLog(@"Exception: [DicomDatabase albums] %@", e);
	} @finally {
		[context unlock];
	}
	
	return NULL;
}

-(void)addDefaultAlbums {
	NSArray* albumsNames = [self.albums valueForKey:@"name"];
	
	if ([albumsNames indexOfObject:NSLocalizedString(@"Just Added", nil)] == NSNotFound)
	{
		DicomAlbum* album = [NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext:self.context];
		album.name = NSLocalizedString( @"Just Added", nil);
		album.predicateString = @"(dateAdded >= CAST($LASTHOUR, 'NSDate'))";
		album.smartAlbum = [NSNumber numberWithBool: YES];
	}
	
	if ([albumsNames indexOfObject:NSLocalizedString(@"Today MR", nil)] == NSNotFound)
	{
		DicomAlbum* album = [NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext:self.context];
		album.name = NSLocalizedString( @"Today MR", nil);
		album.predicateString = @"(ANY series.modality CONTAINS[cd] 'MR') AND (date >= CAST($TODAY, 'NSDate'))";
		album.smartAlbum = [NSNumber numberWithBool: YES];
	}
	
	if ([albumsNames indexOfObject:NSLocalizedString(@"Today CT", nil)] == NSNotFound)
	{
		DicomAlbum* album = [NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext:self.context];
		album.name = NSLocalizedString( @"Today CT", nil);
		album.predicateString = @"(ANY series.modality CONTAINS[cd] 'CT') AND (date >= CAST($TODAY, 'NSDate'))";
		album.smartAlbum = [NSNumber numberWithBool: YES];
	}
	
	if ([albumsNames indexOfObject:NSLocalizedString(@"Yesterday MR", nil)] == NSNotFound)
	{
		DicomAlbum* album = [NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext:self.context];
		album.name = NSLocalizedString( @"Yesterday MR", nil);
		album.predicateString = @"(ANY series.modality CONTAINS[cd] 'MR') AND (date >= CAST($YESTERDAY, 'NSDate') AND date <= CAST($TODAY, 'NSDate'))";
		album.smartAlbum = [NSNumber numberWithBool: YES];
	}
	
	if ([albumsNames indexOfObject:NSLocalizedString(@"Yesterday CT", nil)] == NSNotFound)
	{
		DicomAlbum* album = [NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext:self.context];
		album.name = NSLocalizedString( @"Yesterday CT", nil);
		album.predicateString = @"(ANY series.modality CONTAINS[cd] 'CT') AND (date >= CAST($YESTERDAY, 'NSDate') AND date <= CAST($TODAY, 'NSDate'))";
		album.smartAlbum = [NSNumber numberWithBool: YES];
	}
	
	if ([albumsNames indexOfObject:NSLocalizedString(@"Interesting Cases", nil)] == NSNotFound)
	{
		DicomAlbum* album = [NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext:self.context];
		album.name = NSLocalizedString( @"Interesting Cases", nil);
	}
	
	if ([albumsNames indexOfObject:NSLocalizedString(@"Cases with comments", nil)] == NSNotFound)
	{
		DicomAlbum* album = [NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext:self.context];
		album.name = NSLocalizedString( @"Cases with comments", nil);
		album.predicateString = @"(ANY series.comment != '' AND ANY series.comment != NIL) OR (comment != '' AND comment != NIL)";
		album.smartAlbum = [NSNumber numberWithBool: YES];
	}
}	


#pragma mark Add files

//#define DEFAULTUSERDATABASEPATH @"~/Library/Application Support/OsiriX/WebUsers.sql"
//#define DATABASEVERSION @"2.5"
//#define DATABASEPATH @"/DATABASE.noindex/"
//#define DECOMPRESSIONPATH @"/DECOMPRESSION.noindex/"
//#define INCOMINGPATH @"/INCOMING.noindex/"
//#define TOBEINDEXED @"/TOBEINDEXED.noindex/"
//#define ERRPATH @"/NOT READABLE/"
//#define DATABASEFPATH @"/DATABASE.noindex"
//#define DATAFILEPATH @"/Database.sql"


// TODO: these static methods should move away
+ (BOOL) unzipFile: (NSString*) file withPassword: (NSString*) pass destination: (NSString*) destination showGUI: (BOOL) showGUI
{
	[[NSFileManager defaultManager] removeFileAtPath: destination handler: nil];
	
	NSTask *t;
	NSArray *args;
	WaitRendering *wait = nil;
	
	if( [NSThread isMainThread] && showGUI == YES)
	{
		wait = [[WaitRendering alloc] init: NSLocalizedString(@"Decompressing the files...", nil)];
		[wait showWindow:self];
	}
	
	t = [[[NSTask alloc] init] autorelease];
	
	@try
	{
		[t setLaunchPath: @"/usr/bin/unzip"];
		
		if( [[NSFileManager defaultManager] fileExistsAtPath: @"/tmp/"] == NO)
			[[NSFileManager defaultManager] createDirectoryAtPath: @"/tmp/" attributes: nil];
		
		[t setCurrentDirectoryPath: @"/tmp/"];
		if( pass)
			args = [NSArray arrayWithObjects: @"-qq", @"-o", @"-d", destination, @"-P", pass, file, nil];
		else
			args = [NSArray arrayWithObjects: @"-qq", @"-o", @"-d", destination, file, nil];
		[t setArguments: args];
		[t launch];
		[t waitUntilExit];
	}
	@catch ( NSException *e)
	{
		NSLog( @"***** unzipFile exception: %@", e);
		[e printStackTrace];
	}
	
	[wait close];
	[wait release];
	
	BOOL fileExist = NO;
	
	NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath: destination];
	NSString *item = nil;
	while( item = [dirEnum nextObject])
	{
		BOOL isDirectory;
		if( [[NSFileManager defaultManager] fileExistsAtPath: [destination stringByAppendingPathComponent: item] isDirectory: &isDirectory])
		{
			if( isDirectory == NO && [[[[NSFileManager defaultManager] attributesOfItemAtPath: [destination stringByAppendingPathComponent: item] error: nil] valueForKey: NSFileSize] longLongValue] > 0)
			{
				fileExist = YES;
				break;
			}
		}
	}
	
	if( fileExist)
	{
		// Is it on writable media? Ask if the user want to delete the original file?
		
		if( [NSThread isMainThread] && [[NSFileManager defaultManager] isWritableFileAtPath: file] && showGUI == YES)
		{
			if ([[NSUserDefaults standardUserDefaults] boolForKey: @"HideZIPSuppressionMessage"] == NO)
			{
				NSAlert* alert = [[NSAlert new] autorelease];
				[alert setMessageText: NSLocalizedString(@"Delete ZIP file", nil)];
				[alert setInformativeText: NSLocalizedString(@"The ZIP file was successfully decompressed and the images successfully incorporated in OsiriX database. Should I delete the ZIP file?", nil)];
				[alert setShowsSuppressionButton: YES];
				[alert addButtonWithTitle: NSLocalizedString( @"OK", nil)];
				[alert addButtonWithTitle: NSLocalizedString( @"Cancel", nil)];
				int result = [alert runModal];
				
				if( result == NSAlertFirstButtonReturn)
					[[NSUserDefaults standardUserDefaults] setBool: YES forKey: @"deleteZIPfile"];
				else
					[[NSUserDefaults standardUserDefaults] setBool: NO forKey: @"deleteZIPfile"];
				
				if ([[alert suppressionButton] state] == NSOnState)
					[[NSUserDefaults standardUserDefaults] setBool:YES forKey: @"HideZIPSuppressionMessage"];
			}
			
			if( [[NSUserDefaults standardUserDefaults] boolForKey: @"deleteZIPfile"]) 
				[[NSFileManager defaultManager] removeItemAtPath: file error: nil];
		}
		return YES;
	}
	
	return NO;
}

+ (BOOL) unzipFile: (NSString*) file withPassword: (NSString*) pass destination: (NSString*) destination
{
	return [self unzipFile:  file withPassword:  pass destination:  destination showGUI: YES];
}

+ (NSString*) extractReportSR: (NSString*) dicomSR contentDate: (NSDate*) date
{
	NSString *destPath = nil;
	NSString *uidName = [SRAnnotation getReportFilenameFromSR: dicomSR];
	if( [uidName length] > 0)
	{
		NSString *zipFile = [@"/tmp/" stringByAppendingPathComponent: uidName];
		
		// Extract the CONTENT to the REPORTS folder
		SRAnnotation *r = [[[SRAnnotation alloc] initWithContentsOfFile: dicomSR] autorelease];
		[[NSFileManager defaultManager] removeFileAtPath: zipFile handler: nil];
		
		// Check for http/https !
		if( [[r reportURL] length] > 8 && ([[r reportURL] hasPrefix: @"http://"] || [[r reportURL] hasPrefix: @"https://"]))
			destPath = [[[r reportURL] copy] autorelease];
		else
		{
			if( [[r dataEncapsulated] length] > 0)
			{
				[[r dataEncapsulated] writeToFile: zipFile atomically: YES];
				
				[[NSFileManager defaultManager] removeFileAtPath: @"/tmp/zippedFile/" handler: nil];
				[self unzipFile: zipFile withPassword: nil destination: @"/tmp/zippedFile/" showGUI: NO];
				[[NSFileManager defaultManager] removeFileAtPath: zipFile handler: nil];
				
				for( NSString *f in [[NSFileManager defaultManager] contentsOfDirectoryAtPath: @"/tmp/zippedFile/" error: nil])
				{
					if( [f hasPrefix: @"."] == NO)
					{
						if( destPath)
							NSLog( @"*** multiple files in Report decompression ?");
						
						destPath = [@"/tmp/" stringByAppendingPathComponent: f];
						if( destPath)
						{
							[[NSFileManager defaultManager] removeItemAtPath: destPath error: nil];
							[[NSFileManager defaultManager] moveItemAtPath: [@"/tmp/zippedFile/" stringByAppendingPathComponent: f] toPath: destPath error: nil];
						}
					}
				}
			}
		}
	}
	
	[[NSFileManager defaultManager] removeFileAtPath: @"/tmp/zippedFile/" handler: nil];
	
	if( destPath)
		[[NSFileManager defaultManager] setAttributes: [NSDictionary dictionaryWithObjectsAndKeys: date, NSFileModificationDate, nil] ofItemAtPath: destPath error: nil];
	
	return destPath;
}

-(NSArray*)addFiles:(NSArray*)newFilesArray onlyDICOM:(BOOL)onlyDICOM notifyAddedFiles:(BOOL)notifyAddedFiles parseExistingObject:(BOOL)parseExistingObject
{
	return [self addFiles:newFilesArray onlyDICOM:onlyDICOM notifyAddedFiles:notifyAddedFiles parseExistingObject:parseExistingObject generatedByOsiriX:NO mountedVolume:NO];
}

-(NSArray*)addFiles:(NSArray*)newFilesArray onlyDICOM:(BOOL)onlyDICOM notifyAddedFiles:(BOOL)notifyAddedFiles parseExistingObject:(BOOL)parseExistingObject generatedByOsiriX:(BOOL)generatedByOsiriX
{
	return [self addFiles:newFilesArray onlyDICOM:onlyDICOM notifyAddedFiles:notifyAddedFiles parseExistingObject:parseExistingObject generatedByOsiriX:generatedByOsiriX mountedVolume:NO];
}



// removed: toContext: (NSManagedObjectContext*) context toDatabase: (BrowserController*) browserController  dbFolder:(NSString*)dbFolder
-(NSArray*)addFiles:(NSArray*)newFilesArray onlyDICOM:(BOOL)onlyDICOM notifyAddedFiles:(BOOL)notifyAddedFiles parseExistingObject:(BOOL)parseExistingObject generatedByOsiriX:(BOOL)generatedByOsiriX mountedVolume:(BOOL)mountedVolume
{
	if (newFilesArray.count == 0)
		return [NSMutableArray array];
	
	NSDate *today = [NSDate date];
	NSError *error = nil;
	NSString *curPatientUID = nil, *curStudyID = nil, *curSerieID = nil, *newFile,
		*ERRpath = self.errDirectoryPath,
		*dbDirectory = self.databaseDirectoryPath,
		*reportsDirectory = self.reportsDirectoryPath,
		*tempDirectory = self.temporaryDirectoryPath;
	
	NSInteger index;
	Wait *splash = nil;
	NSManagedObjectModel *model = context.persistentStoreCoordinator.managedObjectModel;
	NSMutableArray *addedImagesArray = nil, *completeImagesArray = nil, *addedSeries = [NSMutableArray array], *modifiedStudiesArray = nil;
	BOOL DELETEFILELISTENER = [[NSUserDefaults standardUserDefaults] boolForKey: @"DELETEFILELISTENER"], COMMENTSAUTOFILL = [[NSUserDefaults standardUserDefaults] boolForKey: @"COMMENTSAUTOFILL"], newStudy = NO, newObject = NO, isCDMedia = NO, addFailed = NO;
	NSMutableArray *vlToRebuild = [NSMutableArray array], *vlToReload = [NSMutableArray array], *dicomFilesArray = [NSMutableArray arrayWithCapacity: [newFilesArray count]];
	int combineProjectionSeries = [[NSUserDefaults standardUserDefaults] boolForKey: @"combineProjectionSeries"], combineProjectionSeriesMode = [[NSUserDefaults standardUserDefaults] boolForKey: @"combineProjectionSeriesMode"];
//	BOOL isBonjour = [browserController isBonjour: context];
//	NSMutableArray *bonjourFilesToSend = nil;
	
//	if( isBonjour)
//		bonjourFilesToSend = [NSMutableArray array];
	
	[NSFileManager.defaultManager confirmDirectoryAtPath:dbDirectory];
	[NSFileManager.defaultManager confirmDirectoryAtPath:reportsDirectory];
	
	//	if( [[NSUserDefaults standardUserDefaults] boolForKey: @"onlyDICOM"]) onlyDICOM = YES;
	
//#define RANDOMFILES
#ifdef RANDOMFILES
	NSMutableArray	*randomArray = [NSMutableArray array];
	for( int i = 0; i < 50000; i++)
		[randomArray addObject:@"yahoo/google/osirix/microsoft"];
	newFilesArray = randomArray;
#endif
	
	/*if ([NSThread isMainThread]) // TODO: re-enable this
	{
		isCDMedia = [BrowserController isItCD: [newFilesArray objectAtIndex: 0]];
		
		[DicomFile setFilesAreFromCDMedia: isCDMedia];
		
		if (([newFilesArray count] > 50 || isCDMedia == YES) && generatedByOsiriX == NO)
		{
			splash = [[Wait alloc] initWithString: [NSString stringWithFormat: NSLocalizedString(@"Adding %@ file(s)...", nil), [decimalNumberFormatter stringForObjectValue:[NSNumber numberWithInt:[newFilesArray count]]]]];
			[splash showWindow: browserController];
			
			if( isCDMedia) [[splash progress] setMaxValue:[newFilesArray count]];
			else [[splash progress] setMaxValue:[newFilesArray count]/30];
			
			[splash setCancel: YES];
		}
	}*/
	
	int ii = 0;
	for (newFile in newFilesArray)
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		@try
		{
			DicomFile *curFile = nil;
			NSMutableDictionary	*curDict = nil;
			
			@try
			{
#ifdef RANDOMFILES
				curFile = [[DicomFile alloc] initRandom];
#else
				curFile = [[DicomFile alloc] init: newFile];
#endif
			}
			@catch (NSException * e)
			{
				NSLog( @"*** exception [[DicomFile alloc] init: newFile] : %@", e);
				[e printStackTrace];
			}
			
			if( curFile)
			{
				curDict = [curFile dicomElements];
				
				if( onlyDICOM)
				{
					if( [[curDict objectForKey: @"fileType"] hasPrefix:@"DICOM"] == NO)
						curDict = nil;
				}
				
				if( curDict)
				{
					[dicomFilesArray addObject: curDict];
				}
				else
				{
					// This file was not readable -> If it is located in the DATABASE folder, we have to delete it or to move it to the 'NOT READABLE' folder
					if( dbDirectory && [newFile hasPrefix: dbDirectory])
					{
						NSLog(@"**** Unreadable file: %@", newFile);
						
						if ( DELETEFILELISTENER)
						{
							[[NSFileManager defaultManager] removeFileAtPath: newFile handler:nil];
						}
						else
						{
							NSLog(@"**** This file in the DATABASE folder: move it to the unreadable folder");
							
							if( [[NSFileManager defaultManager] movePath: newFile toPath:[ERRpath stringByAppendingPathComponent: [newFile lastPathComponent]]  handler:nil] == NO)
								[[NSFileManager defaultManager] removeFileAtPath: newFile handler:nil];
						}
					}
				}
				
				[curFile release];
			}
			
			if( splash)
			{
				if( isCDMedia)
				{
					ii++;
					[splash incrementBy:1];
				}
				else
				{
					if( (ii++) % 30 == 0)
						[splash incrementBy:1];
				}
			}
		}
		
		@catch (NSException * e)
		{
			NSLog( @"**** addFilesToDatabase exception : DicomFile alloc : %@", e);
			[e printStackTrace];
		}
		
		[pool release];
		
		if( [splash aborted]) break;
	}
	
	[context retain];
	[context lock];
	
	// Find all current studies
	
	NSFetchRequest *dbRequest = [[[NSFetchRequest alloc] init] autorelease];
	[dbRequest setEntity: [[model entitiesByName] objectForKey: @"Study"]];
	[dbRequest setPredicate: [NSPredicate predicateWithValue: YES]];
	error = nil;
	NSMutableArray *studiesArray = nil;
	
	@try
	{
		studiesArray = [[context executeFetchRequest:dbRequest error:&error] mutableCopy];
	}
	@catch( NSException *ne)
	{
		NSLog( @"AddFilesToDatabase executeFetchRequest exception: %@", [ne description]);
		NSLog( @"executeFetchRequest failed for studiesArray.");
		error = [NSError errorWithDomain:OsirixErrorDomain code:1 userInfo:NULL];
		[ne printStackTrace];
	}
	
	if (error)
	{
		NSLog( @"addFilesToDatabase ERROR: %@", [error localizedDescription]);
		
		[context unlock];
		[context release];
		
		//All these files were NOT saved..... due to an error. Move them back to the INCOMING folder.
		addFailed = YES;
	}
	else
	{
		addedImagesArray = [NSMutableArray arrayWithCapacity: [newFilesArray count]];
		completeImagesArray = [NSMutableArray arrayWithCapacity: [newFilesArray count]];
		modifiedStudiesArray = [NSMutableArray array];
		
		DicomStudy *study = nil;
		DicomSeries *seriesTable = nil;
		DicomImage *image = nil;
		NSMutableArray *studiesArrayStudyInstanceUID = [[studiesArray valueForKey:@"studyInstanceUID"] mutableCopy];
		
		// Add the new files
		for (NSMutableDictionary *curDict in dicomFilesArray)
		{
			@try
			{
				newFile = [curDict objectForKey:@"filePath"];
				
				BOOL DICOMSR = NO;
				BOOL inParseExistingObject = parseExistingObject;
				
				NSString *SOPClassUID = [curDict objectForKey:@"SOPClassUID"];
				
				if( [DCMAbstractSyntaxUID isStructuredReport: SOPClassUID])
				{
					// Check if it is an OsiriX Annotations SR
					if( [[curDict valueForKey:@"seriesDescription"] isEqualToString: @"OsiriX Annotations SR"])
					{
						[curDict setValue: @"OsiriX Annotations SR" forKey: @"seriesID"];
						inParseExistingObject = YES;
						DICOMSR = YES;
					}
					
					// Check if it is an OsiriX ROI SR
					if( [[curDict valueForKey:@"seriesDescription"] isEqualToString: @"OsiriX ROI SR"])
					{
						[curDict setValue: @"OsiriX ROI SR" forKey: @"seriesID"];
						
						inParseExistingObject = YES;
						DICOMSR = YES;
					}
					
					// Check if it is an OsiriX Report SR
					if( [[curDict valueForKey:@"seriesDescription"] isEqualToString: @"OsiriX Report SR"])
					{
						[curDict setValue: @"OsiriX Report SR" forKey: @"seriesID"];
						
						inParseExistingObject = YES;
						DICOMSR = YES;
					}
				}
				
				if( SOPClassUID != nil 
				   && [DCMAbstractSyntaxUID isImageStorage: SOPClassUID] == NO 
				   && [DCMAbstractSyntaxUID isRadiotherapy: SOPClassUID] == NO
				   && [DCMAbstractSyntaxUID isStructuredReport: SOPClassUID] == NO
				   && [DCMAbstractSyntaxUID isKeyObjectDocument: SOPClassUID] == NO
				   && [DCMAbstractSyntaxUID isPresentationState: SOPClassUID] == NO
				   && [DCMAbstractSyntaxUID isSupportedPrivateClasses: SOPClassUID] == NO)
				{
					NSLog(@"unsupported DICOM SOP CLASS (%@)-> Reject the file : %@", SOPClassUID, newFile);
					curDict = nil;
				}
				
				if( [curDict objectForKey:@"SOPClassUID"] == nil && [[curDict objectForKey: @"fileType"] hasPrefix:@"DICOM"] == YES)
				{
					NSLog(@"no DICOM SOP CLASS -> Reject the file: %@", newFile);
					curDict = nil;
				}
				
				if( curDict != nil)
				{
					if( [[curDict objectForKey: @"studyID"] isEqualToString: curStudyID] == YES && [[curDict objectForKey: @"patientUID"] caseInsensitiveCompare: curPatientUID] == NSOrderedSame)
					{
						if( [[study valueForKey: @"modality"] isEqualToString: @"SR"] || [[study valueForKey: @"modality"] isEqualToString: @"OT"])
							[study setValue: [curDict objectForKey: @"modality"] forKey:@"modality"];
					}
					else
					{
						/*******************************************/
						/*********** Find study object *************/
						// match: StudyInstanceUID and patientUID (see patientUID function in dicomFile.m, based on patientName, patientID and patientBirthDate)
						study = nil;
						curSerieID = nil;
						
						index = [studiesArrayStudyInstanceUID indexOfObject:[curDict objectForKey: @"studyID"]];
						
						if( index != NSNotFound)
						{
							if( [[curDict objectForKey: @"fileType"] hasPrefix:@"DICOM"] == NO) // We do this double check only for DICOM files.
							{
								study = [studiesArray objectAtIndex: index];
							}
							else
							{
								if( [[curDict objectForKey: @"patientUID"] caseInsensitiveCompare: [[studiesArray objectAtIndex: index] valueForKey: @"patientUID"]] == NSOrderedSame)
									study = [studiesArray objectAtIndex: index];
								else
								{
									NSLog( @"-*-*-*-*-* same studyUID (%@), but not same patientUID (%@ versus %@)", [curDict objectForKey: @"studyID"], [curDict objectForKey: @"patientUID"], [[studiesArray objectAtIndex: index] valueForKey: @"patientUID"]);
									
									NSString *curUID = [curDict objectForKey: @"studyID"];
									for( int i = 0 ; i < [studiesArrayStudyInstanceUID count]; i++)
									{
										NSString *uid = [studiesArrayStudyInstanceUID objectAtIndex: i];
										
										if( [uid isEqualToString: curUID])
										{
											if( [[curDict objectForKey: @"patientUID"] caseInsensitiveCompare: [[studiesArray objectAtIndex: i] valueForKey: @"patientUID"]] == NSOrderedSame)
												study = [studiesArray objectAtIndex: i];
										}
									}
								}
							}
						}
						
						if( study == nil)
						{
							// Fields
							study = [NSEntityDescription insertNewObjectForEntityForName:@"Study" inManagedObjectContext: context];
							
							newObject = YES;
							newStudy = YES;
							
							[study setValue:today forKey:@"dateAdded"];
							
							[studiesArray addObject: study];
							[studiesArrayStudyInstanceUID addObject: [curDict objectForKey: @"studyID"]];
							
							curSerieID = nil;
						}
						else
						{
							newObject = NO;
						}
						
						if( newObject || inParseExistingObject)
						{
							study.studyInstanceUID = [curDict objectForKey: @"studyID"];
							study.accessionNumber = [curDict objectForKey: @"accessionNumber"];
							study.modality = [curDict objectForKey: @"modality"];
							study.dateOfBirth = [curDict objectForKey: @"patientBirthDate"];
							study.patientSex = [curDict objectForKey: @"patientSex"];
							study.patientID = [curDict objectForKey: @"patientID"];
							study.name = [curDict objectForKey: @"patientName"];
							study.patientUID = [curDict objectForKey: @"patientUID"];
							study.id = [curDict objectForKey: @"studyNumber"];
							
							if( [DCMAbstractSyntaxUID isStructuredReport: SOPClassUID] && inParseExistingObject)
							{
								if( [(NSString*)[curDict objectForKey: @"studyDescription"] length])
									study.studyName = [curDict objectForKey: @"studyDescription"];
								if( [(NSString*)[curDict objectForKey: @"referringPhysiciansName"] length])
									study.referringPhysician = [curDict objectForKey: @"referringPhysiciansName"];
								if( [(NSString*)[curDict objectForKey: @"performingPhysiciansName"] length])
									study.performingPhysician = [curDict objectForKey: @"performingPhysiciansName"];
								if( [(NSString*)[curDict objectForKey: @"institutionName"] length])
									study.institutionName = [curDict objectForKey: @"institutionName"];
							}
							else
							{
								study.studyName = [curDict objectForKey: @"studyDescription"];
								study.referringPhysician = [curDict objectForKey: @"referringPhysiciansName"];
								study.performingPhysician = [curDict objectForKey: @"performingPhysiciansName"];
								study.institutionName = [curDict objectForKey: @"institutionName"];
							}
							
							//need to know if is DICOM so only DICOM is queried for Q/R
							if ([curDict objectForKey: @"hasDICOM"])
								study.hasDICOM = [curDict objectForKey: @"hasDICOM"];
							
							if (newObject)
								[self checkForExistingReport:study];
						}
						else
						{
							if ([study.modality isEqualToString:@"SR"] || [study.modality isEqualToString:@"OT"])
								study.modality = [curDict objectForKey:@"modality"];
							if (!study.studyName.length || [study.studyName isEqualToString:@"unnamed"])
								study.studyName = [curDict objectForKey: @"studyDescription"];
						}
						
						if ([curDict objectForKey:@"studyDate"])
							if (!study.date || [study.date timeIntervalSinceDate:[curDict objectForKey:@"studyDate"]] >= 0)
								study.date = [curDict objectForKey: @"studyDate"];
						
						curStudyID = [curDict objectForKey:@"studyID"];
						curPatientUID = [curDict objectForKey:@"patientUID"];
						
						[modifiedStudiesArray addObject:study];
					}
					
					int NoOfSeries = [[curDict objectForKey:@"numberOfSeries"] intValue];
					for (int i = 0; i < NoOfSeries; i++)
					{
						NSString* SeriesNum = i ? [NSString stringWithFormat:@"%d",i] : @"";
						
						if( [[curDict objectForKey: [@"seriesID" stringByAppendingString:SeriesNum]] isEqualToString: curSerieID])
						{
						}
						else
						{
							/********************************************/
							/*********** Find series object *************/
							
							NSArray *seriesArray = [[study valueForKey:@"series"] allObjects];
							
							index = [[seriesArray valueForKey:@"seriesInstanceUID"] indexOfObject:[curDict objectForKey: [@"seriesID" stringByAppendingString:SeriesNum]]];
							if( index == NSNotFound)
							{
								// Fields
								seriesTable = [NSEntityDescription insertNewObjectForEntityForName:@"Series" inManagedObjectContext: context];
								[seriesTable setValue:today forKey:@"dateAdded"];
								
								newObject = YES;
							}
							else
							{
								seriesTable = [seriesArray objectAtIndex: index];
								newObject = NO;
							}
							
							if( newObject || inParseExistingObject)
							{
								if( [curDict objectForKey: @"seriesDICOMUID"]) [seriesTable setValue:[curDict objectForKey: @"seriesDICOMUID"] forKey:@"seriesDICOMUID"];
								if( [curDict objectForKey: @"SOPClassUID"]) [seriesTable setValue:[curDict objectForKey: @"SOPClassUID"] forKey:@"seriesSOPClassUID"];
								[seriesTable setValue:[curDict objectForKey: [@"seriesID" stringByAppendingString:SeriesNum]] forKey:@"seriesInstanceUID"];
								[seriesTable setValue:[curDict objectForKey: [@"seriesDescription" stringByAppendingString:SeriesNum]] forKey:@"name"];
								[seriesTable setValue:[curDict objectForKey: @"modality"] forKey:@"modality"];
								[seriesTable setValue:[curDict objectForKey: [@"seriesNumber" stringByAppendingString:SeriesNum]] forKey:@"id"];
								[seriesTable setValue:[curDict objectForKey: @"studyDate"] forKey:@"date"];
								[seriesTable setValue:[curDict objectForKey: @"protocolName"] forKey:@"seriesDescription"];
								
								// Relations
								[seriesTable setValue:study forKey:@"study"];
								// If a study has an SC or other non primary image  series. May need to change modality to true modality
								if (([[study valueForKey:@"modality"] isEqualToString:@"OT"]  || [[study valueForKey:@"modality"] isEqualToString:@"SC"])
									&& !([[curDict objectForKey: @"modality"] isEqualToString:@"OT"] || [[curDict objectForKey: @"modality"] isEqualToString:@"SC"]))
									[study setValue:[curDict objectForKey: @"modality"] forKey:@"modality"];
							}
							
							curSerieID = [curDict objectForKey: @"seriesID"];
						}
						
						/*******************************************/
						/*********** Find image object *************/
						
						BOOL local = NO;
						
						if( dbDirectory && [newFile hasPrefix: dbDirectory])
							local = YES;
						
						NSArray	*imagesArray = [[seriesTable valueForKey:@"images"] allObjects];
						int numberOfFrames = [[curDict objectForKey: @"numberOfFrames"] intValue];
						if( numberOfFrames == 0) numberOfFrames = 1;
						
						for( int f = 0 ; f < numberOfFrames; f++)
						{
							index = imagesArray.count? [[imagesArray valueForKey:@"sopInstanceUID"] indexOfObject:[curDict objectForKey: [@"SOPUID" stringByAppendingString: SeriesNum]]] : NSNotFound;
							
							if( index != NSNotFound)
							{
								image = [imagesArray objectAtIndex: index];
								
								// Does this image contain a valid image path? If not replace it, with the new one
								if( [[NSFileManager defaultManager] fileExistsAtPath: [DicomImage completePathForLocalPath:[image valueForKey:@"path"] directory:self.basePath]] == YES && inParseExistingObject == NO)
								{
									[addedImagesArray addObject: image];
									
									if( local)	// Delete this file, it's already in the DB folder
									{
										if( [[image valueForKey:@"path"] isEqualToString: [newFile lastPathComponent]] == NO)
											[[NSFileManager defaultManager] removeFileAtPath: newFile handler:nil];
									}
									
									newObject = NO;
								}
								else
								{
									newObject = YES;
									[image clearCompletePathCache];
									
									NSString *imPath = [DicomImage completePathForLocalPath: [image valueForKey:@"path"] directory: self.basePath];
									
									if( [[image valueForKey:@"inDatabaseFolder"] boolValue] && [imPath isEqualToString: newFile] == NO)
									{
										if( [[NSFileManager defaultManager] fileExistsAtPath: imPath])
											[[NSFileManager defaultManager] removeFileAtPath: imPath handler:nil];
									}
								}
							}
							else
							{
								image = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext: context];
								
								newObject = YES;
							}
							
							[completeImagesArray addObject: image];
							
							if( newObject || inParseExistingObject)
							{
//								browserController.needDBRefresh = YES; // TODO: re-enable
								
								if( DICOMSR == NO)
									[seriesTable setValue:today forKey:@"dateAdded"];
								
								[image setValue: [curDict objectForKey: @"modality"] forKey:@"modality"];
								
								if( numberOfFrames > 1)
								{
									[image setValue: [NSNumber numberWithInt: f] forKey:@"frameID"];
									
									NSString *Modality = [study valueForKey: @"modality"];
									if( combineProjectionSeries && combineProjectionSeriesMode == 0 && ([Modality isEqualToString:@"MG"] || [Modality isEqualToString:@"CR"] || [Modality isEqualToString:@"DR"] || [Modality isEqualToString:@"DX"] || [Modality  isEqualToString:@"RF"]))
									{
										// *******Combine all CR and DR Modality series in a study into one series
										long imageInstance = [[curDict objectForKey: [ @"imageID" stringByAppendingString: SeriesNum]] intValue];
										imageInstance *= 10000;
										imageInstance += f;
										[image setValue: [NSNumber numberWithLong: imageInstance] forKey:@"instanceNumber"];
									}
									else [image setValue: [NSNumber numberWithInt: f] forKey:@"instanceNumber"];
								}
								else
									[image setValue: [curDict objectForKey: [@"imageID" stringByAppendingString: SeriesNum]] forKey:@"instanceNumber"];
								
								if( local) [image setValue: [newFile lastPathComponent] forKey:@"path"];
								else [image setValue:newFile forKey:@"path"];
								
								[image setValue:[NSNumber numberWithBool: local] forKey:@"inDatabaseFolder"];
								
								[image setValue:[curDict objectForKey: @"studyDate"]  forKey:@"date"];
								
								[image setValue:[curDict objectForKey: [@"SOPUID" stringByAppendingString: SeriesNum]] forKey:@"sopInstanceUID"];
								[image setValue:[curDict objectForKey: @"sliceLocation"] forKey:@"sliceLocation"];
								[image setValue:[[newFile pathExtension] lowercaseString] forKey:@"extension"];
								[image setValue:[curDict objectForKey: @"fileType"] forKey:@"fileType"];
								
								[image setValue:[curDict objectForKey: @"height"] forKey:@"height"];
								[image setValue:[curDict objectForKey: @"width"] forKey:@"width"];
								[image setValue:[curDict objectForKey: @"numberOfFrames"] forKey:@"numberOfFrames"];
								[image setValue:[NSNumber numberWithBool: mountedVolume] forKey:@"mountedVolume"];
								if( mountedVolume)
									[seriesTable setValue:[NSNumber numberWithBool:mountedVolume] forKey:@"mountedVolume"];
								[image setValue:[curDict objectForKey: @"numberOfSeries"] forKey:@"numberOfSeries"];
								
								if( generatedByOsiriX)
									[image setValue: [NSNumber numberWithBool: generatedByOsiriX] forKey: @"generatedByOsiriX"];
								else
									[image setValue: 0L forKey: @"generatedByOsiriX"];
								
								[seriesTable setValue:[NSNumber numberWithInt:0]  forKey:@"numberOfImages"];
								[study setValue:[NSNumber numberWithInt:0]  forKey:@"numberOfImages"];
								[seriesTable setValue: nil forKey:@"thumbnail"];
								
								if( DICOMSR && [curDict objectForKey: @"numberOfROIs"] && [curDict objectForKey: @"referencedSOPInstanceUID"]) // OsiriX ROI SR
								{
									NSString *s = [curDict objectForKey: @"referencedSOPInstanceUID"];
									[image setValue: s forKey:@"comment"];
									[image setValue: [curDict objectForKey: @"numberOfROIs"] forKey:@"scale"];
								}
								
								// Relations
								[image setValue:seriesTable forKey:@"series"];
								
								/*if( isBonjour) // re-enable
								{
									if( local)
									{
										NSString *bonjourPath = [BonjourBrowser uniqueLocalPath: image];
										[[NSFileManager defaultManager] removeItemAtPath: bonjourPath error: nil];
										[[NSFileManager defaultManager] moveItemAtPath: newFile toPath: bonjourPath error: nil];
										[bonjourFilesToSend addObject: bonjourPath];
									}
									else
										[bonjourFilesToSend addObject: newFile];
									
									NSLog( @"------ AddFiles to a shared Bonjour DB: %@", [newFile lastPathComponent]);
								}*/
								
								if( DICOMSR == NO)
								{
									if( COMMENTSAUTOFILL)
									{
										if([curDict objectForKey: @"commentsAutoFill"])
										{
											[seriesTable setPrimitiveValue: [curDict objectForKey: @"commentsAutoFill"] forKey: @"comment"];
											[study setPrimitiveValue:[curDict objectForKey: @"commentsAutoFill"] forKey: @"comment"];
										}
									}
									
									if( generatedByOsiriX == NO && [(NSString*)[curDict objectForKey: @"seriesComments"] length] > 0)
										[seriesTable setPrimitiveValue: [curDict objectForKey: @"seriesComments"] forKey: @"comment"];
									
									if( generatedByOsiriX == NO && [(NSString*)[curDict objectForKey: @"studyComments"] length] > 0)
										[study setPrimitiveValue: [curDict objectForKey: @"studyComments"] forKey: @"comment"];
									
									if( generatedByOsiriX == NO && [[study valueForKey:@"stateText"] intValue] == 0 && [[curDict objectForKey: @"stateText"] intValue] != 0)
										[study setPrimitiveValue: [curDict objectForKey: @"stateText"] forKey: @"stateText"];
									
									if( generatedByOsiriX == NO && [curDict objectForKey: @"keyFrames"])
									{
										@try
										{
											for( NSString *k in [curDict objectForKey: @"keyFrames"])
											{
												if( [k intValue] == f) // corresponding frame
												{
													[image setPrimitiveValue: [NSNumber numberWithBool: YES] forKey: @"storedIsKeyImage"];
													break;
												}
											}
										}
										@catch (NSException * e) {NSLog( @"***** exception in %s: %@", __PRETTY_FUNCTION__, e);[e printStackTrace];}
									}
								}
								
								if( DICOMSR && [[curDict valueForKey:@"seriesDescription"] isEqualToString: @"OsiriX Report SR"])
								{
									BOOL reportUpToDate = NO;
									NSString *p = [study reportURL];
									
									if( p && [[NSFileManager defaultManager] fileExistsAtPath: p])
									{
										NSDictionary *fattrs = [[NSFileManager defaultManager] attributesOfItemAtPath: p error: nil];
										if( [[curDict objectForKey: @"studyDate"] isEqualToDate: [fattrs objectForKey: NSFileModificationDate]])
											reportUpToDate = YES;
									}
									
									if( reportUpToDate == NO)
									{
										NSString *reportURL = nil; // <- For an empty DICOM SR File
										
										DicomImage *reportSR = [study reportImage];
										
										if( reportSR == image) // Because we can have multiple reports -> only the most recent one is valid
										{
											NSString *reportURL = nil, *reportPath = [DicomDatabase extractReportSR: newFile contentDate: [curDict objectForKey: @"studyDate"]];
											
											if( reportPath)
											{
												if( [reportPath length] > 8 && ([reportPath hasPrefix: @"http://"] || [reportPath hasPrefix: @"https://"]))
												{
													reportURL = reportPath;
												}
												else // It's a file!
												{
													NSString *reportFilePath = nil;
													
													/*if( isBonjour) // TODO: re-enable
														reportFilePath = [tempDirectory stringByAppendingPathComponent: [reportPath lastPathComponent]];
													else*/
														reportFilePath = [reportsDirectory stringByAppendingPathComponent: [reportPath lastPathComponent]];
													
													[[NSFileManager defaultManager] removeItemAtPath: reportFilePath error: nil];
													[[NSFileManager defaultManager] moveItemAtPath: reportPath toPath: reportFilePath error: nil];
													
													reportURL = [@"REPORTS/" stringByAppendingPathComponent: [reportPath lastPathComponent]];
												}
												
												NSLog( @"--- DICOM SR -> Report : %@", [curDict valueForKey: @"patientName"]);
											}
											
											if( [reportURL length] > 0)
												[study setPrimitiveValue: reportURL forKey: @"reportURL"];
											else
												[study setPrimitiveValue: 0L forKey: @"reportURL"];
										}
									}
								}
								
								[addedImagesArray addObject: image];
								
								if(seriesTable && [addedSeries containsObject: seriesTable] == NO)
									[addedSeries addObject: seriesTable];
								
								if( DICOMSR == NO && [curDict valueForKey:@"album"] !=nil)
								{
									NSArray* albumArray = [self albums];
									
									DicomAlbum* album = NULL;
									for (album in albumArray)
									{
										if ([album.name isEqualToString:[curDict valueForKey:@"album"]])
											break;
									}
									
									if (album == nil)
									{
										//NSString *name = [curDict valueForKey:@"album"];
										//album = [NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext: context];
										//[album setValue:name forKey:@"name"];
										
										for (album in albumArray)
										{
											if ([album.name isEqualToString:@"other"])
												break;
										}
										
										if (album == nil)
										{
											album = [NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext: context];
											[album setValue:@"other" forKey:@"name"];
										}
									}
									
									// add the file to the album
									if ( [[album valueForKey:@"smartAlbum"] boolValue] == NO)
									{
										NSMutableSet *studies = [album mutableSetValueForKey: @"studies"];	
										[studies addObject: [image valueForKeyPath:@"series.study"]];
										[[image valueForKeyPath:@"series.study"] archiveAnnotationsAsDICOMSR];
									}
								}
							}
						}
					}
				}
				else
				{
					// This file was not readable -> If it is located in the DATABASE folder, we have to delete it or to move it to the 'NOT READABLE' folder
					if( dbDirectory && [newFile hasPrefix: dbDirectory])
					{
						NSLog(@"**** Unreadable file: %@", newFile);
						
						if ( DELETEFILELISTENER)
						{
							[[NSFileManager defaultManager] removeFileAtPath: newFile handler:nil];
						}
						else
						{
							if( [[NSFileManager defaultManager] movePath: newFile toPath:[ERRpath stringByAppendingPathComponent: [newFile lastPathComponent]]  handler:nil] == NO)
								[[NSFileManager defaultManager] removeFileAtPath: newFile handler:nil];
						}
					}
				}
			}
			
			@catch( NSException *ne)
			{
				NSLog(@"AddFilesToDatabase DicomFile exception: %@", [ne description]);
				NSLog(@"Parser failed for this file: %@", newFile);
				[ne printStackTrace];
			}
		}
		
		[studiesArrayStudyInstanceUID release];
		[studiesArray release];
		
		NSString *dockLabel = nil;
		NSString *growlString = nil;
		
		@try
		{
			// Compute no of images in studies/series
			for( NSManagedObject *study in modifiedStudiesArray) [study valueForKey:@"noFiles"];
			
			// Reapply annotations from DICOMSR file
			for( DicomStudy *study in modifiedStudiesArray) [study reapplyAnnotationsFromDICOMSR];
			
/*			if( isBonjour && [bonjourFilesToSend count] > 0) // TODO: re-enable
			{
				if( generatedByOsiriX)
					[NSThread detachNewThreadSelector: @selector( sendFilesToCurrentBonjourGeneratedByOsiriXDB:) toTarget: browserController withObject: bonjourFilesToSend];
				else 
					[NSThread detachNewThreadSelector: @selector( sendFilesToCurrentBonjourDB:) toTarget: browserController withObject: bonjourFilesToSend];
			}*/
			
			if( notifyAddedFiles)
			{
				NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
				
				@try
				{
					NSDictionary *userInfo = [NSDictionary dictionaryWithObject:addedImagesArray forKey:OsirixAddToDBNotificationImagesArray];
					[[NSNotificationCenter defaultCenter] postNotificationName:OsirixAddToDBNotification object:nil userInfo:userInfo];
					
					userInfo = [NSDictionary dictionaryWithObject:completeImagesArray forKey:OsirixAddToDBCompleteNotificationImagesArray];
					[[NSNotificationCenter defaultCenter] postNotificationName:OsirixAddToDBCompleteNotification object:nil userInfo:userInfo];
				}
				@catch( NSException *ne)
				{
					NSLog( @"******* OsirixAddToDBNotification: %@", [ne description]);
					[ne printStackTrace];
				}
				
				if( [addedImagesArray count] > 0 && generatedByOsiriX == NO)
				{
					dockLabel = [NSString stringWithFormat:@"%d", [addedImagesArray count]];
					growlString = [NSString stringWithFormat: NSLocalizedString(@"Patient: %@\r%d images added to the database", nil), [[addedImagesArray objectAtIndex:0] valueForKeyPath:@"series.study.name"], [addedImagesArray count]];
				}
				
				[dockLabel retain];
				[growlString retain];
				
				// if( isBonjour == NO) // TODO: re-enable
				//	[[BrowserController currentBrowser] executeAutorouting: addedImagesArray rules: nil manually: NO generatedByOsiriX: generatedByOsiriX];
				
				[p release];
			}
		}
		@catch( NSException *ne)
		{
			NSLog(@"******* Compute no of images in studies/series: %@", [ne description]);
			[ne printStackTrace];
		}
		
		[splash close];
		[splash release];
		splash = nil;
		
		@try
		{
			//[browserController autoCleanDatabaseFreeSpace: browserController]; // TODO: re-enable
			
			NSError *error = nil;
			[context save: &error];
			
			if( error)
			{
				NSLog( @"***** error saving DB: %@", [[error userInfo] description]);
				NSLog( @"***** saveDatabase ERROR: %@", [error localizedDescription]);
				
				addFailed = YES;
			}
			
			if( addFailed == NO)
			{
				NSMutableArray *viewersList = [ViewerController getDisplayed2DViewers];
				
				for( NSManagedObject *seriesTable in addedSeries)
				{
					NSString *curPatientID = [seriesTable valueForKeyPath:@"study.patientID"];
					
					for( ViewerController *vc in viewersList)
					{
						if( [[vc fileList] count])
						{
							NSManagedObject	*firstObject = [[vc fileList] objectAtIndex: 0];
							
							// For each new image in a pre-existing study, check if a viewer is already opened -> refresh the preview list
							
							if( curPatientID == nil || [curPatientID isEqualToString: [firstObject valueForKeyPath:@"series.study.patientID"]])
							{
								if( [vlToRebuild containsObject: vc] == NO)
									[vlToRebuild addObject: vc];
							}
							
							if( seriesTable == [firstObject valueForKey:@"series"])
							{
								if( [vlToReload containsObject: vc] == NO)
									[vlToReload addObject: vc];
							}
						}
					}
				}
			}
		}
		@catch( NSException *ne)
		{
			NSLog(@"******* vlToReload vlToRebuild: %@", [ne description]);
			[ne printStackTrace];
		}
		
		[context unlock];
		[context release];
		
		if (addFailed == NO)
		{
			if( dockLabel)
				[AppController.sharedAppController performSelectorOnMainThread:@selector( setDockLabel:) withObject: dockLabel waitUntilDone:NO];
			
			if( growlString)
				[AppController.sharedAppController performSelectorOnMainThread:@selector( setGrowlMessage:) withObject: growlString waitUntilDone:NO];
			
			/*if([NSThread isMainThread]) // TODO: re-enable
				[browserController newFilesGUIUpdate: browserController];
			
			[browserController.newFilesConditionLock lock];
			
			int prevCondition = [browserController.newFilesConditionLock condition];
			
			for( ViewerController *a in vlToReload)
			{
				if( [[BrowserController currentBrowser].viewersListToReload containsObject: a] == NO)
					[[BrowserController currentBrowser].viewersListToReload addObject: a];
			}
			for( ViewerController *a in vlToRebuild)
			{
				if( [[BrowserController currentBrowser].viewersListToRebuild containsObject: a] == NO)
					[[BrowserController currentBrowser].viewersListToRebuild addObject: a];
			}
			
			if( newStudy || prevCondition == 1) [browserController.newFilesConditionLock unlockWithCondition: 1];
			else [browserController.newFilesConditionLock unlockWithCondition: 2];
			
			
			if([NSThread isMainThread])
				[browserController newFilesGUIUpdate: browserController];
			
			[[BrowserController currentBrowser] setDatabaseLastModification:[NSDate timeIntervalSinceReferenceDate]];*/
		}
		
		[dockLabel release]; dockLabel = nil;
		[growlString release]; growlString = nil;
	}
	
	[DicomFile setFilesAreFromCDMedia: NO];
	
	[[NSFileManager defaultManager] removeFileAtPath: @"/tmp/dicomsr_osirix" handler: nil];
	
	if( addFailed)
	{
		NSLog(@"adding failed....");
		
		return nil;
	}
	
	return addedImagesArray;
}

-(void)checkIncomingBlocking:(BOOL)blockFlag {
	//if( DatabaseIsEdited == YES && [[self window] isKeyWindow] == YES) return; // TODO: re-enable
//	if ( [NSDate timeIntervalSinceReferenceDate] - lastCheckIncoming < 0.5) return;
	
	if ([NSFileManager.defaultManager isDiskFull:self.basePath]) {
		// Kill the incoming directory
		[[NSFileManager defaultManager] removeItemAtPath: [[self localDocumentsDirectory] stringByAppendingPathComponent: INCOMINGPATH] error: nil];
		
		[[AppController sharedAppController] growlTitle: NSLocalizedString(@"WARNING", nil) description: NSLocalizedString(@"Hard Disk is Full ! Cannot accept more files.", nil) name:@"newfiles"];
	}
	
	BOOL needUnlock = YES;
	if ([self tryWriteLock])
		@try {
			NSThread* thread = [[NSThread alloc] initWithTarget:self selector:@selector(checkIncomingThread:) object:NULL];
			[thread start];
			
			if (blockFlag) {
				[self writeUnlock]; // must
				needUnlock = NO;
				while (![thread isFinished])
					[NSThread sleepForTimeInterval:0.001];
			}
			
			[thread release];
				
		}
		@catch (NSException* e) {
			ExceptionLog(e);
		}
		@finally {
			if (needUnlock)
				[self writeUnlock];
		}
	else ErrorLog(@"writeLock was locked");
	
	//[self setDockIcon];
}

-(void)checkIncoming {
	[self checkIncomingBlocking:NO];
}


/*-(void)checkIncomingNow:(id)sender {
	// if (DatabaseIsEdited == YES && [[self window] isKeyWindow] == YES) return; // TODO: re-enable
	//if ([NSDate timeIntervalSinceReferenceDate] - lastCheckIncoming < 0.4) return;
	
	[self writeLock];
	@try {
		if ([self tryLock])
		{
			[self checkIncomingThread: self];
			[NSThread sleepForTimeInterval: 1];
			
			// Do we have a compression/decompression process? re-checkincoming to include these compression/decompression images
			[self checkIncomingThread: self];
			[NSThread sleepForTimeInterval: 1];
			
			[self checkIncomingThread: self];
			
			[self unlock];
		}
		else
		{
			/*[checkIncomingLock unlock];
			
			[self checkIncoming: self];
			[NSThread sleepForTimeInterval: 1];
			
			// Do we have a compression/decompression process? re-checkincoming to include these compression/decompression images
			[self checkIncoming: self];
			[NSThread sleepForTimeInterval: 1];
			
			[self checkIncoming: self];
			*
			NSLog(@"*** We will not checkIncomingNow, because we can find ourself in a locked in loop....");
		}
	}
	@catch (NSException* e) {
		NSLog(@"Error: [DicomDatabase checkIncomingNow] %@", e);
	} @finally {
		[self writeUnlock];
	}
}*/


-(void)checkIncomingThread:(id)obj {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	[writeLock lock];
	@try
	{
		BOOL DELETEFILELISTENER = [[NSUserDefaults standardUserDefaults] boolForKey: @"DELETEFILELISTENER"];
		BOOL ListenerCompressionSettings = [[NSUserDefaults standardUserDefaults] integerForKey: @"ListenerCompressionSettings"];
		BOOL twoStepsIndexing = [[NSUserDefaults standardUserDefaults] boolForKey: @"twoStepsIndexing"];
		NSMutableArray *filesArray = [NSMutableArray array];
		NSMutableArray *compressedPathArray = [NSMutableArray array];
		
#ifdef OSIRIX_LIGHT
		ListenerCompressionSettings = 0;
#endif
		
		lastCheckIncoming = [NSDate timeIntervalSinceReferenceDate];
		
		NSString *dbFolder = [self localDocumentsDirectory];
		NSString *INpath = [dbFolder stringByAppendingPathComponent:INCOMINGPATH];
		NSString *ERRpath = [dbFolder stringByAppendingPathComponent:ERRPATH];
		NSString *OUTpath = [dbFolder stringByAppendingPathComponent:DATABASEPATH];
		NSString *DECOMPRESSIONpath = [dbFolder stringByAppendingPathComponent:DECOMPRESSIONPATH];
		NSString *toBeIndexed = [dbFolder stringByAppendingPathComponent:TOBEINDEXED];
		
		NSMutableArray *twoStepsIndexingArrayFrom = [NSMutableArray array];
		NSMutableArray *twoStepsIndexingArrayTo = [NSMutableArray array];
		
		if( bonjourDownloading == NO)
		{
			//need to resolve aliases and symbolic links
			INpath = [self folderPathResolvingAliasAndSymLink:INpath];
			OUTpath = [self folderPathResolvingAliasAndSymLink:OUTpath];
			ERRpath = [self folderPathResolvingAliasAndSymLink:ERRpath];
			DECOMPRESSIONpath = [self folderPathResolvingAliasAndSymLink:DECOMPRESSIONpath];
			if( twoStepsIndexing)
				toBeIndexed = [self folderPathResolvingAliasAndSymLink: toBeIndexed];
			
			[AppController createNoIndexDirectoryIfNecessary: OUTpath];
			
			NSString *pathname;
			
			NSDirectoryEnumerator *enumer = [[NSFileManager defaultManager] enumeratorAtPath:INpath];
			
			int maxNumberOfFiles = [[NSUserDefaults standardUserDefaults] integerForKey: @"maxNumberOfFilesForCheckIncoming"];
			if( maxNumberOfFiles < 100) maxNumberOfFiles = 100;
			if( maxNumberOfFiles > 10000) maxNumberOfFiles = 10000;
			
			while( (pathname = [enumer nextObject]) && [filesArray count] < maxNumberOfFiles)
			{
				NSString *srcPath = [INpath stringByAppendingPathComponent:pathname];
				NSString *originalPath = srcPath;
				NSString *lastPathComponent = [srcPath lastPathComponent];
				
				if ([[lastPathComponent uppercaseString] isEqualToString:@".DS_STORE"])
					continue;
				
				if ( [lastPathComponent length] > 0 && [lastPathComponent characterAtIndex: 0] == '.')
				{
					NSDictionary *atr = [enumer fileAttributes];// [[NSFileManager defaultManager] attributesOfItemAtPath: srcPath error: nil];
					if( [atr fileModificationDate] && [[atr fileModificationDate] timeIntervalSinceNow] < -60*60*24)
					{
						[NSThread sleepForTimeInterval: 0.1]; //We want to be 100% sure...
						
						atr = [[NSFileManager defaultManager] attributesOfItemAtPath: srcPath error: nil];
						if( [atr fileModificationDate] && [[atr fileModificationDate] timeIntervalSinceNow] < -60*60*24)
						{
							NSLog( @"old files with '.' -> delete it : %@", srcPath);
							if( srcPath)
								[[NSFileManager defaultManager] removeItemAtPath: srcPath error: nil];
						}
					}
					continue;
				}
				
				BOOL result, isAlias = [self isAliasPath: srcPath];
				if( isAlias)
					srcPath = [self pathResolved: srcPath];
				
				// Is it a real file? Is it writable (transfer done)?
				//					if ([[NSFileManager defaultManager] isWritableFileAtPath:srcPath] == YES)	<- Problems with CD : read-only files, but valid files
				{
					NSDictionary *fattrs = [enumer fileAttributes];	//[[NSFileManager defaultManager] fileAttributesAtPath:srcPath traverseLink: YES];
					
					//						// http://www.noodlesoft.com/blog/2007/03/07/mystery-bug-heisenbergs-uncertainty-principle/
					//						[fattrs allKeys];
					
					//						NSLog( @"%@", [fattrs objectForKey:NSFileBusy]);
					
					if( [[fattrs objectForKey:NSFileType] isEqualToString: NSFileTypeDirectory] == YES)
					{
						NSArray		*dirContent = [[NSFileManager defaultManager] directoryContentsAtPath: srcPath];
						
						//Is this directory empty?? If yes, delete it!
						//if alias assume nested folders should stay
						if( [dirContent count] == 0 && !isAlias) [[NSFileManager defaultManager] removeFileAtPath:srcPath handler:nil];
						if( [dirContent count] == 1)
						{
							if( [[[dirContent objectAtIndex: 0] uppercaseString] isEqualToString:@".DS_STORE"]) [[NSFileManager defaultManager] removeFileAtPath:srcPath handler:nil];
						}
					}
					else if( fattrs != nil && [[fattrs objectForKey:NSFileBusy] boolValue] == NO && [[fattrs objectForKey:NSFileSize] longLongValue] > 0)
					{
						if( [[srcPath pathExtension] isEqualToString: @"zip"] || [[srcPath pathExtension] isEqualToString: @"osirixzip"])
						{
							NSString *compressedPath = [DECOMPRESSIONpath stringByAppendingPathComponent: lastPathComponent];
							[[NSFileManager defaultManager] movePath:srcPath toPath:compressedPath handler:nil];
							[compressedPathArray addObject: compressedPath];
						}
						else
						{
							BOOL isDicomFile, isJPEGCompressed, isImage;
							NSString *dstPath = [OUTpath stringByAppendingPathComponent: lastPathComponent];
							
							isDicomFile = [DicomFile isDICOMFile:srcPath compressed: &isJPEGCompressed image: &isImage];
							
							if( isDicomFile == YES ||
							   (([DicomFile isFVTiffFile:srcPath] ||
								 [DicomFile isTiffFile:srcPath] ||
								 [DicomFile isNRRDFile:srcPath])
								&& [[NSFileManager defaultManager] fileExistsAtPath:dstPath] == NO))
							{
								newFilesInIncoming = YES;
								
								if (isDicomFile && isImage)
								{
#ifndef OSIRIX_LIGHT
									if( (isJPEGCompressed == YES && ListenerCompressionSettings == 1) || (isJPEGCompressed == NO && ListenerCompressionSettings == 2 && [self needToCompressFile: srcPath]))
#else
										if( (isJPEGCompressed == YES && ListenerCompressionSettings == 1) || (isJPEGCompressed == NO && ListenerCompressionSettings == 2))
#endif
										{
											NSString *compressedPath = [DECOMPRESSIONpath stringByAppendingPathComponent: lastPathComponent];
											
											[[NSFileManager defaultManager] movePath:srcPath toPath:compressedPath handler:nil];
											
											[compressedPathArray addObject: compressedPath];
											
											continue;
										}
									
									dstPath = [self getNewFileDatabasePath: @"dcm" dbFolder: dbFolder];
								}
								else dstPath = [self getNewFileDatabasePath: [[srcPath pathExtension] lowercaseString] dbFolder: dbFolder];
								
								if( isAlias)
								{
									if( twoStepsIndexing)
									{
										NSString *stepsPath = [toBeIndexed stringByAppendingPathComponent: [dstPath lastPathComponent]];
										
										result = [[NSFileManager defaultManager] copyPath:srcPath toPath: stepsPath handler:nil];
										[[NSFileManager defaultManager] removeFileAtPath:originalPath handler:nil];
										
										if( result)
										{
											[twoStepsIndexingArrayFrom addObject: stepsPath];
											[twoStepsIndexingArrayTo addObject: dstPath];
										}
									}
									else
									{
										result = [[NSFileManager defaultManager] copyPath:srcPath toPath: dstPath handler:nil];
										[[NSFileManager defaultManager] removeFileAtPath:originalPath handler:nil];
									}
								}
								else
								{
									if( twoStepsIndexing)
									{
										NSString *stepsPath = [toBeIndexed stringByAppendingPathComponent: [dstPath lastPathComponent]];
										
										result = [[NSFileManager defaultManager] movePath:srcPath toPath: stepsPath handler:nil];
										
										if( result)
										{
											[twoStepsIndexingArrayFrom addObject: stepsPath];
											[twoStepsIndexingArrayTo addObject: dstPath];
										}
									}
									else
										result = [[NSFileManager defaultManager] movePath:srcPath toPath: dstPath handler:nil];
								}
								
								if( result == YES)
									[filesArray addObject:dstPath];
							}
							else // DELETE or MOVE THIS UNKNOWN FILE ?
							{
								if ( DELETEFILELISTENER)
									[[NSFileManager defaultManager] removeFileAtPath:srcPath handler:nil];
								else
								{
									//NSLog( [ERRpath stringByAppendingPathComponent: [srcPath lastPathComponent]]);
									
									if( [[NSFileManager defaultManager] movePath:srcPath toPath:[ERRpath stringByAppendingPathComponent: lastPathComponent]  handler:nil] == NO)
										[[NSFileManager defaultManager] removeFileAtPath:srcPath handler:nil];
								}
							}
						}
					}
				}
			}
			
			if( twoStepsIndexing == YES && [twoStepsIndexingArrayFrom count] > 0)
			{
				[checkIncomingLock unlock];
				
				for( int i = 0 ; i < [twoStepsIndexingArrayFrom count] ; i++)
				{
					[[NSFileManager defaultManager] removeItemAtPath: [twoStepsIndexingArrayTo objectAtIndex: i]  error: nil];
					[[NSFileManager defaultManager] moveItemAtPath: [twoStepsIndexingArrayFrom objectAtIndex: i] toPath: [twoStepsIndexingArrayTo objectAtIndex: i] error: nil];
					[[NSFileManager defaultManager] removeItemAtPath: [twoStepsIndexingArrayFrom objectAtIndex: i]  error: nil];
				}
				
				[checkIncomingLock lock];
			}
			
			if ( [filesArray count] > 0)
			{
				newFilesInIncoming = YES;
				
				if ( [[NSUserDefaults standardUserDefaults] boolForKey:@"ANONYMIZELISTENER"] == YES)
					[self listenerAnonymizeFiles: filesArray];
				
				for( id filter in [PluginManager preProcessPlugins])
				{
					[filter processFiles: filesArray];
				}
				
				NSManagedObjectContext *sqlContext = [self localManagedObjectContextIndependentContext: YES];
				NSArray* addedFiles = [[self addFilesToDatabase: filesArray onlyDICOM:NO produceAddedFiles:YES parseExistingObject: NO context: sqlContext dbFolder: dbFolder] valueForKey:@"completePath"];
				
				if( addedFiles)
				{
				}
				else	// Add failed.... Keep these files: move them back to the INCOMING folder and try again later....
				{
					NSString *dstPath;
					int x = 0;
					
					NSLog(@"Move the files back to the incoming folder...");
					
					for( NSString *file in filesArray)
					{
						do
						{
							dstPath = [INpath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", x]];
							x++;
						}
						while( [[NSFileManager defaultManager] fileExistsAtPath:dstPath] == YES);
						
						[[NSFileManager defaultManager] movePath: file toPath: dstPath handler: nil];
					}
				}
			}
			else
			{
				if( [compressedPathArray count] == 0) newFilesInIncoming = NO;
				else newFilesInIncoming = YES;
			}
		}
		else newFilesInIncoming = NO;
		
#ifndef OSIRIX_LIGHT
		if( [compressedPathArray count] > 0)
		{
			[decompressThreadRunning lock];
			[decompressArrayLock lock];
			[decompressArray addObjectsFromArray: compressedPathArray];
			[decompressArrayLock unlock];
			
			if( ListenerCompressionSettings == 1 || ListenerCompressionSettings == 0)		// Decompress, ListenerCompressionSettings == 0 for zip support !
				[self decompressThread: [NSNumber numberWithChar: 'I']];
			else if( ListenerCompressionSettings == 2)	// Compress
				[self decompressThread: [NSNumber numberWithChar: 'X']];
			[decompressThreadRunning unlock];
		}
#endif
		
		lastCheckIncoming  = [NSDate timeIntervalSinceReferenceDate];
	}
	@catch (NSException * e)
	{
		NSLog( @"checkIncomingThread exception %@", e);
		[e printStackTrace];
	} @finally {
		[writeLock unlock];
		[pool release];
	}
}

#pragma mark Reports

-(void)checkForExistingReport:(DicomStudy*)study {
#ifndef OSIRIX_LIGHT
	@try {
		// Is there a report?
		NSString* filename[] = {[Reports getUniqueFilename:study], [Reports getOldUniqueFilename:study]};
		for (int i = 0; i < 2; ++i)
			for (NSString* ext in [NSArray arrayWithObjects: @"pages", @"odt", @"doc", @"rtf", NULL]) {
				NSString* path = [[self.reportsDirectoryPath stringByAppendingPathComponent:filename[i]] stringByAppendingPathExtension:ext];
				if ([NSFileManager.defaultManager fileExistsAtPath:path]) {
					study.reportURL = path;
					return;
				}
			}
	} @catch (NSException* e) {
		NSLog(@"***** checkForExistingReport exception: %@", e);
		[e printStackTrace];
	}
#endif
}



-(BOOL)isBonjour {
	return NO;
}


-(void)rebuild {
	//if (isCurrentDatabaseBonjour) return;
	
	[self waitForRunningProcesses];
	
	[[AppController sharedAppController] closeAllViewers: self];
	
	if( COMPLETEREBUILD)	// Delete the database file
	{
		if ([[NSFileManager defaultManager] fileExistsAtPath: currentDatabasePath])
		{
			[[NSFileManager defaultManager] removeFileAtPath: [currentDatabasePath stringByAppendingString:@" - old"] handler: nil];
			[[NSFileManager defaultManager] movePath: currentDatabasePath toPath: [currentDatabasePath stringByAppendingString:@" - old"] handler: nil];
		}
	}
	else
	{
		[self saveDatabase:currentDatabasePath];
	}
	
	displayEmptyDatabase = YES;
	[self outlineViewRefresh];
	[self refreshMatrix: self];
	
	[checkIncomingLock lock];
	
	[managedObjectContext lock];
	[managedObjectContext unlock];
	[managedObjectContext release];
	managedObjectContext = nil;
	
	[databaseOutline reloadData];
	
	NSMutableArray				*filesArray;
	
	WaitRendering *wait = [[WaitRendering alloc] init: NSLocalizedString(@"Step 1: Checking files...", nil)];
	[wait showWindow:self];
	
	filesArray = [[NSMutableArray alloc] initWithCapacity: 10000];
	
	// SCAN THE DATABASE FOLDER, TO BE SURE WE HAVE EVERYTHING!
	
	NSString	*aPath = [[self documentsDirectory] stringByAppendingPathComponent:DATABASEPATH];
	NSString	*incomingPath = [[self documentsDirectory] stringByAppendingPathComponent:INCOMINGPATH];
	long		totalFiles = 0;
	
	[AppController createNoIndexDirectoryIfNecessary: aPath];
	
	// In the DATABASE FOLDER, we have only folders! Move all files that are wrongly there to the INCOMING folder.... and then scan these folders containing the DICOM files
	
	NSArray	*dirContent = [[NSFileManager defaultManager] directoryContentsAtPath:aPath];
	for( NSString *dir in dirContent)
	{
		NSString * itemPath = [aPath stringByAppendingPathComponent: dir];
		id fileType = [[[NSFileManager defaultManager] fileAttributesAtPath: itemPath traverseLink: YES] objectForKey:NSFileType];
		if ([fileType isEqual:NSFileTypeRegular])
		{
			[[NSFileManager defaultManager] movePath:itemPath toPath:[incomingPath stringByAppendingPathComponent: [itemPath lastPathComponent]] handler: nil];
		}
		else totalFiles += [[[[NSFileManager defaultManager] fileAttributesAtPath: itemPath traverseLink: YES] objectForKey: NSFileReferenceCount] intValue];
	}
	
	dirContent = [[NSFileManager defaultManager] directoryContentsAtPath:aPath];
	
	NSLog( @"Start Rebuild");
	
	for( NSString *name in dirContent)
	{
		NSAutoreleasePool		*pool = [[NSAutoreleasePool alloc] init];
		
		NSString	*curDir = [aPath stringByAppendingPathComponent: name];
		NSArray		*subDir = [[NSFileManager defaultManager] directoryContentsAtPath: [aPath stringByAppendingPathComponent: name]];
		
		for( NSString *subName in subDir)
		{
			if( [subName characterAtIndex: 0] != '.')
				[filesArray addObject: [curDir stringByAppendingPathComponent: subName]];
		}
		
		[pool release];
	}
	
	[wait close];
	[wait release];
	wait = nil;
	
	// ** DICOM ROI SR FOLDER
	dirContent = [[NSFileManager defaultManager] directoryContentsAtPath: [[self documentsDirectory] stringByAppendingPathComponent:@"ROIs"]];
	for( NSString *name in dirContent)
	{
		if( [name characterAtIndex: 0] != '.')
		{
			[filesArray addObject: [[[self documentsDirectory] stringByAppendingPathComponent:@"ROIs"] stringByAppendingPathComponent: name]];
		}
	}
	
	NSManagedObjectContext *context = self.database.context;
	NSManagedObjectModel *model = self.database.model;
	
	[context retain];
	[context lock];
	
	@try
	{
		// ** Finish the rebuild
		[[self addFilesToDatabase: filesArray onlyDICOM:NO produceAddedFiles:NO] valueForKey:@"completePath"];
		
		NSLog( @"End Rebuild");
		
		[filesArray release];
		
		Wait  *splash = [[Wait alloc] initWithString: NSLocalizedString(@"Step 3: Cleaning Database...", nil)];
		
		[splash showWindow:self];
		
		NSFetchRequest	*dbRequest;
		NSError			*error = nil;
		
		if( COMPLETEREBUILD == NO)
		{
			// FIND ALL images, and REMOVE non-available images
			
			NSFetchRequest *dbRequest = [[[NSFetchRequest alloc] init] autorelease];
			[dbRequest setEntity: [[model entitiesByName] objectForKey:@"Image"]];
			[dbRequest setPredicate: [NSPredicate predicateWithValue:YES]];
			error = nil;
			NSArray *imagesArray = [context executeFetchRequest:dbRequest error:&error];
			
			[[splash progress] setMaxValue:[imagesArray count]/50];
			
			// Find unavailable files
			int counter = 0;
			for( NSManagedObject *aFile in imagesArray)
			{
				
				FILE *fp = fopen( [[aFile valueForKey:@"completePath"] UTF8String], "r");
				if( fp)
				{
					fclose( fp);
				}
				else
					[context deleteObject: aFile];
				
				if( counter++ % 50 == 0) [splash incrementBy:1];
			}
		}
		
		dbRequest = [[[NSFetchRequest alloc] init] autorelease];
		[dbRequest setEntity: [[model entitiesByName] objectForKey:@"Study"]];
		[dbRequest setPredicate: [NSPredicate predicateWithValue:YES]];
		error = nil;
		NSArray *studiesArray = [context executeFetchRequest:dbRequest error:&error];
		NSString	*basePath = [NSString stringWithFormat: @"%@/REPORTS/", [self documentsDirectory]];
		
		if ([studiesArray count] > 0)
		{
			for( NSManagedObject *study in studiesArray)
			{
				BOOL deleted = NO;
				
				[self checkForExistingReport: study dbFolder: [self documentsDirectory]];
				
				if( [[study valueForKey:@"series"] count] == 0)
				{
					deleted = YES;
					[context deleteObject: study];
				}
				
				if( [[study valueForKey:@"noFiles"] intValue] == 0)
				{
					if( deleted == NO) [context deleteObject: study];
				}
			}
		}
		
		[self saveDatabase: currentDatabasePath];
		
		[splash close];
		[splash release];
		
		displayEmptyDatabase = NO;
		
		[self checkReportsDICOMSRConsistency];
		
		[self outlineViewRefresh];
		
		[checkIncomingLock unlock];
	}
	@catch( NSException *e)
	{
		NSLog( @"ReBuildDatabase exception: %@", e);
		[e printStackTrace];
	}
	[context unlock];
	[context release];
	
//	COMPLETEREBUILD = NO;
//	NEEDTOREBUILD = NO;
}




#pragma mark from BrowserControllerDCMTKCategory

#ifndef OSIRIX_LIGHT

-(NSData*)getDICOMFile:(NSString*)file inSyntax:(NSString*)syntax quality:(int)quality {
	OFCondition cond;
	OFBool status = NO;
	
	DcmFileFormat fileformat;
	cond = fileformat.loadFile( [file UTF8String]);
	
	if (cond.good())
	{
		DcmDataset *dataset = fileformat.getDataset();
		
		DcmXfer filexfer( dataset->getOriginalXfer());
		DcmXfer xfer( [syntax UTF8String]);
		
		if( filexfer.getXfer() == xfer.getXfer())
			return [NSData dataWithContentsOfFile: file];
		
		if(  filexfer.getXfer() == EXS_JPEG2000 && xfer.getXfer() == EXS_JPEG2000LosslessOnly)
			return [NSData dataWithContentsOfFile: file];
		
		if(  filexfer.getXfer() == EXS_JPEG2000LosslessOnly && xfer.getXfer() == EXS_JPEG2000)
			return [NSData dataWithContentsOfFile: file];
		
		// ------
		
		[[NSFileManager defaultManager] removeItemAtPath: @"/tmp/wado-recompress.dcm"  error: nil];
		
		if( [[NSUserDefaults standardUserDefaults] boolForKey: @"useDCMTKForJP2K"])
		{
			DcmItem *metaInfo = fileformat.getMetaInfo();
			
			DcmRepresentationParameter *params = nil;
			DJ_RPLossy lossyParams( 90);
			DJ_RPLossy JP2KParams( quality);
			DJ_RPLossy JP2KParamsLossLess( quality);
			DcmRLERepresentationParameter rleParams;
			DJ_RPLossless losslessParams(6,0);
			
			if( xfer.getXfer() == EXS_JPEGProcess14SV1TransferSyntax)
				params = &losslessParams;
			else if( xfer.getXfer() == EXS_JPEGProcess2_4TransferSyntax)
				params = &lossyParams; 
			else if( xfer.getXfer() == EXS_RLELossless)
				params = &rleParams;
			else if( xfer.getXfer() == EXS_JPEG2000LosslessOnly)
				params = &JP2KParamsLossLess; 
			else if( xfer.getXfer() == EXS_JPEG2000)
				params = &JP2KParams;
			
			// this causes the lossless JPEG version of the dataset to be created
			dataset->chooseRepresentation( xfer.getXfer(), params);
			
			// check if everything went well
			if (dataset->canWriteXfer( xfer.getXfer()))
			{
				// force the meta-header UIDs to be re-generated when storing the file 
				// since the UIDs in the data set may have changed 
				//delete metaInfo->remove(DCM_MediaStorageSOPClassUID);
				//delete metaInfo->remove(DCM_MediaStorageSOPInstanceUID);
				
				fileformat.loadAllDataIntoMemory();
				
				cond = fileformat.saveFile( "/tmp/wado-recompress.dcm", xfer.getXfer());
				status =  (cond.good()) ? YES : NO;
				
				if( status == NO)
					NSLog( @"getDICOMFile:(NSString*) file inSyntax:(NSString*) syntax quality: (int) quality failed");
			}
		}
		else
		{
			DCMObject *dcmObject = nil;
			@try
			{
				dcmObject = [[DCMObject alloc] initWithContentsOfFile: file decodingPixelData: NO];
				status = [dcmObject writeToFile: @"/tmp/wado-recompress.dcm" withTransferSyntax: [[[DCMTransferSyntax alloc] initWithTS: syntax] autorelease] quality: quality AET:@"OsiriX" atomically:YES];
			}
			@catch (NSException *e)
			{
				NSLog( @"dcmObject writeToFile failed: %@", e);
			}
			[dcmObject release];
		}
		
		if( status == NO || [[NSFileManager defaultManager] fileExistsAtPath: @"/tmp/wado-recompress.dcm"] == NO)
		{
			DCMObject *dcmObject = nil;
			@try
			{
				dcmObject = [[DCMObject alloc] initWithContentsOfFile: file decodingPixelData: NO];
				status = [dcmObject writeToFile: @"/tmp/wado-recompress.dcm" withTransferSyntax: [DCMTransferSyntax ExplicitVRLittleEndianTransferSyntax] quality: quality AET:@"OsiriX" atomically:YES];
				
			}
			@catch (NSException *e)
			{
				NSLog( @"dcmObject writeToFile failed: %@", e);
			}
			[dcmObject release];
		}
		
		NSData *data = [NSData dataWithContentsOfFile: @"/tmp/wado-recompress.dcm"];
		
		[[NSFileManager defaultManager] removeItemAtPath: @"/tmp/wado-recompress.dcm"  error: nil];
		
		return data;
	}
	
	return nil;
}

#endif




@end
