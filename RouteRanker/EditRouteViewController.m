//
//  EditRouteViewController.m
//  RouteRanker
//
//  Created by Nick Gilligan on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EditRouteViewController.h"
#import "AppDelegate.h"
#import "RouteData.h"

@interface EditRouteViewController ()
{
    UIAlertView *editAlertView;
}

@end

@implementation EditRouteViewController

@synthesize nameTextField;
@synthesize startLocationTextLabel;
@synthesize endLocationTextLabel;
@synthesize routeData;
@synthesize delegate, tapRecognizer;

- (IBAction)scroll:(id)sender {
    NSLog(@"called");
    NSUInteger *path = malloc(sizeof(NSUInteger)*2); path[0] = 2; path[1] = 0;
     [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathWithIndexes:path length:2] atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
    self.nameTextField.delegate = self;
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    tapRecognizer.enabled = NO;
    [self.view addGestureRecognizer:tapRecognizer];
}

- (void)viewDidUnload
{
    [self setNameTextField:nil];
    [self setStartLocationTextLabel:nil];
    [self setEndLocationTextLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did select called");
	if (indexPath.section == 0)
		[self.nameTextField becomeFirstResponder];
    
   // [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    tapRecognizer.enabled = NO;
	[textField resignFirstResponder];
	return YES;
}

- (void)singleTap:(id)sender
{
	[nameTextField resignFirstResponder];
    tapRecognizer.enabled = NO;
}

- (void) viewWillAppear:(BOOL)animated {
    self.navigationItem.title = self.routeData.title;
    self.nameTextField.text = routeData.title;
    NSLog(@"%@",routeData.startLocation);
    NSLog(@"%@",routeData.endLocation);
    self.startLocationTextLabel.text = routeData.startLocation;
    self.endLocationTextLabel.text = routeData.endLocation;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    tapRecognizer.enabled = YES;
    return YES;
}

- (BOOL)textFieldShouldFinishEditing:(UITextField *)textField { 
	return YES;
}

- (IBAction)save:(id)sender {
    if(nameTextField.text.length == 0){
        editAlertView  = [[UIAlertView alloc] initWithTitle:@"Route name cannot be empty" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        editAlertView.alertViewStyle = UIAlertViewStyleDefault;
        [editAlertView show];
        nameTextField.text = self.routeData.title;
    }
    else{
        self.routeData.title = nameTextField.text;
       // self.routeData.startLocation = startLocationTextField.text;
        //self.routeData.endLocation = endLocationTextField.text;
    
        NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        [[self navigationController] popViewControllerAnimated:YES];
        //[self.delegate editRouteViewControllerDidSave:self withData:self.routeData];
    }
}



@end
