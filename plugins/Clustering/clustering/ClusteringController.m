#import "ClusteringController.h"
#import "BrowserController.h"


@implementation ClusteringController

- (id) init
{
	NSLog(@"init ClusteringController !");
	self = [super initWithWindowNibName:@"Clustering"];
	
	connectionDone=NO;
	// init clusterDS
	
	clusterDS=[[NSMutableArray alloc] initWithCapacity:10];
	NSMutableDictionary* values=[NSMutableDictionary dictionaryWithCapacity:8];
	NSButtonCell*	buttonCell;
	buttonCell = [[NSButtonCell alloc] init];
    [buttonCell setButtonType:NSSwitchButton];
    [buttonCell setTitle:@""];
	[buttonCell setState:YES];
	[values setObject:buttonCell forKey:@"Add"];
	[buttonCell release];
	
	[values setObject:@"Lavim" forKey:@"Name"];
	[values setObject:@"127.0.0.1" forKey:@"Ip"];
	[values setObject:@"4242" forKey:@"Port"];
	
	[clusterDS addObject:values];
	
	// register server to wget end
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(finishedDownload:) 
												 name:NSTaskDidTerminateNotification 
											   object:nil];
	
	// register controller to Remote Notification
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(osirixAddToDB:) name:@"OsirixAddToDBNotification" object:nil];
	
	[[NSFileManager defaultManager] createDirectoryAtPath: [[[BrowserController currentBrowser] documentsDirectory] stringByAppendingFormat:@"/CLUSTER/"] attributes: 0L];
	[[NSFileManager defaultManager] createDirectoryAtPath: [[[BrowserController currentBrowser] documentsDirectory] stringByAppendingFormat:@"/CLUSTER/CLIENTQUEUE/"] attributes: 0L];
	[[NSFileManager defaultManager] createDirectoryAtPath: [[[BrowserController currentBrowser] documentsDirectory] stringByAppendingFormat:@"/CLUSTER/SERVERQUEUE/"] attributes: 0L];
	
	/*
	 // init wget
	 wget=[[NSTask alloc] init];
	 [wget setLaunchPath:@"/opt/local/bin/wget"];
	 [wget setCurrentDirectoryPath:  [[[BrowserController currentBrowser] documentsDirectory] stringByAppendingPathComponent:@"INCOMING"]];
	 */
	
	return self;
}

- (void)awakeFromNib
{
	//customize Create/Activate tab
	[createTabView setTabViewType:NSNoTabsBezelBorder];
	[createTabView selectTabViewItemWithIdentifier:@"start"];
	
	// set HUG ip
	NSString* ip=[NSString stringWithString:@"IP: "];
	[ipTextField setStringValue:[ip stringByAppendingString:[self retrieveHUGIP]]];
	
	// start on the join tab
	[clusterTab selectTabViewItemWithIdentifier:@"join"];
}

- (void) dealloc
{
	if(remoteDistributedNC) [remoteDistributedNC release];
	if(RDNCServer) [RDNCServer release];
	[clusterDS release];
	//[ftpServer release];
	//[wget release]; 
	[super dealloc];
}

-(void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	NSMutableDictionary* rowValues = [clusterDS objectAtIndex:rowIndex];
	[rowValues setObject:anObject forKey:[aTableColumn identifier]];
	//NSLog(@"[ClusteringController] TB setObjectValue=%@",anObject);
}

- (id)tableView:(NSTableView *)tableView
      objectValueForTableColumn:(NSTableColumn *)tableColumn
			row:(int)row
{
	//if (![[tableColumn identifier] isEqualToString:@"2006"])
	NSMutableDictionary* rowValues = [clusterDS objectAtIndex:row];
	return [rowValues objectForKey:[tableColumn identifier]];
}

- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [clusterDS count];
}

// Join clusters
- (IBAction)connectToServer:(id)sender
{
	//unsigned short port=[[NSNumber numberWithInt:[serverPortTextField intValue]] unsignedShortValue];
	//hostServer=[NSString stringWithString:[serverHostTextField stringValue]];
	
	//ftpServer=[[NSString alloc] initWithString:[@"ftp://joris:1234@" stringByAppendingString:hostServer]];
	
	[joinButton setEnabled:NO];
	// for now join only one server
	NSMutableDictionary* rowValues = [clusterDS objectAtIndex:0];
	NSString *hostServer=[NSString stringWithString:[rowValues objectForKey:@"Ip"]];
	NSLog(@"[Clustering Controller], connectToServer: host =%@",hostServer);
	remoteDistributedNC = [[RemoteDistributedNotificationCenter alloc] initWithTCPPort:4242 host:hostServer isTransactional:YES];
	[remoteDistributedNC	addObserver: self
							   selector: @selector(osirixRDAddToDB:)
								   name: @"OsirixRDAddedImages"];
}

-(void)waitConnection
{
	if([RDNCServer isRunning] && !connectionDone)
	{
		[timerServerStatus invalidate];
		connectionDone=YES;
		[progressConnection stopAnimation:nil];
		[createTabView selectTabViewItemWithIdentifier:@"ready"];
		
		// automatically connect the server
		remoteDistributedNC = [[RemoteDistributedNotificationCenter alloc] initWithTCPPort:4242 host:@"127.0.0.1" isTransactional:YES];
		[remoteDistributedNC	addObserver: self
								   selector: @selector(osirixRDAddToDB:)
									   name: @"OsirixRDAddedImages"];
	}
}

-(NSString*)retrieveHUGIP
{
	NSString* ip=nil;
	NSArray	*addresses = [[NSHost currentHost] addresses];
	NSEnumerator *addressesEnumerator = [addresses objectEnumerator];
	NSString *anAddress;
	while (anAddress = [addressesEnumerator nextObject])
	{
		NSLog(@"anAddress : %@", anAddress);
		if([anAddress hasPrefix:@"129."])
		{
			ip = [NSString stringWithString:anAddress];
			break;
		}
	}
	return ip;
}

// activate cluster !
- (IBAction)enableServer:(id)sender
{
	
	if ([sender state])
	{
		NSLog(@"Activate Cluster !");
		[createTabView selectTabViewItemWithIdentifier:@"wait"];
		[activateButton setEnabled: NO];
		[progressConnection startAnimation:nil];
		[joinButton setEnabled:NO];
		//RDNCServer = [[RDNotificationServer alloc] initWithDefaultContainer];
		RDNCServer = [[RDNotificationServer alloc] initWithTransactionalContainer];
		//[self performSelectorOnMainThread:@selector(waitConnection) withObject:nil afterDelay:0];
		timerServerStatus=[NSTimer scheduledTimerWithTimeInterval:5
																	target:self
																  selector:@selector(waitConnection)
																  userInfo:nil
																   repeats:YES];
	}
	else
	{
		NSLog(@"kill Cluster server !");
		[RDNCServer stopServer];
		[RDNCServer release];
	}
	
}

- (void)osirixAddToDB:(NSNotification*) note
{
	NSAutoreleasePool* pool1 = [[NSAutoreleasePool alloc] init];
	
	NSLog(@"osirixAddToDB");
	
	NSArray *images = [[note userInfo] valueForKey:@"OsiriXAddToDBArray"];
	
	//	NSMutableArray *datas = [[NSMutableArray alloc] initWithCapacity:[images count]];
	NSMutableArray *datas = [[NSMutableArray alloc] initWithCapacity:200];
	int i;
	
	NSLog(@">>>[images count] : %d", [images count]);
	
	if(![[note userInfo] valueForKey:@"hasBeenSent"])
	{
		
		//NSMutableDictionary *newUserInfo = [NSMutableDictionary dictionaryWithDictionary:[note userInfo]];
		NSMutableDictionary *newUserInfo = [NSMutableDictionary dictionaryWithCapacity:2];
		if(newUserInfo)
		{
			[newUserInfo setObject:[NSNumber numberWithBool:YES] forKey:@"hasBeenSent"];
			[newUserInfo setObject:[remoteDistributedNC softID] forKey:@"softID"];
		}
		//NSNotification* NewNote = [NSNotification notificationWithName:[note name] object:datas userInfo:newUserInfo];
		int cpt=0;
		for(i=0; i<[images count] ; i++)
		{
			NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
			
			[datas addObject:[NSData dataWithContentsOfFile:[[images objectAtIndex:i] valueForKey:@"completePath"]]];
			
			//NSLog(@"last added object : %@", [[datas lastObject] className]);
			
			cpt++;
			if (cpt>=200)
			{
				NSLog(@"# i: %d, cpt : %d, [datas count] : %d", i, cpt, [datas count]);
				NSLog(@"# postNotification");
				[remoteDistributedNC postNotificationName:@"OsirixRDAddedImages" object:[NSArray arrayWithArray:datas] userInfo:newUserInfo];
				NSLog(@"# [datas removeAllObjects]");
				[datas removeAllObjects];
				NSLog(@"# cpt=0");
				cpt=0;
				NSDate *sleepUntil = [NSDate dateWithTimeIntervalSinceNow:5];
				[NSThread sleepUntilDate:sleepUntil];
			}
			[pool release];
		}
		if (cpt>0)
		{
			NSLog(@"# cpt : %d, [datas count] : %d", cpt, [datas count]);
			NSLog(@"# postNotification");
			[remoteDistributedNC postNotificationName:@"OsirixRDAddedImages" object:[NSArray arrayWithArray:datas] userInfo:newUserInfo];
		}
		NSLog(@">>> [datas count] : %d", [datas count]);
	}
	
	[datas release];
	[pool1 release];
}


/*
 // strategy with wget!
 - (void)osirixAddToDB:(NSNotification*) note
 {
	 NSAutoreleasePool* pool1 = [[NSAutoreleasePool alloc] init];	
	 NSLog(@"osirixAddToDB");
	 NSArray *images = [[note userInfo] valueForKey:@"OsiriXAddToDBArray"];
	 NSMutableArray *imagesPath=[NSMutableArray arrayWithCapacity:[images count]];
	 int i;
	 NSRange range;
	 for(i=0;i<[images count];i++)
	 {
		 // retrieve relative path
		 NSString* relativePath=[[[images objectAtIndex:i] valueForKey:@"completePath"] stringByAbbreviatingWithTildeInPath];
		 // remove tilde
		 range.length=[relativePath length]-1;
		 range.location=1;
		 [imagesPath addObject:[relativePath substringWithRange:range]];	
	 }
	 
	 
	 NSLog(@">>>[images count] : %d", [images count]);
	 
	 if(![[note userInfo] valueForKey:@"hasBeenSent"])
	 {
		 NSMutableDictionary *newUserInfo = [NSMutableDictionary dictionaryWithCapacity:2];
		 if(newUserInfo)
		 {
			 [newUserInfo setObject:[NSNumber numberWithBool:YES] forKey:@"hasBeenSent"];
			 [newUserInfo setObject:[remoteDistributedNC softID] forKey:@"softID"];
		 }
		 
		 NSLog(@"# postNotification");
		 [remoteDistributedNC postNotificationName:@"OsirixRDAddedImages" object:imagesPath userInfo:newUserInfo];
	 }
	 
	 [pool1 release];
 }
 
 // strategy with wget!
 - (NSNumber*)osirixRDAddToDB:(NSNotification*) note
 {
	 int i=0;
	 NSLog(@">>> osirixRDAddToDB");
	 if(![[[note userInfo] valueForKey:@"softID"] isEqualToString:[remoteDistributedNC softID]])
	 {
		 NSArray *images = [note object];
		 for(i=0;i<[images count];i++)
		 {
			 NSString* path=[NSString stringWithString:[ftpServer stringByAppendingString:[images objectAtIndex:i]]];
			 NSLog(@"--> wget %@",path);
			 [wget setArguments:[NSArray arrayWithObject:path]];
			 [wget launch];
		 }
	 }
	 else
	 {
		 NSLog(@">>> same softID");
	 }
	 return [NSNumber numberWithInt:8];
 }
 */


// reception de la notif distrib
- (NSNumber*)osirixRDAddToDB:(NSNotification*) note
{
	NSLog(@">>> osirixRDAddToDB");
	// sauvegarde de limage [note object]
	// update du path dans le dico
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"OsirixAddToDBNotification" object:note];
	if(![[[note userInfo] valueForKey:@"softID"] isEqualToString:[remoteDistributedNC softID]])
	{
		NSArray *datas = [note object];
		NSMutableArray *filesPaths = [[NSMutableArray alloc] initWithCapacity:[datas count]];
		
		NSString	*dstPath;
		
		int i;
		for(i=0; i<[datas count] ; i++)
		{
			//NSLog(@">>>[[datas objectAtIndex:i] length] : %d", [[datas objectAtIndex:i] length]);
			
			dstPath = [[BrowserController currentBrowser] getNewFileDatabasePath:@""];
			
			[[datas objectAtIndex:i] writeToFile: dstPath atomically:NO];
			[filesPaths addObject:dstPath];
		}
		[[BrowserController currentBrowser] addFilesToDatabase:filesPaths onlyDICOM:NO safeRebuild:NO produceAddedFiles:NO];
		[filesPaths release];
	}
	else
	{
		NSLog(@">>> same softID");
	}
	return [NSNumber numberWithInt:8];
}

- (NSString*)softID
{
	return [remoteDistributedNC softID];
}

- (void)finishedDownload:(NSNotification *)aNotification {
	
	NSLog(@"retrieve image...");
	//[wget release]; // Don't forget to clean up memory
	//wget=nil; // Just in case...
}

@end
