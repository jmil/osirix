/*=========================================================================
 CMIVSaveResult
 
 Kernel Algorithms for Auto Cropping and Auto Seeding
 
 Author: Chunliang Wang (chunliang.wang@imv.liu.se)
 
 
 Program:  CMIV CTA image processing Plugin for OsiriX
 
 This file is part of CMIV CTA image processing Plugin for OsiriX.
 
 Copyright (c) 2007,
 Center for Medical Image Science and Visualization (CMIV),
 Linköping University, Sweden, http://www.cmiv.liu.se/
 
 CMIV CTA image processing Plugin for OsiriX is free software;
 you can redistribute it and/or modify it under the terms of the
 GNU General Public License as published by the Free Software 
 Foundation, either version 3 of the License, or (at your option)
 any later version.
 
 CMIV CTA image processing Plugin for OsiriX is distributed in
 the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 =========================================================================*/


#import <Cocoa/Cocoa.h>


@interface CMIVAutoSeedingCore : NSObject {
	float* inputData;
	unsigned char* outputData;
	long imageWidth,imageHeight,imageAmount,imageSize;
	float lungThreshold;
	float curveWeightFactor,distanceWeightFactor,intensityWeightFactor,gradientWeightFactor;
	unsigned char* directorMapBuffer;
	long* weightMapBuffer;
	long* costMapBuffer;
	float zoomFactor;

}
-(int)autoCroppingBasedOnLungSegment:(float*)inData :(unsigned char*)outData:(float)threshold:(float)diameter: (long*)origin:(long*)dimension:(float)zoomfactor;
-(void)lungSegmentation:(float*)inData :(unsigned char*)outData:(float)diameter;
-(void)closingVesselHoles:(unsigned char*)img2d8bit :(float)diameter;
-(int)findingHeart:(float*)inData:(unsigned char*)outData:(long*)origin:(long*)dimension;
-(int)createParameterFunctionWithCenter:(long)x:(long)y:(float)diameter:(unsigned char*)img2d8bit:(float*)curve:(float*)precurve;
-(int)convertParameterFunctionIntoCircle:(long)x:(long)y:(float*)curve:(float*)precurve:(unsigned char*)img2d8bit:(float*)image;
-(void)fillAreaInsideCircle:(long*)pcenterx:(long*)pcentery:(unsigned char*)img2d8bit:(float*)curve:(float*)precurve;
//-(int)relabelConnectedArea2D:(unsigned char)binaryimg;
-(void)finding2DMinimiumCostPath:(long)centerx:(long)centery:(float*)curve:(float*)precurve:(unsigned char*)img2d8bit:(float*)image:(long)startangle:(long)endangle;
-(long)dijkstraAlgorithm:(long)width:(long)height:(long)costrange:(long*)weightmap:(unsigned char*)directormap;//return the bridge point between two seeds
-(void)intensityRelatedWeightMap:(long)width:(long)height:(long*)weightmap;
-(void)distanceReleatedWeightMap:(long)startangle:(long)minradius:(long)width:(long)height:(float*)precurve:(long*)weightmap;
-(int)connectedComponetsLabeling2D:(unsigned char*)img2d8bit:(unsigned char*)preSlice:(long*)buffer;
-(void)smoothOutput:(unsigned char*)outData;
@end
