//
//  CompareVC.h
//  RouteRanker
//
//  Created by Mark Whelan on 5/1/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Route.h"
#import "Group.h"

@interface CompareVC : UIViewController {
    Group* firstGroup;
    Group* secondGroup;
    IBOutlet UIScrollView* scrollView;
}
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsButton;

@property (nonatomic, strong) IBOutlet UIScrollView* scrollView; 
@property (nonatomic, strong) Group* firstGroup;
@property (nonatomic, strong) Group* secondGroup;

@end
