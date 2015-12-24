//
//  APIDataFetcher.m
//  APITest
//
//  Created by Admin on 9/5/15.
//  Copyright (c) 2015 IphoneGameZone. All rights reserved.
//

#import "APIDataFetcher.h"

static NSOperationQueue * _connectionQueue = nil;
static SuccessBlock _successBlock;
static FailureBlock _failureBlock;

@implementation APIDataFetcher

+ (NSOperationQueue *) connectionQueue
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_connectionQueue)
        {
            _connectionQueue = [[NSOperationQueue alloc] init];
        }
    });
    return _connectionQueue;
}

+ (void) loadDataFromAPI : (NSString *) url : (SuccessBlock) successBlock :(FailureBlock) failureBlock
{
    _successBlock = successBlock;
    _failureBlock = failureBlock;
    
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [NSURLConnection sendAsynchronousRequest:request queue:[self connectionQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (response != nil)
         {
             if ([[self acceptableStatusCodes] containsIndex:[(NSHTTPURLResponse *)response statusCode] ])
             {
                 if ([data length] > 0)
                 {
                     NSError *jsonError  = nil;
                     id jsonObject  = nil;
                     
                     jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                     
                     if (jsonObject != nil)
                     {
                         if ([jsonObject respondsToSelector:@selector(setObject:forKey:)])
                         {
                             [self presentData:jsonObject];
                         }
                         else
                         {
                             [self presentError:jsonError];
                         }
                     }
                     else
                     {
                         [self presentError:jsonError];
                     }
                 }
                 else
                 {
                     [self presentError:nil];
                 }
             }
             else
             {
                 [self presentError:nil];
             }
         }
        else
        {
             [self presentError:connectionError];
        }
     }];
}

+ (NSIndexSet *) acceptableStatusCodes
{
    return [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 99)];
}

+ (void) presentData:(id)jsonObject
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:
     ^{
         _successBlock(jsonObject);
     }];
}

+ (void) presentError:(NSError *)error
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:
     ^{
        _failureBlock(error);
    }];
}
@end
