//
//  clientRest.m
//  Calculator
//
//  Created by Eric Denovitzer on 4/28/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "clientRest.h"



@implementation clientRest
NSString const * 
baseURL = @"http://ec2-177-71-143-149.sa-east-1.compute.amazonaws.com:8080/";
//baseURL = @"http://localhost:8080/";
#define CC_MD5_DIGEST_LENGTH 16 

-(void) createCookie: (NSString *)id {
   // NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults ];            
    //NSString *id = [prefs stringForKey:@"myID"];
    //NSString *id = @"123";
    NSString *hashId = [self md5:[NSString stringWithFormat:@"%@#.4a!" , id]];
    NSURL *originURL = [NSURL URLWithString :@"http://ec2-177-71-143-149.sa-east-1.compute.amazonaws.com:8080"];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy :NSHTTPCookieAcceptPolicyAlways];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:[ NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys: originURL, NSHTTPCookieOriginURL,
                                                                                                  @"/",NSHTTPCookiePath,
                                                                                                  @"hash", NSHTTPCookieName,
                                                                                                  hashId, NSHTTPCookieValue,
                                                                                                  nil]]];
    /*   
     URLRequest *request = [[URLRequest alloc] init];
     NSString *dir = @"getCookie";
     NSString *url = [baseURL stringByAppendingString: dir];
     NSString *values = [NSString stringWithFormat:@""];
     NSString *data = [request sendRequest:url withMethod:@"post" andValues:values];
     NSLog(data);
     */
    
}


- (NSString *)md5:(NSString *)str { 
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH]; 
    CC_MD5(cStr, strlen(cStr), result); 
    return [NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",                     
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]];        
}

-(NSArray *) getFriends: (int)id {
    URLRequest *request = [[URLRequest alloc] init];
    NSString *idStr = [NSString stringWithFormat:@"%d", id];
    NSString *dir = [@"get/friends/" stringByAppendingString:idStr];
    NSString *url = [baseURL stringByAppendingString: dir];
    NSString *data = [request sendRequest:url withMethod:@"get" andValues:@""];
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSError *error = nil;
    NSDictionary *jsonObject = [jsonParser objectWithString:data error:&error];
    NSArray *friends = [jsonObject valueForKey:@"friends"];
    return friends;
}

-(NSArray *) getPenFriends: (int)id {
    URLRequest *request = [[URLRequest alloc] init];
    NSString *idStr = [NSString stringWithFormat:@"%d", id];
    NSString *dir = [@"get/penFriends/" stringByAppendingString:idStr];
    NSString *url = [baseURL stringByAppendingString: dir];
    NSString *data = [request sendRequest:url withMethod:@"get" andValues:@""];
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSError *error = nil;
    NSDictionary *jsonObject = [jsonParser objectWithString:data error:&error];
    NSArray *penFriends = [jsonObject valueForKey:@"penFriends"];
    return penFriends;
}

-(NSArray *) getPathByUser: (int)id {
    URLRequest *request = [[URLRequest alloc] init];
    NSString *dir = [NSString stringWithFormat:@"getPathByUser/%d", id];
    NSString *url = [baseURL stringByAppendingString: dir];    
    NSString *data = [request sendRequest:url withMethod:@"get" andValues:@""];
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSError *error = nil;
    NSDictionary *jsonObject = [jsonParser objectWithString:data error:&error];
    NSArray *paths = [jsonObject valueForKey:@"paths"];
    return paths;

}

-(bool) addFriend: (int)id1 add:(int)id2 {
    URLRequest *request = [[URLRequest alloc] init];
    NSString *dir = @"addFriend";
    NSString *url = [baseURL stringByAppendingString: dir];
    NSString *values = [NSString stringWithFormat:@"id1=%d&id2=%d", id1, id2];
    NSString *data = [request sendRequest:url withMethod:@"post" andValues:values];
    if ([data isEqualToString:@"1"]) 
        return TRUE;
    else 
        return FALSE;
}

-(bool) acceptFriend: (int)id1 accept:(int)id2 {
    URLRequest *request = [[URLRequest alloc] init];
    NSString *dir = @"acceptFriend";
    NSString *url = [baseURL stringByAppendingString: dir];
    NSString *values = [NSString stringWithFormat:@"id1=%d&id2=%d", id1, id2];
    NSString *data = [request sendRequest:url withMethod:@"post" andValues:values];
    if ([data isEqualToString:@"1"]) 
        return TRUE;
    else 
        return FALSE;
}

-(bool) sharePath: (int)pathId fromUser:(NSString *)creator name:(NSString *)userName withFriend:(NSString *)userId {
    URLRequest *request = [[URLRequest alloc] init];
    NSString *dir = @"share";
    NSString *url = [baseURL stringByAppendingString: dir];
    NSString *shareId = [NSString stringWithFormat:@"%@a%d", creator, pathId];
    NSString *values = [NSString stringWithFormat:@"pathId=%@&userId=%@&userName=%@&fromUser=%@",
                        shareId, userId, userName, creator];
    NSString *data = [request sendRequest:url withMethod:@"post" andValues:values];
    if ([data isEqualToString:@"1"]) 
        return TRUE;
    else 
        return FALSE;
}

-(bool) addPath:(Route *)path withId:(int)idPath ofUser:(NSString *)userId {
    URLRequest *request = [[URLRequest alloc] init];
    NSString *dir = @"addPath";
    NSString *url = [baseURL stringByAppendingString: dir];
    
    //Get all variables
    MKMapPoint *points = path.points;
    NSUInteger numPoints = path.numPoints;
    NSMutableArray *times = path.timeArray;
    NSString *distance = [[NSNumber numberWithDouble:[path getTotalDistanceTraveled]] stringValue];
    NSMutableArray *annotations = path.annotations;
    NSString *name = path.name;
    NSString *totalTime = [[NSNumber numberWithDouble:[path getTotalTimeElapsed]] stringValue];

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *userName = [prefs stringForKey:@"myName"];
    //Format
    //Points
    NSString *pointsFormat = [[NSString alloc] init];
    for(int i = 0; i < numPoints; i++) {
        pointsFormat =  [pointsFormat stringByAppendingString: 
                         [NSString stringWithFormat:@"%f,%f#", points[i].x, points[i].y]];
        
    }
    
    //Times
    NSString *timesFormat = [[NSString alloc] init];
    for (int i = 0; i < numPoints; i++) {
        NSDate *current = [times objectAtIndex:i];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];    
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        NSString *formattedDateString = [dateFormatter stringFromDate:current];
        timesFormat = [timesFormat stringByAppendingString:formattedDateString];
        timesFormat = [timesFormat stringByAppendingString:@"#"];
    }
    
    //Annotations
    
    NSString *annotationsFormat = [[NSString alloc] init];
    if (annotations) {
        NSString *currTime;
        for (id<MKAnnotation> a in annotations) {
            if ([a isKindOfClass:[AutoAnnotation class]]) {
                AutoAnnotation *current = (AutoAnnotation *)a;
                currTime = [current.time description];
                annotationsFormat = [annotationsFormat stringByAppendingString:[NSString stringWithFormat:@"%@,%@,%@,%f,%f#",
                                     currTime, current.title, nil,
                                     current.coordinate.latitude, current.coordinate.longitude]];
            } else {
                RouteAnnotation *current = (RouteAnnotation *)a;
                currTime = [current.time description];
                annotationsFormat = [annotationsFormat stringByAppendingString:[NSString stringWithFormat:@"%@,%@,%@,%f,%f#",
                                     currTime, current.title, current.subtitle,
                                     current.coordinate.latitude, current.coordinate.longitude]];
            }
        }
    }
    else 
        annotationsFormat = @"NULL";
    
    NSString *values =  [NSString stringWithFormat:
                         @"idPath=%d&userId=%@&userName=%@&name=%@&points=%@&times=%@&distance=%@&numPoints=%d&numAnnotations=%d&annotations=%@&totalTime=%@",
                         idPath, userId, userName, name, pointsFormat,timesFormat,distance, numPoints,
                         path.numAnnotations, annotationsFormat, totalTime];
    
    NSString *data = [request sendRequest:url withMethod:@"post" andValues:values];
    
    if (data == @"0") 
        return TRUE;
    else 
        return FALSE;
}

-(void)getPathWithId: (int)pathId ofUser: (NSString *)userId from:(NSString *)fromUser {
    URLRequest *request = [[URLRequest alloc] init];
    NSString *idStr = [NSString stringWithFormat:@"%@a%d", userId, pathId];
    NSString *dir = [@"getPath/" stringByAppendingString:idStr];
    NSString *url = [baseURL stringByAppendingString: dir];
    NSString *values = [NSString stringWithFormat:@"pathId=%@&fromUser=%@", idStr, fromUser];
    NSString *data = [request sendRequest:url withMethod:@"post" andValues:values];
    NSLog(@"%@",data);
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSError *error = nil;
    NSDictionary *jsonObject = [jsonParser objectWithString:data error:&error];
    
    NSLog(@"%@", jsonObject);
    //Get raw values
    NSString *name = [jsonObject valueForKey:@"pathName"];
    int numPoints = [[jsonObject valueForKey:@"numPoints"] intValue];
    NSString *points = [jsonObject valueForKey:@"points"];
    NSString *times = [jsonObject valueForKey:@"times"];
    int numAnnotations = [[jsonObject valueForKey:@"numAnnotations"] intValue];
    NSString *annotations = [jsonObject valueForKey:@"annotations"];
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];   
    double distance = [[jsonObject valueForKey:@"distance"] doubleValue];
    double totalTime = [[jsonObject valueForKey:@"totalTime"] doubleValue];
    NSString *userName = [jsonObject valueForKey:@"userName"];
    //Core data
    RouteData *routeData = [NSEntityDescription insertNewObjectForEntityForName:@"RouteData" inManagedObjectContext:context];
    routeData.title = name;
    routeData.ownerID = [NSString stringWithFormat:@"%@", userId];  //[NSNumber numberWithInt: userId];
    routeData.ownerName = userName;
    routeData.idNo = [NSNumber numberWithInt:pathId];
    routeData.distance = [NSNumber numberWithDouble:distance];
    routeData.numAnnotations = [NSNumber numberWithInt: numAnnotations];
    routeData.numPoints = [NSNumber numberWithInt: numPoints];
    routeData.time = [NSNumber numberWithInt:totalTime];

    //Points
    NSMutableArray *mapPoints = [NSMutableArray arrayWithCapacity:numPoints];
    NSArray *pointsArrayString = [points componentsSeparatedByString:@"#"];
    NSArray *timesArrayString = [times componentsSeparatedByString:@"#"];
    for (int i=0; i<numPoints; i++) {
        MapPointData *mapPoint = [NSEntityDescription insertNewObjectForEntityForName:@"MapPointData" inManagedObjectContext:context];
        NSArray *coord =[[pointsArrayString objectAtIndex:i] componentsSeparatedByString:@","];
        double x = [[coord objectAtIndex:0] doubleValue];
        double y = [[coord objectAtIndex:1] doubleValue];
        NSString *currentTime = [timesArrayString objectAtIndex:i];
        
        //Format NSDate
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];    
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        NSDate *currentDate = [dateFormatter dateFromString:currentTime];
        
        mapPoint.sequence = [NSNumber numberWithInt: i];
        mapPoint.timestamp = currentDate;
        mapPoint.x = [NSNumber numberWithDouble:x];
        mapPoint.y = [NSNumber numberWithDouble:y];
        mapPoint.route = routeData;
        [mapPoints addObject:mapPoint];
    }
    routeData.points = [NSSet setWithArray:mapPoints];
    
    //Annotations
    
    if (numAnnotations > 0) {
        NSArray *annotationsArrayString = [annotations componentsSeparatedByString:@"#"];
        NSMutableArray *annotationData = [NSMutableArray arrayWithCapacity:numAnnotations];
        for (int i = 0; i < numAnnotations; i++) {
            NSLog(@"%d numAnnotations", numAnnotations);
            NSArray *dataAnnotation = [[annotationsArrayString objectAtIndex:i] componentsSeparatedByString:@","];
            NSLog(@"dataAnnotation %@", dataAnnotation);
            AnnotationData *annotation = [NSEntityDescription insertNewObjectForEntityForName:@"AnnotationData" inManagedObjectContext:context];
            if ([[dataAnnotation objectAtIndex:2] isEqualToString:@"(null)"]) {
                annotation.type = @"auto";
                annotation.subtitle = nil;
            } else {
                annotation.type = @"route";
                annotation.subtitle = [dataAnnotation objectAtIndex:2];
            }
            annotation.title = [dataAnnotation objectAtIndex:1];
            double lat = [[dataAnnotation objectAtIndex:3] doubleValue];
            double lon = [[dataAnnotation objectAtIndex:4] doubleValue];
            annotation.latitude = [NSNumber numberWithDouble:lat];
            annotation.longitude = [NSNumber numberWithDouble:lon];
            annotation.route = routeData;
            [annotationData addObject:annotation];
        }
        routeData.annotations = [NSSet setWithArray:annotationData];
    } else {
        routeData.annotations = nil;
    }
    NSLog(@"Hey 3");

        
    NSError *errorSave;
    if (![context save:&errorSave]) {
        NSLog(@"Whoops, couldn't save: %@", [errorSave localizedDescription]);
    }
}

-(NSString *) checkUser:(NSString *) users {
    URLRequest *request = [[URLRequest alloc] init];
    NSString *dir = @"checkUser";
    NSString *url = [baseURL stringByAppendingString: dir];
    NSString *values = [NSString stringWithFormat:@"users=%@", users];
    NSString *data = [request sendRequest:url withMethod:@"post" andValues:values];

    return data;
}

-(NSMutableArray *)getSharedPaths:(NSString *) userId {
    URLRequest *request = [[URLRequest alloc] init];
    NSString *dir = [NSString stringWithFormat:@"get/sharepaths/%@", userId];
    NSString *url = [baseURL stringByAppendingString: dir];
    NSString *data = [request sendRequest:url withMethod:@"get" andValues:@""];
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSError *error = nil;
    NSDictionary *jsonObject = [jsonParser objectWithString:data error:&error];
    NSArray *list = [jsonObject objectForKey:@"list"];
    int size = [list count];
    NSMutableArray *ret = [[NSMutableArray alloc]init];
    NSMutableArray *pathNames = [[NSMutableArray alloc] init];
    NSMutableArray *pathIds = [[NSMutableArray alloc] init];
    NSMutableArray *userNames = [[NSMutableArray alloc] init];
    bool check = false;
    for (int i = 0; i < size; i++) {
        check = true;
        NSDictionary *current = [list objectAtIndex:i];
        NSString *name = [current objectForKey:@"pathName"];
        NSString *pathId = [current objectForKey:@"path"];
        NSString *userName = [current objectForKey:@"userName"];
        [pathNames addObject:name];
        [pathIds addObject:pathId];
        [userNames addObject:userName];
        
    }
    
    if (check) {
        [ret addObject:pathNames];
        [ret addObject:pathIds];
        [ret addObject:userNames];
    }
    return ret;
}

-(void) addUser:(NSString *)userId {
    URLRequest *request = [[URLRequest alloc] init];
    NSString *dir = @"addUser";
    NSString *url = [baseURL stringByAppendingString: dir];
    NSString *values = [NSString stringWithFormat:@"fbid=%@", userId];
    [request sendRequest:url withMethod:@"post" andValues:values];
}

-(void) deletePath:(NSString *)pathId fromUser:(NSString *)userId {
    URLRequest *request = [[URLRequest alloc] init];
    NSString *dir = @"deleteSharedPath";
    NSString *url = [baseURL stringByAppendingString: dir];
    NSString *values = [NSString stringWithFormat:@"userId=%@&pathId=%@", userId, pathId];
    [request sendRequest:url withMethod:@"post" andValues:values];
    
}

@end
