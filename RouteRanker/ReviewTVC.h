//
//  ReviewTVC.h
//  RouteRanker
//
//  Created by Mark Whelan on 5/1/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewGroupTVC.h"
#import "CompareVC.h"
#import "Group.h"
#import "Route.h"
#import "EditGroupTVC.h"
#import "SingleRouteStatsVC.h"
#import <MapKit/MapKit.h>

@class ReviewTVC;

@interface ReviewTVC : UITableViewController {
    NSString* groupName;
}

@property (nonatomic, strong) NSMutableArray* groupList;   //list of all routes on the phone
@property (nonatomic, strong) NSString* groupName;    //nam of group typed by user when they click the first cell

@end
