//
//  NSURL+N2.h
//  Nitrogen
//
//  Created by Alessandro Volz on 19.10.09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface N2URLParts : NSObject {
	NSString *_protocol, *_address, *_port, *_path, *_params;
}

@property(retain) NSString *protocol, *address, *port, *path, *params;
@property(readonly) NSString* pathAndParams;

@end


@interface NSURL (N2)

-(N2URLParts*)parts;
+(NSURL*)URLWithParts:(N2URLParts*)parts;

@end
