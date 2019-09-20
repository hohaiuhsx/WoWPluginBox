//
//  NSObject+HTTPRequest.h
//  cpsdna
//
//  Created by 黄 时欣 on 13-11-11.
//  Copyright (c) 2013年 黄 时欣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ASIHTTPRequest.h>
#import "HttpRequestManager.h"

typedef void (^ RequestCompleteBlock)(ASIHTTPRequest *request, NSDictionary *dict, NSError *error);

@interface NSObject (HTTPRequest)

- (NSString *)requestUUID;
- (void)registerRequestManagerObserver;
- (void)unregisterRequestManagerObserver;

//POST
- (ASIHTTPRequest *)startRequestWithDict:(NSDictionary *)jsonDict tag:(NSInteger)tag;
- (ASIHTTPRequest *)startRequestWithDict:(NSDictionary *)jsonDict tag:(NSInteger)tag url:(NSString *)url;

- (ASIHTTPRequest *)startRequestWithDict:(NSDictionary *)jsonDict completeBlock:(RequestCompleteBlock)block;
- (ASIHTTPRequest *)startRequestWithDict:(NSDictionary *)jsonDict completeBlock:(RequestCompleteBlock)block url:(NSString *)url;

//GET
- (ASIHTTPRequest *)startGetRequestWithUrl:(NSString *)url tag:(NSInteger)tag;
- (ASIHTTPRequest *)startGetRequestWithUrl:(NSString *)url completeBlock:(RequestCompleteBlock)block;

//DOWNLOAD
- (ASIHTTPRequest *)startDownloadWithUrl:(NSString *)url destinationPath:(NSString *)path progressDelegate:(id)progress showAccurateProgress:(BOOL)show completionBlock:(RequestManagerBlock)block;

//CallBack Method
- (void)request:(ASIHTTPRequest *)request failedWithError:(NSError *)error;
- (void)request:(ASIHTTPRequest *)request successedWithDictionary:(NSDictionary *)dict;

@end

