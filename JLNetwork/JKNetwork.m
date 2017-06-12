//
//  JKNetwork.m
//  Test Upload Progress
//
//  Created by Jack on 2017/1/11.
//  Copyright © 2017年 mini1. All rights reserved.
//

#import "JKNetwork.h"


#define JSON_TIMEOUT 600
#define BOUNDARY @"AaB03x"

NSString *MethodPost = @"POST";
NSString *MethodGet = @"GET";

@implementation JKNetwork


+ (NSURLSession *)standSession {
    
    NSURLSession *session = nil;
    
    JKNetworkTaskDelegate *delegate = [JKNetworkTaskDelegate sharedInstance];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//    config.timeoutIntervalForRequest = JSON_TIMEOUT;
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    session = [NSURLSession sessionWithConfiguration:config delegate:delegate delegateQueue:queue];
    
    return session;
}

+ (NSString *)mimeType:(MIME_TYPE)type {
    
    switch (type) {
        case MIME_TYPE_TEXT_PLAIN: {
            return @"text/plain";
        }
            break;
        case MIME_TYPE_IMAGE_PNG: {
            return @"image/png";
        }
            break;
        case MIME_TYPE_IMAGE_JPEG: {
            return @"image/jpeg";
        }
            break;
        case MIME_TYPE_APPLICATION_PDF: {
            return @"application/pdf";
        }
            break;
        case MIME_TYPE_APPLICATION_ZIP: {
            return @"application/zip";
        }
            break;
            
        default:
            return nil;
            break;
    }
    return nil;
}

+ (NSString *)stringParam:(NSDictionary *)params {
 
    if (params && params.allValues.count > 0) {
        
        __block NSMutableArray *paramArr = [NSMutableArray array];
        
        [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
            [paramArr addObject:[NSString stringWithFormat:@"%@=%@",key,obj]];
        
        }];
        
        NSString *paramStr = [paramArr componentsJoinedByString:@"&"];
        
        return paramStr;
        
    }
    return nil;
}

+ (void)configSessionDelegate:(JKNetworkTaskDelegate *)delegate CompletionHandler:(resultHandler)r recvProgressHandler:(progressHandler)recvP sendProgressHandler:(progressHandler)sendP {
    
    delegate.r = r;
    delegate.recvProgressHandler = recvP;
    delegate.sendProgressHandler = sendP;
    
}

#pragma mark - data task

+ (NSURLSessionTask *)dataTaskWithURL:(NSString *)urlString Method:(NSString *)method Params:(NSDictionary *)params progressHandler:(progressHandler)p completionHandler:(resultHandler)r {
    
    if (!urlString) {
        return nil;
    }
    
    NSString *paramString = [self stringParam:params];
    
    NSURL *url = nil;
    NSMutableURLRequest *req = nil;
    
    if ([method isEqualToString:MethodPost]) {
        
        url = [NSURL URLWithString:urlString];
        req = [NSMutableURLRequest requestWithURL:url];
        req.HTTPMethod = method;
        
        if (paramString) {
            req.HTTPBody = [paramString dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        
    } else {
        
        if (paramString) {
            urlString = [[urlString stringByAppendingFormat:@"?%@",paramString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        url = [NSURL URLWithString:urlString];
        req = [NSMutableURLRequest requestWithURL:url];
        
    }
    
    NSURLSession *session = [self standSession];
    
    JKNetworkTaskDelegate *delegate = nil;
    if (session.delegate) {
        if ([session.delegate isKindOfClass:[JKNetworkTaskDelegate class]]) {
            
            delegate = (JKNetworkTaskDelegate *)session.delegate;
            delegate.type = TaskTypeData;
            [self configSessionDelegate:delegate CompletionHandler:r recvProgressHandler:p sendProgressHandler:nil];
            
        }
    }
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:req];
    [task resume];
    
    return task;
    
}


#pragma mark - upload task

+ ( NSData *) fileData:(NSString *)path mimeType:(MIME_TYPE)type Params:(NSDictionary *)params {
    
    {
        
        NSString *fileName = [path lastPathComponent];
        
        NSMutableData *dataM = [NSMutableData data];
        
        NSMutableString *stringM = [NSMutableString string];
        
        for (NSString *key in params) {
            
            [stringM appendString:[NSString stringWithFormat:@"--%@\r\n",BOUNDARY]];
            [stringM appendFormat:@"Content-Type: text/plain; charset=UTF-8\r\n"];
            [stringM appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
            [stringM appendFormat:@"%@\r\n",[params objectForKey:key]];
        }
        
        [stringM appendString:[NSString stringWithFormat:@"--%@\r\n",BOUNDARY]];
        
        [stringM appendFormat:@"Content-Disposition: form-data; name=\"upfile\"; filename=%@\r\n",fileName];
        [stringM appendString:[NSString stringWithFormat:@"Content-Type: %@\r\n",[self mimeType:type]]];
        [stringM appendString:@"\r\n"];
        
        NSData *stringM_data = [stringM dataUsingEncoding:NSUTF8StringEncoding];
        [dataM appendData:stringM_data];
        
        NSData *file_data = [NSData dataWithContentsOfFile:path];
        [dataM appendData:file_data];
        
        NSString *end = [NSString stringWithFormat:@"\r\n--%@--",BOUNDARY];
        [dataM appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
        
        return dataM.copy;
    }
}

+ (NSURLSessionTask *)upload:(NSString *)filePath MimeType:(MIME_TYPE)type Params:(NSDictionary *)params ToHost:(NSString *)urlString Result:(resultHandler)r Progress:(progressHandler)p {

     return [self upload:filePath MimeType:type Params:params ToHost:urlString Result:r Progress:p DecryptHandler:nil];
}

+ (NSURLSessionTask *)upload:(NSString *)filePath MimeType:(MIME_TYPE)type Params:(NSDictionary *)params ToHost:(NSString *)urlString Result:(resultHandler)r Progress:(progressHandler)p DecryptHandler:(id (^)(NSString *))decrypt {
    
    // Data
    NSData *data = [self fileData:filePath mimeType:type Params:params];
    
    
    // 可变请求
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:url
                                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:JSON_TIMEOUT];
    // line note
    requestM.HTTPMethod = @"POST";
    
    // request header
    [requestM addValue:@"close" forHTTPHeaderField:@"Connection"];

    [requestM addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",BOUNDARY] forHTTPHeaderField:@"Content-Type"];
    
    [requestM addValue:[NSString stringWithFormat:@"%lu", (unsigned long)[data length]] forHTTPHeaderField:@"Content-Length"];
    
    // request body
    requestM.HTTPBody = data;
    
    
    
    NSURLSession *urlSession = [self standSession];
    
    JKNetworkTaskDelegate *delegate = nil;
    if (urlSession.delegate) {
        if ([urlSession.delegate isKindOfClass:[JKNetworkTaskDelegate class]]) {
            
            delegate = (JKNetworkTaskDelegate *)urlSession.delegate;
            delegate.type = TaskTypeUpload;
            if (p) {
                delegate.sendProgressHandler = p;
            }
            
            if (r) {
                delegate.r = r;
            }
            
            if (decrypt) {
                delegate.decryptHandler = decrypt;
            }
            
        }
    }
    
    NSURLSessionDataTask *dataTask = [urlSession uploadTaskWithRequest:requestM fromData:data];
    delegate.uploadTask = dataTask;
    
    [dataTask resume];

    return dataTask;
}

#pragma mark - download task

+ (NSURLSessionTask *)downloadFile:(BOOL)needDecodeStr offset:(NSUInteger)offset Param:(NSDictionary *)param from:(NSString *)url method:(NSString *)method toPath:(NSString *)path progressHandler:(progressHandler)progressHandler completionHandler:(resultHandler)result {
    
    
    
    NSURLSession *sessoin = [self standSession];
    
    JKNetworkTaskDelegate *sessionDelegate = nil;
    if (sessoin.delegate) {
        if ([sessoin.delegate isKindOfClass:[JKNetworkTaskDelegate class]]) {
            
            sessionDelegate = (JKNetworkTaskDelegate *)sessoin.delegate;
            sessionDelegate.type = TaskTypeDownload;
            sessionDelegate.filePath = path;
            sessionDelegate.r = result;
            sessionDelegate.recvProgressHandler = progressHandler;
        }
    }
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    req.HTTPMethod = method;
    
    if (offset > 0) {
        [req addValue:[NSString stringWithFormat:@"bytes=%ld-",(unsigned long)offset] forHTTPHeaderField:@"Range"];
    }
    
    // 拼接参数
    if (param && param.allValues.count > 0) {
        __block NSMutableArray *paramArr = [NSMutableArray array];
        [param enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [paramArr addObject:[NSString stringWithFormat:@"%@=%@",key,obj]];
        }];
        NSString *paramStr = [paramArr componentsJoinedByString:@"&"];
        
        req.HTTPBody = [paramStr dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    
    if (needDecodeStr) {
        
        NSURLSessionDataTask *downloadTask = [sessoin dataTaskWithRequest:req];
        sessionDelegate.downloadTask = downloadTask;
        
        [downloadTask resume];
        
        return downloadTask;
        
    } else {
        
        
        NSURLSessionDownloadTask *downloadTask = [sessoin downloadTaskWithRequest:req];
        sessionDelegate.downloadTask = downloadTask;
        [downloadTask resume];
        
        return downloadTask;
        
    }
    

    
}

+ (NSURLSessionTask *)downloadFile:(BOOL)needDecodeStr Param:(NSDictionary *)param from:(NSString *)url method:(NSString *)method toPath:(NSString *)path progressHandler:(progressHandler)progressHandler completionHandler:(resultHandler)result {
    
    return [self downloadFile:needDecodeStr offset:0 Param:param from:url method:method toPath:path progressHandler:progressHandler completionHandler:result];
    
}

+ (NSURLSessionTask *)fileDownloadParam:(NSDictionary *)param from:(NSString *)url method:(NSString *)method toPath:(NSString *)path progressHandler:(progressHandler)progressHandler completionHandler:(resultHandler)result {
    
    return [self downloadFile:NO Param:param from:url method:method toPath:path progressHandler:progressHandler completionHandler:result];
    
}

+ (NSURLSessionTask *)dataDownloadParam:(NSDictionary *)param from:(NSString *)url method:(NSString *)method toPath:(NSString *)path progressHandler:(progressHandler)progressHandler completionHandler:(resultHandler)result {
    
    return [self downloadFile:YES Param:param from:url method:method toPath:path progressHandler:progressHandler completionHandler:result];
    
}




@end
