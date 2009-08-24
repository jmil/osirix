//
//  NSData+N2.h
//  Nitrogen Framework
//
//  Created by Alessandro Volz on 07/08/09.
//  Copyright 2009 OsiriX Foundation. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSData (N2)

+(NSData*)dataWithHex:(NSString*)hex;
-(NSData*)initWithHex:(NSString*)hex;

@end
