//
//  ClusteringFilter.m
//  Clustering
//
//  Copyright (c) 2006 Arnaud. All rights reserved.
//

#import "ClusteringFilter.h"

@class ClusteringController;

@implementation ClusteringFilter

- (void) initPlugin
{
	ClusteringController *cluster = [[ClusteringController alloc] init];
	[cluster showWindow:self];
}

- (long) filterImage:(NSString*) menuName
{
	return 0;
}

@end
