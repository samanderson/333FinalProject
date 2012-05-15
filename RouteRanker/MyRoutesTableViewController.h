//
//  MyRoutesTableViewController.h
//  RouteRanker
//
//  Created by Nick Gilligan on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapPointData.h"
#import "RouteData+Helper.h"
#import "PrevRouteViewController.h"

@class MyRoutesTableViewController;

@protocol MyRoutesTableViewControllerDelegate <NSObject>
- (void)myRoutesTableViewControllerDidFinish:(MyRoutesTableViewController *)controller;
@end


@interface MyRoutesTableViewController : UITableViewController

@property (nonatomic, weak) id <MyRoutesTableViewControllerDelegate> delegate;
- (IBAction)done:(id)sender;

@end
