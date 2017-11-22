//
//  CZYUserInfo.h
//  酷跑
//
//  Created by hzxsdz030 on 15/12/3.
//  Copyright © 2015年 hzxsdz030. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
@interface CZYUserInfo : NSObject
singleton_interface(CZYUserInfo)
//用户信息
@property (nonatomic,copy) NSString *username;
@property (nonatomic,copy) NSString *userpwd
;
//用户注册信息
@property (nonatomic,copy) NSString *registerName;
@property (nonatomic,copy) NSString *registerPwd;
@property (nonatomic,copy) NSString *jid;
//判断是不是注册
@property (nonatomic,assign,getter=isRegister) BOOL isRegister;
/*是否是新浪登录*/
@property (nonatomic,copy) NSString *sinaToken;
@property (nonatomic,assign) BOOL sinaLogin;
//用户数据的沙盒读写
- (void)saveCZYUserInfoToSandBox;
- (void)loadCZYUserInfoFromSandBox;
@end
