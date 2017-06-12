//
//  JKNetwork.h
//  Test Upload Progress
//
//  Created by Jack on 2017/1/11.
//  Copyright © 2017年 mini1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKNetworkTaskDelegate.h"


typedef enum {
    
    MIME_TYPE_TEXT_PLAIN,
    MIME_TYPE_IMAGE_JPEG,
    MIME_TYPE_IMAGE_PNG,
    MIME_TYPE_APPLICATION_PDF,
    MIME_TYPE_APPLICATION_ZIP,

} MIME_TYPE;


extern NSString *MethodPost;
extern NSString *MethodGet;

@interface JKNetwork : NSObject

+ (NSURLSessionTask *)dataTaskWithURL:(NSString *)urlString Method:(NSString *)method Params:(NSDictionary *)params progressHandler:(progressHandler)p completionHandler:(resultHandler)r;

/**
 上传

 @param filePath 本地文件路径
 @param type 文件类型
 @param params 所需上传参数
 @param url 服务器地址
 @param r 结果处理Block
 @param p 进度Block
 @param decrypt 解密Block
 @return Task
 */
+ (NSURLSessionTask *)upload:(NSString *)filePath MimeType:(MIME_TYPE)type Params:(NSDictionary *)params ToHost:(NSString *)url Result:(resultHandler)r Progress:(progressHandler)p DecryptHandler:(id(^)(NSString *result))decrypt;

/**
 上传
 
 @param filePath 本地文件路径
 @param type 文件类型
 @param params 所需上传参数
 @param url 服务器地址
 @param r 结果处理Block
 @param p 进度Block
 @return Task
 */
+ (NSURLSessionTask *)upload:(NSString *)filePath MimeType:(MIME_TYPE)type Params:(NSDictionary *)params ToHost:(NSString *)url Result:(resultHandler)r Progress:(progressHandler)p;


/**
 下载文件，不用接收文件下载失败返回提示

 @param param 下载上行参数
 @param url 下载地址
 @param method 请求方法
 @param path 文件保存路径,可以是文件所在文件夹路径
 @param progressHandler 下载进度
 @param result 下载结束回调Block
 @return Task
 */
+ (NSURLSessionTask *)fileDownloadParam:(NSDictionary *)param from:(NSString *)url method:(NSString *)method toPath:(NSString *)path progressHandler:(progressHandler)progressHandler completionHandler:(resultHandler)result;

/**
 下载文件，接收文件下载失败返回提示
 
 @param param 下载上行参数
 @param url 下载地址
 @param method 请求方法
 @param path 文件保存路径,可以是文件所在文件夹路径
 @param progressHandler 下载进度
 @param result 下载结束回调Block
 @return Task
 */
+ (NSURLSessionTask *)dataDownloadParam:(NSDictionary *)param from:(NSString *)url method:(NSString *)method toPath:(NSString *)path progressHandler:(progressHandler)progressHandler completionHandler:(resultHandler)result;

+ (NSURLSessionTask *)downloadFile:(BOOL)needDecodeStr offset:(NSUInteger)offset Param:(NSDictionary *)param from:(NSString *)url method:(NSString *)method toPath:(NSString *)path progressHandler:(progressHandler)progressHandler completionHandler:(resultHandler)result;

@end
