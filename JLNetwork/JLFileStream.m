//
//  JLFileStream.m
//  Test Upload Progress
//
//  Created by emerys on 2017/2/20.
//  Copyright © 2017年 mini1. All rights reserved.
//

#import "JLFileStream.h"

@interface JLFileStream ()

@property (nonatomic,strong) NSInputStream *inputStream;
@property (nonatomic,strong) NSOutputStream *outputStream;

@end

@implementation JLFileStream

#pragma mark - life

+ (instancetype)jl_fileStreamOfPath:(NSString *)path {
    
    JLFileStream *stream = [[JLFileStream alloc] init];
    stream.filePath = path;
    
    return stream;
}

- (void)setFilePath:(NSString *)filePath {
    _filePath = filePath;
    
    if (!filePath) {
        return;
    }
    
    if (_outputStream) {
        [_outputStream close];
    }
    
    _outputStream = [NSOutputStream outputStreamToFileAtPath:self.filePath append:YES];
    [_outputStream open];
    
}

#pragma mark - out put stream

- (void)jl_writeData:(NSData *)data {
    
    [self writeData:data toPath:self.filePath];
    
}

- (void)writeData:(NSData *)data toPath:(NSString *)path {
    
    [self.outputStream write:data.bytes maxLength:data.length];
    
}

- (void)jl_closeWriter {
    
    [self.outputStream close];
    
}

@end
