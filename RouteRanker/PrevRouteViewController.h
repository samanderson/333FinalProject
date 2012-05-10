//
//  PrevRouteViewController.h
//  RouteRanker
//
//  Created by Nick Gilligan on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "RouteData+Helper.h"
#import "EditRouteViewController.h"
#import "RouteView.h"
//#import "MapViewController.h"
#import "Route.h"

@class PrevRouteViewController;

@protocol PrevRouteViewControllerDelegate <NSObject>
- (void)myRoutesHasBeenEdited:(PrevRouteViewController *)controller;
@end

@interface PrevRouteViewController : UIViewController <EditRouteViewControllerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (strong, nonatomic) RouteData *routeData;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
@property (nonatomic) id <PrevRouteViewControllerDelegate> delegate;
@property (strong, nonatomic) RouteView *routeView;
@property (strong, nonatomic) Route *route;

- (void)displayRoute;

@end
