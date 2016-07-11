//
//  DataManager.m
//  Lab1
//
//  Created by Eman Ghobrial on 4/8/16.
//  Copyright © 2016 Eman Ghobrial. All rights reserved.
//

#import "DataManager.h"
@interface DataManager ()

- (NSURL *)applicationDocumentsDirectory;

@end

@implementation DataManager
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (id)sharedManager {
    static DataManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "org.eghobrial.Lab1" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"photosmemories" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"photosmemories.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

-(BOOL)addImageWithImageDict:(NSDictionary *)imageDict withError:(NSError **)error
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Image" inManagedObjectContext:self.managedObjectContext];
    
    Image *newImage = [[Image alloc] initWithEntity:entity insertIntoManagedObjectContext:[[DataManager sharedManager] managedObjectContext]];
    newImage.dateStamp = [imageDict objectForKey:@"dateStamp"] ? [imageDict objectForKey:@"dateStamp"]: @"";
    newImage.displayOrder = [imageDict objectForKey:@"displayOrder"] ? [imageDict objectForKey:@"displayOrder"]: @"";
    newImage.latitude = [imageDict objectForKey:@"latitude"] ? [imageDict objectForKey:@"latitude"]: @"";
    newImage.localURL = [imageDict objectForKey:@"localURL"] ? [imageDict objectForKey:@"localURL"]: @"";
    newImage.longitude = [imageDict objectForKey:@"longitude"] ? [imageDict objectForKey:@"longitude"]: @"";
    newImage.streetAdd= [imageDict objectForKey:@"streetAdd"] ? [imageDict objectForKey:@"streetAdd"]: @"";
    newImage.city= [imageDict objectForKey:@"city"] ? [imageDict objectForKey:@"city"]: @"";
    newImage.audioURL= [imageDict objectForKey:@"audioURL"] ? [imageDict objectForKey:@"audioURL"]: @"";
    
    NSLog(@"Image file name off Data Manager *** %@",[imageDict objectForKey:@"localURL"]  );
    
    NSError *myError = nil;
    if (![self.managedObjectContext save:&myError]) {
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", myError, myError.localizedDescription);
        
        //error = &[myError copy];
        
        return false;
    } else {
        return true;
    }

}

-(BOOL)updateImageWithImageDict:(NSString *)audioURL andImageObject:(NSManagedObject*)selectedObject withError:(NSError **)error
{
    Image *myImage;
    if ([selectedObject isKindOfClass:[Image class]]) {
        myImage = (Image *)selectedObject;
    }
        myImage.audioURL= audioURL;
        
        NSLog(@"Image audio file name off Data Manager *** %@",audioURL);
        
        NSError *myError = nil;
        if (![self.managedObjectContext save:&myError]) {
            NSLog(@"Unable to save managed object context.");
            NSLog(@"%@, %@", myError, myError.localizedDescription);
            //error = &[myError copy];
            return false;
        } else {
            return true;
        }
    
    
}

-(void)delete:(NSManagedObject *)selectedObject {
    
    if ([selectedObject isKindOfClass:[Image class]]) {
        Image *myImage = (Image *)selectedObject;
        
        [[[DataManager sharedManager] managedObjectContext] deleteObject:myImage];
        
        NSError *error = nil;
        
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Unable to save managed object context.");
            NSLog(@"%@, %@", error, error.localizedDescription);
        }
        
    }
}

@end
