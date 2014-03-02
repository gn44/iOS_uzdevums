//
//  ViewController.h
//  ios_uzdevums
//
//  Created by GN4 on 23/02/14.
//  Copyright (c) 2014 espats. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSMutableDictionary *annotations;

-(void) updatePlacemark:(NSNotification *)notification;
-(void) addPlacemark:(NSNotification *)notification;
-(void)refreshAnnotation:(NSNotification *)notification;
@end
