#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@class ViewerController;

@interface DicomFile: NSObject <NSCoding>
{
    NSCalendarDate      *date;
    NSString            *description, *descriptionshort;
    NSString            *name;
    NSString            *study;
    NSString            *serie;
    NSString            *filePath;
    NSString            *Modality;
	NSString			*SOPUID;
	NSString			*comment;
    
    NSString            *studyID;
    NSString            *serieID;
    NSString            *imageID;
	NSString			*patientID;
	NSString			*studyIDs;
	NSString			*sliceLocation;
    
    char                type;
    long                noFiles;
    long                filesSize;
	long				width, height;
	long				NoOfFrames;
	long				NoOfSeries;
    
    NSMutableArray      *child;
	NSMutableArray		*father;
	DicomFile			*fatherDicomFile;
    
    ViewerController    *viewer[ 50];
    
    NSString            *fatherDescription;
    NSString            *stringForSorting;
	
	NSCalendarDate		*dateAdded, *dateOpened;
	
	BOOL				loadingFlag;
	BOOL				valid;
	BOOL				local;
	BOOL				iPod;
	
	NSMutableDictionary *dicomElements;
}

- (NSCalendarDate*) dateOpened;
- (void) setDateAdded:(NSCalendarDate*) d;
- (BOOL) valid;
- (long) NoOfFrames;
- (long) NoOfSeries;
- (BOOL) loadingFlag;
- (BOOL) setLoadingFlag:(BOOL)w;
- (long) getWidth;
- (long) getHeight;
- (void) setWidthHeight:(short) w :(short)h;
- (void) addChild:(NSMutableArray*) p;
- (NSMutableArray*) child;
- (void) setFather: (NSMutableArray*) p :(DicomFile*) f;
- (NSMutableArray*) father;
- (void) computeStringForSorting;
- (BOOL) findViewer :(long) s;
- (void) setViewer:(ViewerController*) v forSerie:(long)s;
- (void) setDType:(char)t;
- (char) Dtype;
- (NSCalendarDate*) dateAdded;
- (void) setDescription:(NSString*)d :(NSString*)e;
- (NSString*) description;
- (NSString*) descriptionshort;
- (NSString*) fatherDescription;
- (void) setNo:(long)a setSize:(long)b;
- (void) addNo:(long)a addSize:(long)b;
- (NSString *)stringForSorting;
- (NSString *)filesSizeFormatted;
- (NSComparisonResult)compareDcm:(DicomFile *)p;
- (id) init:(NSString*) f;
- (id) initWithObject: (DicomFile*) other;
- (NSString*) patName;
- (NSString*) filePath;
- (NSCalendarDate*) date;
- (NSString*) study;
- (NSString*) serie;
- (NSString*) studyIDs;
- (NSString*) serieID;
- (NSString*) imageID;
- (NSString*) Modality;
- (NSString*) patientID;
- (NSString*) studyID;
- (NSString*) SOPUID;
- (NSString *)uid;
- (NSString*) sliceLocationString;
- (long) filesSize;
- (long) noFiles;
- (BOOL) local;
- (BOOL) iPod;
- (void) setLocal :(BOOL) l;
- (void) SetDateOpened;
- (void) setModality:(NSString*) m;
- (void) setNoFiles:(long)number;
- (NSMutableDictionary *)dicomElements;
- (id)elementForKey:(id)key;
- (int)numberFromLocalizedStringEncodingName:(NSString*)aName;
@end