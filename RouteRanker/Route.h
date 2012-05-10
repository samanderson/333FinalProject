//
//  Route.h
//  RouteRanker
//
//  Created by Chuck Anderson on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "RouteAnnotation.h"
#import "RouteData.h"
#import "MapPointData.h"
#import "AnnotationData.h"

@interface Route : NSObject <MKOverlay>
{
    MKMapPoint *points;
    NSMutableArray *timeArray;
    NSUInteger numPoints;
    NSUInteger pointSpace;
    NSString *name;
    MKMapRect boundingMapRect;
    pthread_rwlock_t rwLock;
}

-(id) initWithStartPoint: (CLLocation *) loc;

-(MKMapRect) addPoint: (CLLocation *) loc;
-(MKMapRect) addEstimatedPoint:(CLLocation *) loc withEstimatedCoordinate: (CLLocationCoordinate2D) coord;
-(double) getTotalDistanceTraveled;
-(NSTimeInterval) getTotalTimeElapsed;

-(void) lockForReading;

@property (nonatomic) int idNo;
@property MKMapPoint *points;
@property NSMutableArray *timeArray;
@property (nonatomic, strong) NSMutableArray *annotations;
@property (copy) NSString *name;
@property NSUInteger numPoints;
@property NSUInteger numAnnotations;
@property (nonatomic) MKMapRect boundingMapRect;
@property (nonatomic) CLLocationCoordinate2D coordinate;

-(void) unlockForReading;

- (void) addAnnotation: (id <MKAnnotation>) a;

+ (Route *)routeFromRouteData:(RouteData *)routeData;

@end
