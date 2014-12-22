//
//  ALEtsyAPIClient.h
//  Etsy Project
//
//  Created by Austin Lange on 12/20/14.
//  Copyright (c) 2014 Austin Lange. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "ALEtsyAPIResponse.h"

@class ALEtsyAPIPaging;

@interface ALEtsyAPIClient : AFHTTPSessionManager

@property (nonatomic, copy) NSString *key;

+ (instancetype)defaultClient;

- (NSURLSessionDataTask *)queryAPIEndpoint:(NSString *)endpoint withParameters:(NSDictionary *)params completion:(void(^)(ALEtsyAPIResponse *response))completion error:(void(^)(NSError *error))failure;

@end
