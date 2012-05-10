//
//  MyRoutesTableViewController.m
//  RouteRanker
//
//  Created by Nick Gilligan on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyRoutesTableViewController.h"
#import "AppDelegate.h"
#import "Route.h"
#import "PrevRouteViewController.h"

@interface MyRoutesTableViewController ()

@end

@implementation MyRoutesTableViewController

@synthesize delegate;
@synthesize routes;

// fetch NSArray of RouteData
- (void)loadTable
{
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RouteData" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    self.routes = [context executeFetchRequest:fetchRequest error:&error];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
        //update CoreData
        NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        [context deleteObject:[self.routes objectAtIndex:indexPath.row]];
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        [self loadTable];
        
        //update table
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // color the top navigation bar black
    //self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    [self loadTable];
}

- (IBAction)done:(id)sender
{
    [self.delegate myRoutesTableViewControllerDidFinish:self];
}

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return [self.routes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"RouteCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"RouteCell"];
    }
    RouteData *routeData = [self.routes objectAtIndex:indexPath.row];
    cell.textLabel.text = routeData.title;
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM dd, yyyy h:mm a"];
    NSString *dateString = [format stringFromDate:[routeData getStartTimeDate]];
    cell.detailTextLabel.text = dateString;
    
    
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"SeePreviousRoute"]) {
        PrevRouteViewController *prevRouteViewController = segue.destinationViewController;
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        prevRouteViewController.routeData = [routes objectAtIndex:indexPath.row];
        prevRouteViewController.delegate = self;
        //[prevRouteViewController displayRoute];
    }
}

- (void)myRoutesHasBeenEdited:(PrevRouteViewController *)controller
{
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RouteData" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    self.routes = [context executeFetchRequest:fetchRequest error:&error];
    [self.tableView reloadData];
}

@end
