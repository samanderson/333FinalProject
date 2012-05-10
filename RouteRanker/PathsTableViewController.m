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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) share {
    
}


- (void) viewWillAppear:(BOOL)animated {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RouteData"
                                              inManagedObjectContext:context];
    NSError *error;
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    self.routes = [[NSArray alloc] initWithArray:fetchedObjects];
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
- (void) sharePath:(NSString*)path withFriend:(NSString*) friendName
{
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
