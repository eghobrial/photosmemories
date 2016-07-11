//
//  MapViewController.h
//  Lab1
//
//  Created by Eman Ghobrial on 4/18/16.
//  Copyright © 2016 Eman Ghobrial. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "myAnnotation.h"
#import "DetailViewController.h"

@interface MapViewController : UIViewController <MKMapViewDelegate,CLLocationManagerDelegate>

-(NSMutableArray*) makeAnnotationArr;
-(void)displayDetailVC;

@end
