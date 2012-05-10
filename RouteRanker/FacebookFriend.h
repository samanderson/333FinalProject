//
//  FacebookFriend.h
//  RouteRanker
//
//  Created by Chuck Anderson on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FacebookFriend : NSObject {
    NSString *name;
    NSString *ID;
}

@property NSString *name;
@property NSString *ID;

- (NSComparisonResult)compare:(FacebookFriend *)other;
- (id)initWithName:(NSString *)n andID:(NSString *)i;


@end
