//
//  getPathsTVC.m
//  RouteRanker
//
//  Created by Mark Whelan on 5/11/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "getPathsTVC.h"

@interface getPathsTVC () {
    NSMutableArray* pathOwner;
    int selectedRouteIndex;
}

@end

@implementation getPathsTVC

@synthesize tableData = _tableData;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewDidAppear:(BOOL)animated {
    //clientRest *client = [[clientRest alloc] init];
    //NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //NSString *ID = [prefs stringForKey: @"myID"];
    

    
    /*NSMutableArray * serverPaths = [client getSharedPaths:ID];
    if ([serverPaths count] > 0) {
        self.tableData = [[serverPaths objectAtIndex:0] mutableCopy];
        pathOwner = [[serverPaths objectAtIndex:2] mutableCopy];
        NSLog(@"%@", serverPaths);
    }
    
    tableData = serverPaths;
    
    NSLog(@"%@",[[tableData objectAtIndex:0] objectAtIndex:0]);*/

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pathOwner = [[NSMutableArray alloc] init];
    //tableData = [[NSMutableArray alloc] init];
    selectedRouteIndex = -1;
    
    self.navigationItem.title = @"Paths Shared";
    
    UIBarButtonItem *getPathsButton = [[UIBarButtonItem alloc] initWithTitle:@"Download" style:UIBarButtonItemStylePlain target: self action: @selector(download)];
    self.navigationItem.rightBarButtonItem = getPathsButton;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    clientRest *client = [[clientRest alloc] init];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *ID = [prefs stringForKey: @"myID"];
    
    
    NSMutableArray * serverPaths = [client getSharedPaths:ID];
    if ([serverPaths count] > 0) {
        self.tableData = [[serverPaths objectAtIndex:0] mutableCopy];
        pathOwner = [[serverPaths objectAtIndex:2] mutableCopy];
        NSLog(@"%@", serverPaths);
    }
    
    if([serverPaths count] > 0) 
        tableData = serverPaths;
    
    NSLog(@"%@",[[tableData objectAtIndex:0] objectAtIndex:0]);
}

-(void) download {
    if (selectedRouteIndex == -1) 
        return;
    //download the route at selectedRouteIndex
    clientRest* client = [[clientRest alloc] init];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *ID = [prefs stringForKey: @"myID"];

    UIActivityIndicatorView  *av = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [av setCenter:self.tableView.center];
    av.tag  = 1;
    [self.tableView addSubview:av];
    [av startAnimating];
    
    NSMutableArray * serverPaths = [client getSharedPaths:ID];
    NSArray *friendRoute = [serverPaths objectAtIndex: 1];
    if ([serverPaths count] > 0) {
         NSArray *pathNoFormat = [[friendRoute objectAtIndex:selectedRouteIndex] componentsSeparatedByString:@"a"];
         int pathID = [[pathNoFormat objectAtIndex:1] intValue];
         NSString* userID = [pathNoFormat objectAtIndex:0];
        NSLog(@"Path ID : %d", pathID);
        [client getPathWithId:pathID ofUser:userID from:ID];
        [client deletePath:[friendRoute objectAtIndex:selectedRouteIndex] fromUser:ID];
    }

        
    [self.navigationController popViewControllerAnimated:YES];

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
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"RouteCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"RouteCell"];
    }
    
    if (tableData) {
        cell.detailTextLabel.text = [[tableData objectAtIndex:2] objectAtIndex:indexPath.row];
        cell.textLabel.text = [[tableData objectAtIndex:0] objectAtIndex:indexPath.row];
    }
    

    
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
