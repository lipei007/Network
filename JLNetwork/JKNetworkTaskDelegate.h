//
//  JKNetworkSessionDelegate.h
//  Test Upload Progress
//
//  Created by Jack on 2017/1/11.
//  Copyright © 2017年 mini1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKNetworkResult.h"

typedef void(^resultHandler)(JKNetworkResult *result);
typedef void(^progressHandler)(double progress);

typedef enum {
    
    TaskTypeData,
    TaskTypeUpload,
    TaskTypeDownload
    
} TaskType;


@interface JKNetworkTaskDelegate : NSObject <NSURLSessionDataDelegate,NSURLSessionDownloadDelegate>

@property (nonatomic,copy) progressHandler sendProgressHandler;
@property (nonatomic,copy) progressHandler recvProgressHandler;

@property (nonatomic,copy) resultHandler r;
@property (nonatomic,copy) id(^decryptHandler)(NSString *encryptString);
@property (nonatomic,copy) NSString *filePath;///<文件地址
@property (nonatomic,assign) TaskType type;

@property (nonatomic,weak) NSURLSessionTask *downloadTask;
@property (nonatomic,weak) NSURLSessionTask *uploadTask;
@property (nonatomic,weak) NSURLSessionTask *dataTask;

+ (instancetype)sharedInstance;

@end
