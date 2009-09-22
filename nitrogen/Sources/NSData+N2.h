//
//  NSData+N2.h
//  Nitrogen Framework
//
//  Created by Alessandro Volz on 07/08/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSData (N2)

+(NSData*)dataWithHex:(NSString*)hex;
-(NSData*)initWithHex:(NSString*)hex;
+(NSData*)dataWithBase64:(NSString*)base64;
-(NSData*)initWithBase64:(NSString*)base64;
-(NSString*)base64;

@end
