//
//  EditGroupTVC.h
//  RouteRanker
//
//  Created by Mark Whelan on 5/2/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupData.h"
#include "RouteData.h"
#include "AppDelegate.h"


@interface EditGroupTVC : UITableViewController {
    GroupData *group;
}

@property (nonatomic, strong) GroupData *group; //group clicked on by user to edit
@property (nonatomic, strong) NSArray *groupList;

@end
