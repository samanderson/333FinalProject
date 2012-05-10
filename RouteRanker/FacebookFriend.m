//
//  FacebookFriend.m
//  RouteRanker
//
//  Created by Chuck Anderson on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FacebookFriend.h"

@implementation FacebookFriend {
    NSCharacterSet *alphaSet;

}

@synthesize name, ID;

- (NSComparisonResult)compare:(FacebookFriend *)other {
    BOOL selfValid = [[[self.name substringToIndex:1] stringByTrimmingCharactersInSet:alphaSet] isEqualToString:@""];
    BOOL otherValid = [[[other.name substringToIndex:1] stringByTrimmingCharactersInSet:alphaSet] isEqualToString:@""];
    
    if (selfValid && !otherValid) {
        return NSOrderedAscending;
    } else if (otherValid && !selfValid) {
        return NSOrderedDescending;
    } else {
        return [self.name caseInsensitiveCompare:other.name];
    }
}

- (id)initWithName:(NSString *)n andID:(NSString *)i {
    if ((self = [super init])) {
        self.name = n;
        self.ID = i;
    }
    alphaSet = [NSCharacterSet letterCharacterSet];
    return self;
}

@end
