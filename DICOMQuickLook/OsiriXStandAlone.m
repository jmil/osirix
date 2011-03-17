#import <Foundation/Foundation.h>
#include "DicomFile.h"
#include "BrowserController.h"
#import <OsiriX/DCMCalendarDate.h>
#import <OsiriX/DCMAbstractSyntaxUID.h>
#import <vecLib/vecLib.h>

NSLock					*PapyrusLock = 0L;
NSThread				*mainThread = 0L;
BOOL					NEEDTOREBUILD = NO;
NSMutableDictionary		*DATABASECOLUMNS = 0L;
short					Altivec = 0, Use_kdu_IfAvailable = 1;
short					UseOpenJpeg = 0;

NSString * documentsDirectory()
{
	return 0L;
}

NSString* convertDICOM( NSString *inputfile)
{
	return inputfile;
}
