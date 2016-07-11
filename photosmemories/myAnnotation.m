//
//  myAnnotation.m
//  Lab1
//
//  Created by Eman Ghobrial on 4/19/16.
//  Copyright © 2016 Eman Ghobrial. All rights reserved.
//

#import "myAnnotation.h"

@implementation myAnnotation

- (id)initWithImagePath:(NSString *)imagePath title:(NSString *)title subtitle:(NSString *) subtitle coordinate:(CLLocationCoordinate2D)coordinate andDisplayOrder:(int) displayOrder andAudioURL:(NSString *) audioURL
{
    self = [super init];
    if (self != nil) {
        self.imagePath = imagePath;
        self.title = title;
        self.subtitle = subtitle;
        self.coordinate = coordinate;
        self.displayOrder = displayOrder;
        self.audioURL = audioURL;
    }
    return self;
}

@end
