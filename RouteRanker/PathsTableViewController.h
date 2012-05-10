//
//  PathsTableViewController.h
//  RouteRanker
//
//  Created by Mark Whelan on 4/30/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareTableViewController.h"
#import "AppDelegate.h"
#import "FacebookFriend.h"

@interface PathsTableViewController : UITableViewController
{
}

@property int pathID; //name of path to be shared, selected by user
@property (nonatomic, strong) FacebookFriend* friend; //name of friend to share with, selected from friend table
@property (nonatomic, strong) NSArray* routes; //array of routes selected by user

@end
