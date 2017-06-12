//
//  JKNetworkResult.h
//  Test Upload Progress
//
//  Created by Jack on 2017/1/11.
//  Copyright © 2017年 mini1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JKNetworkResult : NSObject

@property (nonatomic,strong) id data;
@property (nonatomic,strong) NSURLResponse *response;
@property (nonatomic,strong) NSError *error;
@property (nonatomic,copy) NSString *decryptString;
@property (nonatomic,copy) id(^decryptHandler)(NSString *encryptString);


@end
