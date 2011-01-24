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

#import "N2ManagedDatabase.h"

@class DicomStudy;

/*
 This class currently only does 1/1000 of what it is planned to do later.
 This will be a BrowserController's backbone.
 */
@interface DicomDatabase : N2ManagedDatabase {
	NSTimeInterval lastCheckIncoming;
}

+(DicomDatabase*)defaultDatabase;

extern NSString* const OsirixActiveDatabaseChangedNotification;
+(DicomDatabase*)activeDatabase;
+(void)setActiveDatabase;

+(NSString*)baseDirectoryPathForMode:(NSInteger)mode path:(NSString*)path;

-(NSString*)sqlFilePath;
-(NSString*)versionFilePath;
-(NSString*)databaseDirectoryPath;
-(NSString*)decompressionDirectoryPath;
-(NSString*)incomingDirectoryPath;
-(NSString*)toBeIndexedDirectoryPath;
-(NSString*)temporaryDirectoryPath;
-(NSString*)errDirectoryPath;
-(NSString*)reportsDirectoryPath;
-(NSString*)dumpDirectoryPath;
-(NSString*)htmlTemplatesDirectoryPath;
-(NSString*)pagesTemplatesDirectoryPath;
	
+(NSPredicate*)predicateForSmartAlbumFilter:(NSString*)string;
-(void)addDefaultAlbums;
+(NSArray*)albumsInContext:(NSManagedObjectContext*)context;
-(NSArray*)albums;


#pragma mark Add files

-(NSArray*)addFiles:(NSArray*)newFilesArray onlyDICOM:(BOOL)onlyDICOM notifyAddedFiles:(BOOL)notifyAddedFiles parseExistingObject:(BOOL)parseExistingObject;
-(NSArray*)addFiles:(NSArray*)newFilesArray onlyDICOM:(BOOL)onlyDICOM notifyAddedFiles:(BOOL)notifyAddedFiles parseExistingObject:(BOOL)parseExistingObject generatedByOsiriX:(BOOL)generatedByOsiriX;
-(NSArray*)addFiles:(NSArray*)newFilesArray onlyDICOM:(BOOL)onlyDICOM notifyAddedFiles:(BOOL)notifyAddedFiles parseExistingObject:(BOOL)parseExistingObject generatedByOsiriX:(BOOL)generatedByOsiriX mountedVolume:(BOOL)mountedVolu;

#pragma mark Reports

-(void)checkForExistingReport:(DicomStudy*)study;

#pragma mark from BrowserControllerDCMTKCategory

#ifndef OSIRIX_LIGHT
-(NSData*)getDICOMFile:(NSString*)file inSyntax:(NSString*)syntax quality:(int)quality;
#endif

-(BOOL)supportsRebuild;
-(BOOL)isBonjour;


@end
