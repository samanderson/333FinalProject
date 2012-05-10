//
//  Group.h
//  RouteRanker
//
//  Created by Chuck Anderson on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Route.h"
#import "GroupData.h"
#import "RouteData.h"

@interface Group : NSObject
{
    NSString *groupName;
    NSMutableArray *routes;
}

@property (copy) NSString *groupName;
@property (nonatomic, strong) NSArray *routes;

-(id) initWithGroupData: (GroupData *) group;
-(void) convertFromMetric;
-(void) convertToMetric;

@property NSMutableArray * routeNames;
@property NSMutableArray * routeTimes;
@property NSMutableArray * routeDistances;
@property NSString * unit;
@property double numRoutes; 
@property double avgDist; //in km
@property double avgSpeed; //in km/hr
@property double avgTime; //in seconds
@property double totalTime; // in seconds
@property double totalDist; //in km
@property double longestDist; //in km
@property double shortestDist; //in km
@property double shortestTime; //returns in seconds
@property double longestTime; //returns in seconds

@end
