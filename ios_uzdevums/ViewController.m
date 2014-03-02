//
//  ViewController.m
//  ios_uzdevums
//
//  Created by GN4 on 23/02/14.
//  Copyright (c) 2014 espats. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "API.h"
#import "User.h"
#import "MapAnnotation.h"
@interface ViewController ()
{
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}
@end
@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [API sharedInstance];
    _annotations = [[NSMutableDictionary alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addPlacemark:)
                                                 name:@"userAdded"
                                            object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePlacemark:)
                                                 name:@"userUpdated"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshAnnotation:)
                                                 name:@"refreshUser"
                                               object:nil];
}
-(void) updatePlacemark:(NSNotification *)notification
{
     NSDictionary *info = [notification userInfo];
     User *user =  (User*)[info objectForKey:@"User"];
    MapAnnotation* currentAnnotation = (MapAnnotation*)[_annotations objectForKey:user.ID];
    CLLocationCoordinate2D coordinate;
    coordinate.longitude = [user.longitude floatValue];
    coordinate.latitude = [user.latitude floatValue];
    currentAnnotation.coordinate = coordinate;
}

-(void)refreshAnnotation:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    MapAnnotation *annotation = (MapAnnotation*)[info objectForKey:@"User"];
    [_mapView deselectAnnotation:annotation animated:NO];
    [_mapView selectAnnotation:annotation animated:YES];
}
-(void) addPlacemark:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    User *user =  (User*)[info objectForKey:@"User"];
    CLLocationCoordinate2D coordinate;
    coordinate.longitude = [user.longitude floatValue];
    coordinate.latitude = [user.latitude floatValue];
    MapAnnotation* annotation = [[MapAnnotation alloc] initWithCoordinate:coordinate andTitle:user.name];
    annotation.description = user.ID;
    [_mapView addAnnotation:annotation];
    [_annotations setObject:annotation forKey:(NSString*)user.ID];
}
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views{
    MKAnnotationView *annotationView = [views objectAtIndex:0];
    id<MKAnnotation> mp = [annotationView annotation];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate], 300, 300);
    [_mapView setRegion:region animated:YES];
}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    static NSString *AnnotationIdentifier = @"AnnotationIdentifier";
    MKAnnotationView *AnnotationView =
    [self.mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
    if (AnnotationView == nil)
    {
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                        reuseIdentifier:AnnotationIdentifier];
        //annotation.description = user.id
        User *user = (User*)[[API sharedInstance].usersDict objectForKey:annotation.description];
        UIImage *img = user.image;
        annotationView.canShowCallout = YES;
        UIImage *pointImage = [UIImage imageNamed:@"point.png"];
        annotationView.image = pointImage;
        annotationView.opaque = NO;
        UIImageView *IconView = [[UIImageView alloc] initWithImage:img];
        IconView.frame = CGRectMake(IconView.frame.origin.x, IconView.frame.origin.y,
                                    img.size.width-15, img.size.height-15);
        annotationView.leftCalloutAccessoryView = IconView;
        return annotationView;
    }
    else
    {
        AnnotationView.annotation = annotation;
    }
    return AnnotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[MapAnnotation class]])
    {
        MapAnnotation *annotation = (MapAnnotation*)view.annotation;
        annotation.selected = YES;
    }
}
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[MapAnnotation class]])
    {
        MapAnnotation *annotation = (MapAnnotation*)view.annotation;
        annotation.selected = NO;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
