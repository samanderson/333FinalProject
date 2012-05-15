//
//  EditGroupTVC.m
//  RouteRanker
//
//  Created by Mark Whelan on 5/2/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "EditGroupTVC.h"

@interface EditGroupTVC () {
    NSMutableArray* pathsInGroup;
    NSMutableArray* allOtherPaths; 
    NSMutableArray* tableData;
    UITextField * activeField;
    BOOL reload; 
}

@end

@implementation EditGroupTVC

@synthesize group = _group;
@synthesize groupList = _groupList;

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) 
        return @"Paths in Group";    
    else 
        return @"All Other Paths";
}

- (void)viewWillAppear:(BOOL)animated {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RouteData"
                                              inManagedObjectContext:context];
    NSError *error;
    [fetchRequest setEntity:entity];
    NSArray *fetchedRoutes = [context executeFetchRequest:fetchRequest error:&error];    
    NSArray *groupRoutes = [self.group.routes allObjects];
        
    for (RouteData *route in fetchedRoutes) {
        if ([groupRoutes containsObject:route]) {
            [pathsInGroup addObject:route];
        } else {
            [allOtherPaths addObject:route];
        }
    }
    [pathsInGroup sortUsingSelector:@selector(routeCompare:)];
    [allOtherPaths sortUsingSelector:@selector(routeCompare:)];
    [tableData addObject:pathsInGroup];
    [tableData addObject:allOtherPaths];
    
    self.navigationItem.title = self.group.name;
    [self.tableView setEditing:YES animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *newPath;
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        RouteData *route = [pathsInGroup objectAtIndex:indexPath.row];
        [pathsInGroup removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationLeft];
        newPath = [NSIndexPath indexPathForRow:[allOtherPaths count] inSection:1];
        [allOtherPaths addObject:route];
        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:newPath, nil] withRowAnimation:UITableViewRowAnimationRight];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        RouteData *route = [allOtherPaths objectAtIndex:indexPath.row];
        [allOtherPaths removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationLeft];
        newPath = [NSIndexPath indexPathForRow:[pathsInGroup count] inSection:0];
        [pathsInGroup addObject:route];
        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:newPath, nil] withRowAnimation:UITableViewRowAnimationRight];
    }
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GroupData" inManagedObjectContext:context];
    [request setEntity:entity];
    // retrive the objects with a given value for a certain property
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"name == %@", self.group.name];
    [request setPredicate:predicate];
    NSArray *fetchedGroups = [context executeFetchRequest:request error:&error];
    GroupData *g = [fetchedGroups objectAtIndex:0];
    g.routes = [[NSSet alloc] initWithArray:pathsInGroup];
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pathsInGroup = [[NSMutableArray alloc] init];
    allOtherPaths = [[NSMutableArray alloc] init];
    tableData = [[NSMutableArray alloc] init];
    activeField = [[UITextField alloc] init];

    UIBarButtonItem *editNameButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem: UIBarButtonSystemItemCompose
                                    target: self
                                    action: @selector(editName)];
    self.navigationItem.rightBarButtonItem = editNameButton;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 }

- (void) editName {
    UIAlertView *alertView  = [[UIAlertView alloc] initWithTitle:@"Edit Group" message:@"Rename the group" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeWords;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 0) {
        BOOL uniqueName = YES;
        NSString *newName = [[alertView textFieldAtIndex:0] text];
        for (GroupData *g in self.groupList) {
            if ([g.name isEqualToString:newName]) {
                [self editName];
                uniqueName = NO;
            }
        }
        if (uniqueName && ![newName isEqualToString:self.group.name] && ![newName isEqualToString:@""]) {
            NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
            NSError *error;
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"GroupData" inManagedObjectContext:context];
            [request setEntity:entity];
            // retrive the objects with a given value for a certain property
            NSPredicate *predicate = [NSPredicate predicateWithFormat: @"name == %@", self.group.name];
            [request setPredicate:predicate];
            NSArray *fetchedGroups = [context executeFetchRequest:request error:&error];
            GroupData *g = [fetchedGroups objectAtIndex:0];
            g.name = newName;
            if (![context save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
            self.group.name = newName;
            self.navigationItem.title = newName;
        }
    }
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
    if ([title isEqualToString:@"Routes in Group"])
        return 0;
    return 1;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleInsert;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"RouteTitle"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"RouteTitle"];
    }
    //cell.showsReorderControl = YES;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString * myName = [prefs stringForKey:@"myName"];
    
    RouteData *route= [[tableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = route.title;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];        
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
