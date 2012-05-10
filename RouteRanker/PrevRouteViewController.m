//
//  PrevRouteViewController.m
//  RouteRanker
//
//  Created by Nick Gilligan on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PrevRouteViewController.h"
#import "EditRouteViewController.h"
#import "RouteData.h"
#import "MapPointData.h"
#import "Route.h"
#import "AutoAnnotation.h"

@interface PrevRouteViewController ()

@end

@implementation PrevRouteViewController

@synthesize map;
@synthesize routeData;
@synthesize navigationBar;
@synthesize delegate;
@synthesize routeView;
@synthesize route;


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if(!self.routeView)
    {
        self.routeView = [[RouteView alloc] initWithOverlay:overlay];
    }
    return self.routeView;
}

- (void)displayRoute
{
    self.navigationBar.title = self.routeData.title;
    
    self.route = [Route routeFromRouteData:routeData];
    
    [map setVisibleMapRect:[self.route boundingMapRect]];
    [map addOverlay:self.route];
    
    for (id<MKAnnotation> annotation in self.route.annotations) {
        [map addAnnotation:annotation];
    }
    
    MKZoomScale currentZoomScale = (CGFloat)(map.bounds.size.width /map.visibleMapRect.size.width);
    CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
    self.route.boundingMapRect = MKMapRectInset(self.route.boundingMapRect, -lineWidth, -lineWidth);
    
    [routeView setNeedsDisplayInMapRect:self.route.boundingMapRect];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self displayRoute];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    map.delegate = self;
    //[self displayRoute];
    
    if (route) {
        //[map addOverlay:route];
    }
}

- (void)viewDidUnload
{
    //[self setMap:nil];
    //[self setNavigationBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"EditCell"]) {
        EditRouteViewController *editRouteViewController = segue.destinationViewController;
        editRouteViewController.routeData = self.routeData;
        editRouteViewController.delegate = self;
    }
}

- (void)editRouteViewControllerDidSave:(EditRouteViewController *)controller withData:(RouteData *)editedRoute
{
    self.routeData = editedRoute;
    self.navigationBar.title = self.routeData.title;
    [self.delegate myRoutesHasBeenEdited:self];
}

// copied and pasted from MapViewController.m
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

@end
