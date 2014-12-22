//
//  ALEtsyAPIResponse.m
//  Etsy Project
//
//  Created by Austin Lange on 12/21/14.
//  Copyright (c) 2014 Austin Lange. All rights reserved.
//

#import "ALEtsyAPIResponse.h"

@interface ALEtsyAPIResponse ()

@property (nonatomic, strong) NSArray *results;

@end

/**
 * ALEtsyAPIResponse encapsulates an API response as a native object. Responses
 * are created by the client and passed to the connection.
 */
@implementation ALEtsyAPIResponse

+ (instancetype)responseFromJSONDictionary:(NSDictionary *)dictionary;
{
    ALEtsyAPIResponse *response = [[ALEtsyAPIResponse alloc] initWithJSONDictionary:dictionary];
    
    return response;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary;
{
    self = [super init];
    if (!self) return nil;
    
    _type = [dictionary objectForKey:@"type"];
    _paging = [ALEtsyAPIPaging pagingFromJSONDictionary:[dictionary objectForKey:@"pagination"]];
    _results = [dictionary objectForKey:@"results"];
    
    return self;
}

@end

@implementation ALEtsyAPIPaging

+ (instancetype)pagingFromJSONDictionary:(NSDictionary *)dictionary;
{
    ALEtsyAPIPaging *paging = [[ALEtsyAPIPaging alloc] initWithJSONDictionary:dictionary];
    
    return paging;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary;
{
    self = [super init];
    if (!self) return nil;
    if (!dictionary || [dictionary count] == 0) return nil;
    
    _limit = [[dictionary objectForKey:@"effective_limit"] unsignedIntegerValue];
    _offset = [[dictionary objectForKey:@"effective_offset"] unsignedIntegerValue];
    _page = [[dictionary objectForKey:@"effective_page"] unsignedIntegerValue];
    
    if ([dictionary objectForKey:@"next_offset"] != [NSNull null]) {
        _nextOffset = [[dictionary objectForKey:@"next_offset"] unsignedIntegerValue];
    }
    
    if ([dictionary objectForKey:@"next_page"] != [NSNull null]) {
        _nextPage = [[dictionary objectForKey:@"next_page"] unsignedIntegerValue];
    }
    
    return self;
}

@end