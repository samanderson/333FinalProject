//
//  NewGroupTVC.h
//  RouteRanker
//
//  Created by Mark Whelan on 5/1/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReviewTVC.h"
#import "Route.h"
#import "Group.h"
#import "AppDelegate.h"
#import "GroupData.h"


@interface NewGroupTVC : UITableViewController {
    NSString* groupName;
    NSMutableArray* routeList;
    NSMutableArray* routesInNewGroup;
}

@property (nonatomic, strong) NSString* groupName; //name of the newly created group
@property (nonatomic, strong) NSArray* routeList; //list of routes stored on phone
@property (nonatomic, strong) NSMutableArray* routes; //array of routes selected by user

@end
