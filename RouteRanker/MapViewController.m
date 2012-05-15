//
//  MapViewController.m
//  RouteRanker
//
//  Created by Chuck Anderson on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"


#define IGNORE_POINT 6
#define KALMAN_TIME 0.5
#define CRUMB_RATE 4
#define MINIMUM_DELTA_METERS 25.0

@interface MapViewController() {
    CLLocation *prevCrumbLocation;
    double timeBetween;
    int ignoreAgain;
   // int numCrazyInARow;
}
@end

@implementation MapViewController
@synthesize addPinButton, timer;
@synthesize routes, track, mapTitle;
@synthesize locationManager, map;
@synthesize routeName, currLocation;
@synthesize filter, estLat, estLong, estCoordinate;

@synthesize managedObjectContext, fetchedResultsController;

- (void) toggleTracking {
    track = !track;
    // STOP
    if(!track)
    {
        if (currRoute) {
            CLLocationCoordinate2D firstCoord = MKCoordinateForMapPoint(currRoute.points[0]);
            CLLocationCoordinate2D lastCoord = MKCoordinateForMapPoint(currRoute.points[currRoute.numPoints - 1]);
            CLLocation *first = [[CLLocation alloc] initWithLatitude: firstCoord.latitude longitude:firstCoord.longitude];
            CLLocation *last = [[CLLocation alloc] initWithLatitude: lastCoord.latitude longitude:lastCoord.longitude];
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            CLGeocoder *geocoder2 = [[CLGeocoder alloc] init];
                 
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSManagedObjectContext *context =[(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
            RouteData *routeData = [NSEntityDescription insertNewObjectForEntityForName:@"RouteData" inManagedObjectContext:context];
            
            [geocoder reverseGeocodeLocation: first completionHandler: 
             ^(NSArray *placemarks, NSError *error) {
                 CLPlacemark *placemark = [placemarks objectAtIndex:0];
                 routeData.startLocation = [NSString stringWithFormat:@"%@, %@", placemark.thoroughfare, placemark.locality];
             }];
            
            [geocoder2 reverseGeocodeLocation: last completionHandler: 
             ^(NSArray *placemarks, NSError *error) {
                 CLPlacemark *placemark = [placemarks objectAtIndex:0];
                 routeData.endLocation = [NSString stringWithFormat:@"%@, %@",placemark.thoroughfare, placemark.locality];
             }];
            
            routeData.ownerID = [prefs stringForKey:@"myID"];
            routeData.ownerName = [prefs stringForKey:@"myName"];
            routeData.idNo = [NSNumber numberWithInt: currRoute.idNo];
            routeData.distance = [NSNumber numberWithDouble:[currRoute getTotalDistanceTraveled]];
            routeData.title = currRoute.name;
            routeData.numAnnotations = [NSNumber numberWithInt: currRoute.numAnnotations];
            routeData.numPoints = [NSNumber numberWithInt: currRoute.numPoints];
            routeData.time = [NSNumber numberWithDouble:[currRoute getTotalTimeElapsed]];
        
            MKMapPoint *points = currRoute.points;
            NSMutableArray *times = currRoute.timeArray;
            NSMutableArray *mapPoints = [NSMutableArray arrayWithCapacity:currRoute.numPoints];
            for (int i = 0; i < currRoute.numPoints; i++) {
                MapPointData *mapPoint = [NSEntityDescription insertNewObjectForEntityForName:@"MapPointData" inManagedObjectContext:context];
                mapPoint.sequence = [NSNumber numberWithInt: i];
                mapPoint.timestamp = [times objectAtIndex:i];
                mapPoint.x = [NSNumber numberWithDouble:points[i].x];
                mapPoint.y = [NSNumber numberWithDouble:points[i].y];
                mapPoint.route = routeData;
                [mapPoints addObject:mapPoint];
            }
            routeData.points = [NSSet setWithArray:mapPoints];

            clientRest* client = [[clientRest alloc] init];
            NSString* idOwner = routeData.ownerID;
            int routeNumber = [routeData.idNo intValue];
            [client addPath:currRoute withId:routeNumber ofUser:idOwner];

            if (currRoute.annotations) {
                NSMutableArray *annotations = currRoute.annotations;
                NSMutableArray *annotationsData = [NSMutableArray arrayWithCapacity:currRoute.numAnnotations];
                for (id<MKAnnotation> a in annotations) {
                    AnnotationData *annotationData = [NSEntityDescription insertNewObjectForEntityForName:@"AnnotationData" inManagedObjectContext:context];
                    annotationData.type = [a isKindOfClass:[AutoAnnotation class]] ? @"auto" : @"route";
                    annotationData.title = a.title;
                    if ([a isKindOfClass:[RouteAnnotation class]])
                        annotationData.subtitle = a.subtitle;
                    else
                        annotationData.subtitle = nil;
                    annotationData.latitude = [NSNumber numberWithDouble:a.coordinate.latitude];
                    annotationData.longitude = [NSNumber numberWithDouble:a.coordinate.longitude];
                    annotationData.route = routeData;
                    [annotationsData addObject:annotationData];
                }
                routeData.annotations = [NSSet setWithArray:annotationsData];
            } else {
                routeData.annotations = nil;
            }
             
            NSError *error;
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"RouteData" inManagedObjectContext:context];
            [request setEntity:entity];
            // retrive the objects with a given value for a certain property
            NSPredicate *predicate = [NSPredicate predicateWithFormat: @"title == %@", currRoute.name];
            [request setPredicate:predicate];
            NSArray *fetchedRoutes = [context executeFetchRequest:request error:&error];
            
            // we have multiple routes now by the same name, let's try to group them together
            if ([fetchedRoutes count] > 1) {
                NSFetchRequest *request = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"GroupData" inManagedObjectContext:context];
                [request setEntity:entity];
                // retrive the objects with a given value for a certain property
                NSPredicate *predicate = [NSPredicate predicateWithFormat: @"name == %@", currRoute.name];
                [request setPredicate:predicate];
                NSArray *fetchedGroups = [context executeFetchRequest:request error:&error];
                // there isn't already a group with that name
                if ([fetchedGroups count] == 0) {
                    GroupData *newGroup = [NSEntityDescription insertNewObjectForEntityForName:@"GroupData" inManagedObjectContext:context];
                    newGroup.name = currRoute.name;
                    newGroup.routes = [[NSSet alloc] initWithArray:fetchedRoutes];                    
                } else {
                    // there is already a group with that name, so we add the new one to it
                    GroupData *group = [fetchedGroups objectAtIndex:0];
                    NSArray *ar = [group.routes allObjects];
                    NSMutableArray *newArray = [[NSMutableArray alloc] init];
                    for (RouteData *r in ar) {
                        [newArray addObject:r];
                    }
                    [newArray addObject:routeData];
                    group.routes = [[NSSet alloc] initWithArray:newArray];
                }
            }
            
            if (![context save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }

        }
        
        free_filter(filter);
        numPoints = 0;
        ignoreAgain= 0;
        timerCounter = 0;
        [timer invalidate];
        viewedInMap = NO;
        currLocation = nil;
        prevLocation = nil;
        prevCrumbLocation = nil;
    }
    // START
    else {
        if (map.annotations) {
            [map removeAnnotations:map.annotations];
        }
        [map removeOverlay:currRoute];
        currRoute = nil;
        routeView = nil;
        routeName = nil;
        numPoints = 0;
        ignoreAgain = 0;
        timerCounter = 0;
        
        filter = alloc_filter_velocity2d(1.0);
        timer = [NSTimer scheduledTimerWithTimeInterval:KALMAN_TIME target:self selector:@selector(kalmanUpdate) userInfo:nil repeats:YES];
    }
    
}
                        
- (void) kalmanUpdate {
    if (numPoints >= IGNORE_POINT && ignoreAgain >= IGNORE_POINT) {
        timerCounter++;
        if (!currRoute)
        {
            NSLog(@"HELLO");
            currRoute = [[Route alloc] initWithStartPoint:currLocation];
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];            
            NSInteger numRoutes = [prefs integerForKey:@"numRoutes"];
            numRoutes++;
            [prefs setInteger:numRoutes forKey:@"numRoutes"];
            [prefs synchronize];
            currRoute.idNo = numRoutes;
            if (!routeName) {
                CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                [geocoder reverseGeocodeLocation: currLocation completionHandler: 
                 ^(NSArray *placemarks, NSError *error) {
                     CLPlacemark *placemark = [placemarks objectAtIndex:0];
                     CFGregorianDate currentDate = CFAbsoluteTimeGetGregorianDate(CFAbsoluteTimeGetCurrent(), CFTimeZoneCopySystem());
                     currRoute.name = [NSString stringWithFormat:@"%@ %d/%d/%d", placemark.locality, currentDate.month, currentDate.day, currentDate.year];
                 }];
            } else {
                currRoute.name = routeName;
            }
            if (!routeView) {
                [map addOverlay:currRoute];
            }
        }
        NSLog(@"Distance between points %f", [currLocation distanceFromLocation:prevLocation]);
        //if(//(prevCrumbLocation && ([currLocation distanceFromLocation:prevCrumbLocation] < (100 * KALMAN_TIME) && [currLocation distanceFromLocation:prevCrumbLocation] != -1)) || (!prevCrumbLocation &&([currLocation distanceFromLocation:prevLocation] < (100 * KALMAN_TIME) && [currLocation distanceFromLocation:prevLocation] != -1)))
        timeBetween = [currLocation.timestamp timeIntervalSinceDate:prevLocation.timestamp];
        if(([currLocation distanceFromLocation:prevLocation] < (100 * timeBetween) && [currLocation distanceFromLocation:prevLocation] != -1))
        {
            update_velocity2d(filter, currLocation.coordinate.latitude, currLocation.coordinate.longitude, KALMAN_TIME);
            if (timerCounter % CRUMB_RATE == 0 && (!prevCrumbLocation || [currLocation distanceFromLocation:prevCrumbLocation] >= MINIMUM_DELTA_METERS)) {
                NSDate* today = [NSDate date];
                AutoAnnotation* autoAnnotation = [[AutoAnnotation alloc] initWithCoordinateAndTime: estCoordinate :today];
                [currRoute addAnnotation:autoAnnotation];
                [map addAnnotation:autoAnnotation];
                prevCrumbLocation = currLocation;
            }
            //prevCrumbLocation = currLocation;

        } else {
            update_velocity2d(filter, prevLocation.coordinate.latitude, prevLocation.coordinate.longitude, KALMAN_TIME);            
        }
        get_lat_long(filter, &estLat ,&estLong);
        estCoordinate.latitude = estLat;
        estCoordinate.longitude = estLong;
        MKMapRect updateRect = [currRoute addEstimatedPoint:currLocation withEstimatedCoordinate:estCoordinate];
        if(!MKMapRectIsNull(updateRect))
        {
            MKZoomScale currentZoomScale = (CGFloat)(map.bounds.size.width /map.visibleMapRect.size.width);
            CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
            updateRect = MKMapRectInset(updateRect, -lineWidth, -lineWidth);
            [routeView setNeedsDisplayInMapRect: updateRect];
        }
    }
}

- (void) setName: (NSString *)name {
    routeName = name;
}

- (void) setStart: (CLLocation *) start {
    currLocation = start;
}

- (IBAction)dropPin:(id)sender {
    UIAlertView *alertView  = [[UIAlertView alloc] initWithTitle:@"New Annotation" message:@"Title" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeSentences;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{ 
    NSDate* today = [NSDate date];
    RouteAnnotation* annotation = [[RouteAnnotation alloc] initWithCoordinateAndTime: currLocation.coordinate :today];
    annotation.title = [[alertView textFieldAtIndex:0] text];
    [currRoute addAnnotation:annotation];
    [map addAnnotation:annotation];
}

-(void) viewDidLoad {
    [super viewDidLoad];
    map.delegate = self;
    //viewedInMap = NO;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    //numPoints = 0;
    
    //timerCounter = 0;
    if (currRoute) {
        [map addOverlay:currRoute];
    }
}

-(void) viewDidAppear:(BOOL)animated {
    map.showsUserLocation = track;
    if (track) {
        addPinButton.enabled = YES;
        if (routeName)
            self.navigationItem.title = routeName;
        else {
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder reverseGeocodeLocation: currLocation completionHandler: 
             ^(NSArray *placemarks, NSError *error) {
                 CLPlacemark *placemark = [placemarks objectAtIndex:0];
                 CFGregorianDate currentDate = CFAbsoluteTimeGetGregorianDate(CFAbsoluteTimeGetCurrent(), CFTimeZoneCopySystem());
                 mapTitle.title = [NSString stringWithFormat:@"%@ %d/%d/%d", placemark.locality, currentDate.month, currentDate.day, currentDate.year];
             }];            
        }
        if (currRoute && currRoute.annotations) {
            [map addAnnotations:currRoute.annotations];
        }
        if (!viewedInMap) {
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(currLocation.coordinate, 2000, 2000);
            [map setRegion:region animated:YES];
            viewedInMap = YES;
        }
    } else {
        addPinButton.enabled = NO;
    }
}

-(void) setMapView:(MKMapView *)mapView
{
    map = mapView;
}

-(void) updateUserLocation {
    
}

- (void)viewDidUnload {
    [self setMapTitle:nil];
    [self setAddPinButton:nil];
    [super viewDidUnload];
}

- (void) locationManager:(CLLocationManager *) manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{   
    numPoints++;
    ignoreAgain ++;
    if(prevLocation)
    {
        timeBetween = [newLocation.timestamp timeIntervalSinceDate: prevLocation.timestamp];
        if(timeBetween > 15 && ignoreAgain > IGNORE_POINT + 2)
            ignoreAgain = 0;
        NSLog(@"timeBetween %f:", timeBetween);
    }
    if (newLocation && numPoints >= IGNORE_POINT && ignoreAgain >= IGNORE_POINT) {
        if((oldLocation.coordinate.latitude != newLocation.coordinate.latitude) && (oldLocation.coordinate.longitude != newLocation.coordinate.longitude))
        {
            if(!prevLocation){
                NSLog(@"Set previous");
                //numCrazyInARow = 0;
                prevLocation = currLocation;
            }
            else if([newLocation distanceFromLocation:prevLocation] < 100 * timeBetween)
            {
                NSLog(@"Update previous");
                //numCrazyInARow = 0;
                prevLocation = currLocation;
            }
            else 
            {
                //ignoreAgain = 0;
            }
            /*else{
                numCrazyInARow++;
            }
            //if(numCrazyInARow == 10){
                NSLog(@"I must be crazy");
                prevLocation = currLocation;
                numCrazyInARow = 0;
            }*/
             NSLog(@"Update newCurr");
            currLocation = newLocation; 
        }
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if(!routeView)
    {
        routeView = [[RouteView alloc] initWithOverlay:overlay];
    }
    return routeView;
}


- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // handle our two custom annotations
    if ([annotation isKindOfClass:[RouteAnnotation class]]) // for Golden Gate Bridge
    {
        // try to dequeue an existing pin view first
        static NSString* RouteAnnotationIdentifier = @"routeAnnotationIdentifier";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)
        [map dequeueReusableAnnotationViewWithIdentifier:RouteAnnotationIdentifier];
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            MKPinAnnotationView* customPinView = [[MKPinAnnotationView alloc]
                                                   initWithAnnotation:annotation reuseIdentifier:RouteAnnotationIdentifier];
            customPinView.pinColor = MKPinAnnotationColorRed;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;

            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    else if ([annotation isKindOfClass:[AutoAnnotation class]])
    {
        static NSString* AutoAnnotationIdentifier = @"AutoAnnotationIdentifier";
        MKAnnotationView* annotationView =
        (MKAnnotationView *)[map dequeueReusableAnnotationViewWithIdentifier:AutoAnnotationIdentifier];
        if (!annotationView)
        {
            MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                             reuseIdentifier:AutoAnnotationIdentifier];
            annotationView.canShowCallout = YES;
            UIImage *dotImage = [UIImage imageNamed:@"aqua_dot.png"];
            annotationView.image = dotImage;
            return annotationView;
        }
        else
        {
            annotationView.annotation = annotation;
        }
        return annotationView;
    } else {
        return nil;
    }
}

#pragma mark - ReviewRoutesTableViewControllerDelegate
/*
- (void)myRoutesTableViewControllerDidFinish:(MyRoutesTableViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UINavigationController *navigationController = segue.destinationViewController;
    MyRoutesTableViewController *myRoutesTableViewController = [[navigationController viewControllers] objectAtIndex:0];
    myRoutesTableViewController.delegate = self;
}
 */

- (IBAction)viewRoutes:(id)sender {
    MyRoutesTableViewController *myRoutesTableViewController = [MyRoutesTableViewController alloc];
    [[self navigationController] pushViewController:myRoutesTableViewController animated:YES];
}
@end
