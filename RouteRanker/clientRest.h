//
//  clientRest.h
//  Calculator
//
//  Created by Eric Denovitzer on 4/28/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import "SBJSON.h"
#import "URLRequest.h"
#import "Route.h"
#import "AppDelegate.h"
#import "RouteAnnotation.h"
#import "AutoAnnotation.h"

@interface clientRest : NSObject
-(void) createCookie: (NSString *) id;
-(NSArray *)getFriends: (int)id;
-(NSArray *)getPenFriends: (int)id;
-(bool)addFriend: (int)id1 add:(int)id2;
-(bool)acceptFriend: (int)id1 accept:(int)id2;
-(bool) sharePath: (int)pathId fromUser:(NSString *)creator name:(NSString *)userName withFriend:(NSString *)userId;
-(bool)addPath:(Route *)path withId:(int)idPath ofUser:(NSString *)userId;
-(void)getPathWithId: (int)pathId ofUser:(NSString *)userId  from:(NSString *)fromUser;
-(void) deletePath:(NSString *)pathId fromUser:(NSString *)userId;
-(NSMutableArray *)getSharedPaths:(NSString *) userId;
- (NSArray *)md5:(NSString *)str;
-(void) addUser:(NSString *)userId;
- (NSString *) checkUser:(NSString *)users;
@end
