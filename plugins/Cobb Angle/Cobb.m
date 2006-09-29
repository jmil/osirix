//
//  Cobb.m
//

#import "Cobb.h"
#import "ROI.h"

@implementation Cobb

- (void) create: (NSArray*) A :(NSArray*) B :(NSMutableArray*) roiImageList
{
	ROI				*newROI;
	
	NSPoint	a1 = [[A objectAtIndex: 0] point], a2 = [[A objectAtIndex: 1] point], b1 = [[B objectAtIndex: 0] point], b2 = [[B objectAtIndex: 1] point];

	newROI = [viewerController newROI: tAngle];

	// Points of this ROI (it's currently empty)
	NSMutableArray  *points = [newROI points];
	
	NSPoint	a, b, c, d;
	
	a = NSMakePoint( a1.x + (a2.x - a1.x)/2, a1.y + (a2.y - a1.y)/2);
	
	float slope1 = (a2.y - a1.y) / (a2.x - a1.x);
	slope1 = -1./slope1;
	float or1 = a.y - slope1*a.x;

	float slope2 = (b2.y - b1.y) / (b2.x - b1.x);
	float or2 = b1.y - slope2*b1.x;
	
	float xx = (or2 - or1) / (slope1 - slope2);
	
	d = NSMakePoint( xx, or1 + xx*slope1);

	b = [newROI ProjectionPointLine: a :b1 :b2];
	
	b.x = b.x + (d.x - b.x)/2.;
	b.y = b.y + (d.y - b.y)/2.;
	
	slope2 = -1./slope2;
	or2 = b.y - slope2*b.x;
	
	xx = (or2 - or1) / (slope1 - slope2);
	
	c = NSMakePoint( xx, or1 + xx*slope1);
	
	[points addObject: [viewerController newPoint : b.x : b.y]];
	[points addObject: [viewerController newPoint : c.x : c.y]];
	[points addObject: [viewerController newPoint : d.x : d.y]];
	[roiImageList addObject: newROI];
	[newROI setROIMode: ROI_selected];
	
	
	newROI = [viewerController newROI: tMesure];
	points = [newROI points];
	[points addObject: [viewerController newPoint : a.x : a.y]];
	[points addObject: [viewerController newPoint : c.x : c.y]];
	[roiImageList addObject: newROI];
	[newROI setROIMode: ROI_selected];
}

- (long) filterImage:(NSString*) menuName
{
	NSMutableArray  *roiSeriesList;
	NSMutableArray  *roiImageList;
	DCMPix			*curPix;
	
	curPix = [[viewerController pixList] objectAtIndex: [[viewerController imageView] curImage]];
	
	// All rois contained in the current series
	roiSeriesList = [viewerController roiList];
	
	// All rois contained in the current image
	roiImageList = [roiSeriesList objectAtIndex: [[viewerController imageView] curImage]];
	
	ROI		*line[ 2];
	
	int i, total = 0;
	
	// Is there 2 lines in this image?
	total = 0;
	for( i = 0; i < [roiImageList count]; i++)
	{
		ROI *curROI = [roiImageList objectAtIndex: i];
		
		if( [curROI type] == tMesure)
		{
			if( total < 2) line[ total] = curROI;
			total ++;
			
			[curROI setROIMode: ROI_sleep];
		}
	}
	
	if( total != 2)
	{
		// Is there 2 SELECTED lines in this image?
		total = 0;
		for( i = 0; i < [roiImageList count]; i++)
		{
			ROI *curROI = [roiImageList objectAtIndex: i];
			long mode = [curROI ROImode];
			
			if( [curROI type] == tMesure && (mode == ROI_selected || mode == ROI_selectedModify || mode == ROI_drawing))
			{
				if( total < 2)
				{
					line[ total] = [roiImageList objectAtIndex: i];
					total ++;
				}
				
				[curROI setROIMode: ROI_sleep];
			}
		}
		
		if( total != 2)
		{
			NSRunCriticalAlertPanel( NSLocalizedString(@"Cobb's Angle", nil),  NSLocalizedString(@"Create two lines, Select them and run the Cobb's Angle plugin.", nil), NSLocalizedString(@"OK", nil), nil, nil);
		
			return 0;
		}
	}
	
	[self create: [line[ 0] points] : [line[ 1] points] :roiImageList];
		
	// We modified the view: OsiriX please update the display!
	[viewerController needsDisplayUpdate];
	
	return 0;
}

@end
