//
//  ReviewTVC.m
//  RouteRanker
//
//  Created by Mark Whelan on 5/1/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "ReviewTVC.h"

@interface ReviewTVC () {
    UIAlertView * compareAlertView;
    int numSelectedGroups, selected1, selected2;
    BOOL editingMode;
}


@end

@implementation ReviewTVC
@synthesize groupName = _groupName;
@synthesize groupList = _groupList; 

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"Select Group(s)";
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GroupData"
                                              inManagedObjectContext:context];
    NSError *error;
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    self.groupList = [[NSMutableArray alloc] initWithArray:fetchedObjects];
    editingMode = FALSE;
    numSelectedGroups = 0;
    selected1 = -1;
    selected2 = -1;

    [self.tableView reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
        //Set the title
    self.navigationItem.title = @"Select Group(s)";
    numSelectedGroups = 0;
    
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
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.groupList count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MakeNewGroupCell"];
        cell.editing = NO;
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MakeNewGroupCell"];
        }
        cell.textLabel.text = @"Make New Group...";
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell"];
        if (editingMode) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        //[cell setEditing:editingMode animated:YES];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GroupCell"];
        }
        GroupData* group = [self.groupList objectAtIndex:indexPath.row - 1];
        cell.textLabel.text = group.name;
    }

    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return UITableViewCellEditingStyleNone;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row != 0;
}

- (IBAction)compareButtonPushed:(id)sender {
    if (numSelectedGroups == 1) {
        SingleRouteStatsVC *singleRoute = [[SingleRouteStatsVC alloc] init];
        int index = selected1 == -1 ? selected2 : selected1;
        singleRoute.firstGroup = [[Group alloc] initWithGroupData:[self.groupList objectAtIndex:index]];
        
        [[self navigationController] pushViewController:singleRoute animated:YES];
    } else if (numSelectedGroups == 2)  {
        // set groups to compare
        CompareVC *compare = [[CompareVC alloc] init];
        Group *firstGroup = [[Group alloc] initWithGroupData:[self.groupList objectAtIndex:selected1]];
        Group *secondGroup = [[Group alloc] initWithGroupData:[self.groupList objectAtIndex:selected2]];

        compare.firstGroup = firstGroup;
        compare.secondGroup = secondGroup;
        [[self navigationController] pushViewController:compare animated:YES];
    } else { 
        compareAlertView  = [[UIAlertView alloc] initWithTitle:@"Please select two groups to compare or one group to examine" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        compareAlertView.alertViewStyle = UIAlertViewStyleDefault;
        [compareAlertView show];
    } 
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        GroupData *g = [self.groupList objectAtIndex:(indexPath.row - 1)];
        [self.groupList removeObjectAtIndex:(indexPath.row - 1)];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationLeft];    
        NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        [context deleteObject:g];
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
}


#pragma mark - Table view delegate
- (IBAction)EditButtonPushed:(id)sender {
    
    if ((selected1 != -1 && selected2 == -1) || (selected1 == -1 && selected2 != -1)) {
        int index = selected1 == -1 ? selected2 : selected1;
        EditGroupTVC *editGroup = [[EditGroupTVC alloc] initWithStyle:UITableViewStylePlain];
        GroupData *selected = [self.groupList objectAtIndex:index];
        editGroup.group = selected;
        editGroup.groupList = self.groupList;
        [[self navigationController] pushViewController:editGroup animated:YES];
    } else {
        if(editingMode)
            self.navigationItem.title = @"Select Group(s)";
        else {
             self.navigationItem.title = @"Select Group";
        }
        editingMode = !editingMode;
        //[self.tableView setEditing:editingMode animated:YES];
        [self.tableView reloadData];
        numSelectedGroups = 0;
        selected1 = -1;
        selected2 = -1;
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{ 
    if (alertView == compareAlertView) { 
        return;
    } else {
        self.groupName = [[alertView textFieldAtIndex:0] text];
        for (GroupData* group in self.groupList) {
            if ([self.groupName isEqualToString:group.name]) {
                [self makeNewPathAlert];
                return;
            }
        }
        
        NSUInteger titleLength = [self.groupName length];
        if (titleLength == 0) {
            return;
        }
        //switch view controllers
        NewGroupTVC* newGroupController = [[NewGroupTVC alloc] initWithStyle:UITableViewStylePlain];

        //update name of new group
        newGroupController.groupName = self.groupName;
    
        [[self navigationController] pushViewController:newGroupController animated:YES];
    }
}

- (void) makeNewPathAlert {
    //create a pop up so that user can name new group
    UIAlertView *alertView  = [[UIAlertView alloc] initWithTitle:@"Name Your Group" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeWords;
    [alertView show];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [self makeNewPathAlert];
       
    } else {
        [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if (editingMode) {
            EditGroupTVC* editGroup = [[EditGroupTVC alloc] initWithStyle:UITableViewStylePlain];
            GroupData *selected = [self.groupList objectAtIndex:(indexPath.row - 1)];
            editGroup.group = selected;
            editGroup.groupList = self.groupList;
            [[self navigationController] pushViewController:editGroup animated:YES];
        } else {
            if (cell.accessoryType == UITableViewCellAccessoryNone && numSelectedGroups <= 1) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                numSelectedGroups++;
                if (selected1 == -1) {
                    selected1 = (indexPath.row - 1);
                } else {
                    selected2 = (indexPath.row - 1);
                }
                // Reflect selection in data model
            } else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
                cell.accessoryType = UITableViewCellAccessoryNone;
                numSelectedGroups--;
                if (selected1 == (indexPath.row - 1)) {
                    selected1 = -1;
                } else {
                    selected2 = -1;
                }
                // Reflect deselection in data model
            }
        }
    }
}

@end
