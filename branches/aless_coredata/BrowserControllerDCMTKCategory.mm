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

#import "BrowserControllerDCMTKCategory.h"
#import <OsiriX/DCMObject.h>
#import <OsiriX/DCM.h>
#import <OsiriX/DCMTransferSyntax.h>
#import <OsiriX/DCMAbstractSyntaxUID.h>
#import "AppController.h"
#import "DCMPix.h"
#import "WaitRendering.h"
#import "DicomDatabase+DCMTK.h"

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

extern NSRecursiveLock *PapyrusLock;

@implementation BrowserController (BrowserControllerDCMTKCategory)

+ (NSString*) compressionString: (NSString*) string
{
	if( [string isEqualToString: @"1.2.840.10008.1.2"])
		return NSLocalizedString( @"Uncompressed", nil);
	if( [string isEqualToString: @"1.2.840.10008.1.2.1"])
		return NSLocalizedString( @"Uncompressed", nil);
	if( [string isEqualToString: @"1.2.840.10008.1.2.2"])
		return NSLocalizedString( @"Uncompressed BigEndian", nil);
	
	if( dcmFindNameOfUID( [string UTF8String]))
		return [NSString stringWithFormat:@"%s", dcmFindNameOfUID( [string UTF8String])];
	else
		return NSLocalizedString( @"Unknown UID", nil);
}

#ifndef OSIRIX_LIGHT

- (NSData*) getDICOMFile:(NSString*) file inSyntax:(NSString*) syntax quality: (int) quality
{
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

-(BOOL)needToCompressFile:(NSString*)path { // __deprecated
	return [DicomDatabase fileNeedsDecompression:path];
}


-(BOOL)compressDICOMWithJPEG:(NSArray*)paths { // __deprecated
	return [_database compressFilesAtPaths:paths];
}

-(BOOL)compressDICOMWithJPEG:(NSArray*)paths to:(NSString*)dest { // __deprecated
	return [_database compressFilesAtPaths:paths intoDirAtPath:dest];
}

-(BOOL)decompressDICOMList:(NSArray*)files to:(NSString*)dest { // __deprecated
	return [_database decompressFilesAtPaths:files intoDirAtPath:dest];
}

- (BOOL) testFiles: (NSArray*) files;
{
	WaitRendering *splash = nil;
	NSMutableArray *tasksArray = [NSMutableArray array];
	int CHUNK_SIZE;
	
	if( [NSThread isMainThread])
	{
		splash = [[WaitRendering alloc] init: NSLocalizedString( @"Validating files...", nil)];
		[splash showWindow:self];
		[splash setCancel: YES];
		[splash start];
	}
	
	BOOL succeed = YES;
	
	int total = [files count];
	
	CHUNK_SIZE = total / MPProcessors();
	if( CHUNK_SIZE > 500)
		CHUNK_SIZE = 500;
	else
		CHUNK_SIZE += 20;
	
	@try
	{
		for( int i = 0; i < total;)
		{
			int no;
			
			if( i + CHUNK_SIZE >= total) no = total - i; 
			else no = CHUNK_SIZE;
			
			NSRange range = NSMakeRange( i, no);
			
			id *objs = (id*) malloc( no * sizeof( id));
			if( objs)
			{
				[files getObjects: objs range: range];
				
				NSArray *subArray = [NSArray arrayWithObjects: objs count: no];
				
				NSTask *theTask = [[[NSTask alloc] init] autorelease];
				
				[tasksArray addObject: theTask];
				
				NSArray *parameters = [[NSArray arrayWithObjects: @"unused", @"testFiles", nil] arrayByAddingObjectsFromArray: subArray];
				
				[theTask setArguments: parameters];
				[theTask setLaunchPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"/Decompress"]];
				[theTask launch];
				
				free( objs);
			}
			
			i += no;
		}
	}
	@catch ( NSException *e)
	{
		NSLog( @"***** testList exception : %@", e);
		succeed = NO;
	}
	
	@try
	{
		for( NSTask *t in tasksArray)
		{
			while( [t isRunning] && [splash aborted] == NO)
			{
				[NSThread sleepForTimeInterval: 0.05];
				[splash run];
			}
			
			if( [splash aborted])
				break;
			
			if( [t terminationStatus] != 0)
				succeed = NO;
		}
		
		if( [splash aborted])
		{
			for( NSTask *t in tasksArray)
				[t interrupt];
		}
	}
	@catch (NSException * e)
	{
		NSLog( @"***** testList exception 2 : %@", e);
	}
	[splash end];
	[splash close];
	[splash release];
	
	if( succeed == NO)
		NSLog( @"******* test Files FAILED : one of more of these files are corrupted : %@", files);
	
	return succeed;
}

#endif

@end
