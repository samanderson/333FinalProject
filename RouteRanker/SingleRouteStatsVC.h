//
//  SingleRouteStatsVC.h
//  RouteRanker
//
//  Created by Mark Whelan on 5/9/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"

@interface SingleRouteStatsVC : UIViewController {
    Group* firstGroup; 
    IBOutlet UIScrollView* scrollView;
}

@property (nonatomic, strong) Group* firstGroup;
@property (nonatomic, strong) IBOutlet UIScrollView* scrollView; 
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsButton;

@end

