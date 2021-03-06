//
//  ProxyDelegate.m
//  NetworkTracker
//
//  Created by xzj on 16/8/4.
//  Copyright © 2016年 xzj. All rights reserved.
//

#import "NTProxyDelegate.h"
#import "NTTrackerManager.h"

@interface NTProxyDelegate ()
@property (nonatomic, strong) NSMutableData *data;

@end

@implementation NTProxyDelegate

- (instancetype)init {
    if (self = [super init]) {
        _httpModel = [NTHTTPModel new];
        _data = [NSMutableData data];
        NSLog(@"ProxyDelegate init");
    }
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(connection:didReceiveResponse:)) {
        return YES;
    }
    if (aSelector == @selector(connection:didReceiveResponse:)) {
        return YES;
    }
    if (aSelector == @selector(connectionDidFinishLoading:)) {
        return YES;
    }
    if (aSelector == @selector(URLSession:dataTask:didReceiveData:)) {
        return YES;
    }
    if (aSelector == @selector(URLSession:dataTask:didReceiveResponse:completionHandler:)) {
        return YES;
    }
    if (aSelector == @selector(URLSession:task:didCompleteWithError:)) {
        return YES;
    }
    return [self.hookDelegate respondsToSelector:aSelector] ;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [self.hookDelegate methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    [anInvocation invokeWithTarget:self.hookDelegate];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (void)saveModel {
    [_httpModel setEndTime:[NSDate date].timeIntervalSince1970];
    [_httpModel setResponse:self.response];
    [_httpModel setData:self.data];
    
    [[NTTrackerManager shareInstance]addHTTPModel:_httpModel];
}



#pragma mark - NSURLConnectionDataDelgate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.response = (NSHTTPURLResponse *)response;
    if ([self.hookDelegate respondsToSelector:@selector(connection:didReceiveResponse:)]) {
        [self.hookDelegate connection:connection didReceiveResponse:response];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.data appendData:data];
    if ([self.hookDelegate respondsToSelector:@selector(connection:didReceiveData:)]) {
        [self.hookDelegate connection:connection didReceiveData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [self saveModel];
    
    if ([self.hookDelegate respondsToSelector:@selector(connectionDidFinishLoading:)]) {
        [self.hookDelegate connectionDidFinishLoading:connection];
    }
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    self.response = (NSHTTPURLResponse *)response;
    completionHandler(NSURLSessionResponseAllow);
    
    if ([self.hookDelegate respondsToSelector:@selector(URLSession:dataTask:didReceiveResponse:completionHandler:)]) {
        [self.hookDelegate URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.data appendData:data];
    
    if ([self.hookDelegate respondsToSelector:@selector(URLSession:dataTask:didReceiveData:)]) {
        [self.hookDelegate URLSession:session dataTask:dataTask didReceiveData:data];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    [self saveModel];
    
    if ([self.hookDelegate respondsToSelector:@selector(URLSession:task:didCompleteWithError:)]) {
        [self.hookDelegate URLSession:session task:task didCompleteWithError:error];
    }
    [session setProxyDelegate:nil];
}
@end
