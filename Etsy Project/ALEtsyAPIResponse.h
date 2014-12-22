//
//  ALEtsyAPIResponse.h
//  Etsy Project
//
//  Created by Austin Lange on 12/21/14.
//  Copyright (c) 2014 Austin Lange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ALEtsyAPIPaging;

@interface ALEtsyAPIResponse : NSObject

@property (nonatomic, strong, readonly) NSArray *results;

@property (nonatomic, strong, readonly) ALEtsyAPIPaging *paging;
@property (nonatomic, strong, readonly) NSString *type;

+ (instancetype)responseFromJSONDictionary:(NSDictionary *)dictionary;

@end

@interface ALEtsyAPIPaging : NSObject

@property (nonatomic, readonly) NSUInteger limit;
@property (nonatomic, readonly) NSUInteger offset;
@property (nonatomic, readonly) NSUInteger page;

@property (nonatomic, readonly) NSUInteger nextOffset;
@property (nonatomic, readonly) NSUInteger nextPage;

+ (instancetype)pagingFromJSONDictionary:(NSDictionary *)dictionary;

@end
