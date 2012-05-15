//
//  Route.m
//  RouteRanker
//
// We used Apple's Breadcrumb class CrumbPath.m to help write this file. 
//  Created by Chuck Anderson on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
// kCLLocationAccuracyBest (gps) 
// kCLLocationAccuracyBestForNavigation;
// kCLLocationAccuracyNearestTenMeters
//

#import "Route.h"
#import "AutoAnnotation.h"

#define INITIAL_POINT_SPACE 1000
#define MINIMUM_DELTA_METERS 10.0

@implementation Route

@synthesize points, numPoints, timeArray, annotations, name, idNo;
@synthesize numAnnotations, coordinate, boundingMapRect;

-(id) initWithStartPoint:(CLLocation *)loc
{
    self = [super init];
    if (self)
    {
        CLLocationCoordinate2D coord = loc.coordinate;
        MKMapPoint point= MKMapPointForCoordinate(coord);
        NSDate *timeStamp = [loc.timestamp copy];
        pointSpace = INITIAL_POINT_SPACE;
        points = malloc(sizeof(MKMapPoint) * pointSpace);
        timeArray = [NSMutableArray arrayWithCapacity:pointSpace]; 
        [timeArray addObject:timeStamp];
        points[0] = point;
        numPoints = 1;
        numAnnotations = 0;
        annotations = [[NSMutableArray alloc] init];
        
        MKMapPoint center = point;
        center.x -= MKMapSizeWorld.width / 8.0;
        center.y -= MKMapSizeWorld.height / 8.0;
        MKMapSize size = MKMapSizeWorld;
        size.width /= 4.0;
        size.height /=4.0;
        boundingMapRect = MKMapRectMake(center.x,center.y,size.width,size.height); 
        MKMapRect worldRect = MKMapRectMake(0, 0, MKMapSizeWorld.width, MKMapSizeWorld.height);
        boundingMapRect = MKMapRectIntersection(boundingMapRect, worldRect);
        
        pthread_rwlock_init(&rwLock, NULL);
    }
    return self;
    
}
-(void) dealloc
{
    free(points);
    pthread_rwlock_destroy(&rwLock);
}

-(CLLocationCoordinate2D) coordinate
{
    return MKCoordinateForMapPoint(points[0]);
}

-(MKMapRect) boundingMapRect
{
    return boundingMapRect;
}
-(void) lockForReading
{
    pthread_rwlock_rdlock(&rwLock);
}


- (void)unlockForReading
{
    pthread_rwlock_unlock(&rwLock);
}

- (void) addAnnotation:(id <MKAnnotation>)a {
    numAnnotations++;
    [annotations addObject: a];
}

-(MKMapRect) addEstimatedPoint:(CLLocation *) loc withEstimatedCoordinate: (CLLocationCoordinate2D) coord
{
    pthread_rwlock_wrlock(&rwLock);
    
    MKMapPoint newPoint = MKMapPointForCoordinate(coord);
    MKMapPoint prevPoint = points[numPoints -1];
    
    //NSLog(@"%@", MKMapPointForCoordinate(loc.coordinate));
    CLLocationDistance metersApart = MKMetersBetweenMapPoints(newPoint, prevPoint);
    MKMapRect updateRect = MKMapRectNull;
    
    if(metersApart > MINIMUM_DELTA_METERS)
    {
        NSDate *newDate = [loc.timestamp copy];
        if (pointSpace == numPoints)
        {
            pointSpace *= 2;
            points = realloc(points, sizeof(MKMapPoint) * pointSpace);
        }
        [timeArray addObject:newDate];
        points[numPoints] = newPoint;
        numPoints++;
        
        double minX = MIN(newPoint.x, prevPoint.x);
        double minY = MIN(newPoint.y, prevPoint.y);
        double maxX = MAX(newPoint.x, prevPoint.x);
        double maxY = MAX(newPoint.y, prevPoint.y);
        
        updateRect = MKMapRectMake(minX, minY, maxX-minX, maxY- minY);
    }
    
    pthread_rwlock_unlock(&rwLock);
    
    return updateRect;
}

-(MKMapRect) addPoint:(CLLocation *)loc
{
    pthread_rwlock_wrlock(&rwLock);
    
    MKMapPoint newPoint = MKMapPointForCoordinate(loc.coordinate);
    MKMapPoint prevPoint = points[numPoints -1];

    //NSLog(@"%@", MKMapPointForCoordinate(loc.coordinate));
    CLLocationDistance metersApart = MKMetersBetweenMapPoints(newPoint, prevPoint);
    MKMapRect updateRect = MKMapRectNull;
    
    if(metersApart > MINIMUM_DELTA_METERS)
    {
        NSDate *newDate = [loc.timestamp copy];
        if (pointSpace == numPoints)
        {
            pointSpace *= 2;
            points = realloc(points, sizeof(MKMapPoint) * pointSpace);
        }
        [timeArray addObject:newDate];
        points[numPoints] = newPoint;
        numPoints++;
        
        double minX = MIN(newPoint.x, prevPoint.x);
        double minY = MIN(newPoint.y, prevPoint.y);
        double maxX = MAX(newPoint.x, prevPoint.x);
        double maxY = MAX(newPoint.y, prevPoint.y);
        
        updateRect = MKMapRectMake(minX, minY, maxX-minX, maxY- minY);
    }
    
    pthread_rwlock_unlock(&rwLock);
    
    return updateRect;
}

//Returns in m
-(double) getTotalDistanceTraveled
{
    double distanceTraveled = 0;
    for(int i = 0; i < numPoints-1; i++)
    {
        distanceTraveled += MKMetersBetweenMapPoints(points[i], points[i+1]);
    }
    return distanceTraveled;
}

- (NSTimeInterval) getTotalTimeElapsed
{
    NSDate * start = [timeArray objectAtIndex:0];
    NSDate * end = [timeArray objectAtIndex:numPoints -1];
    NSTimeInterval timeElapsed = [end timeIntervalSinceDate:start];
    return timeElapsed;
    
}

+ (Route *)routeFromRouteData:(RouteData *)routeData
{
    Route * route = [[Route alloc] init];
    
    route.name = routeData.title;
    route.numAnnotations = [routeData.numAnnotations intValue];
    route.numPoints = [routeData.numPoints intValue];
    
    MKMapPoint *routePoints = malloc(sizeof(MKMapPoint) * route.numPoints);
    NSMutableArray *routeTimes = [[NSMutableArray alloc] initWithCapacity:route.numPoints];
    
    //reate array of MapPointData ordered by their sequence numbers
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sequence" ascending:YES];
    NSArray *dataPoints = [routeData.points sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    int i = 0;
    for(MapPointData *dataPoint in dataPoints) {
        routePoints[i] = MKMapPointMake([dataPoint.x doubleValue], [dataPoint.y doubleValue]);
        [routeTimes addObject: dataPoint.timestamp];
        i++;
    }
    
    route.points = routePoints;
    route.timeArray = routeTimes;
    
    double x;
    double y;
    double maxX = route.points[0].x;
    double maxY = route.points[0].y;
    double minX = route.points[0].x;
    double minY = route.points[0].y;
    for(int i = 1; i < route.numPoints; i++)
    {
        x = route.points[i].x ;
        y = route.points[i].y;
        if(x < minX)
            minX = x;
        if(x > maxX)
            maxX = x;
        if (y < minY)
            minY = y;
        if(y > maxY)
            maxY = y;
        
    }
    MKMapRect rect = MKMapRectMake(minX, minY, maxX-minX, maxY-minY);
    route.boundingMapRect = rect;
    
    
    NSMutableArray *routeAnnotations = [[NSMutableArray alloc] init];
    for(AnnotationData *annotationData in routeData.annotations) {
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([annotationData.latitude doubleValue],[annotationData.longitude doubleValue]);
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yy hh:mm:ss a"];
        NSDate *date = [formatter dateFromString:annotationData.title];
        
        if([annotationData.type isEqualToString:@"auto"]) {
            AutoAnnotation *annotation = [[AutoAnnotation alloc] initWithCoordinateAndTime:coord :date];
            annotation.title = annotationData.title;
            [routeAnnotations addObject:annotation];
        } else {
            RouteAnnotation *annotation = [[RouteAnnotation alloc] initWithCoordinateAndTime:coord :date];
            annotation.title = annotationData.title;
            annotation.subtitle = annotationData.subtitle;
            [routeAnnotations addObject:annotation];
        }
    }
    
    route.annotations = routeAnnotations;
    
    return route; 
}

@end
