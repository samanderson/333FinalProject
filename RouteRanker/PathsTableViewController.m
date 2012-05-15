//
//  PathsTableViewController.m
//  RouteRanker
//
//  Created by Mark Whelan on 4/30/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "PathsTableViewController.h"

@interface PathsTableViewController () {
    int selectedRouteIndex;
}
    
@end

@implementation PathsTableViewController

@synthesize pathID = _pathID;
@synthesize friend = _friend;
@synthesize routes = _routes;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set the title of the table
    self.navigationItem.title = self.friend.name;
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStylePlain target: self action: @selector(share)];
    self.navigationItem.rightBarButtonItem = shareButton;

}

- (void) share {
    if (selectedRouteIndex < 0) 
        return;
    if (selectedRouteIndex >= [self.routes count])
        return; 
    
    clientRest *client = [[clientRest alloc] init];
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    NSString *myId = [prefs stringForKey:@"myID"];
    NSString *myName = [prefs stringForKey:@"myName"];
    NSLog(@"%@  %@", myId, myName);
    RouteData* data = [self.routes objectAtIndex:selectedRouteIndex];
    int IDNumber = [data.idNo intValue];
    [client sharePath:IDNumber fromUser:myId name:myName withFriend:self.friend.ID];
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void) viewWillAppear:(BOOL)animated {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString * myName = [prefs stringForKey:@"myName"];
    
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RouteData"
                                              inManagedObjectContext:context];
    NSError *error;
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    self.routes = [[NSArray alloc] initWithArray:fetchedObjects];
    self.routes = [self.routes sortedArrayUsingSelector:@selector(routeCompare:)];
    NSMutableArray *displayRoutes = [[NSMutableArray alloc] initWithCapacity:1];
    for (RouteData *route in self.routes) {
        if ([route.ownerName isEqualToString:myName]) 
            [displayRoutes addObject:route];
    }
    self.routes = [NSArray arrayWithArray:displayRoutes];
    selectedRouteIndex = -1;
    [self.tableView reloadData];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.routes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"PathName"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"PathName"];
    }
    RouteData *route = [self.routes objectAtIndex:indexPath.row];
    cell.textLabel.text = route.title;
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM dd, yyyy h:mm a"];
    NSString *dateString = [format stringFromDate:[route getStartTimeDate]];
    cell.detailTextLabel.text = dateString;
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f km", [route.distance doubleValue]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (selectedRouteIndex != -1) {
        UITableViewCell *otherCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRouteIndex inSection:0]];
        otherCell.accessoryType = UITableViewCellAccessoryNone;
    }
    if (indexPath.row == selectedRouteIndex)
        selectedRouteIndex = -1;
    else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        selectedRouteIndex = indexPath.row;
    }
}


@end
