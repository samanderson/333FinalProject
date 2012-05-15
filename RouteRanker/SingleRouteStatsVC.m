//
//  SingleRouteStatsVC.m
//  RouteRanker
//
//  Created by Mark Whelan on 5/9/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "SingleRouteStatsVC.h"

@interface SingleRouteStatsVC () {
    int headerHeight;
    int catHeight; 
    int startHeight; 
    int lastPos;
    int lastHeight; 
}


@end

@implementation SingleRouteStatsVC
@synthesize settingsButton;

@synthesize scrollView; 
@synthesize firstGroup = _firstGroup; 

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
            [self.firstGroup convertFromMetric];
            [self viewWillAppear:YES];
        }
    }
    else {
        NSLog(@"km pressed");
        [prefs setObject:@"km" forKey:@"units"];
        if(![self.firstGroup.unit isEqualToString:@"km"])
        {
            [self.firstGroup convertToMetric];
            [self viewWillAppear:YES];
        }
    }
    [prefs synchronize];

}

-(void) drawHeaderwithText:(NSString*) toDisplay {
    UILabel* header = [[UILabel alloc] initWithFrame:CGRectMake(0, lastHeight + lastPos, 320, headerHeight)];
    header.textAlignment = UITextAlignmentCenter;
    header.font= [UIFont boldSystemFontOfSize:17];
    header.text = toDisplay;
    header.backgroundColor = [UIColor clearColor];
    header.textColor = [UIColor blackColor];
    [self.view addSubview:header];
    lastPos = lastPos + lastHeight;
    lastHeight = headerHeight;
    
}

-(void) drawSeperator {
    lastPos = lastPos + lastHeight;
    lastHeight = catHeight; 
}

-(void) drawCatWithText:(NSString*) text {
    UILabel* category = [[UILabel alloc] initWithFrame:CGRectMake(0, lastHeight + lastPos, 320, catHeight)];
    category.text = text;
    category.backgroundColor = [UIColor colorWithRed:0.292076 green:0.388945 blue:0.637058 alpha:1];
    category.textColor = [UIColor whiteColor];
    category.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:category];
    [self drawSeperator];
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
        if([groupUnit isEqualToString:@"km"])
            [self.firstGroup convertFromMetric];
        else {
            [self.firstGroup convertToMetric];
        }
    }
    //[prefs setInteger:numRoutes forKey:@"numRoutes"];
    //[prefs synchronize];
    
    //set first title
    UILabel* firstTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, startHeight, 320, headerHeight)];
    firstTitle.text = self.firstGroup.groupName;
    firstTitle.font = [UIFont boldSystemFontOfSize:20];
    firstTitle.textAlignment = UITextAlignmentCenter;
    firstTitle.backgroundColor = [UIColor clearColor];
    firstTitle.textColor = [UIColor whiteColor];
    [self.view addSubview:firstTitle];
    
    lastPos = startHeight;
    lastHeight = headerHeight;
    
    
    //set numOfPaths Header
    [self drawHeaderwithText:@"Number of Paths"];
    
    //set firstNumOfPaths
    NSString* toDisplay;
    int numPaths = self.firstGroup.numRoutes;
    toDisplay = [NSString stringWithFormat:@"%d", numPaths];
    [self drawCatWithText:toDisplay];
    
    
    //set average distance header
    [self drawHeaderwithText:@"Average Route Distance"];
    
    //set firstAvgDist
    double dist = self.firstGroup.avgDist;
    toDisplay = [NSString stringWithFormat:@"%.2lf %@", dist, units];
    [self drawCatWithText:toDisplay];
    
    
    //set average speed header
    [self drawHeaderwithText:@"Average Route Speed"];
    
    //set firstAvgSpeed
    double avgMPH = self.firstGroup.avgSpeed;
    toDisplay = [NSString stringWithFormat:@"%.2lf %@/hr", avgMPH, units];
    [self drawCatWithText:toDisplay];
    
    //set total time header
    [self drawHeaderwithText:@"Total Time"];
    
    
    //set firstTotalTime
    toDisplay = [self convertTimeFormatfromSeconds:self.firstGroup.totalTime];
    [self drawCatWithText:toDisplay];
    
    
    //set AverageTime Header
    [self drawHeaderwithText:@"Average Route Time"];
    
    //set firstAvgTime
    toDisplay = [self convertTimeFormatfromSeconds:self.firstGroup.avgTime];
    [self drawCatWithText:toDisplay];
    
    
    //set longestTime header
    [self drawHeaderwithText:@"Longest Time"];
    
    //set firstLongestTime
    toDisplay = [self convertTimeFormatfromSeconds:self.firstGroup.longestTime];
    [self drawCatWithText:toDisplay];
    
    
    //set longestDistHeader
    [self drawHeaderwithText:@"Longest Route Distance"];
    
    //set firstLongestDist
    dist = self.firstGroup.longestDist;
    toDisplay = [NSString stringWithFormat:@"%.2lf %@", dist, units];
    //toDisplay = [toDisplay stringByAppendingString:@" miles"];
    [self drawCatWithText:toDisplay];
    
    
    //set shortestTime header
    [self drawHeaderwithText:@"Shortest Time"];
    
    //set firstShortestTime
    toDisplay = [self convertTimeFormatfromSeconds:self.firstGroup.shortestTime];
    [self drawCatWithText:toDisplay];
    
    
    //set shortestDist header
    [self drawHeaderwithText:@"Shortest Distance"];
    
    //set firstShortestDist
    dist = self.firstGroup.shortestDist;
    toDisplay = [NSString stringWithFormat:@"%.2lf %@", dist, units];
    //toDisplay = [toDisplay stringByAppendingString:@" miles"];
    [self drawCatWithText:toDisplay];
    
    lastPos = lastPos + lastHeight;
    lastHeight = catHeight; 
    
    scrollView.contentSize=CGSizeMake(320, lastPos);
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings"                                            style:UIBarButtonItemStyleBordered target:self action:@selector(changeSetting)];
    self.navigationItem.rightBarButtonItem = settingsButton;
    //create a UIScrollView
    self.navigationItem.title = @"Stats";
    CGRect fullScreenRect=[[UIScreen mainScreen] applicationFrame];
    scrollView=[[UIScrollView alloc] initWithFrame:fullScreenRect];
    [scrollView setScrollEnabled:YES];
    scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [scrollView setCanCancelContentTouches:NO];
    self.view = scrollView;
    self.view.backgroundColor = [UIColor colorWithRed:0.292076 green:0.388945 blue:0.637058 alpha:1];
    
    headerHeight = 35;  //change to make more room before headers
    catHeight = 30;    // change to make more room before data
    startHeight = 15;  //change to move the all text up or down together

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
