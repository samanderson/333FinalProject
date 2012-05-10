//
//  RouteData.h
//  RouteRanker
//
//  Created by Chuck Anderson on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AnnotationData, GroupData, MapPointData;

@interface RouteData : NSManagedObject

@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * endLocation;
@property (nonatomic, retain) NSNumber * idNo;
@property (nonatomic, retain) NSNumber * numAnnotations;
@property (nonatomic, retain) NSNumber * numPoints;
@property (nonatomic, retain) NSNumber * owner;
@property (nonatomic, retain) NSString * startLocation;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *annotations;
@property (nonatomic, retain) NSSet *points;
@property (nonatomic, retain) GroupData *group;
@end

@interface RouteData (CoreDataGeneratedAccessors)

- (void)addAnnotationsObject:(AnnotationData *)value;
- (void)removeAnnotationsObject:(AnnotationData *)value;
- (void)addAnnotations:(NSSet *)values;
- (void)removeAnnotations:(NSSet *)values;

- (void)addPointsObject:(MapPointData *)value;
- (void)removePointsObject:(MapPointData *)value;
- (void)addPoints:(NSSet *)values;
- (void)removePoints:(NSSet *)values;

@end
