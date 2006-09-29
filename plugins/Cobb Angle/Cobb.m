//
//  Cobb.m
//

#import "Cobb.h"
#import "ROI.h"

@implementation Cobb

- (long) filterImage:(NSString*) menuName
{
	NSMutableArray  *roiSeriesList;
	NSMutableArray  *roiImageList;
	DCMPix			*curPix;
	ROI				*newROI;
	
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
	
	// See DCMView.h for available ROIs, we create here a closed polygon
	newROI = [viewerController newROI: tAngle];
	
	NSPoint	a1 = [[[line[ 0] points] objectAtIndex: 0] point], a2 = [[[line[ 0] points] objectAtIndex: 1] point], b1 = [[[line[ 1] points] objectAtIndex: 0] point], b2 = [[[line[ 1] points] objectAtIndex: 1] point];
	
	// Points of this ROI (it's currently empty)
	NSMutableArray  *points = [newROI points];
	
	NSPoint	a, b, c;
	
	a = NSMakePoint( a1.x + (a2.x - a1.x)/2, a1.y + (a2.y - a1.y)/2);
	
	float slope1 = (a2.y - a1.y) / (a2.x - a1.x);
	slope1 = -1./slope1;
	float or1 = a.y - slope1*a.x;

	float slope2 = (b2.y - b1.y) / (b2.x - b1.x);
	float or2 = b1.y - slope2*b1.x;
	
	float xx = (or2 - or1) / (slope1 - slope2);
	
	c = NSMakePoint( xx, or1 + xx*slope1);
	
	float angle = atan( (slope2 - slope1) / (1 - slope1*slope2));
	float distance = sqrt((a.x - c.x)*(a.x - c.x) + (a.y - c.y)*(a.y - c.y));
	
	float length = cos( angle) * distance;
	
	float bAngle = atan( slope2);
	
	b.x = c.x + cos( bAngle) * length;
	b.y = c.y + sin( bAngle) * length;
	
	// *******************
	
	slope2 = -1./slope2;
	or2 = b.y - slope2*b.x;
	
	xx = (or2 - or1) / (slope1 - slope2);
	
	c = NSMakePoint( xx, or1 + xx*slope1);
	
	[points addObject: [viewerController newPoint : a.x : a.y]];
	[points addObject: [viewerController newPoint : c.x : c.y]];
	[points addObject: [viewerController newPoint : b.x : b.y]];
	
	// Select it!
	[newROI setROIMode: ROI_selected];
	
	[roiImageList addObject: newROI];
	
	// We modified the view: OsiriX please update the display!
	[viewerController needsDisplayUpdate];
	
	return 0;
}

@end
