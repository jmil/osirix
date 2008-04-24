/*=========================================================================
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


#import "CMIVAutoSeedingCore.h"
#import "CMIVBuketPirortyQueue.h"
#include <Accelerate/Accelerate.h>
/*
#define id Id
#include "itkMultiThreader.h"
#include "itkImage.h"
#include "itkImportImageFilter.h"
#include "itkGradientAnisotropicDiffusionImageFilter.h"
#include "itkRecursiveGaussianImageFilter.h"
#include "itkHessianRecursiveGaussianImageFilter.h"
#include "itkHessian3DToVesselnessMeasureImageFilter.h"
#undef id
*/
static		float						deg2rad = 3.14159265358979/180.0;
@implementation CMIVAutoSeedingCore
-(int)autoCroppingBasedOnLungSegment:(float*)inData :(unsigned char*)outData:(float)threshold:(float)diameter: (long*)origin:(long*)dimension:(float)zoomfactor
{
	NSLog( @"lung segment ");
	int err=0;
	imageWidth=dimension[0];
	imageHeight=dimension[1];
	imageAmount=dimension[2];
	imageSize=imageWidth*imageHeight;
	zoomFactor=zoomfactor;
	//zoomFactor=1.0;
	curveWeightFactor=1;
	distanceWeightFactor=1;
	intensityWeightFactor=1;
	gradientWeightFactor=1;
	lungThreshold=(long)threshold;
	[self lungSegmentation:inData:outData:diameter];
	NSLog( @"finding heart");
	err=[self findingHeart:inData:outData:origin:dimension];
	[self smoothOutput:outData];
	if(err)
		return err;
	return err;
}
-(void)lungSegmentation:(float*)inData :(unsigned char*)outData:(float)diameter
{
	long size=imageAmount*imageSize;
	long i;
	for(i=0;i<size;i++)
	{
		if(inData[i]<lungThreshold)
			outData[i]=1;
	}
	int preLungSegNumber=0;
	long* buffer=(long*)malloc(4*imageSize*sizeof(long));
	unsigned char* preSlice=nil;
	
	for(i=imageAmount-1;i>=0;i--)
	{
		memset(buffer, 0x00, 2*imageSize*sizeof(long));
		preLungSegNumber=[self connectedComponetsLabeling2D:outData+i*imageSize:preSlice:buffer];
		preSlice=outData+i*imageSize;
	}
	free(buffer);
}
-(int)connectedComponetsLabeling2D:(unsigned char*)img2d8bit:(unsigned char*)preSlice:(long*)buffer
{
	long labebindex=1;
	long isconnected=0;
	
	long i,j,k,x,y,neighbor;
	long index1,index2;
	long* tempimg=buffer;
	long* connectingmap=buffer+imageSize;
	long* areaList=buffer+2*imageSize;

	for(j=0;j<imageHeight;j++)
		for(i=0;i<imageWidth;i++)
			if(*(img2d8bit+j*imageWidth+i))
			{
				isconnected=0;
				for(neighbor=0;neighbor<4;neighbor++)
				{
					switch(neighbor)
					{
						case 0:
							x=i-1;y=j-1;break;
						case 1:
							x=i;y=j-1;break;
						case 2:
							x=i+1;y=j-1;break;
						case 3:
							x=i-1;y=j;break;
					}
					if(x<0 || y<0 ||x>=imageWidth)
						continue;
					if(*(tempimg+y*imageWidth+x))
					{
						if(!isconnected)
						{
							*(tempimg+j*imageWidth+i)=*(tempimg+y*imageWidth+x);
							isconnected=1;
						}
						else
						{
							if(*(tempimg+j*imageWidth+i)!=*(tempimg+y*imageWidth+x))
							{
								index1=*(tempimg+j*imageWidth+i);
								index2=*(tempimg+y*imageWidth+x);
								if(connectingmap[index1]==0&&connectingmap[index2]==0)
								{

									connectingmap[index1]=index1;
									connectingmap[index2]=index1;
									
								}
								else if(connectingmap[index1]==0&&connectingmap[index2]!=0)
								{
									connectingmap[index1]=connectingmap[index2];
								}
								else if(connectingmap[index1]!=0&&connectingmap[index2]==0)
								{
									connectingmap[index2]=connectingmap[index1];
								}
								else
								{

									index1=connectingmap[index1];
									index2=connectingmap[index2];
									if(index1!=index2)
									for(k=1;k<labebindex;k++)
										if(connectingmap[k]==index2)
											connectingmap[k]=index1;
								}
								
	
							}
						}
					}
				}
				if(!*(tempimg+j*imageWidth+i))
				{
					*(tempimg+j*imageWidth+i)=labebindex;
					connectingmap[labebindex]=labebindex;
					labebindex++;
				}

				
			}

	// replace connected map with continuous number.
	index1=0;
	for(k=1;k<labebindex;k++)
	{
		if(connectingmap[k]>index1)
		{
			index1++;
			index2=connectingmap[k];
			for(i=k;i<labebindex;i++)
			{
				if(connectingmap[i]==index2)
					connectingmap[i]=index1;
					
			}
		}
	}
	index1++;
	//caculate the area of each object
	memset(areaList,0x00,index1*4*sizeof(long));
	for(i=0;i<index1;i++)
	{
		areaList[i*4]=imageWidth;
		areaList[i*4+1]=imageHeight;
		areaList[i*4+2]=0;
		areaList[i*4+3]=0;
	}
	index2=index1;
	
	for(j=0;j<imageHeight;j++)
		for(i=0;i<imageWidth;i++)
		{
			index1=connectingmap[tempimg[j*imageWidth+i]];
			tempimg[j*imageWidth+i]=index1;
			if(index1>0)
			{
				if(areaList[index1*4]>i)
					areaList[index1*4]=i;
				if(areaList[index1*4+1]>j)
					areaList[index1*4+1]=j;
				if(areaList[index1*4+2]<i)
					areaList[index1*4+2]=i;
				if(areaList[index1*4+3]<j)
					areaList[index1*4+3]=j;
			}
		}
	//try to remove air object in front of the patient and small air area
	long width,height;
	index1=1;
	for(i=1;i<index2;i++)//
	{
		connectingmap[i]=index1;
		index1++;
		x=areaList[i*4];
		y=areaList[i*4+1];

		width=areaList[i*4+2]-areaList[i*4];
		height=areaList[i*4+3]-areaList[i*4+1];
		//small air area
		if((width+height)<(imageWidth)/10)
		{
			connectingmap[i]=0;
			index1--;
		}
		else if(y==0 && height<imageHeight/2) //check for air area in front of patient on suspicous area.
		{
			int isconnectedToLung=0;
			if(preSlice)
			{
				long s,t;
				for(t=0;t<height&&!isconnectedToLung;t++)
					for(s=0;s<width&&!isconnectedToLung;s++)
					{
						if(*(tempimg+(t+y)*imageWidth+s+x)==connectingmap[i]&&*(preSlice+(t+y)*imageWidth+s+x))
							isconnectedToLung=1;
				
					}
			}

			if(!isconnectedToLung)
			{
				connectingmap[i]=0;
				index1--;

			}
		}
		
		
	}

	for(i=0;i<imageSize;i++)
	{
		
		img2d8bit[i]=connectingmap[tempimg[i]];
		
	}
	
		
	return index1;
	
}
-(void)closingVesselHoles:(unsigned char*)img2d8bit :(float)diameter
{
	
}
-(int)findingHeart:(float*)inData:(unsigned char*)outData:(long*)origin:(long*)dimension
{
	int err=0;

	float *precurve=(float*)malloc(360*sizeof(float));
	float *curve=(float*)malloc(360*sizeof(float));
	directorMapBuffer=(unsigned char*)malloc(360*1000*sizeof(unsigned char));
	weightMapBuffer=(long*)malloc(360*1000*sizeof(long));
	costMapBuffer=(long*)malloc(360*1000*sizeof(long));
	*precurve=-1;
	long i,j;
	unsigned char* img8bit;
	float * image;
	long heartcenterx=imageWidth/2,heartcentery=imageHeight/2;
	for(i=imageAmount-1;i>=0;i--)
	{
		img8bit=outData+i*imageSize;
		image=inData+i*imageSize;
		memset(curve,0x00,360*sizeof(float));
		int localerr=0;
		//NSLog( @"starting curve");
		localerr=[self createParameterFunctionWithCenter:heartcenterx:heartcentery:10:img8bit:curve:precurve];
		//NSLog( @"closing curve");
		if(!localerr)
			localerr=[self convertParameterFunctionIntoCircle:heartcenterx:heartcentery:curve:precurve:img8bit:image];
		//NSLog( @"filling curve");
		if(!localerr)
		{
			[self fillAreaInsideCircle:&heartcenterx:&heartcentery:img8bit:curve:precurve];
			//NSLog( @"finished curve");
		}
		else
		{
			*precurve=-1;
		}
		/*for			for(j=0;j<360;j++)
		{
			long tempy=curve[j];
			if(tempy>511)tempy=511;
			*(img8bit+tempy*imageWidth+j)=1;
			*(image+tempy*imageWidth+j)=3000;
		}

	 test
	
			*/
	}
	free(curve);
	free(precurve);
	free(directorMapBuffer);
	free(weightMapBuffer);
	free(costMapBuffer);
	return err;
}
-(int)createParameterFunctionWithCenter:(long)centerx:(long)centery:(float)diameter:(unsigned char*)img2d8bit:(float*)curve:(float*)precurve
{
	int i=0;
	long tempx=0,tempy=0,tempdiameter;

		for(i=0;i<360;i++)
		{
			tempdiameter=0;
			curve[i]=0;
			do
			{
				tempdiameter++;
				tempx=centerx+(float)tempdiameter*cos((float)i*deg2rad);
				tempy=centery+(float)tempdiameter*sin((float)i*deg2rad);
				if(tempx<0 || tempy<0 || tempx>=imageWidth || tempy>=imageHeight)
				{
					curve[i]=10000;
					break;
				}
					
			}while(*(img2d8bit+tempy*imageWidth+tempx)==0);
			if(curve[i]==0)
			{
				curve[i]=tempdiameter;
			}
		}

	/* doesn't help
	 if(*precurve==-1)
	 {
	 	}
	else
	{
		float distancethreshold=30/zoomFactor;
		for(i=0;i<360;i++)
		{
			tempdiameter=precurve[i]-distancethreshold;
			curve[i]=0;
			do
			{
				tempdiameter++;
				tempx=centerx+(float)tempdiameter*cos((float)i*deg2rad);
				tempy=centery+(float)tempdiameter*sin((float)i*deg2rad);
				if(tempx<0 || tempy<0 || tempx>=imageWidth || tempy>=imageHeight)
				{
					curve[i]=10000;
					break;
				}
				
			}while(*(img2d8bit+tempy*imageWidth+tempx)==0);
			if(curve[i]==0)
			{
				curve[i]=tempdiameter;
			}
		}
		
	}*/
	return 0;
	
}
-(int)convertParameterFunctionIntoCircle:(long)x:(long)y:(float*)curve:(float*)precurve:(unsigned char*)img2d8bit:(float*)image
{
	int i,j,segnum=0;
	int gapstart,gapend;

	i=0;
	//first round check based on lung contour
	{

		while(i<360&&curve[i]==10000)i++;

		if(i>=360)
			return 1;
		
		for(j=0;j<360;j++)
		{
			if(curve[(i+j)%360]==10000)
			{ 
				segnum++;
				gapstart=(i+j)%360-1;
				while(j<360&&(curve[(i+j)%360]==10000))j++;
				if(j>360)
					return 1;

				gapend=(i+j)%360;
				//[self fillGapsInParameterFunction:curve:gapstart:gapend];
				[self finding2DMinimiumCostPath:x:y:curve:(float*)precurve:img2d8bit:image:gapstart:gapend];
			}
		}
	}
	if(precurve[0]>0)
	{
		gapstart=abs(curve[i]-precurve[i]);
		while(i<360&&gapstart>30)
		{i++;gapstart=abs(curve[i]-precurve[i]);}
		
		if(i>=360)
			return 1;
		float distancethreshold=30/zoomFactor;
		for(j=0;j<360;j++)
		{
			if(abs(curve[(i+j)%360]-precurve[(i+j)%360])>distancethreshold)
			{ 
				segnum++;
				gapstart=(i+j)%360-1;
				while(j<360&&(abs(curve[(i+j)%360]-precurve[(i+j)%360])>distancethreshold))
				{
					curve[(i+j)%360]=10000;
					j++;
				}
				if(j>360)
					return 1;			
				gapend=(i+j)%360;
				
				[self finding2DMinimiumCostPath:x:y:curve:(float*)precurve:img2d8bit:image:gapstart:gapend];
			}
		}	
	}
	
	return 0;
}
-(void)fillAreaInsideCircle:(long*)pcenterx:(long*)pcentery:(unsigned char*)img2d8bit:(float*)curve:(float*)precurve;
{
	int i,j;
	float angle;
	float x,y;
	long centerx=*pcenterx,centery=*pcentery;
	long newcenterx=0,newcentery=0;
	long tempx,tempy;
	int angleindex;

	int needchechx1=0;

	float slope;
	long x1,x2,y1,y2;
	unsigned char marker=0;
	//NSLog( @"clean memory");
	memset(img2d8bit,0x00,imageSize*sizeof(char));
	//NSLog( @"stroke curve");
	for(i=1;i<361;i++)
		curve[i%360]=(curve[i%360]+curve[(i-1)%360]+curve[(i-1)%360])/3;
		
	for(i=1;i<362;i++)
	{
		needchechx1=0;
		x1=centerx+curve[(i-1)%360]*cos((float)(i-1)*deg2rad);
		y1=centery+curve[(i-1)%360]*sin((float)(i-1)*deg2rad);

		x2=centerx+curve[i%360]*cos((float)i*deg2rad);
		y2=centery+curve[i%360]*sin((float)i*deg2rad);
		if(x1<0)x1=0; if(x1>imageWidth-1)x1=imageWidth-1;
		if(x2<0)x1=0; if(x2>imageWidth-1)x2=imageWidth-1;
		if(y1<0)x1=0; if(y1>imageHeight-1)y2=imageHeight-1;
		if(y2<0)x1=0; if(y2>imageHeight-1)y2=imageHeight-1;
		if(x1<x2)
		{
			if(y1<y2)marker=1;
			if(y1>y2)marker=2;
			if(y1==y2)marker=3;
		
		}
		if(x1>x2)
		{
			if(y1<y2)marker=1;
			if(y1>y2)marker=2;
			if(y1==y2)marker=3;
			
		}
		if(x1==x2)
		{
			if(y1<y2)marker=1;
			if(y1>y2)marker=2;
			if(y1==y2)
			{
				continue;
			}
					
		}
		
		if(*(img2d8bit+y1*imageWidth+x1)!=0&&*(img2d8bit+y1*imageWidth+x1)!=marker)
		{
			if(*(img2d8bit+y1*imageWidth+x1)==3)
				*(img2d8bit+y1*imageWidth+x1)=marker;
			else if(marker!=3)
			{
				if(*(img2d8bit+y1*imageWidth+x1-1)==0x00&&*(img2d8bit+y1*imageWidth+x1+1)==0x00)
				{
					*(img2d8bit+y1*imageWidth+x1)=3;
					needchechx1=1;
				}
				else
					*(img2d8bit+y1*imageWidth+x1)=marker;
			}
		}
		
		if(x1!=x2)
		{
			if(x1>x2)
			{
				tempx=x1;x1=x2;x2=tempx;
				tempy=y1;y1=y2;y2=tempy;
			}
			slope=(float)(y2-y1)/(float)(x2-x1);
			for(j=x1;j<=x2;j++)
			{
				tempx=j;
				tempy=slope*(j-x1)+y1;

				if(*(img2d8bit+tempy*imageWidth+tempx)==0)
				{
						*(img2d8bit+tempy*imageWidth+tempx)=marker;
				}
				
			}
		}
		if(y1!=y2)
		{
			if(y1>y2)
			{
				tempx=x1;x1=x2;x2=tempx;
				tempy=y1;y1=y2;y2=tempy;
			}
			slope=(float)(x2-x1)/(float)(y2-y1);
			for(j=y1;j<=y2;j++)
			{
				tempx=slope*(j-y1)+x1;
				tempy=j;

				if(*(img2d8bit+tempy*imageWidth+tempx)==0)
				{

						*(img2d8bit+tempy*imageWidth+tempx)=marker;
				}
			}
		}
		
		if(needchechx1)
		{
			x1=centerx+curve[(i-1)%360]*cos((float)(i-1)*deg2rad);
			y1=centery+curve[(i-1)%360]*sin((float)(i-1)*deg2rad);
			if(*(img2d8bit+y1*imageWidth+x1-1)!=0x00||*(img2d8bit+y1*imageWidth+x1+1)!=0x00)
			{
				if(marker==1)
					*(img2d8bit+y1*imageWidth+x1)=2;
				else
					*(img2d8bit+y1*imageWidth+x1)=1;
			}
		}
	}
	
//NSLog( @"filling area");
	for(j=0;j<imageHeight;j++)
	{
		marker=0;
		for(i=0;i<imageWidth;i++)
		{

			if(*(img2d8bit+j*imageWidth+i)==3)
				*(img2d8bit+j*imageWidth+i)=0xff;
			else if(*(img2d8bit+j*imageWidth+i)==1)
			{
				marker=0x00;
				*(img2d8bit+j*imageWidth+i)=0xff;
			}
			else if(*(img2d8bit+j*imageWidth+i)==2)
			{
				marker=0xff;
				*(img2d8bit+j*imageWidth+i)=0xff;
			}
			else
				*(img2d8bit+j*imageWidth+i)=marker;
			
		}
	}
	//NSLog( @"creating pre curve");
	for(i=0;i<360;i++)
	{
		tempx=centerx+curve[i]*cos((float)i*deg2rad);
		tempy=centery+curve[i]*sin((float)i*deg2rad);
		newcenterx+=tempx;
		newcentery+=tempy;
	}

	newcenterx=newcenterx/360;
	newcentery=newcentery/360;
	*pcenterx=newcenterx;
	*pcentery=newcentery;
	memset(precurve,0x00,360*sizeof(float));
	for(i=0;i<360;i++)
	{
		tempx=centerx+curve[i]*cos((float)i*deg2rad);
		tempy=centery+curve[i]*sin((float)i*deg2rad);
		x=tempx-newcenterx;
		y=tempy-newcentery;
		if(x!=0)
		{
			angle=(atan(y/x)/ deg2rad);
			if(x<0)
				angle+=180;
			
		}
		else
		{
			if(y<=0)
				angle=270;
			else
				angle=90;
		}
		if(angle<0)
			angle+=360;
		angleindex=(int)angle;
		precurve[angleindex]=sqrt(x*x+y*y);
				
	}
	i=0;
	while(i<360&&precurve[i]==0)
	{
		i++;
	}
	long startangle,endangle;
	long starty,endy;
	
		
	if(i<360)
	{

		for(j=0;j<360;j++)
		{
			if(precurve[(i+j)%360]==0)
			{
				startangle=i+j-1;
				starty=precurve[(i+j-1)%360];
				while(j<=360&&precurve[(i+j)%360]==0)
					j++;
				endangle=i+j;
				endy=precurve[(i+j)%360];
				
				for(angleindex=startangle+1;angleindex<endangle;angleindex++)
					precurve[angleindex%360]=(i+j-startangle)*(endy-starty)/(endangle-startangle)+starty;
			}
		}
	}
	else
		precurve[0]=-1;
	
}
-(void)finding2DMinimiumCostPath:(long)centerx:(long)centery:(float*)curve:(float*)precurve:(unsigned char*)img2d8bit:(float*)image:(long)startangle:(long)endangle
{
	long minradius,maxradius,tempradius;
	long gapborderfactor=20;
	float gapatfactor=0.02;
	long gapattitude;
	long i;
	long searchareawidth,searchareaheight;
	long stepcostrange=1000;
	long endseedsangle;
	long tempx,tempy;
	if(endangle<startangle)endangle+=360;
	minradius = maxradius =curve[startangle%360];
	if(*precurve!=-1)
		for(i=startangle;i<=endangle;i++)
		{
			tempradius=precurve[i%360];
			if(tempradius==10000)
			{
				i=gapborderfactor;
				continue;
			}
			if(tempradius>maxradius)
				maxradius=tempradius;
			if(tempradius<minradius)
				minradius=tempradius;
			
		}
	
	for(i=0;i<gapborderfactor;i++)
	{
		tempradius=curve[(startangle-i+360)%360];
		if(tempradius==10000)
		{
			i=gapborderfactor;
			break;
		}
		if(tempradius>maxradius)
			maxradius=tempradius;
		if(tempradius<minradius)
			minradius=tempradius;
	}
	startangle-=i;
	for(i=0;i<gapborderfactor;i++)
	{
		tempradius=curve[(endangle+i+360)%360];
		if(tempradius==10000)
		{
			i=gapborderfactor;
			break;
		}
		if(tempradius>maxradius)
			maxradius=tempradius;
		if(tempradius<minradius)
			minradius=tempradius;
	}	
	endangle+=i;
	endseedsangle=i;
	

	
	if(endangle<startangle)endangle+=360;
	if(*precurve!=-1)
		gapattitude=20/zoomFactor;//
	else
		gapattitude=(maxradius - minradius)*gapatfactor*(endangle-startangle);
	 minradius-=gapattitude;
	 maxradius+=gapattitude;
	
	// check min radius
	int ifneedchechminradius=1;
	while(ifneedchechminradius)
	{
		ifneedchechminradius=0;
		for(i=startangle;i<endangle;i++)
		{
			tempx=centerx+(float)tempradius*cos((float)i*deg2rad);
			tempy=centery+(float)tempradius*sin((float)i*deg2rad);

			if(tempx<0 || tempy<0 || tempx>=imageWidth || tempy>=imageHeight)
			{
				ifneedchechminradius=1;
			}
		}
		if(ifneedchechminradius)
			minradius-=20/zoomFactor;
		if(minradius<=0)
			break;

	}
	 if(minradius<=0)
	 minradius=1;
	if(maxradius>sqrt(imageWidth*imageWidth+imageHeight*imageHeight))
		maxradius=sqrt(imageWidth*imageWidth+imageHeight*imageHeight);
	
	searchareawidth=endangle-startangle;
	searchareaheight=maxradius-minradius;
	if(searchareaheight*searchareawidth<=0)
	{
		NSLog( @"width*height<");
		return;
	}

	unsigned char* directors=directorMapBuffer;
	long* weightmap= weightMapBuffer;
	memset(directors,0x00,searchareaheight*searchareawidth*sizeof(char));
	memset(weightmap,0x00,searchareaheight*searchareawidth*sizeof(long));

	
	for(i=startangle;i<endangle;i++)
	{
		long islungreached=0;
		for(tempradius=minradius;tempradius<maxradius;tempradius++)
		{
			
			tempx=centerx+(float)tempradius*cos((float)i*deg2rad);
			tempy=centery+(float)tempradius*sin((float)i*deg2rad);
			
			long tempindex=(tempradius-minradius)*searchareawidth+i-startangle;
			
			
			if(tempx>=0 && tempy>=0 && tempx<imageWidth && tempy<imageHeight)
			{
				
				if(!islungreached)
					*(weightmap+tempindex)=*(image+tempy*imageWidth+tempx);
				else
				{
					*(weightmap+tempindex)=lungThreshold+2000;
					*(directors+tempindex)=0x40;
				}
				if(*(img2d8bit+tempy*imageWidth+tempx))
				{
					*(directors+tempindex)=0x40;
					islungreached=1;
				}

			}
			else
			{
				*(weightmap+tempindex)=lungThreshold+2000;
				*(directors+tempindex)=0x40;
			}
			
		}
		if(curve[(i+360)%360]!=10000)
		{
			long tempindex=(curve[(i+360)%360]-minradius)*searchareawidth+i-startangle;
			
			if(i>=endangle-endseedsangle)
				*(directors+tempindex)=0x90;
			else
				*(directors+tempindex)=0x80;
		}

	}
	

	[self intensityRelatedWeightMap:searchareawidth:searchareaheight:weightmap];
	if(precurve[0]!=-1)
		[self distanceReleatedWeightMap:startangle:minradius:searchareawidth:searchareaheight:precurve:weightmap];
			

			

	long endpoint=[self dijkstraAlgorithm:searchareawidth:searchareaheight:stepcostrange:weightmap:directors];
	if(endpoint!=-1)
	{
		unsigned char neighbor;
		tempy=endpoint/searchareawidth;
		tempx=endpoint%searchareawidth;
		while((neighbor=(*(directors+tempy*searchareawidth+tempx))&0x0f)!=0)
		{
			curve[(startangle+tempx+360)%360]=tempy+minradius;
			//*(weightmap+tempy*searchareawidth+tempx)=-10000; for test;
			switch(neighbor)
			{
				/*case 1:
					tempy++;break;
				case 2:
					tempx++;break;
				case 3:
					tempx--;break;
				case 4:
					tempy--;break;*/
				case 1:
					tempx++;tempy++;break;
				case 2:
					tempy++;break;
				case 3:
					tempx--;tempy++;break;
				case 4:
					tempx--; break;	
				case 5:
					tempx--;tempy--;break;
				case 6:
					tempy--;break;
				case 7:
					tempx++;tempy--;break;
				case 8:
					tempx++;break;
					
					
			}
		}
				
	}
	
 /* for    	 
	for(tempy=0;tempy<searchareaheight;tempy++)
		for(tempx=0;tempx<searchareawidth;tempx++)
		{
			*(image+(tempy+minradius)*imageWidth+tempx+startangle%360)=*(weightmap+tempy*searchareawidth+tempx);
		}
  test	*/

	return;
	
	
	
}
-(long)dijkstraAlgorithm:(long)width:(long)height:(long)costrange:(long*)weightmap:(unsigned char*)directormap
{//return the bridge point between two seeds
	
	long i,j;
	long x,y;
	long item;
	int neighbors;
	long directiondev;
	long directioncost;
	long directionweight[5]={0,10,100,999,1000};
	if(height*width<=0)
	{
		NSLog( @"width*height<");
		return -1;
	}
	
	long* costmap= costMapBuffer;
	memset(costmap,0x00,height*width*sizeof(long));
	CMIVBuketPirortyQueue* pirortyQueue=[[CMIVBuketPirortyQueue alloc] initWithParameter:1000*curveWeightFactor+1000*distanceWeightFactor+1000*intensityWeightFactor+1000*gradientWeightFactor+1 :width*height];
	
	
	for(j=0;j<height;j++)
		for(i=0;i<width;i++)
		{
			if((*(directormap+j*width+i))&0x80 && !((*(directormap+j*width+i))&0x10))//0x80 is seeds or checked point 0x10 is another side
			{
				for(neighbors=1;neighbors<9;neighbors++)
				{
					switch(neighbors)
					{/*
					 case 1:
					 x=i;y=j-1; break;
					 case 2:
					 x=i-1;y=j; break;
					 case 3:
					 x=i+1;y=j; break;
					 case 4:
					 x=i;y=j+1; break;*/
						case 1:
							x=i-1;y=j-1; break;
						case 2:
							x=i;y=j-1; break;
						case 3:
							x=i+1;y=j-1; break;
						case 4:
							x=i+1;y=j; break;	
						case 5:
							 x=i+1;y=j+1;break;
						case 6:
							x=i;y=j+1; break;
						case 7:
							 x=i-1;y=j+1;break;
						case 8:
							x=i-1;y=j; break;
					}
					if(x>=0 && y>=0 && x<width && y<height && !((*(directormap+y*width+x))&0x80) && !((*(directormap+y*width+x))&0x40)) //0x40 is border area
					{
						if((*(directormap+y*width+x))&0x20) // 0x20 is in queue
						{
							if((*(costmap+y*width+x))>(*(costmap+j*width+i))+(*(weightmap +y*width+x)))
							{
								(*(costmap+y*width+x))=(*(costmap+j*width+i))+(*(weightmap +y*width+x));
								(*(directormap+y*width+x))=0x20|neighbors;
								[pirortyQueue update:y*width+x:(*(weightmap +y*width+x))];
							}
						}
						else //not in queue
						{
							(*(costmap+y*width+x))=(*(costmap+j*width+i))+(*(weightmap +y*width+x));
							(*(directormap+y*width+x))=0x20|neighbors;
							[pirortyQueue push:y*width+x:(*(weightmap +y*width+x))];
						}
					}
						
				}
			}
		}
	long curcos=0;
	while((item=[pirortyQueue pop])!=-1)
	{
		i=item%width;
		j=item/width;

		curcos=(*(costmap+j*width+i));
		if(curcos==53199&&j==191)
			curcos=(*(costmap+j*width+i));
		
		*(directormap+j*width+i)=(*(directormap+j*width+i))|0x80;
		for(neighbors=1;neighbors<9;neighbors++)
		{
			switch(neighbors)
			{/*
			 case 1:
			 x=i;y=j-1; break;
			 case 2:
			 x=i-1;y=j; break;
			 case 3:
			 x=i+1;y=j; break;
			 case 4:
			 x=i;y=j+1; break;*/
				case 1:
					x=i-1;y=j-1; break;
				case 2:
					x=i;y=j-1; break;
				case 3:
					x=i+1;y=j-1; break;
				case 4:
					x=i+1;y=j; break;	
				case 5:
					x=i+1;y=j+1;break;
				case 6:
					x=i;y=j+1; break;
				case 7:
					x=i-1;y=j+1;break;
				case 8:
					x=i-1;y=j; break;
			}
			if(x>=0 && y>=0 && x<width && y<height) //0x40 is border area
			{
				if(!((*(directormap+y*width+x))&0x80) && !((*(directormap+y*width+x))&0x40))
				{
					directiondev=(*(directormap+j*width+i))&0x0f;
					if(directiondev==0)
						directioncost=0;
					else
					{
						directiondev-=neighbors;
						directiondev=abs(directiondev);
						if(directiondev>4)directiondev=8-directiondev;
						if(directiondev==4)
							directiondev=4;
						directioncost=directionweight[directiondev]*curveWeightFactor;
					}
					
					
					if((*(directormap+y*width+x))&0x20) // 0x20 is in queue
					{
						if((*(costmap+y*width+x))>(*(costmap+j*width+i))+directioncost+(*(weightmap +y*width+x)))
						{
							(*(costmap+y*width+x))=(*(costmap+j*width+i))+(*(weightmap +y*width+x));
							(*(directormap+y*width+x))=0x20|neighbors;
							[pirortyQueue update:y*width+x:(*(weightmap +y*width+x))];
						}
					}
					else //not in queue
					{
						(*(costmap+y*width+x))=(*(costmap+j*width+i))+directioncost+(*(weightmap +y*width+x));
						(*(directormap+y*width+x))=0x20|neighbors;
						[pirortyQueue push:y*width+x:(*(weightmap +y*width+x))];
					}
				}
				else if(((*(directormap+y*width+x))&0x80) && ((*(directormap+y*width+x))&0x10)) //0x10 stop area
				{
					(*(directormap+y*width+x))=neighbors;
					[pirortyQueue release];
					//memcpy(weightmap,costmap,height*width*sizeof(long));//for test

					return y*width+x;
				}
			}
			
			
		}
	}
	[pirortyQueue release];

	return -1;
	
}
-(void)intensityRelatedWeightMap:(long)width:(long)height:(long*)weightmap
{

	if(width*height<=0)
	{
		NSLog( @"width*height<");
		return;
	}

	float* tempweightmap=(float*)malloc(width*height*sizeof(float));
	float* tempweightmap2=(float*)malloc(width*height*sizeof(float));
	long i,j;
	long size=width*height;
	float  fkernel[25]={0.0192, 0.0192, 0.0385, 0.0192, 0.0192, 0.0192, 0.0385, 0.0769, 0.0385, 0.0192, 0.0385, 0.0769, 0.1538, 0.0769, 0.0385, 0.0192, 0.0385, 0.0769, 0.0385, 0.0192, 0.0192, 0.0192, 0.0385, 0.0192, 0.0192};
	
	for(i=0;i<size;i++)
		*(tempweightmap+i)=(*(weightmap+i));

	vImage_Buffer dstf, srcf;
	
	srcf.height = height;
	srcf.width = width;
	srcf.rowBytes = width*sizeof(float);
	srcf.data = (void*) tempweightmap;
	
	dstf.height = height;
	dstf.width = width;
	dstf.rowBytes = width*sizeof(float);
	dstf.data=tempweightmap2;
	if( srcf.data)
	{
		short err;
		
		err = vImageConvolve_PlanarF( &srcf, &dstf, 0, 0, 0, fkernel, 5, 5, 0, kvImageEdgeExtend);
		if( err) NSLog(@"Error applyConvolutionOnImage = %d", err);
	}
	for(i=0;i<size;i++)
		*(weightmap+i)=*(tempweightmap2+i);	


	for(i=0;i<width;i++)
	{
		*(tempweightmap+i)=*(weightmap+width+i)-*(weightmap+i);
	}
	for(j=1;j<height;j++)
	{
		for(i=0;i<width;i++)
		{
			
			*(tempweightmap+j*width+i)=*(weightmap+j*width+i)-*(weightmap+(j-1)*width+i);

		}
	}
// weight map from threshold and distance to ribs
	for(j=0;j<height;j++)
	{
		
		for(i=0;i<width;i++)
		{
			if(*(weightmap+j*width+i)>lungThreshold+400)
				*(weightmap+j*width+i)=1000;
			else if(*(weightmap+j*width+i)>lungThreshold+300)
				*(weightmap+j*width+i)=*(weightmap+j*width+i)-lungThreshold-299;
			else
				*(weightmap+j*width+i)=1;
		}
	}
	long edgedisweight[12]={0,2,4,8,16,32,64,128,256,512,999,999};
	for(i=0;i<width;i++)
	{
		
		for(j=0;j<height;j++)
		{
			if(*(weightmap+j*width+i)==1)
			{
				long fatrangestart=j;
				
				while(j<height&&*(weightmap+j*width+i)<1000)j++;
				if(j>=height)j=height-1;
				long fatrangeend=j;
				long k;
				float unitdelta;
				long x1,x2;
				for(k=fatrangeend-1;k>=fatrangestart;k--)
				{
					x1=(fatrangeend-k)*10/(fatrangeend-fatrangestart);
					x2=x1+1;
					unitdelta=(float)((fatrangeend-k)*10)/(float)(fatrangeend-fatrangestart);
					unitdelta-=x1;
					*(weightmap+k*width+i)+=edgedisweight[x1]+(edgedisweight[x2]-edgedisweight[x1])*unitdelta;
				}
				*(weightmap+(fatrangeend-1)*width+i)=999;
			}
		}
	}

	for(j=0;j<height;j++)
	{
		
		for(i=0;i<width;i++)
		{
			if(*(weightmap+j*width+i)>1000)
				*(weightmap+j*width+i)=1000;
			else if(*(weightmap+j*width+i)<0)
				*(weightmap+j*width+i)=1;
			*(weightmap+j*width+i)*=intensityWeightFactor;
		}
	}


	for(j=0;j<height;j++)
	{
		
		for(i=0;i<width;i++)
		{
			if(*(tempweightmap+j*width+i)<-100)
				*(weightmap+j*width+i)+=1000*gradientWeightFactor;
			else if(*(tempweightmap+j*width+i)>-100&&*(tempweightmap+j*width+i)<100)
			{
				*(weightmap+j*width+i)+=gradientWeightFactor*edgedisweight[(100-(int)(*(tempweightmap+j*width+i)))/20];
			}
			
			//else 
			//	*(weightmap+j*width+i)+=0;
			
			if(*(weightmap+j*width+i)>2000)
				*(weightmap+j*width+i)=1000;
			else if(*(weightmap+j*width+i)<0)
				*(weightmap+j*width+i)=1;
			
		}
	}	


	free(tempweightmap);
	free(tempweightmap2);
}
-(void)distanceReleatedWeightMap:(long)startangle:(long)minradius:(long)width:(long)height:(float*)precurve:(long*)weightmap
{
	long i,j;
	long distanceweight,distance;
	long disweight[21]={1,2,3,4,6,8,12,16,20,32,40,64,70,128,160,256,320,512,650,999,999};
	float distancethreshold=5.0/zoomFactor+0.5;
	for(j=0;j<height;j++)
		for(i=0;i<width;i++)
		{
			distance=abs(j+minradius-precurve[i+startangle]);
			if(distance<distancethreshold)
				distanceweight=0;
			else if(distance>20+distancethreshold)
				distanceweight=1000;
			else
				distanceweight=disweight[(int)(distance-distancethreshold)];
				
			*(weightmap+j*width+i)+=distanceweight*distanceWeightFactor;
			if(*(weightmap+j*width+i)<0)
				*(weightmap+j*width+i)=1;
		}
}
-(void)smoothOutput:(unsigned char*)outData
{
	/*
	int i;
	unsigned char*temp2D8bit=(unsigned char*)malloc(imageSize*sizeof(char));
	for(i=0;i<imageAmount;i++)
	{
		vImage_Buffer dstf, srcf;
		
		srcf.height = imageHeight;
		srcf.width = imageWidth;
		srcf.rowBytes = imageWidth*sizeof(float);
		srcf.data = (void*) (outData+i*imageSize);
		
		dstf.height = imageHeight;
		dstf.width = imageWidth;
		dstf.rowBytes = imageWidth*sizeof(float);
		dstf.data=temp2D8bit;
		if( srcf.data)
		{
			short err;
			
			err = vImageConvolve_PlanarF( &srcf, &dstf, 0, 0, 0, fkernel, 5, 5, 0, kvImageEdgeExtend);
			if( err) NSLog(@"Error applyConvolutionOnImage = %d", err);
		}
		memcpy(temp2D8bit, imageSize
		
	}*/
}
@end
