//
//  ListTableViewController.h
//  Lab1
//
//  Created by Eman Ghobrial on 4/8/16.
//  Copyright © 2016 Eman Ghobrial. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "DetailViewController.h"



@interface ListTableViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate,CLLocationManagerDelegate,NSFetchedResultsControllerDelegate,UISearchBarDelegate, UISearchResultsUpdating>
- (IBAction)addFunction:(id)sender;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) UISearchController *searchController;

@end
