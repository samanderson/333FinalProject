//
//  GroupData.m
//  RouteRanker
//
//  Created by Chuck Anderson on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GroupData.h"
#import "RouteData.h"


@implementation GroupData

@dynamic name;
@dynamic routes;

- (NSComparisonResult)compare:(GroupData *)other {
    return [self.name caseInsensitiveCompare:other.name];
}

@end
