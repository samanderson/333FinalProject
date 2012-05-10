//
//  ShareTableViewController.h
//  RouteRanker
//
//  Created by Mark Whelan on 4/28/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UILocalizedIndexedCollation.h>
#include <unistd.h>
#import "PathsTableViewController.h"
#import "FBConnect.h"
#import "FBRequest.h"
#import "FacebookFriend.h"

@interface ShareTableViewController : UITableViewController <FBSessionDelegate, FBRequestDelegate>
{
    NSArray* tableData;
}

@property (nonatomic, strong) NSArray* tableData; //array of arrays holding data for table
@property (nonatomic, retain) Facebook *facebook;


@end
