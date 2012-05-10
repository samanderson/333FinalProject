//
//  GroupData.h
//  RouteRanker
//
//  Created by Chuck Anderson on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RouteData;

@interface GroupData : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *routes;
@end

@interface GroupData (CoreDataGeneratedAccessors)

- (NSComparisonResult)compare:(GroupData *)other;

- (void)addRoutesObject:(RouteData *)value;
- (void)removeRoutesObject:(RouteData *)value;
- (void)addRoutes:(NSSet *)values;
- (void)removeRoutes:(NSSet *)values;

@end
