//
//  CompareVC.m
//  RouteRanker
//
//  Created by Mark Whelan on 5/1/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "CompareVC.h"

@interface CompareVC () {
    int headerHeight;
    int catHeight; 
    int startHeight; 
    int lastPos;
    int lastHeight;
}


@end

@implementation CompareVC

@synthesize firstGroup = _firstGroup;
@synthesize secondGroup = _secondGroup;
@synthesize settingsButton;
@synthesize scrollView; 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSString*) convertTimeFormatfromSeconds:(double) secondsAsDouble {
    int seconds = (int) secondsAsDouble;
    NSString* toDisplay = @"";
    int minutes = seconds/60;
    seconds = seconds % 60;
    int hours = minutes/ 60;
    minutes = minutes %60;
    if (hours > 0) {
        toDisplay = [NSString stringWithFormat:@"%d", hours];
        toDisplay = [toDisplay stringByAppendingString:@":"];
    }
    NSString* strMinutes = [NSString stringWithFormat:@"%d", minutes];
    if (minutes < 10 && hours > 0) 
        strMinutes = [@"0" stringByAppendingString:strMinutes];
    NSString* strSeconds= [NSString stringWithFormat:@"%d", seconds];
    if (seconds < 10) 
        strSeconds = [@"0" stringByAppendingString:strSeconds];
    
    toDisplay = [toDisplay stringByAppendingString:strMinutes];
    toDisplay = [toDisplay stringByAppendingString:@":"];
    toDisplay = [toDisplay stringByAppendingString:strSeconds];
    return toDisplay;
    
}

-(void) drawHeaderwithText:(NSString*) toDisplay {
    UILabel* header = [[UILabel alloc] initWithFrame:CGRectMake(0, lastHeight + lastPos, 320, headerHeight)];
    header.textAlignment = UITextAlignmentCenter;
    header.font= [UIFont boldSystemFontOfSize:17];
    header.text = toDisplay;
    header.backgroundColor = [UIColor colorWithRed:0.292076 green:0.388945 blue:0.637058 alpha:1];
    header.textColor = [UIColor blackColor];
    [self.view addSubview:header];
    lastPos = lastPos + lastHeight;
    lastHeight = headerHeight;
    
}
- (IBAction)changeSetting{
    UIAlertView *alertView  = [[UIAlertView alloc] initWithTitle:@"Settings" message:@"Units" delegate:self cancelButtonTitle:@"miles" otherButtonTitles:@"km",nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{ 
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];            
    NSLog(@"%@",self.firstGroup.unit);
    if(buttonIndex == 0){
        NSLog(@"miles pressed");
        [prefs setObject:@"miles" forKey:@"units"];
        if(![self.firstGroup.unit isEqualToString:@"miles"])
        {
            NSLog(@"converting...");
            [self.firstGroup convertFromMetric];
            [self.secondGroup convertFromMetric];
            [self viewWillAppear:YES];
        }
    }
    else {
        NSLog(@"km pressed");
        [prefs setObject:@"km" forKey:@"units"];
        if(![self.firstGroup.unit isEqualToString:@"km"])
        {
            NSLog(@"converting...");
            [self.firstGroup convertToMetric];
            [self.secondGroup convertToMetric];
            [self viewWillAppear:YES];
        }
    }
    [prefs synchronize];
}

-(void) drawSeperator {
    lastPos = lastPos + lastHeight;
    lastHeight = catHeight; 
}

-(void) drawCatWithText:(NSString*) text onRight:(BOOL) onRight {
    UILabel* category; 
    if (onRight) {
        category = [[UILabel alloc] initWithFrame:CGRectMake(20, lastHeight + lastPos, 135, catHeight)];
        category.text = text;
        category.textColor = [UIColor whiteColor];
    }
    else {
        category = [[UILabel alloc] initWithFrame:CGRectMake(165, lastHeight + lastPos, 135, catHeight)];
        category.text = text;
        category.textColor = [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:1];
    }
    category.textAlignment = UITextAlignmentCenter;
    category.backgroundColor = [UIColor colorWithRed:0.292076 green:0.388945 blue:0.637058 alpha:1];
    [self.view addSubview:category];
}

- (void) viewWillAppear:(BOOL)animated {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if(![prefs stringForKey:@"units"])
    {
        [prefs setObject:@"km" forKey:@"units"];
    }
    NSString *units = [prefs stringForKey:@"units"];
    NSString *groupUnit = self.firstGroup.unit;
    if(![groupUnit isEqualToString:units])
    {
        if([groupUnit isEqualToString:@"km"]){
            [self.secondGroup convertFromMetric];
            [self.firstGroup convertFromMetric];
        }
        else {
            [self.secondGroup convertToMetric];
            [self.firstGroup convertToMetric];
        }
    }
    
    //set first title
    UILabel* firstTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, startHeight, 160, headerHeight)];
    firstTitle.text = self.firstGroup.groupName;
    firstTitle.backgroundColor = [UIColor clearColor];
    firstTitle.textColor = [UIColor whiteColor];
    //firstTitle.adjustsFontSizeToFitWidth = YES;
    firstTitle.font = [UIFont boldSystemFontOfSize:20];
    firstTitle.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:firstTitle];
    
    //set second title
    UILabel* secondTitle = [[UILabel alloc] initWithFrame:CGRectMake(160, startHeight, 160, headerHeight)];
    secondTitle.text = self.secondGroup.groupName;
    secondTitle.textColor = [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:1];
    secondTitle.backgroundColor = [UIColor clearColor];
    //secondTitle.adjustsFontSizeToFitWidth = YES;
    //secondTitle.minimumFontSize = [UIFont boldSystemFontOfSize:10];
    secondTitle.font= [UIFont boldSystemFontOfSize:20];
    secondTitle.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:secondTitle];
    
    
    lastPos = startHeight;
    lastHeight = headerHeight;
    
    
    //set numOfPaths Header
    [self drawHeaderwithText:@"Number of Paths"];
    
    //set firstNumOfPaths
    int numPaths = self.firstGroup.numRoutes;
    NSString *toDisplay = [NSString stringWithFormat:@"%d", numPaths];
    [self drawCatWithText:toDisplay onRight:YES];
    
    //set secondNumOfPaths
    numPaths = self.secondGroup.numRoutes;
    toDisplay = [NSString stringWithFormat:@"%d", numPaths];
    [self drawCatWithText:toDisplay onRight:NO];
    
    //draw seperator
    [self drawSeperator];
    
    //set average distance header
    [self drawHeaderwithText:@"Average Route Distance"];
    
    //set firstAvgDist
    double dist = self.firstGroup.avgDist;
    toDisplay = [NSString stringWithFormat:@"%.2lf %@", dist, units];
    [self drawCatWithText:toDisplay onRight:YES];
    
    //set secondAvgDist
    dist = self.secondGroup.avgDist;
    toDisplay = [NSString stringWithFormat:@"%.2lf %@", dist, units];
    [self drawCatWithText:toDisplay onRight:NO];
    
    [self drawSeperator];
    
    //set average speed header
    [self drawHeaderwithText:@"Average Route Speed"];
    
    //set firstAvgSpeed
    double avgSpeed = self.firstGroup.avgSpeed;
    toDisplay = [NSString stringWithFormat:@"%.2lf %@/hr", avgSpeed, units];
    [self drawCatWithText:toDisplay onRight:YES];
    
    //set secondAvgSpeed
    avgSpeed = self.secondGroup.avgSpeed; 
    toDisplay = [NSString stringWithFormat:@"%.2lf %@/hr", avgSpeed, units];
    [self drawCatWithText:toDisplay onRight:NO];
    
    [self drawSeperator];
    
    //set total time header
    [self drawHeaderwithText:@"Total Time"];
    
    
    //set firstTotalTime
    toDisplay = [self convertTimeFormatfromSeconds:self.firstGroup.totalTime];
    [self drawCatWithText:toDisplay onRight:YES];
    
    //set secondTotalTime
    toDisplay = [self convertTimeFormatfromSeconds:self.secondGroup.totalTime];
    [self drawCatWithText:toDisplay onRight:NO];
    
    
    [self drawSeperator];
    
    //set AverageTime Header
    [self drawHeaderwithText:@"Average Route Time"];
    
    //set firstAvgTime
    toDisplay = [self convertTimeFormatfromSeconds:self.firstGroup.avgTime];
    [self drawCatWithText:toDisplay onRight:YES];
    
    //set secondAvgTime
    toDisplay = [self convertTimeFormatfromSeconds:self.secondGroup.avgTime];
    [self drawCatWithText:toDisplay onRight:NO];
    
    [self drawSeperator]; 
    
    //set longestTime header
    [self drawHeaderwithText:@"Longest Time"];
    
    //set firstLongestTime
    toDisplay = [self convertTimeFormatfromSeconds:self.firstGroup.longestTime];
    [self drawCatWithText:toDisplay onRight:YES];
    
    //set secondLongestTime
    toDisplay = [self convertTimeFormatfromSeconds:self.secondGroup.longestTime];
    [self drawCatWithText:toDisplay onRight:NO];
    
    [self drawSeperator]; 
    
    //set longestDistHeader
    [self drawHeaderwithText:@"Longest Route Distance"];
    
    //set firstLongestDist
    dist = self.firstGroup.longestDist;
    toDisplay = [NSString stringWithFormat:@"%.2lf %@", dist, units];
    //toDisplay = [toDisplay stringByAppendingString:@" miles"];
    [self drawCatWithText:toDisplay onRight:YES];
    
    //set secondLongestDist
    dist= self.secondGroup.longestDist;
    toDisplay = [NSString stringWithFormat:@"%.2lf %@", dist, units];
    //toDisplay = [toDisplay stringByAppendingString:@" miles"];
    [self drawCatWithText:toDisplay onRight:NO];
    
    [self drawSeperator]; 
    
    //set shortestTime header
    [self drawHeaderwithText:@"Shortest Time"];
    
    //set firstShortestTime
    toDisplay = [self convertTimeFormatfromSeconds:self.firstGroup.shortestTime];
    [self drawCatWithText:toDisplay onRight:YES];
    
    //set secondShortestTime
    toDisplay = [self convertTimeFormatfromSeconds:self.secondGroup.shortestTime];
    [self drawCatWithText:toDisplay onRight:NO];
    
    [self drawSeperator]; 
    
    //set shortestDist header
    [self drawHeaderwithText:@"Shortest Distance"];
    
    //set firstShortestDist
    dist = self.firstGroup.shortestDist;
    toDisplay = [NSString stringWithFormat:@"%.2lf %@", dist, units];
    [self drawCatWithText:toDisplay onRight:YES];
    
    //set secondShortestDist
    dist = self.secondGroup.shortestDist; 
    toDisplay = [NSString stringWithFormat:@"%.2lf %@", dist, units];
    [self drawCatWithText:toDisplay onRight:NO];
    
    [self drawSeperator];
    
    lastPos = lastPos + lastHeight;
    
    scrollView.contentSize=CGSizeMake(320, lastPos);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings"                                            style:UIBarButtonItemStyleBordered target:self action:@selector(changeSetting)];
    self.navigationItem.rightBarButtonItem = settingsButton;
    
    //create a UIScrollView
    CGRect fullScreenRect=[[UIScreen mainScreen] applicationFrame];
    scrollView=[[UIScrollView alloc] initWithFrame:fullScreenRect];
    //    scrollView.contentSize=CGSizeMake(320,550);
    
    [scrollView setScrollEnabled:YES];
    scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [scrollView setCanCancelContentTouches:NO];
    self.view = scrollView;
//    self.view.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor colorWithRed:0.292076 green:0.388945 blue:0.637058 alpha:1];
      
    headerHeight = 35;  //change to make more room before headers
    catHeight = 30;    // change to make more room before data
    startHeight = 15;  //change to move the all text up or down together
    
    self.navigationItem.title = @"Compare Stats";

}

- (void)viewDidUnload
{
    [self setSettingsButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
