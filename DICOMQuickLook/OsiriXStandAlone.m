#import <Foundation/Foundation.h>
#include "DicomFile.h"
#include "BrowserController.h"
#import <OsiriX/DCMCalendarDate.h>
#import <OsiriX/DCMAbstractSyntaxUID.h>

NSLock	*PapyrusLock = 0L;
NSMutableDictionary *fileFormatPlugins = 0L;

NSMutableArray			*preProcessPlugins = 0L;
NSMutableDictionary		*reportPlugins = 0L;
NSMutableDictionary		*plugins = 0L, *pluginsDict = 0L;
NSThread				*mainThread = 0L;
BOOL					NEEDTOREBUILD = NO;
NSMutableDictionary		*DATABASECOLUMNS = 0L;
short					Altivec = 0;

#if __ppc__ || __ppc64__
// ALTIVEC FUNCTIONS

void InverseLongs(register vector unsigned int *unaligned_input, register long size)
{
	register long						i = size / 4;
	register vector unsigned char		identity = vec_lvsl(0, (int*) NULL );
	register vector unsigned char		byteSwapLongs = vec_xor( identity, vec_splat_u8(sizeof( int )- 1 ) );
	
	while(i-- > 0)
	{
		*unaligned_input++ = vec_perm( *unaligned_input, *unaligned_input, byteSwapLongs);
	}
}

void InverseShorts( register vector unsigned short *unaligned_input, register long size)
{
	register long						i = size / 8;
	register vector unsigned char		identity = vec_lvsl(0, (int*) NULL );
	register vector unsigned char		byteSwapShorts = vec_xor( identity, vec_splat_u8(sizeof( short) - 1) );
	
	while(i-- > 0)
	{
		*unaligned_input++ = vec_perm( *unaligned_input, *unaligned_input, byteSwapShorts);
	}
}

void vmultiply(vector float *a, vector float *b, vector float *r, long size)
{
	long i = size / 4;
	register vector float zero = (vector float) vec_splat_u32(0);
	
	while(i-- > 0)
	{
		*r++ = vec_madd( *a++, *b++, zero);
	}
}

void vsubtract(vector float *a, vector float *b, vector float *r, long size)
{
	long i = size / 4;
	
	while(i-- > 0)
	{
		*r++ = vec_sub( *a++, *b++);
	}
}

void vmax8(vector unsigned char *a, vector unsigned char *b, vector unsigned char *r, long size)
{
	long i = size / 4;
	
	while(i-- > 0)
	{
		*r++ = vec_max( *a++, *b++);
	}
}

void vmax(vector float *a, vector float *b, vector float *r, long size)
{
	long i = size / 4;
	
	while(i-- > 0)
	{
		*r++ = vec_max( *a++, *b++);
	}
}

void vmin(vector float *a, vector float *b, vector float *r, long size)
{
	long i = size / 4;
	
	while(i-- > 0)
	{
		*r++ = vec_min( *a++, *b++);
	}
}

void vmin8(vector float *a, vector float *b, vector float *r, long size)
{
	long i = size / 4;
	
	while(i-- > 0)
	{
		*r++ = vec_min( *a++, *b++);
	}
}
#else
void vmaxIntel( vFloat *a, vFloat *b, vFloat *r, long size)
{
	long i = size/4;
	
	while(i-- > 0)
	{
		*r++ = _mm_max_ps( *a++, *b++);
	}
}
void vminIntel( vFloat *a, vFloat *b, vFloat *r, long size)
{
	long i = size/4;
	
	while(i-- > 0)
	{
		*r++ = _mm_min_ps( *a++, *b++);
	}
}
#endif

void vmultiplyNoAltivec( float *a,  float *b,  float *r, long size)
{
	long i = size;
	
	while(i-- > 0)
	{
		*r++ = *a++ * *b++;
	}
}

void vsubtractNoAltivec( float *a,  float *b,  float *r, long size)
{
	long i = size;
	
	while(i-- > 0)
	{
		*r++ = *a++ - *b++;
	}
}

void vmaxNoAltivec(float *a, float *b, float *r, long size)
{
	long i = size;
	
	while(i-- > 0)
	{
		if( *a > *b) { *r++ = *a++; b++; }
		else { *r++ = *b++; a++; }
	}
}

void vminNoAltivec( float *a,  float *b,  float *r, long size)
{
	long i = size;
	
	while(i-- > 0)
	{
		if( *a < *b) { *r++ = *a++; b++; }
		else { *r++ = *b++; a++; }
	}
}

NSString * documentsDirectory()
{
	return 0L;
}

NSString* convertDICOM( NSString *inputfile)
{
	return inputfile;
}
