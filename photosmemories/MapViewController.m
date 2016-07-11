//
//  MapViewController.m
//  Lab1
//
//  Created by Eman Ghobrial on 4/18/16.
//  Copyright © 2016 Eman Ghobrial. All rights reserved.
//

#import "MapViewController.h"
#import "DataManager.h"

@interface MapViewController ()
@property CLLocation *location;
//@property CLPlacemark *placemark;
@property NSArray *results;
@property CLLocationManager *manager;
@property NSMutableArray *annotationsArr;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property int displayOrder;
@end

@implementation MapViewController

static const CLLocationCoordinate2D centerLocation = {32.858411, -117.1838572};


- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchResults];
    self.annotationsArr = [self makeAnnotationArr];
    //  self.mapView.showsUserLocation = YES;
    [self.mapView addAnnotations:self.annotationsArr];
    [self.mapView showAnnotations:self.annotationsArr animated:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchResults];
    MKCoordinateRegion region;
    region.center = centerLocation;
    region.span.latitudeDelta = 1.0;
    region.span.longitudeDelta = 1.0;
    [self.mapView setRegion:region animated:YES];
    [self.mapView removeAnnotations:self.mapView.annotations];
    // [self.mapView setRegion:region animated:YES];
    self.annotationsArr = [self makeAnnotationArr];
    [self.mapView addAnnotations:self.annotationsArr];
    [self.mapView showAnnotations:self.annotationsArr animated:YES];
}


-(IBAction)displayDetailVC:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    DetailViewController *audioVC  = [storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    audioVC.myOrder = self.displayOrder;
    //   [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController pushViewController:audioVC animated:YES];
    //[self dismissViewControllerAnimated:YES completion:nil];
    
}
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    //  CGFloat iconSize = 40.0f;
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[myAnnotation class]])
    {
        //create annotation view
        MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinView"];
        //MKPointAnnotation *mkAnnotation = (MKPointAnnotation *)annotation;
        myAnnotation *currentAnnotation = (myAnnotation*) annotation;
        NSURL *documentsURL = [[[NSFileManager defaultManager]
                                URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSString *fileName = currentAnnotation.imagePath;
        self.displayOrder = currentAnnotation.displayOrder;
        documentsURL = [documentsURL URLByAppendingPathComponent:fileName];
        NSLog(@"doc path = %@", documentsURL);
        UIImage *myIm;
        //NSData *myImageData = UIImagePNGRepresentation(selectedImage);
        //if the image is a video display frame at time 1
        if ([fileName containsString:@"mp4"])
        {
            MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc]
                                                    initWithContentURL:documentsURL];
            moviePlayer.shouldAutoplay = NO;
            UIImage *thumbnail = [moviePlayer thumbnailImageAtTime:1
                                                        timeOption:MPMovieTimeOptionNearestKeyFrame];
            myIm = thumbnail;
        } else {
            myIm = [UIImage imageWithContentsOfFile:documentsURL.path];
        }
        
        UIImageView *myImageView = [[UIImageView alloc] initWithImage:myIm];
        myImageView.frame = CGRectMake(0, 0, 40, 40);
        pinView.leftCalloutAccessoryView = myImageView;
        //pinView.animatesDrop = FALSE;
        pinView.canShowCallout = YES;
        pinView.enabled = YES;
        //pinView.tintColor = MAP_TINT;
        // Add a detail disclosure button to the callout.
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton addTarget:self action:@selector(displayDetailVC:) forControlEvents:UIControlEventTouchUpInside];
        pinView.rightCalloutAccessoryView = rightButton;
        return pinView;
    }
    return nil;
}




-(void)fetchResults {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Image" inManagedObjectContext:[[DataManager sharedManager] managedObjectContext]];
    [fetchRequest setEntity:entity];
    //to sort
    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"displayOrder" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor1]];
    NSError *error = nil;
    self.results = [[[DataManager sharedManager] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    } else {
        NSLog(@"%@", self.results);
    }
}

-(NSMutableArray*) makeAnnotationArr
{
    
    self.annotationsArr = [[NSMutableArray alloc]init];
    for (int i=0;i<[self.results count];i++)
    {
        Image *tempIm = [self.results objectAtIndex:i];
        myAnnotation *tempAnn = [[myAnnotation alloc]initWithImagePath:tempIm.localURL title:tempIm.streetAdd subtitle:tempIm.dateStamp coordinate:CLLocationCoordinate2DMake([tempIm.latitude doubleValue], [tempIm.longitude doubleValue]) andDisplayOrder:[tempIm.displayOrder intValue] andAudioURL:tempIm.audioURL];
        
        [self.annotationsArr addObject:tempAnn];
    }
    
    return self.annotationsArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
