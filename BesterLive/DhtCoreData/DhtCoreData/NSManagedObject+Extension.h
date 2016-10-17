//
//  NSManagedObject+Extension.h
//  DhtCoreData
//
//  Created by Nguyen Van Dung on 8/8/16.
//  Copyright © 2016 Dht. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface NSManagedObject (dht)
+ (id)findFirstWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context;
+ (NSArray *)findAllWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context;
+ (id)createInContext:(NSManagedObjectContext *)context;
+ (NSArray *)findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context;
+ (NSUInteger)countOfEntitiesWithContext:(NSManagedObjectContext *)context;
@end
