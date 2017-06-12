//
//  JLFileStream.h
//  Test Upload Progress
//
//  Created by emerys on 2017/2/20.
//  Copyright © 2017年 mini1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JLFileStream : NSObject

@property (nonatomic,copy) NSString *filePath;

+ (instancetype)jl_fileStreamOfPath:(NSString *)path;

- (void)jl_writeData:(NSData *)data;

- (void)jl_closeWriter;

@end
