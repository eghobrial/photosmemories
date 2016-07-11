//
//  Image+CoreDataProperties.h
//  Lab3
//
//  Created by Eman Ghobrial on 5/18/16.
//  Copyright © 2016 Eman Ghobrial. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Image.h"

NS_ASSUME_NONNULL_BEGIN

@interface Image (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *dateStamp;
@property (nullable, nonatomic, retain) NSNumber *displayOrder;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSString *localURL;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSString *streetAdd;
@property (nullable, nonatomic, retain) NSString *city;
@property (nullable, nonatomic, retain) NSString *audioURL;

@end

NS_ASSUME_NONNULL_END
