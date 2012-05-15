//
//  AppDelegate.h
//  RouteRanker
//
//  Created by Chuck Anderson on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MapViewController.h"
#import "FBConnect.h"
#import "FBRequest.h"
#import "ReviewTVC.h"
#import "ShareTableViewController.h"
#import "FirstViewController.h"
#import "ShareTableViewController.h"
#import "FacebookFriend.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, FBSessionDelegate, FBRequestDelegate> {
    Facebook *facebook;
    NSMutableArray* friendNames;
    UIWindow *window;
    UITabBarController *tabBarController;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

@property (strong, nonatomic) NSMutableArray* friendNames;
@property (nonatomic, retain) Facebook *facebook;
@property (strong, nonatomic) UIWindow *window;


@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (void) loginToFacebook;
- (NSURL *)applicationDocumentsDirectory;

@end
