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
    NSMutableArray * finalTitles;
    UIActivityIndicatorView *av;
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
    return finalTitles;
}

-(NSArray *)partitionObjects:(NSArray *)array collationStringSelector:(SEL)selector

{
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    NSInteger sectionCount = [[collation sectionTitles] count]; //section count is take from sectionTitles and not sectionIndexTitles
    NSMutableArray *unsortedSections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    finalTitles = [[[UILocalizedIndexedCollation currentCollation] sectionIndexTitles] mutableCopy];
    
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
    for(int i = sectionCount -1; i >= 0; i--)
    {
        if([[unsortedSections objectAtIndex:i ] count] == 0)
        {
            [unsortedSections removeObjectAtIndex:i];
            [finalTitles removeObjectAtIndex:i];
        }
    }
    return unsortedSections;
}




- (void)viewDidLoad
{ 
    
    [super viewDidLoad];
    finalTitles = [[NSMutableArray alloc] init];
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
    
    UIBarButtonItem *getPathsButton = [[UIBarButtonItem alloc] initWithTitle:@"Get Paths" style:UIBarButtonItemStylePlain target: self action: @selector(getPaths)];
    self.navigationItem.rightBarButtonItem = getPathsButton;
    
    av = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [av setCenter:self.tableView.center];
    av.tag  = 1;
    av.opaque = TRUE;
    //av.hidden = TRUE;
    //av.hidesWhenStopped = TRUE;
    //[av startAnimating];
    [self.tableView addSubview:av];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[av stopAnimating];
}

-(void)getPaths {
    //av.hidden = FALSE;
    getPathsTVC *getPaths = [getPathsTVC alloc];
    [[self navigationController] pushViewController:getPaths animated:YES];
    
}

- (void)request:(FBRequest *)request didLoad:(id)result {
    if ([request.url isEqualToString:@"https://graph.facebook.com/me/friends"]) {   
        NSLog(@"loading friends");
        NSArray *friendsArray = [(NSDictionary*)result objectForKey:@"data"];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        NSMutableArray *validFriends = [[NSMutableArray alloc] init];
        NSMutableString *pingString = [[NSMutableString alloc] init];
        for (NSDictionary *dict in friendsArray) {
            [pingString appendString:[dict objectForKey:@"id"]];
            [pingString appendString:@","];
        }
        clientRest *client = [[clientRest alloc] init];
        NSString *valid = [client checkUser:pingString];
        for (int i = 0; i < valid.length; i++) {
            if ([valid characterAtIndex:i] == '1') {
                [validFriends addObject:[friendsArray objectAtIndex:i]];
            }
        }
        [prefs setObject:validFriends forKey:@"friends"];
        NSMutableArray *friendsTemp = [[NSMutableArray alloc] init];
        for (int i = 0; i < [validFriends count]; i++) {
            NSDictionary *friend = [validFriends objectAtIndex:i];
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
    //  return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
    NSLog(@"%d", [self.tableData count]);
    return [self.tableData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.tableData objectAtIndex:section] count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //return [[[UILocalizedIndexedCollation currentCollation] sectionIndexTitles] objectAtIndex:section];
    return [finalTitles objectAtIndex:section];
}

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
    
    cell.textLabel.text = friend.name;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    PathsTableViewController *shareController = [[PathsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    shareController.friend = [[self.tableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    [[self navigationController] pushViewController:shareController animated:YES];
    
}

@end
