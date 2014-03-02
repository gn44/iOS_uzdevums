//
//  User.h
//  ios_uzdevums
//
//  Created by GN4 on 25/02/14.
//  Copyright (c) 2014 espats. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property (nonatomic,strong) UIImage *image;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSString *ID;
@end
