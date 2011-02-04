//
//  OSIVolumeData.h
//  OsiriX
//
//  Created by Joël Spaltenstein on 1/25/11.
//  Copyright 2011 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CPRVolumeData.h>

// volume data represents a volume in the three natural dimensions
// this strictly represents a float volume, color volumes will be supported with a OSIRGBVolumeData, but no one really cares about that so it is being put off


@interface OSIFloatVolumeData : CPRVolumeData {

}


@end
