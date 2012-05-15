//
//  RouteData+Helper.m
//  RouteRanker
//
//  Created by Nick Gilligan on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RouteData+Helper.h"
#import "MapPointData.h"

@implementation RouteData (Helper)

- (NSDate *)getStartTimeDate
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sequence" ascending:YES];
    NSArray *mapPoints = [self.points sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    MapPointData *mapPointData = [mapPoints objectAtIndex:0];
    return mapPointData.timestamp;
}

-(int) routeCompare: (RouteData *)routeData {
    NSDate *thisDate = [self getStartTimeDate];
    NSDate *thatDate = [routeData getStartTimeDate];
    return [thatDate compare:thisDate];
}

@end
