//
//  API.h
//  ios_uzdevums
//
//  Created by GN4 on 24/02/14.
//  Copyright (c) 2014 espats. All rights reserved.
//
#define kServer @"spacebox.lv"
#define kPort 6111;
#define kEmail @"gints.osis@brainclub.com"
#import <Foundation/Foundation.h>

@interface API : NSObject <NSStreamDelegate,NSURLSessionDelegate>
+(API *)sharedInstance;
-(void)addUser:(NSString *)info;
-(void)reachabilityChanged:(NSNotification*)note;
-(void)saveImage:(UIImage*)image withName:(NSString*)name;
-(UIImage*) loadImage:(NSString*)name;

@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableDictionary *usersDict;
@property BOOL usersAdded;
@property (nonatomic,weak) NSURLSessionConfiguration *configuration;;
@property (nonatomic, weak) NSURLSession *session;
@property (nonatomic, retain)  NSOperationQueue *queue;
@end
