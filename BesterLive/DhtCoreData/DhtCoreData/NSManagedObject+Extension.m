//
//  NSManagedObject+Extension.m
//  DhtCoreData
//
//  Created by Nguyen Van Dung on 8/8/16.
//  Copyright © 2016 Dht. All rights reserved.
//

#import "NSManagedObject+Extension.h"
static id errorHandlerTarget = nil;
static SEL errorHandlerAction = nil;

@implementation NSManagedObject (dht)

+ (id)createInContext:(NSManagedObjectContext *)context {
    if ([self respondsToSelector:@selector(insertInManagedObjectContext:)]) {
        id entity = [self performSelector:@selector(insertInManagedObjectContext:) withObject:context];
        return entity;
    } else {
        return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
    }
}

+ (id)executeFetchRequestAndReturnFirstObject:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context {
    [request setFetchLimit:1];
    
    NSArray *results = [self executeFetchRequest:request inContext:context];
    if ([results count] == 0) {
        return nil;
    }
    return [results objectAtIndex:0];
}

+ (NSFetchRequest *)requestFirstWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [self createFetchRequestInContext:context];
    [request setPredicate:searchTerm];
    [request setFetchLimit:1];
    
    return request;
}

+ (id)findFirstWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [self requestFirstWithPredicate:searchTerm inContext:context];
    
    return [self executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (NSArray *)findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [self requestAllSortedBy:sortTerm
                                                ascending:ascending
                                            withPredicate:searchTerm
                                                inContext:context];
    
    return [self executeFetchRequest:request inContext:context];

}

+ (NSUInteger)countOfEntitiesWithContext:(NSManagedObjectContext *)context
{
    NSError *error = nil;
    NSUInteger count = [context countForFetchRequest:[self createFetchRequestInContext:context] error:&error];
    [self handleErrors:error];
    
    return count;
}


+ (NSFetchRequest *)requestAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self requestAllInContext:context];
    if (searchTerm)
    {
        [request setPredicate:searchTerm];
    }
    [request setFetchBatchSize: 20];
    
    NSMutableArray* sortDescriptors = [[NSMutableArray alloc] init];
    NSArray* sortKeys = [sortTerm componentsSeparatedByString:@","];
    for (NSString* sortKey in sortKeys)
    {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
        [sortDescriptors addObject:sortDescriptor];
    }
    
    [request setSortDescriptors:sortDescriptors];
    
    return request;
}

+ (NSFetchRequest *)requestAllInContext:(NSManagedObjectContext *)context
{
    return [self createFetchRequestInContext:context];
}

+ (NSFetchRequest *)createFetchRequestInContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[self MR_entityDescriptionInContext:context]];
    return request;
}

+ (NSEntityDescription *) MR_entityDescriptionInContext:(NSManagedObjectContext *)context {
    if ([self respondsToSelector:@selector(entityInManagedObjectContext:)]) {
        NSEntityDescription *entity = [self performSelector:@selector(entityInManagedObjectContext:) withObject:context];
        return entity;
    } else {
        NSString *entityName = [self entityName];
        return [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    }
}

+ (NSString *)entityName {
    NSString *name =  NSStringFromClass(self);
    return name;
}

+ (NSArray *)findAllWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [self createFetchRequestInContext:context];
    [request setPredicate:searchTerm];
    return [self executeFetchRequest: request inContext: context];
}

+ (NSArray *)executeFetchRequest:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context
{
    __block NSArray *results = nil;
    [context performBlockAndWait:^{
        
        NSError *error = nil;
        
        results = [context executeFetchRequest:request error:&error];
        
        if (results == nil)
        {
            [self handleErrors:error];
        }
        
    }];
    return results;
}

+ (void) handleErrors:(NSError *)error {
    if (error) {
        // If a custom error handler is set, call that
        if (errorHandlerTarget != nil && errorHandlerAction != nil) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [errorHandlerTarget performSelector:errorHandlerAction withObject:error];
#pragma clang diagnostic pop
        } else {
            // Otherwise, fall back to the default error handling
            [self defaultErrorHandler:error];
        }
    }
}

+ (void) defaultErrorHandler:(NSError *)error {
    NSDictionary *userInfo = [error userInfo];
    for (NSArray *detailedError in [userInfo allValues]) {
        if ([detailedError isKindOfClass:[NSArray class]]) {
            for (NSError *e in detailedError) {
                if ([e respondsToSelector:@selector(userInfo)]) {
                    NSLog(@"Error Details: %@", [e userInfo]);
                } else {
                    NSLog(@"Error Details: %@", e);
                }
            }
        } else {
            NSLog(@"Error: %@", detailedError);
        }
    }
    NSLog(@"Error Message: %@", [error localizedDescription]);
    NSLog(@"Error Domain: %@", [error domain]);
    NSLog(@"Recovery Suggestion: %@", [error localizedRecoverySuggestion]);
}
@end
