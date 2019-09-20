//
//  HttpRequestManager.m
//  cpsdna
//
//  Created by 黄 时欣 on 13-11-8.
//  Copyright (c) 2013年 黄 时欣. All rights reserved.
//

#import "HttpRequestManager.h"
#import "SysConfig.h"
#import "Macro.h"
#import "OFFileManager.h"

#define RequestTimeOutSeconds 60

#define finishedLog(request)																																																																																												\
	{																																																																																																		\
		NSLog(@"====== request finished =====tag:%ld  \n ========= cost:%.3f s   compress:%@  rawSize:%lu   size:%ld   ========= \n%@", (long)request.tag, [[NSDate date] timeIntervalSinceDate:[request userInfoObjectForKey:@"StartDate"]], request.isResponseCompressed ? @"Yes" : @"No", (long)[request.rawResponseData length], (unsigned long)[request.responseData length], request.responseString);	\
	}																																																																																																		\

#define failedLog(request)																		  \
	{																							  \
		NSLog(@"======= request failed ======tag:%ld  \n\n%@", (long)request.tag, request.error); \
	}																							  \

@interface HttpRequestManager () <ASIHTTPRequestDelegate>

@property (nonatomic, strong) ASINetworkQueue *requestQueue;

@end

@implementation HttpRequestManager
SYNTHESIZE_SINGLETON_FOR_CLASS_M(HttpRequestManager);

+ (void)initialize
{
    [ASIHTTPRequest setDefaultTimeOutSeconds:RequestTimeOutSeconds];
	RequestManager.requestQueue = [ASINetworkQueue queue];
	[RequestManager.requestQueue setShouldCancelAllRequestsOnFailure:NO];
	[RequestManager.requestQueue setMaxConcurrentOperationCount:5];
	[RequestManager.requestQueue setShowAccurateProgress:YES];
	RequestManager.requestQueue.delegate = RequestManager;
    RequestManager.requestQueue.requestDidStartSelector		= @selector(requestStarted:);
	RequestManager.requestQueue.requestDidFailSelector		= @selector(requestFailed:);
	RequestManager.requestQueue.requestDidFinishSelector	= @selector(requestFinished:);
	[RequestManager.requestQueue go];
}

- (void)dealloc
{
	[_requestQueue cancelAllOperations];
}

- (ASIHTTPRequest *)startRequestWithDict:(NSDictionary *)jsonDict
{
	return [self startRequestWithDict:jsonDict url:kBASE_URL];
}

- (ASIHTTPRequest *)startRequestWithDict:(NSDictionary *)jsonDict block:(RequestManagerBlock)block
{
	return [self startRequestWithDict:jsonDict url:kBASE_URL block:block];
}

- (ASIHTTPRequest *)startRequestWithDict:(NSDictionary *)jsonDict url:(NSString *)url
{
	return [self startRequestWithDict:jsonDict url:url block:nil];
}

- (ASIHTTPRequest *)startRequestWithDict:(NSDictionary *)jsonDict url:(NSString *)url block:(RequestManagerBlock)block
{
	NSAssert([NSJSONSerialization isValidJSONObject:jsonDict], @"the param jsonDict must be valid jsonobject.");

	ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:url]];

	[request setTimeOutSeconds:RequestTimeOutSeconds];
	[request setRequestMethod:@"POST"];
	[request setRequestHeaders:[NSMutableDictionary dictionaryWithDictionary:@{@"Content-Type": @"application/json; charset=UTF-8", @"Accept-Encoding":@"gzip, deflate"}]];

	NSError *error		= nil;
	NSData	*jsonData	= [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];

	[request appendPostData:jsonData];

	if (block) {
		[request addUserInfoObject:block forKey:@"block"];
	}

	[_requestQueue addOperation:request];
	return request;
}

- (ASIHTTPRequest *)startGetRequestWithUrl:(NSString *)url
{
	return [self startGetRequestWithUrl:url block:nil];
}

- (ASIHTTPRequest *)startGetRequestWithUrl:(NSString *)url block:(RequestManagerBlock)block
{
	ASIHTTPRequest		*request	= [[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:url]];
	NSStringEncoding	enc			= CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);

	[request setDefaultResponseEncoding:enc];

	[request setTimeOutSeconds:RequestTimeOutSeconds];
	[request setRequestMethod:@"GET"];
	[request setRequestHeaders:[NSMutableDictionary dictionaryWithDictionary:@{@"Content-Type": @"application/json; charset=UTF-8", @"Accept-Encoding":@"gzip, deflate"}]];

	if (block) {
		[request addUserInfoObject:block forKey:@"block"];
	}

	[_requestQueue addOperation:request];
	return request;
}

- (ASIHTTPRequest *)startDownloadWithUrl:(NSString *)url destinationPath:(NSString *)path progressDelegate:(id)progress showAccurateProgress:(BOOL)show completionBlock:(RequestManagerBlock)block
{
	[OFFileManager createDirectoriesForFileAtPath:path];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
	[request setDownloadDestinationPath:path];
	[request setShowAccurateProgress:show];
	[request setDownloadProgressDelegate:progress];

	if (block) {
		[request addUserInfoObject:block forKey:@"block"];
	}

	[_requestQueue addOperation:request];
	return request;
}

- (void)requestStarted:(ASIHTTPRequest *)request
{
    if([request.requestMethod.uppercaseString isEqualToString:@"GET"]){
        NSLog(@"************* start get request with url: %@ ***********", request.url);
    }else if ([request.requestMethod.uppercaseString isEqualToString:@"POST"]){
        NSLog(@"************* start post request with url: %@ ***********", request.url);
        NSLog(@"************* post body ***********\n%@\n", [[NSString alloc] initWithData:request.postBody encoding:NSUTF8StringEncoding]);
    }
	[request addUserInfoObject:[NSDate date] forKey:@"StartDate"];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	failedLog(request);

	RequestManagerBlock block = [request userInfoObjectForKey:@"block"];

	if (block) {
		block(request, NO);
	} else {
		postNotification(kN_MANAGER_REQUEST_CALLBACK, request);
	}
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	finishedLog(request);
	RequestManagerBlock block = [request userInfoObjectForKey:@"block"];

	if (block) {
		block(request, YES);
	} else {
		postNotification(kN_MANAGER_REQUEST_CALLBACK, request);
	}
}

@end

@implementation ASIHTTPRequest (Oxygen)

- (void)addUserInfoObject:(id)obj forKey:(NSString *)key
{
	if (obj) {
		if (self.userInfo) {
			NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
			[dict setObject:obj forKey:key];
			self.userInfo = dict;
		} else {
			self.userInfo = @{key:obj};
		}
	}
}

- (id)userInfoObjectForKey:(NSString *)key
{
	if ([NSString isStringEmptyOrBlank:key]) {
		return nil;
	}

	return self.userInfo[key];
}

- (NSDictionary *)paramDictionary
{
	NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:self.postBody options:kNilOptions error:nil];

	return dict;
}

@end

