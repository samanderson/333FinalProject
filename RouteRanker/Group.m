//
//  Group.m
//  RouteRanker
//
//  Created by Chuck Anderson on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Group.h"

@implementation Group

@synthesize routes = _routes;
@synthesize groupName = _groupName;
@synthesize totalTime, totalDist, avgDist, avgSpeed, avgTime, numRoutes;
@synthesize unit;
@synthesize routeNames, routeTimes, routeDistances, shortestTime, longestTime, longestDist, shortestDist;

-(id) initWithGroupData:(GroupData *)group
{
    self = [super init];
    if (self)
    {
        self.groupName = group.name;
        self.routes = [group.routes allObjects];
        numRoutes = [self.routes count];
        double time = 0.0, dist = 0.0, maxDist = 0.0, minDist = -1.0;
        double minTime = -1.0, maxTime = 0.0, d, t;
        routeDistances = [[NSMutableArray alloc] init];
        routeNames = [[NSMutableArray alloc] init];
        routeTimes = [[NSMutableArray alloc] init];
        for (RouteData *route in self.routes) {
            d = [route.distance doubleValue]/1000;
            t = [route.time doubleValue];
            time += t;
            dist += d;
            if (d > maxDist)
                maxDist = d;
            if (minDist == -1.0 || d < minDist)
                minDist = d;
            if (minTime == -1.0 || t < minTime)
                minTime = t;
            if (t > maxTime)
                maxTime = t;
            [routeDistances addObject:route.distance];
            [routeTimes addObject:route.time];
            [routeNames addObject:route.title];
        }
        totalTime = time;
        totalDist = dist;
        if (numRoutes != 0) {
            avgDist = totalDist / numRoutes;
            avgTime = totalTime / numRoutes;
            avgSpeed = avgDist / avgTime * 3600;
            shortestDist = minDist;
            shortestTime = minTime;
        }
        else {
            avgDist = 0;
            avgTime = 0;
            avgSpeed = 0;
            shortestDist = 0;
            shortestTime = 0;
        }
        longestTime = maxTime;
        longestDist = maxDist;
        unit = @"km";
        //NSLog(@"avgDist %f", avgDist);
        }
    return self;
}

-(void) convertFromMetric
{
    double distance = 0.0;
    totalDist *= 0.621371192;
    avgSpeed *= 0.621371192;
    avgDist *= 0.621371192;
    shortestDist *= 0.621371192;
    longestDist *= 0.621371192;
    for(int i = 0; i < numRoutes; i++)
    {
        distance = [[routeDistances objectAtIndex:i ] doubleValue];
        distance *= 0.621371192;
        [routeDistances replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:distance]];
    }
    unit = @"miles";
}

-(void) convertToMetric 
{
    double distance = 0.0;
    totalDist /= 0.621371192;
    avgSpeed /= 0.621371192;
    avgDist /= 0.621371192;
    shortestDist /= 0.621371192;
    longestDist /= 0.621371192;
    for(int i = 0; i < numRoutes; i++)
    {
        distance = [[routeDistances objectAtIndex:i ] doubleValue];
        distance /= 0.621371192;
        [routeDistances replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:distance]];
    }
    unit = @"km";
}

@end
