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
@synthesize startLocationTextField;
@synthesize endLocationTextField;
@synthesize routeData;
@synthesize delegate, tapRecognizer;

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
    self.nameTextField.text = routeData.title;
    self.startLocationTextField.text = routeData.startLocation;
    self.endLocationTextField.text = routeData.endLocation;
    self.nameTextField.delegate = self;
    self.startLocationTextField.delegate = self;
    self.endLocationTextField.delegate = self;
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    tapRecognizer.enabled = NO;
    [self.view addGestureRecognizer:tapRecognizer];
}

- (void)viewDidUnload
{
    [self setNameTextField:nil];
    [self setStartLocationTextField:nil];
    [self setEndLocationTextField:nil];
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
	if (indexPath.section == 0)
		[self.nameTextField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    tapRecognizer.enabled = NO;
	[textField resignFirstResponder];
	return YES;
}

- (void)singleTap:(id)sender
{
	[nameTextField resignFirstResponder];
    [startLocationTextField resignFirstResponder];
    [endLocationTextField resignFirstResponder];
    tapRecognizer.enabled = NO;
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
        editAlertView  = [[UIAlertView alloc] initWithTitle:@"Route Name cannot be empty" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        editAlertView.alertViewStyle = UIAlertViewStyleDefault;
        [editAlertView show];
        nameTextField.text = self.routeData.title;
    }
    else{
        self.routeData.title = nameTextField.text;
        self.routeData.startLocation = startLocationTextField.text;
        self.routeData.endLocation = endLocationTextField.text;
    
        NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    
        [self.delegate editRouteViewControllerDidSave:self withData:self.routeData];
    }
}



@end
