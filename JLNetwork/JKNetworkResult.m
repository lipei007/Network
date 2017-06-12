//
//  JKNetworkResult.m
//  Test Upload Progress
//
//  Created by Jack on 2017/1/11.
//  Copyright © 2017年 mini1. All rights reserved.
//

#import "JKNetworkResult.h"

@implementation JKNetworkResult

- (void)setData:(id)data {
    
    _data = data;
    if (self.decryptHandler && data) {
        
        id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resultDic = result;
            NSString* base64str = resultDic[@"str"];
            self.decryptString = self.decryptHandler(base64str);
        }
        
    }

}

@end
