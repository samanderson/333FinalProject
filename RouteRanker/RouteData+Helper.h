//
//  RouteData+Helper.h
//  RouteRanker
//
//  Created by Nick Gilligan on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RouteData.h"

@interface RouteData (Helper)

- (NSDate *)getStartTimeDate;
-(int) routeCompare: (RouteData *)routeData;
@end
