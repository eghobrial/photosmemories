//
//  myAnnotation.h
//  Lab1
//
//  Created by Eman Ghobrial on 4/19/16.
//  Copyright © 2016 Eman Ghobrial. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface myAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *imagePath;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) NSString *audioURL;
@property (nonatomic) int displayOrder;

- (id)initWithImagePath:(NSString *)imagePath title:(NSString *)title subtitle:(NSString *) subtitle coordinate:(CLLocationCoordinate2D)coordinate andDisplayOrder:(int) displayOrder andAudioURL:(NSString *) audioURL;
@end
