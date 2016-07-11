//
//  DataManager.h
//  Lab1
//
//  Created by Eman Ghobrial on 4/8/16.
//  Copyright © 2016 Eman Ghobrial. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Image.h"

@interface DataManager : NSObject
+ (id)sharedManager;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
- (NSURL *)applicationDocumentsDirectory;

-(BOOL)addImageWithImageDict:(NSDictionary *)imageDict withError:(NSError **)error;

-(BOOL)updateImageWithImageDict:(NSString *)audioURL andImageObject:(NSManagedObject*)selectedObject withError:(NSError **)error;
@end
