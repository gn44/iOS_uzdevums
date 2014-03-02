//
//  MapAnnotation.h
//  ios_uzdevums_final
//
//  Created by GN4 on 18/02/14.
//  Copyright (c) 2014 espats. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface MapAnnotation : NSObject<MKAnnotation>{
    CLLocationCoordinate2D _coordinate;
    NSString *title;
    NSString *subTitle;;
    CLGeocoder *geoCoder;
    NSString *description;
    
    CLLocationCoordinate2D oldCoord;
     CLLocationCoordinate2D newCoord;
    NSTimer *timer;
    float frames;
}
@property (nonatomic, copy) NSString *description;
@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic,weak) NSTimer *timer;
@property (nonatomic)CLLocationCoordinate2D coordinate;
@property CLLocationCoordinate2D newCoord;
@property CLLocationCoordinate2D oldCoord;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString*)t;
-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;
-(CLLocationCoordinate2D)lerpFrom:(CLLocationCoordinate2D)fromCoordinate to:(CLLocationCoordinate2D)toCoordinate;
@end
