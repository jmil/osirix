//
//  xmlrpcFilter.m
//  xmlrpc
//
//  XML-RPC Generator for MacOS: http://www.ditchnet.org/xmlrpc/
//
//  About XML-RPC: http://www.xmlrpc.com/
//
//  This plugin supports 2 methods for xml-rpc messages
//
//  exportSelectedToPath - {path:"/Users/antoinerosset/Desktop/"}
//
//  openSelectedWithTiling - {rowsTiling:2, columnsTiling:2}
//

#import "xmlrpcFilter.h"
#import "DCMPix.h"
#import "ViewerController.h"
#import "DicomFile.h"
#import "BrowserController.h"

@implementation xmlrpcFilter

- (void) initPlugin
{
	NSLog( @"************* xml-rpc plugin init :-)");
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OsiriXXMLRPCMessage:) name:@"OsiriXXMLRPCMessage" object:nil];
}

- (void) OsiriXXMLRPCMessage: (NSNotification*) note
{
	NSMutableDictionary	*httpServerMessage = [note object];
	
	// ****************************************************************************************
	
	if( [[httpServerMessage valueForKey: @"MethodName"] isEqualToString: @"importFromURL"])
	{
		NSXMLDocument *doc = [httpServerMessage valueForKey:@"NSXMLDocument"];						// We need the parameters
		
		NSError	*error = 0L;
		NSArray *keys = [doc nodesForXPath:@"methodCall/params//member/name" error:&error];
		NSArray *values = [doc nodesForXPath:@"methodCall/params//member/value" error:&error];
		if (1 == [keys count] || 1 == [values count])
		{
			int i;
			NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
			for( i = 0; i < [keys count]; i++)
				[paramDict setValue: [[values objectAtIndex: i] objectValue] forKey: [[keys objectAtIndex: i] objectValue]];
			
			// Ok, now, we have the parameters -> execute it !
			
//			NSArray *result = [[BrowserController currentBrowser] addURLToDatabaseFiles: [NSArray arrayWithObject: [NSURL URLWithString: @"http://www.osirix-viewer.com/internet.dcm"]]];
			NSArray *result = [[BrowserController currentBrowser] addURLToDatabaseFiles: [NSArray arrayWithObject: [NSURL URLWithString: [paramDict valueForKey:@"url"]]]];
			
			if( [result count] == 0) NSLog(@"error.... addURLToDatabaseFiles failed");
			
			// Done, we can send the response to the sender
			
			NSString *xml = @"<?xml version=\"1.0\"?><methodResponse><params><param><value><struct><member><name>error</name><value>0</value></member></struct></value></param></params></methodResponse>";		// Simple answer, no errors
			NSError *error = nil;
			NSXMLDocument *doc = [[[NSXMLDocument alloc] initWithXMLString:xml options:NSXMLNodeOptionsNone error:&error] autorelease];
			[httpServerMessage setValue: doc forKey: @"NSXMLDocumentResponse"];
			[httpServerMessage setValue: [NSNumber numberWithBool: YES] forKey: @"Processed"];		// To tell to other XML-RPC that we processed this order
		}
	}
	
	// ****************************************************************************************
	
	if( [[httpServerMessage valueForKey: @"MethodName"] isEqualToString: @"exportSelectedToPath"])
	{
		NSXMLDocument *doc = [httpServerMessage valueForKey:@"NSXMLDocument"];						// We need the parameters
		
		NSError	*error = 0L;
		NSArray *keys = [doc nodesForXPath:@"methodCall/params//member/name" error:&error];
		NSArray *values = [doc nodesForXPath:@"methodCall/params//member/value" error:&error];
		if (1 == [keys count] || 1 == [values count])
		{
			int i;
			NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
			for( i = 0; i < [keys count]; i++)
				[paramDict setValue: [[values objectAtIndex: i] objectValue] forKey: [[keys objectAtIndex: i] objectValue]];
			
			// Ok, now, we have the parameters -> execute it !
			
			NSMutableArray *dicomFiles2Export = [NSMutableArray array];
			NSMutableArray *filesToExport;
			
			filesToExport = [[BrowserController currentBrowser] filesForDatabaseOutlineSelection: dicomFiles2Export onlyImages:YES];
			[[BrowserController currentBrowser] exportDICOMFileInt: [paramDict valueForKey:@"path"] files: filesToExport objects: dicomFiles2Export];
			
			// Done, we can send the response to the sender
			
			NSString *xml = @"<?xml version=\"1.0\"?><methodResponse><params><param><value><struct><member><name>error</name><value>0</value></member></struct></value></param></params></methodResponse>";		// Simple answer, no errors
			NSError *error = nil;
			NSXMLDocument *doc = [[[NSXMLDocument alloc] initWithXMLString:xml options:NSXMLNodeOptionsNone error:&error] autorelease];
			[httpServerMessage setValue: doc forKey: @"NSXMLDocumentResponse"];
			[httpServerMessage setValue: [NSNumber numberWithBool: YES] forKey: @"Processed"];		// To tell to other XML-RPC that we processed this order
		}
	}

	
	// ****************************************************************************************
	
	if( [[httpServerMessage valueForKey: @"MethodName"] isEqualToString: @"openSelectedWithTiling"])
	{
		NSXMLDocument *doc = [httpServerMessage valueForKey:@"NSXMLDocument"];						// We need the parameters
		
		NSError	*error = 0L;
		NSArray *keys = [doc nodesForXPath:@"methodCall/params//member/name" error:&error];
		NSArray *values = [doc nodesForXPath:@"methodCall/params//member/value" error:&error];
		if (2 == [keys count] || 2 == [values count])
		{
			int i;
			NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
			for( i = 0; i < [keys count]; i++)
				[paramDict setValue: [[values objectAtIndex: i] objectValue] forKey: [[keys objectAtIndex: i] objectValue]];
			
			// Ok, now, we have the parameters -> execute it !
			
			[[BrowserController currentBrowser] viewerDICOM: self];
			
			// And change the tiling, of the frontmost viewer
			
			NSMutableArray *viewersList = [ViewerController getDisplayed2DViewers];
			
			for( i = 0; i < [viewersList count] ; i++)
			{
				{
					[[viewersList objectAtIndex: i] checkEverythingLoaded];
					[[viewersList objectAtIndex: i] setImageRows: [[paramDict valueForKey: @"rowsTiling"] intValue] columns: [[paramDict valueForKey: @"rowsTiling"] intValue]];
				}
			}
			
			// Done, we can send the response to the sender
			
			NSString *xml = @"<?xml version=\"1.0\"?><methodResponse><params><param><value><struct><member><name>error</name><value>0</value></member></struct></value></param></params></methodResponse>";		// Simple answer, no errors
			NSError *error = nil;
			NSXMLDocument *doc = [[[NSXMLDocument alloc] initWithXMLString:xml options:NSXMLNodeOptionsNone error:&error] autorelease];
			[httpServerMessage setValue: doc forKey: @"NSXMLDocumentResponse"];
			[httpServerMessage setValue: [NSNumber numberWithBool: YES] forKey: @"Processed"];		// To tell to other XML-RPC that we processed this order
		}
	}
	
	// ****************************************************************************************

	NSLog( [httpServerMessage description]);
}

- (long) filterImage : (NSString*) menuName
{

	NSRunInformationalAlertPanel( @"XML-RPC Plugin", @"This plugin is a XML-RPC message listener.", @"OK", 0L, 0L);
	
	return 0;
}

@end