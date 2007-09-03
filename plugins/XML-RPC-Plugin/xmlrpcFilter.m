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
//  closeAllWindows - no parameters
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
	
	NSLog( [httpServerMessage description]);
	
	// ****************************************************************************************
	
	if( [[httpServerMessage valueForKey: @"MethodName"] isEqualToString: @"closeAllWindows"])
	{
		if( [[httpServerMessage valueForKey: @"Processed"] boolValue] == NO)							// Is this order already processed ?
		{
			NSMutableArray *viewersList = [ViewerController getDisplayed2DViewers];
			int i;
			
			for( i = 0; i < [viewersList count] ; i++)
			{
				[[[viewersList objectAtIndex: i] window] close];
			}
			
			[httpServerMessage setValue: [NSNumber numberWithBool: YES] forKey: @"Processed"];		// To tell to other XML-RPC that we processed this order
			
			// Done, we can send the response to the sender
			
			NSString *xml = @"<?xml version=\"1.0\"?><methodResponse><params><param><value><struct><member><name>error</name><value>0</value></member></struct></value></param></params></methodResponse>";		// Simple answer, no errors
			NSError *error = nil;
			NSXMLDocument *doc = [[[NSXMLDocument alloc] initWithXMLString:xml options:NSXMLNodeOptionsNone error:&error] autorelease];
			[httpServerMessage setValue: doc forKey: @"NSXMLDocumentResponse"];
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
		}
	}
	
	// ****************************************************************************************
}

- (long) filterImage : (NSString*) menuName
{

	NSRunInformationalAlertPanel( @"XML-RPC Plugin", @"This plugin is a XML-RPC message listener.", @"OK", 0L, 0L);
	
	return 0;
}

@end