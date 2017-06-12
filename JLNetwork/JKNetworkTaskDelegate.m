//
//  JKNetworkSessionDelegate.m
//  Test Upload Progress
//
//  Created by Jack on 2017/1/11.
//  Copyright © 2017年 mini1. All rights reserved.
//

#import "JKNetworkTaskDelegate.h"
#import "JLFileStream.h"

@interface JKNetworkTaskDelegate ()

@property (nonatomic,strong) NSMutableData *recvData;
@property (nonatomic,strong) JKNetworkResult *result;
@property (nonatomic,strong) JLFileStream *fileStream;

@end

@implementation JKNetworkTaskDelegate

+ (instancetype)sharedInstance {
    JKNetworkTaskDelegate *obj = nil;
    obj = [[JKNetworkTaskDelegate alloc] init];
    obj.recvData = [NSMutableData data];
    obj.result = [[JKNetworkResult alloc] init];
    return obj;
}

- (void)setFilePath:(NSString *)filePath {
    
    _filePath = filePath;
    
    if (!filePath) {
        return;
    }
    
    NSError *err;
    BOOL isDir = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:_filePath isDirectory:&isDir];
    if (isDir) {
        
        _filePath = [self.filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.tmp",[NSUUID UUID].UUIDString]];
    
    } else {
        // 如果文件存在
        if ([[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
            
            [[NSFileManager defaultManager] removeItemAtPath:_filePath error:&err];
            if (err) {
                self.result.error = err;
            }
        }
    }
    
    
    
    if (_fileStream) {
        [_fileStream jl_closeWriter];
    }
    
    _fileStream = [JLFileStream jl_fileStreamOfPath:self.filePath];
    
}


#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {

    double progress = (double)totalBytesSent / totalBytesExpectedToSend;
    
    if (self.sendProgressHandler) {
        self.sendProgressHandler(progress);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {

    if (self.decryptHandler) {
        
        self.result.decryptHandler = self.decryptHandler;
        
    }
    
    
    if (error) {

        self.result.error = error;
                
    } else {
        
        if (self.recvData.length > 0) {
            
            if (self.type != TaskTypeDownload) {
                // 文本数据
                self.result.data = self.recvData;
                
            }else { // 文件数据
                
                // response
                NSURLResponse *response = task.response;
                self.result.response = response;
                
                [self.fileStream jl_closeWriter];
                self.fileStream = nil;
            
                //
                if ([self.filePath hasSuffix:@"tmp"]) {
                    NSString *desPath = [self.filePath stringByReplacingOccurrencesOfString:self.filePath.lastPathComponent withString:response.suggestedFilename options:NSBackwardsSearch range:NSMakeRange(0, self.filePath.length)];
                    [[NSFileManager defaultManager] moveItemAtPath:self.filePath toPath:desPath error:nil];
                }
                
            }
            
        }
        
    }

    
    if (error.code != -999) {
        if (self.r) {
            
            self.r(self.result);
            
        }
    } else {
        
        NSLog(@"task canceled");
        
    }

    
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {

    self.result.response = response;
    
    completionHandler(NSURLSessionResponseAllow);
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {

    [self.recvData appendData:data];
    
    if (self.type == TaskTypeDownload) {
        [self.fileStream jl_writeData:data];
    }
    
    long long totalExpectedRecv = dataTask.countOfBytesExpectedToReceive;
    long long totalRecved = self.recvData.length;
    
    if (totalExpectedRecv <= 0) {
        return;
    }
    
    double progress = (1.0 * totalRecved) / totalExpectedRecv;
    
    if (self.recvProgressHandler) {
        self.recvProgressHandler(progress);
    }
        
    
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {

    // response
    NSURLResponse *response = downloadTask.response;
    self.result.response = response;
    
    // 文件保存地址
    if (!self.filePath) {
        self.filePath = NSTemporaryDirectory();
    }
    NSString *desPath = self.filePath;
    NSError *err;
    BOOL isDir = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:desPath isDirectory:&isDir];
    if (isDir) {
        
        desPath = [self.filePath stringByAppendingPathComponent:response.suggestedFilename];
    }
    
    // 如果文件存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:desPath]) {
        
        [[NSFileManager defaultManager] removeItemAtPath:desPath error:&err];
        if (err) {
            self.result.error = err;
            
            return;
        }
    }
    
    // 移动文件
    NSData *downloadData = [NSData dataWithContentsOfURL:location.absoluteURL];
    if (downloadData.length > 0) {
        [[NSFileManager defaultManager] moveItemAtURL:location.absoluteURL toURL:[NSURL fileURLWithPath:desPath] error:&err];
        if (err) {
            self.result.error = err;
        }
    }
    
    
}

// 断点续传
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    
    
    
}

// 下载进度
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {

    double progress = 0;
    if (totalBytesExpectedToWrite > 0) {
        progress = (1.0 * totalBytesWritten) / totalBytesExpectedToWrite;
    }

    if (self.recvProgressHandler) {
        self.recvProgressHandler(progress);
    }
}


@end
