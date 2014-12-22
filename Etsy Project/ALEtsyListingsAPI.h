//
//  ALEtsyListingsAPI.h
//  Etsy Project
//
//  Created by Austin Lange on 12/21/14.
//  Copyright (c) 2014 Austin Lange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALEtsyAPIClient.h"

@class ALEtsyListing;

// A protocol...
@protocol ALEtsyListingsAPIDelegate <NSObject>

- (void)listingsAPIDidStartLoading;
- (void)listingsAPIDidEndLoading;
- (void)listingsAPILoadedItemsAtIndexPaths:(NSArray *)indexPaths;
- (void)listingsAPIError:(NSError *)error;

@end

@interface ALEtsyListingsAPI : NSObject

@property (nonatomic, strong) NSString *keywords;
@property (nonatomic, strong) NSDictionary *defaultParameters;

@property (nonatomic, strong, readonly) ALEtsyAPIResponse *lastResponse;

@property (nonatomic, weak) id <ALEtsyListingsAPIDelegate> delegate;

@property (nonatomic, readonly, getter=isLoading) BOOL loading;

// Creates a new listings API wrapper with the default client
+ (ALEtsyListingsAPI *)listingsAPI;

- (instancetype)initWithClient:(ALEtsyAPIClient *)client;
- (ALEtsyListing *)listingAtIndex:(NSUInteger)index;
- (NSUInteger)count;

- (void)clearCache;

@end


@interface ALEtsyListing : NSObject

@property (nonatomic) NSUInteger listingId;
@property (nonatomic) NSUInteger userId;
@property (nonatomic) NSUInteger categoryId;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSURL *image;

+ (ALEtsyListing *)listingFromJSONDictionary:(NSDictionary *)dictionary;

@end
