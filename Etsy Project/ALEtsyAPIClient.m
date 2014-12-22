//
//  ALEtsyAPIClient.m
//  Etsy Project
//
//  Created by Austin Lange on 12/20/14.
//  Copyright (c) 2014 Austin Lange. All rights reserved.
//

#import "ALEtsyAPIClient.h"

@interface ALEtsyAPIClient ()

@end

@implementation ALEtsyAPIClient

static ALEtsyAPIClient *defaultClient;

+ (instancetype)defaultClient;
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultClient = [[ALEtsyAPIClient alloc] init];
    });
    
    return defaultClient;
}

- (instancetype)init;
{
    self = [super initWithBaseURL:[NSURL URLWithString:@"https://api.etsy.com/v2/"]];
    if (!self) return nil;
    
    self.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    
    return self;
}

- (NSURLSessionDataTask *)queryAPIEndpoint:(NSString *)endpoint withParameters:(NSDictionary *)params completion:(void(^)(ALEtsyAPIResponse *response))completion error:(void(^)(NSError *error))failure;
{
    return [self GET:endpoint parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        // process our response object, which should be an NSDictionary parsed
        // from the JSON response.
        if (!responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(nil);
            });
            
            return;
        }
        
        ALEtsyAPIResponse *response = [ALEtsyAPIResponse responseFromJSONDictionary:responseObject];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(response);
        });
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (error.code == -999) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            failure(error);
        });
    }];

}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLResponse *, id, NSError *))completionHandler;
{
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    
    if ([mutableRequest.HTTPMethod isEqualToString:@"GET"]) {
        NSURLComponents *components = [NSURLComponents componentsWithURL:mutableRequest.URL resolvingAgainstBaseURL:YES];
        components.query = [components.query stringByAppendingFormat:@"&api_key=%@", self.key];
        
        mutableRequest.URL = [components URL];
    }
    
    NSLog(@"Fetching %@", mutableRequest.URL);
    
    return [super dataTaskWithRequest:mutableRequest completionHandler:completionHandler];
}
    

@end
