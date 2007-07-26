/*=========================================================================
Author: Chunliang Wang (chunliang.wang@imv.liu.se)


Program:  CMIV CTA image processing Plugin for OsiriX

This file is part of CMIV CTA image processing Plugin for OsiriX.

Copyright (c) 2007,
Center for Medical Image Science and Visualization (CMIV),
Linkšping University, Sweden, http://www.cmiv.liu.se/

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

#import "CMIVSegmentCore.h"


@implementation CMIVSegmentCore
- (void) setImageWidth:(long) width Height:(long) height Amount: (long) amount
{

  imageWidth=width;
  imageHeight=height;
  imageAmount=amount;

  
  return;
  
}  

- (void) startShortestPathSearchAsFloat:(float *) pIn Out:(float *) pOut Direction: (unsigned char*) pPointers;
{

	long i,j,k;
	int changed;
	float maxvalue;
	unsigned char maxcolorindex;

	
	long itemp;
	long ilong,iwidth,iheight,imagesize;
	long position_i1,position_i2,position_j1,position_j2,position_j3;
	
	
	ilong=imageWidth;
	iwidth=imageHeight;
	iheight=imageAmount;
	imagesize=iwidth*ilong;

	inputData=pIn;
	outputData=pOut;
	directionOfData=pPointers;


	
	
	do
	{
		changed=0;
		
//**********************positive direction*****************************
		for(i=1;i<iheight-1;i++)
		{
			position_i1 = (i-1)*imagesize;
			position_i2 = i*imagesize;
			
			for(j=1;j<iwidth-1;j++)
			{
				position_j1 = (j-1)*ilong;
				position_j2 = j*ilong;
				position_j3 = (j+1)*ilong;
				for(k=1;k<ilong-1;k++)
				if((!(*(directionOfData + position_i2+position_j2+k)&0x80))&&(*(directionOfData + position_i2+position_j2+k)&0x40))
				{
//1
					itemp=position_i1+position_j1+k-1;
					maxvalue=*(outputData+itemp);
					maxcolorindex=1;
//2
					itemp++;
					if(*(outputData+itemp)>maxvalue)
					{
						maxvalue=*(outputData+itemp);
						maxcolorindex=2;
					}
//3
					itemp++;
					if(*(outputData+itemp)>maxvalue)
					{
						maxvalue=*(outputData+itemp);
						maxcolorindex=3;
					}
//4
					itemp=position_i1+position_j2+k-1;
					if(*(outputData+itemp)>maxvalue)
					{
						maxvalue=*(outputData+itemp);
						maxcolorindex=4;
					}
//5
					itemp++;
					if(*(outputData+itemp)>maxvalue)
					{
						maxvalue=*(outputData+itemp);
						maxcolorindex=5;
					}

//6
					itemp++;
					if(*(outputData+itemp)>maxvalue)
					{
						maxvalue=*(outputData+itemp);
						maxcolorindex=6;
					}
//7					
					itemp=position_i1+position_j3+k-1;
					if(*(outputData+itemp)>maxvalue)
					{
						maxvalue=*(outputData+itemp);
						maxcolorindex=7;
					}
//8	
					itemp++;
					if(*(outputData+itemp)>maxvalue)
					{
						maxvalue=*(outputData+itemp);
						maxcolorindex=8;
					}

//9					
					itemp++;
					if(*(outputData+itemp)>maxvalue)
					{
						maxvalue=*(outputData+itemp);
						maxcolorindex=9;
					}
//10	
					itemp=position_i2+position_j1+k-1;
					if(*(outputData+itemp)>maxvalue)
					{
						maxvalue=*(outputData+itemp);
						maxcolorindex=10;
					}
//11
					itemp++;
					if(*(outputData+itemp)>maxvalue)
					{
						maxvalue=*(outputData+itemp);
						maxcolorindex=11;
					}
//12
					itemp++;
					if(*(outputData+itemp)>maxvalue)
					{
						maxvalue=*(outputData+itemp);
						maxcolorindex=12;
					}
//13
					itemp=position_i2+position_j2+k-1;
					if(*(outputData+itemp)>maxvalue)
					{
						maxvalue=*(outputData+itemp);
						maxcolorindex=13;
					}
//update g
//((*(inputData+itemp)>*(outputData+itemp))||(((*(directionOfData+maxcolorindex))&0x3f) != ((*(directionOfData+itemp))&0x3f)))
					itemp=position_i2+position_j2+k;
					if(maxvalue>*(outputData+itemp))
					{
						if(*(inputData+itemp)>*(outputData+itemp))
						{
							//*(outputData+itemp)=min(maxvalue,*(inputData+itemp));
							if(maxvalue>*(inputData+itemp))
								*(outputData+itemp)=*(inputData+itemp);
							else 
								*(outputData+itemp)=maxvalue;
							*(directionOfData+itemp)=maxcolorindex&0x3f;
							int ii,jj,kk;
							for(ii=0;ii<3;ii++)
								for(jj=0;jj<3;jj++)
									for(kk=0;kk<3;kk++)
									{
										itemp=(i-1+ii)*imagesize+(j-1+jj)*ilong+k-1+kk ;
										if(!((*(directionOfData+itemp))& 0xC0))
										   *(directionOfData+itemp) = (*(directionOfData+itemp)) | 0x40;
									}
							
							changed++;				
						}
						else if(((*(directionOfData+itemp))&0x3f) != (maxcolorindex&0x3f))// connect value won't change, only direction will change, so no need to notice neighbors to check update.
						{
							// to check 26 neighbors to find the highest connectedness( actually 13 has been checked so check the rest 13)
							float recheckmax=maxvalue;
							int   recheckmaxindex=maxcolorindex;
							int ii,jj,kk;
							float ftemp;
							for(ii=1;ii<3;ii++)
								for(jj=0;jj<3;jj++)
									for(kk=0;kk<3;kk++)
									{ 
										ftemp=*(outputData+(i-1+ii)*imagesize+(j-1+jj)*ilong+k-1+kk);
										if(ftemp>=recheckmax)
										{
											recheckmax=ftemp;
											recheckmaxindex=ii*9+jj*3+kk+1;
										}
									}
							//there is difference between maxcolorindex and recheckmaxindex
							//maxcolorindex is the first maxinium of forward 13 neighbors
							//recheckmaxindex is the last maxinium of backward 13 neighbors
							//recheckmaxindex will not be 14!
							if(recheckmaxindex<14 ) 
								*(directionOfData+itemp)=maxcolorindex&0x3f;

							else 
								*(directionOfData+itemp)=(recheckmaxindex&0x3f);
		
							//above sentence also change the "change" status marker to "no change"			
						}
						else
							*(directionOfData+itemp) = (*(directionOfData+itemp))&0x3f;
							
					}
					else 
						*(directionOfData+itemp) = (*(directionOfData+itemp))&0x3f;

				}
			}
		}
				
//*******************************negitive direction*************************
		for(i=iheight-2;i>0;i--)
		{
			position_i1 = (i+1)*imagesize;
			position_i2 = i*imagesize;
			
			for(j=iwidth-2;j>0;j--)
			{
				position_j1 = (j-1)*ilong;
				position_j2 = j*ilong;
				position_j3 = (j+1)*ilong;
				
				for(k=ilong-2;k>0;k--)
				if(!(*(directionOfData + position_i2+position_j2+k)&0x80)&&(*(directionOfData + position_i2+position_j2+k)&0x40))
				{
//1
					itemp=position_i1+position_j3+k+1;
					maxvalue=*(outputData+itemp);
					maxcolorindex=27;
//2
					itemp--;
					if(*(outputData+itemp)>maxvalue)
					{
						maxvalue=*(outputData+itemp);
						maxcolorindex=26;
					}
//3
					itemp--;
					if(*(outputData+itemp)>maxvalue)
					{
						maxvalue=*(outputData+itemp);
						maxcolorindex=25;
					}
//4
					itemp=position_i1+position_j2+k+1;
					if(*(outputData+itemp)>maxvalue)
					{
						maxvalue=*(outputData+itemp);
						maxcolorindex=24;
					}
//5
					itemp--;
					if(*(outputData+itemp)>maxvalue)
					{
						maxvalue=*(outputData+itemp);
						maxcolorindex=23;
					}

//6
					itemp--;
					if(*(outputData+itemp)>maxvalue)
					{
						maxvalue=*(outputData+itemp);
						maxcolorindex=22;
					}
//7					
					itemp=position_i1+position_j1+k+1;
					if(*(outputData+itemp)>maxvalue)
					{
						maxvalue=*(outputData+itemp);
						maxcolorindex=21;
					}
//8	
					itemp--;
					if(*(outputData+itemp)>maxvalue)
					{
						maxvalue=*(outputData+itemp);
						maxcolorindex=20;
					}
//9					
					itemp--;
					if(*(outputData+itemp)>maxvalue)
					{
						maxvalue=*(outputData+itemp);
						maxcolorindex=19;
					}
//10	
					itemp=position_i2+position_j3+k+1;
					if(*(outputData+itemp)>maxvalue)
					{
						maxvalue=*(outputData+itemp);
						maxcolorindex=18;
					}
//11
					itemp--;
					if(*(outputData+itemp)>maxvalue)
					{
						maxvalue=*(outputData+itemp);
						maxcolorindex=17;
					}
//12
					itemp--;
					if(*(outputData+itemp)>maxvalue)
					{
						maxvalue=*(outputData+itemp);
						maxcolorindex=16;
					}
//13
					itemp=position_i2+position_j2+k+1;
					if(*(outputData+itemp)>maxvalue)
					{
						maxvalue=*(outputData+itemp);
						maxcolorindex=15;
					}
//update g
//((*(inputData+itemp)>*(outputData+itemp))||(((*(directionOfData+maxcolorindex))&0x3f) != ((*(directionOfData+itemp))&0x3f)))
					itemp=position_i2+position_j2+k;
					if(maxvalue>*(outputData+itemp))
					{
						if(*(inputData+itemp)>*(outputData+itemp))
						{
													//*(outputData+itemp)=min(maxvalue,*(inputData+itemp));
							if(maxvalue>*(inputData+itemp))
								*(outputData+itemp)=*(inputData+itemp);
							else 
								*(outputData+itemp)=maxvalue;
							*(directionOfData+itemp)=maxcolorindex&0x3f;
							int ii,jj,kk;
							for(ii=0;ii<3;ii++)
								for(jj=0;jj<3;jj++)
									for(kk=0;kk<3;kk++)
									{
										itemp=(i-1+ii)*imagesize+(j-1+jj)*ilong+k-1+kk;
										if(!((*(directionOfData+itemp)) & 0xC0))
											*(directionOfData+itemp) = (*(directionOfData+itemp)) | 0x40;
									}
										
							
							changed++;
						}
						else if(((*(directionOfData+itemp))&0x3f) != (maxcolorindex&0x3f))// connect value won't change, only direction will change, so no need to notice neighbors to check update.
						{
							// to check 26 neighbors to find the highest connectedness( actually 13 has been checked so check the rest 13)
							float recheckmax=maxvalue;
							int   recheckmaxindex=maxcolorindex;
							int ii,jj,kk;
							float ftemp;
							for(ii=0;ii<2;ii++)
								for(jj=0;jj<3;jj++)
									for(kk=0;kk<3;kk++)
									{ 
										ftemp=*(outputData+(i-1+ii)*imagesize+(j-1+jj)*ilong+k-1+kk);
										if(ftemp>recheckmax)
										{
											recheckmax=ftemp;
											recheckmaxindex=ii*9+jj*3+kk+1;
										}
									}
							//there is difference between maxcolorindex and recheckmaxindex
							//maxcolorindex is the lase maxinium of backward 13 neighbors
							//recheckmaxindex is the first maxinium of forward 13 neighbors
							//recheckmaxindex will not be 14!
							if(recheckmaxindex>14 ) 
								*(directionOfData+itemp)=maxcolorindex&0x3f;
							else 
								*(directionOfData+itemp)=(recheckmaxindex&0x3f);
										
						}
						else
							*(directionOfData+itemp) = (*(directionOfData+itemp))&0x3f;
							

					}
					else 
						*(directionOfData+itemp) = (*(directionOfData+itemp))&0x3f;

				}
			}
		}

	}while(changed);

}
- (void) startShortestPathSearchAsFloatWith6Neighborhood:(float *) pIn Out:(float *) pOut Direction: (unsigned char*) pPointers
{
	
	long i,j,k;
	int changed;
	float maxvalue;
	unsigned char maxcolorindex;
	
	
	long itemp;
	long ilong,iwidth,iheight,imagesize;
	long position_i1,position_i2,position_j1,position_j2,position_j3;
	
	
	ilong=imageWidth;
	iwidth=imageHeight;
	iheight=imageAmount;
	imagesize=iwidth*ilong;
	
	inputData=pIn;
	outputData=pOut;
	directionOfData=pPointers;
	
	
	
	
	do
	{
		changed=0;
		
		//**********************positive direction*****************************
		for(i=1;i<iheight-1;i++)
		{
			position_i1 = (i-1)*imagesize;
			position_i2 = i*imagesize;
			
			for(j=1;j<iwidth-1;j++)
			{
				position_j1 = (j-1)*ilong;
				position_j2 = j*ilong;
				position_j3 = (j+1)*ilong;
				for(k=1;k<ilong-1;k++)
					if((!(*(directionOfData + position_i2+position_j2+k)&0x80))&&(*(directionOfData + position_i2+position_j2+k)&0x40))
					{

						//5
						itemp=position_i1+position_j2+k;
						maxvalue=*(outputData+itemp);
						maxcolorindex=5;


						//11
						itemp=position_i2+position_j1+k;
						if(*(outputData+itemp)>maxvalue)
						{
							maxvalue=*(outputData+itemp);
							maxcolorindex=11;
						}
						//13
						itemp=position_i2+position_j2+k-1;
						if(*(outputData+itemp)>maxvalue)
						{
							maxvalue=*(outputData+itemp);
							maxcolorindex=13;
						}
						//update g
						//((*(inputData+itemp)>*(outputData+itemp))||(((*(directionOfData+maxcolorindex))&0x3f) != ((*(directionOfData+itemp))&0x3f)))
						itemp=position_i2+position_j2+k;
						if(maxvalue>*(outputData+itemp))
						{
							if(*(inputData+itemp)>*(outputData+itemp))
							{
								//*(outputData+itemp)=min(maxvalue,*(inputData+itemp));
								if(maxvalue>*(inputData+itemp))
									*(outputData+itemp)=*(inputData+itemp);
								else 
									*(outputData+itemp)=maxvalue;
								*(directionOfData+itemp)=maxcolorindex&0x3f;
								*(directionOfData+position_i1+position_j2+k) = (*(directionOfData+position_i1+position_j2+k)) | 0x40;
								*(directionOfData+position_i2+position_j1+k) = (*(directionOfData+position_i2+position_j1+k)) | 0x40;
								*(directionOfData+position_i2+position_j2+k-1) = (*(directionOfData+position_i2+position_j2+k-1)) | 0x40;
								*(directionOfData+position_i2+position_j2+k+1) = (*(directionOfData+position_i2+position_j2+k+1)) | 0x40;
								*(directionOfData+position_i2+position_j3+k) = (*(directionOfData+position_i2+position_j3+k)) | 0x40;
								*(directionOfData+(i+1)*imagesize+position_j2+k) = (*(directionOfData+(i+1)*imagesize+position_j2+k)) | 0x40;

								changed++;				
							}
							else if(((*(directionOfData+itemp))&0x3f) != (maxcolorindex&0x3f))// connect value won't change, only direction will change, so no need to notice neighbors to check update.
							{
								// to check 26 neighbors to find the highest connectedness( actually 13 has been checked so check the rest 13)
								float recheckmax=maxvalue;
								int   recheckmaxindex=maxcolorindex;

								float ftemp;

								ftemp=*(outputData+position_i2+position_j2+k+1);
								if(ftemp>=recheckmax)
								{
									recheckmax=ftemp;
									recheckmaxindex=15;
								}
								ftemp=*(outputData+position_i2+position_j3+k);
								if(ftemp>=recheckmax)
								{
									recheckmax=ftemp;
									recheckmaxindex=17;
								}
								ftemp=*(outputData+(i+1)*imagesize+position_j2+k);
								if(ftemp>=recheckmax)
								{
									recheckmax=ftemp;
									recheckmaxindex=23;
								}
											//there is difference between maxcolorindex and recheckmaxindex
											//maxcolorindex is the first maxinium of forward 13 neighbors
											//recheckmaxindex is the last maxinium of backward 13 neighbors
											//recheckmaxindex will not be 14!
								if(recheckmaxindex<14 ) 
									*(directionOfData+itemp)=maxcolorindex&0x3f;
						
								else 
									*(directionOfData+itemp)=(recheckmaxindex&0x3f);
									
								//above sentence also change the "change" status marker to "no change"			
							}
							else
								*(directionOfData+itemp) = (*(directionOfData+itemp))&0x3f;
							
						}
						else 
							*(directionOfData+itemp) = (*(directionOfData+itemp))&0x3f;
						
					}
			}
		}
			
			//*******************************negitive direction*************************
			for(i=iheight-2;i>0;i--)
			{
				position_i1 = (i+1)*imagesize;
				position_i2 = i*imagesize;
				
				for(j=iwidth-2;j>0;j--)
				{
					position_j1 = (j-1)*ilong;
					position_j2 = j*ilong;
					position_j3 = (j+1)*ilong;
					
					for(k=ilong-2;k>0;k--)
						if(!(*(directionOfData + position_i2+position_j2+k)&0x80)&&(*(directionOfData + position_i2+position_j2+k)&0x40))
						{

							//5
							itemp=position_i1+position_j2+k;
							maxvalue=*(outputData+itemp);
							maxcolorindex=23;


							//11
							itemp=position_i2+position_j3+k;
							if(*(outputData+itemp)>maxvalue)
							{
								maxvalue=*(outputData+itemp);
								maxcolorindex=17;
							}
							//13
							itemp=position_i2+position_j2+k+1;
							if(*(outputData+itemp)>maxvalue)
							{
								maxvalue=*(outputData+itemp);
								maxcolorindex=15;
							}
							//update g
							//((*(inputData+itemp)>*(outputData+itemp))||(((*(directionOfData+maxcolorindex))&0x3f) != ((*(directionOfData+itemp))&0x3f)))
							itemp=position_i2+position_j2+k;
							if(maxvalue>*(outputData+itemp))
							{
								if(*(inputData+itemp)>*(outputData+itemp))
								{
									//*(outputData+itemp)=min(maxvalue,*(inputData+itemp));
									if(maxvalue>*(inputData+itemp))
										*(outputData+itemp)=*(inputData+itemp);
									else 
										*(outputData+itemp)=maxvalue;
									*(directionOfData+itemp)=maxcolorindex&0x3f;
									*(directionOfData+position_i1+position_j2+k) = (*(directionOfData+position_i1+position_j2+k)) | 0x40;
									*(directionOfData+position_i2+position_j3+k) = (*(directionOfData+position_i2+position_j3+k)) | 0x40;
									*(directionOfData+position_i2+position_j2+k-1) = (*(directionOfData+position_i2+position_j2+k-1)) | 0x40;
									*(directionOfData+position_i2+position_j2+k+1) = (*(directionOfData+position_i2+position_j2+k+1)) | 0x40;
									*(directionOfData+position_i2+position_j1+k) = (*(directionOfData+position_i2+position_j1+k)) | 0x40;
									*(directionOfData+(i-1)*imagesize+position_j2+k) = (*(directionOfData+(i-1)*imagesize+position_j2+k)) | 0x40;
									
									
									
									changed++;
								}
								else if(((*(directionOfData+itemp))&0x3f) != (maxcolorindex&0x3f))// connect value won't change, only direction will change, so no need to notice neighbors to check update.
								{
									// to check 26 neighbors to find the highest connectedness( actually 13 has been checked so check the rest 13)
									float recheckmax=maxvalue;
									int   recheckmaxindex=maxcolorindex;
									float ftemp;
									
									ftemp=*(outputData+position_i2+position_j2+k-1);
									if(ftemp>=recheckmax)
									{
										recheckmax=ftemp;
										recheckmaxindex=13;
									}
									ftemp=*(outputData+position_i2+position_j1+k);
									if(ftemp>=recheckmax)
									{
										recheckmax=ftemp;
										recheckmaxindex=11;
									}
									ftemp=*(outputData+(i-1)*imagesize+position_j2+k);
									if(ftemp>=recheckmax)
									{
										recheckmax=ftemp;
										recheckmaxindex=5;
									}
						
									//there is difference between maxcolorindex and recheckmaxindex
									//maxcolorindex is the lase maxinium of backward 13 neighbors
									//recheckmaxindex is the first maxinium of forward 13 neighbors
									//recheckmaxindex will not be 14!
									if(recheckmaxindex>14 ) 
										*(directionOfData+itemp)=maxcolorindex&0x3f;
									else 
										*(directionOfData+itemp)=(recheckmaxindex&0x3f);
									
								}
								else
									*(directionOfData+itemp) = (*(directionOfData+itemp))&0x3f;
								
								
							}
							else 
								*(directionOfData+itemp) = (*(directionOfData+itemp))&0x3f;
							
						}
				}
			}
				
	}while(changed);
			
}
- (void) caculatePathLength:(float *) pIn:(float *) pOut Pointer: (unsigned char*) pPointers
{
	inputData=pIn;
	outputData=pOut;
	directionOfData=pPointers;
	int i,j,k;
	for(i=1;i<imageAmount-1;i++)
		for(j=1;j<imageHeight-1;j++)
			for(k=1;k<imageWidth-1;k++)
			{
				int itemp=i*imageWidth*imageHeight+j*imageWidth+k;
				if((!((*(directionOfData+itemp))&0x80))&&(*(outputData+itemp)==0))
				{
					int direction=*(directionOfData+itemp);
					
					int xx,yy,zz;
					zz=(direction-1)/9;
					yy=((direction-1)-9*zz)/3;
					xx=(direction-1)-9*zz-3*yy;
					zz--;
					yy--;
					xx--;
					int newPointerToParent=itemp+zz*imageWidth*imageHeight+yy*imageWidth+xx;
					*(outputData+itemp)=[self lengthOfParent:newPointerToParent]+1;
				}
				
			}
				
					
	
}
- (float) lengthOfParent:(int)pointer
{
	if(*(outputData+pointer)==0)
	{
		int direction=*(directionOfData+pointer);
		if(direction)
		{
			int xx,yy,zz;
			zz=(direction-1)/9;
			yy=((direction-1)-9*zz)/3;
			xx=(direction-1)-9*zz-3*yy;
			zz--;
			yy--;
			xx--;
			int newPointerToParent = pointer+zz*imageWidth*imageHeight+yy*imageWidth+xx;
			*(outputData+pointer) = [self lengthOfParent:newPointerToParent]+1;
		}
		else
			return 1;
		
	}
	return(*(outputData+pointer));
}
- (void) caculatePathLengthWithWeightFunction:(float *) pIn:(float *) pOut Pointer: (unsigned char*) pPointers:(float) threshold: (float)wholeValue
{
	inputData=pIn;
	outputData=pOut;
	directionOfData=pPointers;
	weightThreshold=threshold;
	weightWholeValue=wholeValue;
	int i,j,k;
	for(i=1;i<imageAmount-1;i++)
		for(j=1;j<imageHeight-1;j++)
			for(k=1;k<imageWidth-1;k++)
			{
				int itemp=i*imageWidth*imageHeight+j*imageWidth+k;
				if((!((*(directionOfData+itemp))&0x80))&&(*(outputData+itemp)==0))
				{
					int direction=*(directionOfData+itemp);
					
					int xx,yy,zz;
					zz=(direction-1)/9;
					yy=((direction-1)-9*zz)/3;
					xx=(direction-1)-9*zz-3*yy;
					zz--;
					yy--;
					xx--;
					int newPointerToParent=itemp+zz*imageWidth*imageHeight+yy*imageWidth+xx;
					*(outputData+itemp)=[self lengthOfParentWithWeightFunction:newPointerToParent]+((*(inputData+itemp)-weightThreshold)/weightWholeValue);
				}
				
			}
				
				
				
}
- (float) lengthOfParentWithWeightFunction:(int)pointer
{
	if(*(outputData+pointer)==0)
	{
		int direction=*(directionOfData+pointer);
		if(direction)
		{
			int xx,yy,zz;
			zz=(direction-1)/9;
			yy=((direction-1)-9*zz)/3;
			xx=(direction-1)-9*zz-3*yy;
			zz--;
			yy--;
			xx--;
			int newPointerToParent = pointer+zz*imageWidth*imageHeight+yy*imageWidth+xx;
			*(outputData+pointer) = [self lengthOfParentWithWeightFunction:newPointerToParent]+((*(inputData+pointer)-weightThreshold)/weightWholeValue);
		}
		else
			return 0;
	}
	return(*(outputData+pointer));
}
- (void) caculateColorMapFromPointerMap: (unsigned char*) pColor: (unsigned char*) pPointers
{
	colorOfData=pColor;
	directionOfData=pPointers;
	int i,j,k;
	for(i=1;i<imageAmount-1;i++)
		for(j=1;j<imageHeight-1;j++)
			for(k=1;k<imageWidth-1;k++)
			{
				int itemp=i*imageWidth*imageHeight+j*imageWidth+k;
				if(*(colorOfData+itemp)==0)
				{
					if(!((*(directionOfData+itemp))&0x80))
					{
						int direction=*(directionOfData+itemp)&0x3f;
						if(direction)
						{
							int xx,yy,zz;
							zz=(direction-1)/9;
							yy=((direction-1)-9*zz)/3;
							xx=(direction-1)-9*zz-3*yy;
							zz--;
							yy--;
							xx--;
							int newPointerToParent=itemp+zz*imageWidth*imageHeight+yy*imageWidth+xx;
							*(colorOfData+itemp)=[self colorOfParent:newPointerToParent];
						}
					}
					else
						*(colorOfData+itemp)=(*(directionOfData+itemp))&0x3f;
				}
				
				
			}
				
}
- (unsigned char) colorOfParent:(int)pointer
{
	if(*(colorOfData+pointer)==0)
	{
		if(!((*(directionOfData+pointer))&0x80))
		{

				int direction=*(directionOfData+pointer)&0x3f;
				if(direction)
				{
					int xx,yy,zz;
					zz=(direction-1)/9;
					yy=((direction-1)-9*zz)/3;
					xx=(direction-1)-9*zz-3*yy;
					zz--;
					yy--;
					xx--;
					int newPointerToParent = pointer+zz*imageWidth*imageHeight+yy*imageWidth+xx;
					*(colorOfData+pointer) = [self colorOfParent:newPointerToParent];
				}
				else
					return 0;
			
		}
		else if(*(colorOfData+pointer)==0)
			*(colorOfData+pointer)=(*(directionOfData+pointer))&0x3f;
	}

	return(*(colorOfData+pointer));
	
}

- (void) localOptmizeConnectednessTree:(float *)pIn :(float *)pOut Pointer:(unsigned char*) pPointers :(float)minAtEdge
{
	inputData=pIn;
	outputData=pOut;
	directionOfData=pPointers;
	minValueInCurSeries=minAtEdge;
	unsigned char pointerToUpper;
	float maxUpper, currentLength;
	int itemp;
	float tempfloat;
	int x,y,z;
	for(z=1;z<imageAmount-1;z++)
		for(y=1;y<imageHeight-1;y++)
			for(x=1;x<imageWidth-1;x++)
				if(!((*(directionOfData + z*imageWidth * imageHeight + y*imageWidth + x))&0xc0))
				{

					pointerToUpper = ((*(directionOfData + z*imageWidth * imageHeight + y*imageWidth + x))&0x3f);
					
					
					int xx,yy,zz;
					zz=(pointerToUpper-1)/9;
					yy=((pointerToUpper-1)-9*zz)/3;
					xx=(pointerToUpper-1)-9*zz-3*yy;
					zz--;
					yy--;
					xx--;
					

					maxUpper = [self valueAfterConvolutionAt:(x+xx):(y+yy):(z+zz)] ;
					currentLength = *(outputData + z*imageWidth * imageHeight + y*imageWidth +x);
					for(zz=-1;zz<2;zz++)
						for(yy=-1;yy<2;yy++)
							for(xx=-1;xx<2;xx++)
							{
								itemp=(z+zz)*imageWidth * imageHeight+(y+yy)*imageWidth+x+xx;
								if((*(outputData+itemp)<currentLength)&&(*(outputData+itemp)>1))
								{
									tempfloat=[self valueAfterConvolutionAt:(x+xx):(y+yy):(z+zz)];
									if(tempfloat>maxUpper)
									{
										maxUpper=tempfloat;

										//optmize the local pointer
										pointerToUpper=(zz+1)*9+(yy+1)*3+(xx+1)+1;
									}
								}

							}
								
					//mark current point as new seeds(use changed marker) for further skeleton		
					*(directionOfData + z*imageWidth * imageHeight + y*imageWidth + x)=pointerToUpper;					
				}
					
	
	
}
- (float)valueAfterConvolutionAt:(int)x:(int)y:(int)z
{
	int ii,jj,kk;
	float sum;
	int xx,yy,zz;
	
	for(ii=-1;ii<2;ii++)
		for(jj=-1;jj<2;jj++)
			for(kk=-1;kk<2;kk++)
			{
				zz=z+ii;
				yy=y+jj;
				xx=x+kk;
				if(xx>=0 && xx<imageWidth && yy>=0 && yy<imageHeight && zz>=0 && zz<imageAmount && (!((*(directionOfData + zz*imageWidth * imageHeight + yy*imageWidth + xx))&0x80)))
					sum+=*(inputData + zz*imageWidth * imageHeight + yy*imageWidth + xx);
				else
					sum+=minValueInCurSeries;
				
				
			}
				sum=sum/27;
	return sum;
}

@end
