//
//  API.m
//  ios_uzdevums
//
//  Created by GN4 on 24/02/14.
//  Copyright (c) 2014 espats. All rights reserved.
//

#import "API.h"
#import "User.h"
#import "Reachability.h"
@interface API ()
{
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
}
@end
@implementation API
+(API *)sharedInstance
{
    static dispatch_once_t once;
    static API *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
-(id) init
{
    _usersAdded = NO;
    Reachability* reachability = [Reachability reachabilityWithHostname:@"www.spacebox.lv"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    [reachability startNotifier];
    
    _queue = [[NSOperationQueue alloc] init];
    _configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:_configuration delegate:self delegateQueue:_queue];
    
    _users = [[NSMutableArray alloc] init];
    _usersDict = [[NSMutableDictionary alloc] init];
    
    return self;
}
-(void)authorizeUser:(NSString *)email
{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)kServer, 6111, &readStream, &writeStream);
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge NSOutputStream *)writeStream;
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream open];
    [outputStream open];
    
    NSString *response = [NSString stringWithFormat:@"AUTHORIZE %@\n",email];
	NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
	[outputStream write:[data bytes] maxLength:[data length]];
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
	switch (streamEvent) {
            
		case NSStreamEventOpenCompleted:
			NSLog(@"Stream opened");
			break;
            
		case NSStreamEventHasBytesAvailable:
            
            if (theStream == inputStream) {
                
                uint8_t buffer[1024];
                int len;
                while ([inputStream hasBytesAvailable]) {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSUTF8StringEncoding];
                        if (nil != output) {
                            if([output rangeOfString:@"UPDATE"].length>0)
                            {
                                [self updateUser:output];
                            }
                            else if(!_usersAdded)
                            {
                                NSArray *details = [output componentsSeparatedByString:@";"];
                                for (int i=0; i<details.count; i++) {
                                    [self addUser:details[i]];
                                }
                                _usersAdded = YES;
                            }
                        }
                    }
                }
            }
            break;
            
		case NSStreamEventErrorOccurred:
			NSLog(@"Can not connect to the host!");
			break;
            
		case NSStreamEventEndEncountered:
            NSLog(@"close");
			break;
            
		default:
			NSLog(@"Unknown event");
	}
    
}
-(void)updateUser:(NSString *)info
{
    info = [info stringByReplacingOccurrencesOfString:@"UPDATE " withString:@","];
    NSArray *users = [info componentsSeparatedByString:@","];
    for (int i=1; i<users.count; i+=3) {
        //i = ID, i+1 = lat, i+=2 = long
        if([_usersDict objectForKey:(NSString*)users[i]])
        {
            User *currentUser = (User*)[_usersDict objectForKey:(NSString*)users[i]];
            float userLat = [currentUser.latitude floatValue];
            float receivedLAt = [users[i+1] floatValue];
            float userLong = [currentUser.longitude floatValue];
            float receivedLong = [users[i+2] floatValue];
            if(userLat != receivedLAt ||userLong != receivedLong)
            {
                currentUser.latitude = users[i+1];
                currentUser.longitude = users[i+2];
                [_usersDict setObject:currentUser forKey:users[i]];
                NSDictionary *userToUpdate = [NSDictionary dictionaryWithObject:currentUser forKey:@"User"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"userUpdated" object:self userInfo:userToUpdate];
            }
        }
    }
}
-(void)addUser:(NSString *)info
{
    info = [info stringByReplacingOccurrencesOfString:@"USERLIST" withString:@""];  //remove USERLIST from response
    NSArray *details = [info componentsSeparatedByString:@","]; //0-id 1-name,2-link,3-lat,4-long
    if(details.count==5)
    {
        User *user =[User new];
        [_users addObject:user];
        user.ID = [(NSString*)details[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        user.name = details[1];
        user.latitude = details[3];
        user.longitude = details[4];
        NSDictionary *userToAdd = [NSDictionary dictionaryWithObject:user forKey:@"User"];//user to pass in nsnotification
        user.image = [self loadImage:user.ID];
        if(!user.image)
        {
        [[_session dataTaskWithURL: [NSURL URLWithString: details[2]]
                            completionHandler:^(NSData *data, NSURLResponse *response,
                                                NSError *error) {
                               user.image = [UIImage imageWithData:data];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"userAdded" object:self userInfo:userToAdd];
                                [self saveImage:user.image withName:user.ID];
                            }] resume];
        } else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"userAdded" object:self userInfo:userToAdd];
        }
        NSString *trimmedID = [(NSString*)details[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [_usersDict setObject:user forKey:trimmedID];//dictionary with user id's
    }
}
-(void)saveImage:(UIImage*)image withName:(NSString*)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",name]];
    UIImage *currentImage = image;
    NSData *imageData = UIImagePNGRepresentation(currentImage);
    [imageData writeToFile:savedImagePath atomically:NO];
}
-(UIImage *)loadImage:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *getImagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",name]];
    UIImage *image = [UIImage imageWithContentsOfFile:getImagePath];
    return image;
}

-(void)reachabilityChanged:(NSNotification*)note;
{
    Reachability * reach = [note object];
    if([reach isReachable])
    {
        [self authorizeUser:kEmail];
    }
    else
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Ups" message:@"Network connection has been lost" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}
@end
