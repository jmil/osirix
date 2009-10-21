//
//  ClientListener.h
//  HUGE Administration Tool
//
//  Created by Alessandro Volz on 7/22/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>

const extern NSString* N2ConnectionListenerOpenedConnectionNotification;
const extern NSString* N2ConnectionListenerOpenedConnection;

@class N2Connection;

@interface N2ConnectionListener : NSObject  {
	Class _class;
    CFSocketRef ipv4socket;
    CFSocketRef ipv6socket;	
	NSMutableArray* _clients;
}

-(id)initWithPort:(NSInteger)port connectionClass:(Class)classs;
-(id)initWithPath:(NSString*)path connectionClass:(Class)classs;
-(N2Connection*)handleNewConnectionFromAddress:(NSData*)addr inputStream:(NSInputStream*)istr outputStream:(NSOutputStream*)ostr;

@end
