//
//   DCMJpegImportFilter
//  
//

#import <Foundation/Foundation.h>
#import "OsiriX Headers/PluginFilter.h"

@class DCMCalendarDate;

@interface DCMJpegImportFilter : PluginFilter
{
	int imageNumber;
}

- (long) filterImage:(NSString*) menuName;
- (void) convertImageToDICOM:(NSString *)path source:(NSString *)src;

@end
