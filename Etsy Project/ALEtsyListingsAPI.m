//
//  ALEtsyListingsAPI.m
//  Etsy Project
//
//  Created by Austin Lange on 12/21/14.
//  Copyright (c) 2014 Austin Lange. All rights reserved.
//

#import "ALEtsyListingsAPI.h"

#define ACTIVE_LISTINGS_ENDPOINT @"/v2/listings/active"

@interface  ALEtsyListingsAPI ()

@property (nonatomic, strong) ALEtsyAPIClient *client;
@property (nonatomic, strong) NSArray *results;
@property (nonatomic, strong) NSURLSessionDataTask *currentTask;

@end

@implementation ALEtsyListingsAPI

@synthesize keywords = _keywords;

/**
 * Creates and returns a new listings API connection with the default client.
 *
 */
+ (ALEtsyListingsAPI *)listingsAPI;
{
    return [[ALEtsyListingsAPI alloc] initWithClient:[ALEtsyAPIClient defaultClient]];
}

/**
 * Initializes a new listings API connection with a client.
 *
 */
- (instancetype)initWithClient:(ALEtsyAPIClient *)client;
{
    self = [super init];
    if (!self) return nil;
    if (!client) return nil;
    
    self.client = client;
    
    return self;
}

/**
 * Get the current keywords on this connection.
 *
 */
- (NSString *)keywords;
{
    return _keywords;
}

/**
 * Set the connection's keywords.
 *
 */
- (void)setKeywords:(NSString *)keywords;
{
    if ([keywords isEqualToString:_keywords]) return;
    
    _keywords = keywords;
    
    if ([self isLoading]) {
        [self.currentTask cancel];
    }
    
    [self clearCache];
    [self loadPage:1];
}

- (NSUInteger)count;
{
    if (self.lastResponse) {
        if ([self.results count] < self.lastResponse.paging.limit) {
            return [self.results count];
        } else {
            return self.lastResponse.paging.offset + self.lastResponse.paging.limit;
        }
    } else {
        return 0;
    }
}

- (NSArray *)results;
{
    if (!_results) {
        _results = [NSArray array];
    }
    
    return _results;
}

- (void)clearCache;
{
    self.results = nil;
}

- (NSDictionary *)defaultParameters;
{
    return @{ @"page": @1, @"limit": @20, @"includes": @"MainImage" };
}

- (ALEtsyListing *)listingAtIndex:(NSUInteger)index;
{
    ALEtsyListing *listing;
    
    // if it's stored in our internal array, return it
    if (index < [self.results count]) {
        listing = [self.results objectAtIndex:index];

        if (index >= self.lastResponse.paging.offset + (self.lastResponse.paging.limit * 0.5)) {
            [self loadNextPage];
        }
        
    }
    // if not, it might be in our raw response
    else if (index >= self.lastResponse.paging.offset && index < self.lastResponse.paging.offset + self.lastResponse.paging.limit) {
        NSInteger adjustedIndex = index - self.lastResponse.paging.offset;
        
        if (adjustedIndex < [self.lastResponse.results count]) {
            listing = [ALEtsyListing listingFromJSONDictionary:[self.lastResponse.results objectAtIndex:adjustedIndex]];
        }
        
        if (adjustedIndex >= self.lastResponse.paging.offset + (self.lastResponse.paging.limit * 0.5)) {
            [self loadNextPage];
        }
    }
    // if it's in neither, attempt to load the page the index is on
    else {
        NSUInteger page = (index / [[self.defaultParameters objectForKey:@"limit"] integerValue]) + 1;
        [self loadPage:page];
    }
    
    return listing;
}

- (void)loadPage:(NSUInteger)page;
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:self.defaultParameters];
    [parameters setObject:self.keywords forKey:@"keywords"];

    [parameters setObject:@(page) forKey:@"page"];
    
    if (self.lastResponse) {
        [parameters setObject:@(self.lastResponse.paging.limit) forKey:@"limit"];
    }
    
    [self loadWithParameters:parameters];
}

- (void)loadNextPage;
{
    if (!self.lastResponse) {
        [self loadPage:1];
    } else if (self.lastResponse.paging.nextPage > 0) {
        [self loadPage:self.lastResponse.paging.nextPage];
    }
}

- (void)setLastResponse:(ALEtsyAPIResponse *)lastResponse;
{
    _lastResponse = lastResponse;
}

- (BOOL)isLoading;
{
    return self.currentTask && self.currentTask.state == NSURLSessionTaskStateRunning;
}

- (void)loadWithParameters:(NSDictionary *)parameters;
{
    if ([self isLoading]) return;
    
    [self.delegate listingsAPIDidStartLoading];
    
    __weak typeof (self) weakSelf = self;
    
    self.currentTask = [self.client queryAPIEndpoint:ACTIVE_LISTINGS_ENDPOINT withParameters:parameters completion:^(ALEtsyAPIResponse *response) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        
        strongSelf.lastResponse = response;
        
        NSMutableArray *results = [NSMutableArray array];
        
        for (NSDictionary *result in self.lastResponse.results) {
            [results addObject:[ALEtsyListing listingFromJSONDictionary:result]];
        }
        
        strongSelf.results = [strongSelf.results arrayByAddingObjectsFromArray:results];
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        
        for (NSUInteger i = strongSelf.lastResponse.paging.offset; i < strongSelf.lastResponse.paging.offset + strongSelf.lastResponse.paging.limit; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
        }
        
        [strongSelf.delegate listingsAPILoadedItemsAtIndexPaths:indexPaths];
        [strongSelf.delegate listingsAPIDidEndLoading];
    } error:^(NSError *error) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        
        [strongSelf.delegate listingsAPIError:error];
        [strongSelf.delegate listingsAPIDidEndLoading];
    }];
}

@end

@implementation ALEtsyListing

+ (ALEtsyListing *)listingFromJSONDictionary:(NSDictionary *)dictionary;
{
    ALEtsyListing *listing = [[ALEtsyListing alloc] initWithJSONDictionary:dictionary];
    
    return listing;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary;
{
    self = [super init];
    if (!self) return nil;
    
    _listingId = [[dictionary objectForKey:@"listing_id"] unsignedIntegerValue];
    _userId = [[dictionary objectForKey:@"user_id"] unsignedIntegerValue];
    _categoryId = [[dictionary objectForKey:@"category_id"] unsignedIntegerValue];
    
    _title = [dictionary objectForKey:@"title"];
    
    if ([dictionary objectForKey:@"MainImage"]) {
        _image = [NSURL URLWithString:[[dictionary objectForKey:@"MainImage"] objectForKey:@"url_170x135"]];
    }
    
    return self;
}

@end
