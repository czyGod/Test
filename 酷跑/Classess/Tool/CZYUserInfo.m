//
//  CZYUserInfo.m
//  酷跑
//
//  Created by hzxsdz030 on 15/12/3.
//  Copyright © 2015年 hzxsdz030. All rights reserved.
//

#import "CZYUserInfo.h"

@implementation CZYUserInfo
singleton_implementation(CZYUserInfo)

- (void)saveCZYUserInfoToSandBox {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:self.username forKey:@"userName"];
    [userDefault setValue:self.userpwd forKey:@"userPwd"];
}

- (void)loadCZYUserInfoFromSandBox {
    NSUserDefaults *userDefalut = [NSUserDefaults standardUserDefaults];
    self.username = [userDefalut objectForKey:@"userName"];
    self.userpwd = [userDefalut objectForKey:@"userPwd"];

}

- (NSString *)jid {
    return [NSString stringWithFormat:@"%@@%@",self.username,CZYXMPPDOMAIN];
}
@end
