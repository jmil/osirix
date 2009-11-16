//
//  N2XMLRPCConnection.h
//  Nitrogen
//
//  Created by Alessandro Volz on 21.09.09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "N2Connection.h"

@interface N2XMLRPCConnection : N2Connection {
	id _delegate;
	BOOL _executed, _waitingToClose;
	NSTimer* _timeout;
}

@property(retain) id delegate;

-(void)handleRequest:(CFHTTPMessageRef)request;
-(void)writeAndReleaseResponse:(CFHTTPMessageRef)response;

@end
