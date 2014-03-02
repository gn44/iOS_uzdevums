//
//  MapAnnotation.m
//  ios_uzdevums_final
//
//  Created by GN4 on 18/02/14.
//  Copyright (c) 2014 espats. All rights reserved.
//

#import "MapAnnotation.h"

@implementation MapAnnotation
@synthesize coordinate = _coordinate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize description = _description;
@synthesize selected = _selected;
@synthesize timer = _timer;

@synthesize oldCoord = _oldCoord;
@synthesize newCoord = _newCoord;
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString*)t
{
    self = [super init];
    
    if (self != nil)
    {
        _coordinate = coordinate;
        _oldCoord = _coordinate;
        geoCoder = [[CLGeocoder alloc]init];
        [self setAdress:_coordinate];
        _title = t;
    }
    
    return self;
}
- (NSString *)title
{
    return _title;
}
- (NSString *)subtitle
{
    return _subtitle;
}
-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _newCoord = newCoordinate;
    if(frames!=0.3 && _selected)
    {
        [_timer invalidate];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(lerpCoordinate) userInfo:nil repeats:YES];
    }else
        if(!_selected)
        {
            [_timer invalidate];
            _coordinate = _newCoord;
            _oldCoord = _coordinate;
             [self setAdress:_coordinate];
        }
}
-(void)lerpCoordinate
{
    _coordinate = [self lerpFrom:_oldCoord to:_newCoord];
     [self setAdress:_coordinate];
    if(frames>=1)
    {
        frames = 0.3;
        [_timer invalidate];
        _coordinate = _newCoord;
        _oldCoord = _coordinate;
    }
}
-(CLLocationCoordinate2D)lerpFrom:(CLLocationCoordinate2D)fromCoordinate to:(CLLocationCoordinate2D)toCoordinate
{
    CLLocationCoordinate2D currentCoordinate;
    currentCoordinate.latitude = _oldCoord.latitude +(_newCoord.latitude - _oldCoord.latitude) *frames;
    currentCoordinate.longitude = _oldCoord.longitude +(_newCoord.longitude - _oldCoord.longitude) *frames;
    frames+=0.3;
    _oldCoord = currentCoordinate;
    return currentCoordinate;
}
-(void)setAdress:(CLLocationCoordinate2D)coordinate
{
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [geoCoder reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0)
        {
            CLPlacemark *placemark = (CLPlacemark*)placemarks[0];
            NSString *tempAdress = placemark.subThoroughfare;
            NSArray *adress = [tempAdress componentsSeparatedByString:@"–"];
            if(adress[0]==NULL)
            {
                _subtitle = placemark.thoroughfare;

            } else
            _subtitle = [NSString stringWithFormat:@"%@ %@",placemark.thoroughfare,adress[0]];
            if(_selected)
            {
                 NSDictionary *userToRefresh = [NSDictionary dictionaryWithObject:self forKey:@"User"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshUser" object:self userInfo:userToRefresh];
            }
        }
    }];
}
-(BOOL)isSelected
{
    return _selected;
}

@end
