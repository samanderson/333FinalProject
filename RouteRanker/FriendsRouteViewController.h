//
//  FriendsRouteViewController.m
//  RouteRanker
//
//  Created by Chuck Anderson on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendsRouteViewController.h"
#import <UIKit/UIKit.h>
#import "MapPointData.h"
#import "RouteData+Helper.h"
#import "PrevRouteViewController.h"

@class FriendsRouteViewController;


@protocol FriendsRouteViewControllerDelegate <NSObject>
- (void)FriendsRouteViewControllerDidFinish:(FriendsRouteViewController *)controller;
@end


@interface FriendsRouteViewController : UITableViewController 

@property (nonatomic, weak) id <FriendsRouteViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *routes;
- (IBAction)done:(id)sender;

@end
