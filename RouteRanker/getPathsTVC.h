//
//  getPathsTVC.h
//  RouteRanker
//
//  Created by Mark Whelan on 5/11/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "clientRest.h"


@interface getPathsTVC : UITableViewController {
    NSMutableArray* tableData;
}

@property (strong, nonatomic) NSMutableArray* tableData;

@end
