//
//  ListTableViewController.m
//  Lab1
//
//  Created by Eman Ghobrial on 4/8/16.
//  Copyright © 2016 Eman Ghobrial. All rights reserved.
//
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ListTableViewController.h"
#import "DataManager.h"

@interface ListTableViewController ()
@property UIImagePickerController *imagePicker;
@property NSArray *searchResults;
@property (strong, nonatomic) NSFetchRequest *searchFetchRequest;

@property  NSUInteger numofFiles;
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) NSURL *docDirectoryURL;
@property (nonatomic, strong) NSNumber *seqNum;
@property (nonatomic,strong) CLPlacemark *myplacemark;
@property (nonatomic, strong) CLGeocoder *geocoder;
@end

@implementation ListTableViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize searchFetchRequest = _searchFetchRequest;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //self.locationManager = [[CLLocationManager alloc] init];
    //self.locationManager.delegate = self;
    
    // Gets user permission use location while the app is in the foreground.
   // [self.locationManager requestWhenInUseAuthorization];
    
  //  self.geocoder = [[CLGeocoder alloc] init];
    //[self.locationManager startUpdatingLocation];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    
    self.searchController.searchBar.delegate = self;
    
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    self.searchController.searchBar.scopeButtonTitles = @[@"Address",@"Date"];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    self.definesPresentationContext = YES;

}



-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    //   self.currDate = [NSDate date];
    NSArray *URLs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                           inDomains:NSUserDomainMask];
    self.docDirectoryURL = [URLs objectAtIndex:0];
 //   [self fetchResults];
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"fetch error : %@", error.localizedDescription);
    }
    

    [self.navigationController setToolbarHidden:NO];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    if ([self.locationManager locationServicesEnabled]) {
        //start setting up core location
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            [self.locationManager requestWhenInUseAuthorization];
        } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse){
            NSLog(@"authorized to go");
            //[self.manager requestAlwaysAuthorization];
            [self.locationManager startUpdatingLocation];
            self.locationManager.delegate = self;
             self.geocoder = [[CLGeocoder alloc] init];
        }
    } else {
        //show a warning that location is disabled on the phone
    }
}



//when the location updates, update the location
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *lastLocation = locations[0];
    CLLocation *bestLocation;
    
    if ((lastLocation.coordinate.latitude!=0.0)&& (lastLocation.coordinate.longitude!=0.0))
    {
        bestLocation = lastLocation;
        //    NSLog(@"got values ******");
    } else {
        //   NSLog(@"**********got no values");
        bestLocation = [[CLLocation alloc]initWithLatitude:32.858411 longitude:-117.1838572];
    }
    self.currentLocation = bestLocation;
    [self.geocoder reverseGeocodeLocation:bestLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if ((placemarks != nil) && (placemarks.count > 0)) {
            // If the placemark is not nil then we have at least one placemark. Typically there will only be one.
            self.myplacemark = placemarks[0];
            
        }
        else {
            // Handle the nil case if necessary.
        }
    }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addFunction:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *takePic = [UIAlertAction actionWithTitle:@"Take Picture or Video" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                              {
                                  //Take a pic action
                                  //if the camera is available set the type to camera else set to photo album
                                  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                                      self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                      self.imagePicker.mediaTypes = [[NSArray alloc]initWithObjects:(NSString*)kUTTypeMovie,(NSString*)kUTTypeImage, nil];
                                      
                                  } else {
                                      self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;                                     }
                                  [self presentViewController:self.imagePicker animated:YES completion:^{
                                      NSLog(@"Image picker presented!");
                                  }];
                                  
                                  
                              }];
    UIAlertAction *chooseSaved = [UIAlertAction actionWithTitle:@"Choose Saved" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                  {
                                      //Choose Saved action
                                      self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                      [self presentViewController:self.imagePicker animated:YES completion:^{
                                          NSLog(@"Image picker presented!");
                                      }];
                                      
                                  }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:takePic];
    [alert addAction:chooseSaved];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

-(NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Image" inManagedObjectContext:[[DataManager sharedManager] managedObjectContext]];
    
    [fetchRequest setEntity:entity];
    //to sort
    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"displayOrder" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor1]];
    
    
    
    NSFetchedResultsController *myController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[[DataManager sharedManager] managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    
    _fetchedResultsController = myController;
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}


/*-(void)fetchResults {
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
        
        [self.tableView reloadData];
    }
}*/

#pragma mark - Table view search

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self updateSearchResultsForSearchController:self.searchController];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    
    [self searchForText:searchString scope:searchController.searchBar.selectedScopeButtonIndex];
    [self.tableView reloadData];
}


-(void)searchForText:(NSString *)inputString scope:(NSInteger)buttonIndex {
    NSString *predicateFormat;
    NSString *searchAttribute;
    
   if (buttonIndex == 0) {
        
        predicateFormat = @"%K BEGINSWITH[cd] %@";
        searchAttribute = @"streetAdd";
        
    } else {
        
   //     //latitude == %@
        predicateFormat = @"%K BEGINSWITH[cd] %@";
       searchAttribute = @"dateStamp";
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat, searchAttribute, inputString];
    [self.searchFetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    self.searchResults = [[[DataManager sharedManager] managedObjectContext] executeFetchRequest:self.searchFetchRequest error:&error];
    if (error)
    {
        NSLog(@"searchFetchRequest failed: %@",[error localizedDescription]);
    }
}

- (NSFetchRequest *)searchFetchRequest
{
    if (_searchFetchRequest != nil)
    {
        return _searchFetchRequest;
    }
    
    NSManagedObjectContext *sharedContext = [[DataManager sharedManager] managedObjectContext];
    
    _searchFetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Image" inManagedObjectContext:sharedContext];
    
    [_searchFetchRequest setEntity:entity];
    
    
    //to sort
    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"displayOrder" ascending:YES];
  //  NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"grade" ascending:YES];
    [_searchFetchRequest setSortDescriptors:@[sortDescriptor1]];
    return _searchFetchRequest;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray *sectionArray = [self.fetchedResultsController sections];
    
    if (self.searchController.active) {
        return 1;
    }
    
    
    if (sectionArray == nil) {
        return 0;
    }
    return sectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.active) {
        return self.searchResults.count;
    }
    
    id  sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    self.numofFiles = [sectionInfo numberOfObjects];
    NSLog(@"Number of rows ********* = %lu", (unsigned long)self.numofFiles);
    
    
    return [sectionInfo numberOfObjects];

}


-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
   // id selectedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //id selectedObject = [self.results objectAtIndex:indexPath.row];
    
    id selectedObject = nil;
    
    if (self.searchController.active) {
        selectedObject = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        selectedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }

    
    if ([selectedObject isKindOfClass:[Image class]]) {
        Image *myImage = (Image *)selectedObject;
        cell.textLabel.text = myImage.dateStamp;
        cell.detailTextLabel.text = myImage.streetAdd;
        NSLog(@"Street Address = %@", myImage.streetAdd);
        // find Documents directory and append your local filename
        NSURL *documentsURL = [[[NSFileManager defaultManager]
                                URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSString *fileName = myImage.localURL;
        NSLog(@"file name ********** = %@",fileName);
        documentsURL = [documentsURL URLByAppendingPathComponent:fileName];
        NSLog(@"doc path *********** = %@", documentsURL);
        //NSData *myImageData = UIImagePNGRepresentation(selectedImage);
        //if the image is a video display frame at time 1
        if ([fileName containsString:@"mp4"])
        {
            MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc]
                                                    initWithContentURL:documentsURL];
            moviePlayer.shouldAutoplay = NO;
            UIImage *thumbnail = [moviePlayer thumbnailImageAtTime:1
                                                        timeOption:MPMovieTimeOptionNearestKeyFrame];
            cell.imageView.image = thumbnail;
        } else {
            cell.imageView.image = [UIImage imageWithContentsOfFile:documentsURL.path];
        }

       
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell" forIndexPath:indexPath];
        
        [self configureCell:cell atIndexPath:indexPath];
        
        return cell;
    }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    id selectedObject = nil;
    
    if (self.searchController.active) {
        selectedObject = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        selectedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    
    
    if ([selectedObject isKindOfClass:[Image class]]) {
        Image *myImage = (Image *)selectedObject;
        int myOrder = [ myImage.displayOrder intValue];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        DetailViewController *audioVC  = [storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
        audioVC.myOrder = myOrder;
        
     //   [self.tabBarController.tabBar setHidden:YES];
        
        [self.navigationController pushViewController:audioVC animated:YES];
        
    }
    
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the row from the data source
        id selectedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        [[DataManager sharedManager] delete:selectedObject];
        
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - UIImagePickerDelegate delegate methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"EEEE MM/dd hh a"];
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    NSLog(@"%@",dateString);
    
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    //   [self.imageView setImage:selectedImage];
  //  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Image" inManagedObjectContext:[[DataManager sharedManager] managedObjectContext]];
    
  //  Image *newImage = [[Image alloc] initWithEntity:entity insertIntoManagedObjectContext:[[DataManager sharedManager] managedObjectContext]];
    
    if (self.numofFiles < 1) {
        self.seqNum = [NSNumber numberWithInt:1];
    }else {
        self.seqNum = [NSNumber numberWithUnsignedInteger:self.numofFiles+1];
    }
    // find Documents directory and append your local filename
    NSURL *documentsURL = [[[NSFileManager defaultManager]
                            URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSData *myImageData ;
    NSString *fileName ;
    if (CFStringCompare((__bridge_retained CFStringRef)mediaType,kUTTypeImage,0) == kCFCompareEqualTo)
    {
        fileName = [NSString stringWithFormat:@"image%@.png",self.seqNum];
        documentsURL = [documentsURL URLByAppendingPathComponent:fileName];
        NSLog(@"doc path = %@", documentsURL);
        myImageData = UIImagePNGRepresentation(selectedImage);
    } else {
        fileName = [NSString stringWithFormat:@"movie%@.mp4",self.seqNum];
        documentsURL = [documentsURL URLByAppendingPathComponent:fileName];
        NSLog(@"doc path = %@", documentsURL);
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        myImageData = [NSData dataWithContentsOfURL:videoURL];
    }
    [myImageData writeToURL:documentsURL atomically:NO];
    
    NSString *streetAdd = [NSString stringWithFormat:@"%@ %@",self.myplacemark.subThoroughfare,self.myplacemark.thoroughfare];
    NSString *city = [NSString stringWithFormat:@"%@, %@ %@",self.myplacemark.subAdministrativeArea,self.myplacemark.administrativeArea,self.myplacemark.postalCode];
    //newImage.dateStamp = dateString;
    //newImage.displayOrder = self.seqNum;
    NSNumber *latitude = [NSNumber numberWithFloat:self.currentLocation.coordinate.latitude];
    NSNumber *longitude = [NSNumber numberWithFloat:self.currentLocation.coordinate.longitude];
    //newImage.localURL  = fileName;
    //newImage.audioURL = @"none";
    
    NSError *error = nil;
    NSDictionary *imageDict = @{@"streetAdd": streetAdd, @"city":city,@"dateStamp":dateString,@"displayOrder":self.seqNum,@"latitude":latitude,@"longitude":longitude,@"localURL":fileName,@"audioURL":@"none"};
    NSLog(@"Image Dict %@ ******* ", imageDict);
    if (![[DataManager sharedManager] addImageWithImageDict:imageDict withError:&error]) {
        NSLog(@"Unable to save image record.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    } else {
       [self fetchedResultsController];
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Image selected!");
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Picker cancelled without doing anything");
    }];
}

- (void) getAddressFromLatLon:(CLLocation *)bestLocation
{
    //  CLPlacemark __block *placemark;
    NSLog(@"calling reverse gecoder ***************** ");
    NSLog(@"%f %f", bestLocation.coordinate.latitude, bestLocation.coordinate.longitude);
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:bestLocation
                   completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error){
             NSLog(@"Geocode failed with error: %@", error);
             return;
         }
         self.myplacemark = [placemarks objectAtIndex:0];
         
         NSLog(@"placemark.ISOcountryCode %@",self.myplacemark.subThoroughfare);
         NSLog(@"locality %@",self.myplacemark.thoroughfare);
         NSLog(@"postalCode %@",self.myplacemark.postalCode);
     }];
}
#pragma mark - Fetched results delegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}



@end
