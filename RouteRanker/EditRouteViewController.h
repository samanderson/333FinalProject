//
//  EditRouteViewController.h
//  RouteRanker
//
//  Created by Nick Gilligan on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RouteData+Helper.h"

@class EditRouteViewController;

@protocol EditRouteViewControllerDelegate <NSObject>
- (void)editRouteViewControllerDidSave:(EditRouteViewController *)controller withData:(RouteData *)editedRoute;
@end

@interface EditRouteViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *startLocationTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *endLocationTextLabel;
@property (strong, nonatomic) RouteData *routeData;
@property UIGestureRecognizer *tapRecognizer;
@property (nonatomic) id <EditRouteViewControllerDelegate> delegate;

- (IBAction)save:(id)sender;

@end
