//
//  NewGroupTVC.m
//  RouteRanker
//
//  Created by Mark Whelan on 5/1/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "NewGroupTVC.h"


@interface NewGroupTVC ()
{
    NSMutableArray* includeRoute; //boolean list to include route or not
    UIAlertView* notEnoughSelected; //alert that goes off if no paths are selected at time of saving
}

@end

@implementation NewGroupTVC

@synthesize groupName = _groupName;
@synthesize routes = _routes;
@synthesize routeList = _routeList;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RouteData"
                                              inManagedObjectContext:context];
    NSError *error;
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    self.routeList = [[NSArray alloc] initWithArray:fetchedObjects];
    self.routeList = [self.routeList sortedArrayUsingSelector:@selector(routeCompare:)];
    self.routes = [[NSMutableArray alloc] init];
    includeRoute = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.routeList count]; i++) { 
        [includeRoute addObject:@"NO"];
    }
    [self.tableView reloadData];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem* createButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone
                                                                    target:self 
                                                                    action:@selector(createGroupButtonPressed:)];
    self.navigationItem.rightBarButtonItem = createButton;
    self.navigationItem.title = self.groupName;


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
    // Return the number of rows in the section.
    return [self.routeList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"PathName"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"PathName"];
    }
    RouteData *route = [self.routeList objectAtIndex:indexPath.row];
    cell.textLabel.text = route.title;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString * myName = [prefs stringForKey:@"myName"];
    
    if ([route.ownerName isEqualToString:myName]) {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"MMM dd, yyyy h:mm a"];
        NSString *dateString = [format stringFromDate:[route getStartTimeDate]];
        cell.detailTextLabel.text = dateString;
    }
    else
    {
        cell.detailTextLabel.text = route.ownerName;
    }
    
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{ 
    if (alertView == notEnoughSelected) { 
        return;
    }
}

#pragma mark - Table view delegate
- (void)createGroupButtonPressed:(id)sender {
    for (int i = 0; i < [includeRoute count]; i++) { 
        NSString* include = [includeRoute objectAtIndex:i];
        if ([include isEqualToString:@"YES"]) {
             //NSString* nameOfPath = [self.listOfPaths objectAtIndex:i];
            [self.routes addObject:[self.routeList objectAtIndex:i]];
        }
    }
    NSInteger numPaths = [self.routes count];
    
    //throw alert if no paths selected
    if (numPaths == 0) {
        notEnoughSelected  = [[UIAlertView alloc] initWithTitle:@"Please select at least one path to add." message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        notEnoughSelected.alertViewStyle = UIAlertViewStyleDefault;
        [notEnoughSelected show];
        return; 
    } else {
        // add routes to group
        // self.groupToCreate = [[Group alloc] initWithName:self.groupName];
        NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        GroupData *groupData = [NSEntityDescription insertNewObjectForEntityForName:@"GroupData" inManagedObjectContext:context];
        groupData.name = self.groupName;
        groupData.routes = [NSSet setWithArray:self.routes];
        
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
     //[self performSegueWithIdentifier:@"goBack" sender:sender];
}

/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toReview"]) {
        [self performSegueWithIdentifier:@"toReview" sender:sender];
    }
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        [includeRoute replaceObjectAtIndex:indexPath.row withObject:@"YES"];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        // Reflect selection in data model
    } 
    
    else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [includeRoute replaceObjectAtIndex:indexPath.row withObject:@"NO"];
        // Reflect deselection in data model
    }
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
