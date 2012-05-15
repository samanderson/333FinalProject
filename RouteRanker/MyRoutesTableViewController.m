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
{
    NSMutableArray *tableData;
    NSMutableArray *myRoutes;
    NSMutableArray *theirRoutes;
    NSString *myName;
    BOOL editingMode;
}

@end

@implementation MyRoutesTableViewController

@synthesize delegate;

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
        //update CoreData
        NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        if (indexPath.section == 0) {
            [context deleteObject:[myRoutes objectAtIndex:indexPath.row]];
            [myRoutes removeObjectAtIndex:indexPath.row];
        }
        else {
            [context deleteObject:[theirRoutes objectAtIndex:indexPath.row]];
            [theirRoutes removeObjectAtIndex:indexPath.row];
        }
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        //update table
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
	}   
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) 
        return @"My Routes";    
    else 
        return @"My Friends' Routes";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [tableData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[tableData objectAtIndex:section] count];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if ([title isEqualToString:@"My Routes"])
        return 0;
    return 1;
}

- (void)viewWillAppear:(BOOL)animated
{    
    myRoutes = [[NSMutableArray alloc] init];
    theirRoutes = [[NSMutableArray alloc] init];
    tableData = [[NSMutableArray alloc] init];

    
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RouteData" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedRoutes = [context executeFetchRequest:fetchRequest error:&error];
    for (RouteData *route in fetchedRoutes) {
        if ([route.ownerName isEqualToString:myName]) {
            [myRoutes addObject:route];
        } else {
            [theirRoutes addObject:route];
        }
    }
    [myRoutes sortUsingSelector:@selector(routeCompare:)];
    [tableData addObject:myRoutes];
    [tableData addObject:theirRoutes];
    editingMode = NO;
    [self.tableView reloadData];
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
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    myName = [prefs stringForKey:@"myName"];
    
  
    self.navigationItem.title = @"Routes";
    self.navigationItem.leftBarButtonItem.title = @"Map";
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target: self action: @selector(edit)];
    self.navigationItem.rightBarButtonItem = editButton;
}

- (void) edit {
    editingMode = !editingMode;
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



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"RouteCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"RouteCell"];
    }
    RouteData *routeData = [[tableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = routeData.title;
    
    if ([routeData.ownerName isEqualToString:myName]) {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"MMM dd, yyyy h:mm a"];
        NSString *dateString = [format stringFromDate:[routeData getStartTimeDate]];
        cell.detailTextLabel.text = dateString;
    } else {
        cell.detailTextLabel.text = routeData.ownerName;
    }
    //cell.editing = TRUE;
    //cell.editingStyle = UITableViewCellEditingStyleDelete;
    
    if (editingMode) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}


 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
     return YES;
 }

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}


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
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (!editingMode) {
        PrevRouteViewController *routeVC = [[PrevRouteViewController alloc] init];
        MKMapView *map = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
        routeVC.map  = map;
        routeVC.routeData = [[tableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        [[self navigationController] pushViewController:routeVC animated:YES];        
    } else {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                                 bundle: [NSBundle mainBundle]];
        EditRouteViewController *editVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"edit"];
        editVC.routeData = [[tableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        [[self navigationController] pushViewController:editVC animated:YES];    
        //[[self navigationController] performSegueWithIdentifier:@"toEdit" sender:self.navigationController];
    }
}

/*
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"SeePreviousRoute"]) {
        PrevRouteViewController *prevRouteViewController = segue.destinationViewController;
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        prevRouteViewController.routeData = [[tableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
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
    
    NSArray *fetchedRoutes = [context executeFetchRequest:fetchRequest error:&error];
    for (RouteData *route in fetchedRoutes) {
        if ([route.ownerName isEqualToString:myName]) {
            [myRoutes addObject:route];
        } else {
            [theirRoutes addObject:route];
        }
    }
    [self.tableView reloadData];
}*/

@end
