//
//  CZYXMPPTool.h
//  酷跑
//
//  Created by hzxsdz030 on 15/12/3.
//  Copyright © 2015年 hzxsdz030. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "XMPPFramework.h"
#import "XMPPMessageArchiving.h"
#import "XMPPMessageArchivingCoreDataStorage.h"

typedef enum{
    CZYXMPPResultTypeLoginSuccess,
    CZYXMPPResultTypeLoginFailed,
    CZYXMPPResultTypeNetError,
    CZYXMPPResultTypeRegisterSuccess,
    CZYXMPPResultTypeRegisterFailed
}CZYXMPPResultType;
typedef void(^CZYXMPPResultBlock)(CZYXMPPResultType type);
@interface CZYXMPPTool : NSObject
singleton_interface(CZYXMPPTool)
@property (nonatomic, strong) XMPPStream *stream;

//管理电子名片
@property (nonatomic, strong) XMPPvCardCoreDataStorage *xmppvCardStore;

//增加电子名片模块和头像模块
@property (nonatomic, strong) XMPPvCardAvatarModule *xmppvCardAvtar;
@property (nonatomic, strong) XMPPvCardTempModule *xmppvCard;

//增加花名册模块
@property (nonatomic, strong, readonly) XMPPRoster *roster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRoserStore;

//消息模块
@property (nonatomic, strong, readonly) XMPPMessageArchiving *xmppMegArch;
@property (nonatomic, strong, readonly) XMPPMessageArchivingCoreDataStorage *xmppMsgArchStore;

//自动重连模块
@property (nonatomic, strong) XMPPReconnect *reconnect;
//用户登录
- (void)userLogin:(CZYXMPPResultBlock)block;

- (void)connectToServer;

//用户注册
- (void)userRegister:(CZYXMPPResultBlock)block;


@end
