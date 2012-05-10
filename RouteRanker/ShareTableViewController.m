//
//  ShareTableViewController.m
//  RouteRanker
//
//  Created by Mark Whelan on 4/28/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "ShareTableViewController.h"



@interface ShareTableViewController ()
{
}

@end

@implementation ShareTableViewController

@synthesize tableData = _tableData;
@synthesize facebook;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

-(NSArray *)partitionObjects:(NSArray *)array collationStringSelector:(SEL)selector

{
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    NSInteger sectionCount = [[collation sectionTitles] count]; //section count is take from sectionTitles and not sectionIndexTitles
    NSMutableArray *unsortedSections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    //create an array to hold the data for each section
    for(int i = 0; i < sectionCount; i++)
    {
        [unsortedSections addObject:[NSMutableArray array]];
    }
    //put each object into a section
    NSArray* titles = [[UILocalizedIndexedCollation currentCollation] sectionTitles];
    
    NSInteger index = 0;
    //NSLog([array objectAtIndex:0]);
    for (FacebookFriend *friend in array)
    {
        NSString* firstLetter = [friend.name substringToIndex:1];
        NSString* titleHeader = [titles objectAtIndex:index];
        if ([firstLetter isEqualToString:titleHeader] || index == sectionCount) {
            [[unsortedSections objectAtIndex:index] addObject:friend];
        } else {
            while (![firstLetter isEqualToString:titleHeader] && index != (sectionCount - 1)) {
                index++;
                titleHeader = [titles objectAtIndex:index];
            }
            [[unsortedSections objectAtIndex:index] addObject:friend];
        }
    }
    return unsortedSections;
}




- (void)viewDidLoad
{ 
    
    [super viewDidLoad];

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (![prefs arrayForKey:@"friends"]) {
        facebook = [[Facebook alloc] initWithAppId:@"266592116761408" andDelegate:self];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"FBAccessTokenKey"] 
            && [defaults objectForKey:@"FBExpirationDateKey"]) {
            facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
            facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
            [facebook requestWithGraphPath:@"me/friends" andDelegate:self];
        }
        if (![facebook isSessionValid]) {
            [facebook authorize:nil];
        }
    } else {
        NSArray *friendsArray = [prefs arrayForKey:@"friends"];
        NSMutableArray *friendsTemp = [[NSMutableArray alloc] init];
        for (int i = 0; i < [friendsArray count]; i++) {
            NSDictionary *friend = [friendsArray objectAtIndex:i];
            FacebookFriend *f = [[FacebookFriend alloc] initWithName:[friend objectForKey:@"name"] andID:[friend objectForKey:@"id"]];
            [friendsTemp addObject:f];
        }
        NSMutableArray *friends = [[NSMutableArray alloc] init];
        friends = (NSMutableArray*)[friendsTemp sortedArrayUsingSelector:@selector(compare:)];

        self.tableData = [[NSMutableArray alloc] init];    
        self.tableData = [self partitionObjects:friends collationStringSelector:@selector(name)];
    }
    //Set the title
    self.navigationItem.title = @"Friends";
}



- (void)request:(FBRequest *)request didLoad:(id)result {
    NSLog(@"Something sent back!");
    if ([request.url isEqualToString:@"https://graph.facebook.com/me/friends"]) {    
        NSArray *friendsArray = [(NSDictionary*)result objectForKey:@"data"];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:friendsArray forKey:@"friends"];
        NSMutableArray *friendsTemp = [[NSMutableArray alloc] init];
        for (int i = 0; i < [friendsArray count]; i++) {
            NSDictionary *friend = [friendsArray objectAtIndex:i];
            FacebookFriend *f = [[FacebookFriend alloc] initWithName:[friend objectForKey:@"name"] andID:[friend objectForKey:@"id"]];
            [friendsTemp addObject:f];
        }
        NSMutableArray *friends = [[NSMutableArray alloc] init];
        friends = (NSMutableArray*)[friendsTemp sortedArrayUsingSelector:@selector(compare:)];
        
        self.tableData = [[NSMutableArray alloc] init];    
        self.tableData = [self partitionObjects:friends collationStringSelector:@selector(name)];
        [self.tableView reloadData];
    }
}

- (void)requestLoading:(FBRequest *)request {
    NSLog(@"Loading...");
}

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    
}

- (void)fbDidLogout {
    
}

- (void)fbSessionInvalidated {
    
}

- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt {
    
}

- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data {
    
}



- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Uh oh, request failure.");
}

// For iOS 4.2+ support
//Add the application:handleOpenURL: and application:openURL: methods with a call to the facebook instance:
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [facebook handleOpenURL:url];
}

//save the user's credentials specifically the access token and corresponding expiration date
- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    [facebook requestWithGraphPath:@"me/friends" andDelegate:self];
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
    //we use sectionTitles and not sections
    return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.tableData objectAtIndex:section] count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //BOOL showSection = [[self.tableData objectAtIndex:section] count] != 0;
    //only show the section title if there are rows in the section
    //return (showSection) ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
    return [[[UILocalizedIndexedCollation currentCollation] sectionIndexTitles] objectAtIndex:section];
    
}

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 26;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.nameOfFriends count];
}
*/

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"FriendName"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FriendName"];
    }
    
    FacebookFriend* friend = [[self.tableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
        
   
    //NSString* friend = [self.nameOfFriends objectAtIndex:indexPath.row];
    cell.textLabel.text = friend.name;

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
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    PathsTableViewController *shareController = [[PathsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    shareController.friend = [[self.tableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    [[self navigationController] pushViewController:shareController animated:YES];

}

@end
