//
//  CZYXMPPTool.m
//  酷跑
//
//  Created by hzxsdz030 on 15/12/3.
//  Copyright © 2015年 hzxsdz030. All rights reserved.
//

#import "CZYXMPPTool.h"

#import "CZYUserInfo.h"

@interface  CZYXMPPTool()<XMPPStreamDelegate>
{
    CZYXMPPResultBlock _resultBlock;
}
@end

@implementation CZYXMPPTool
singleton_implementation(CZYXMPPTool)

//设置XMPP数据流
- (void)setupXMPPStream {
    self.stream = [[XMPPStream alloc] init];
    [_stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    //初始化电子名片和头像模块
    self.xmppvCardStore = [XMPPvCardCoreDataStorage sharedInstance];
    self.xmppvCard = [[XMPPvCardTempModule alloc] initWithvCardStorage:self.xmppvCardStore];
    self.xmppvCardAvtar = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:self.xmppvCard];
    //初始化花名册模块
    _xmppRoserStore = [XMPPRosterCoreDataStorage sharedInstance];
    _roster = [[XMPPRoster alloc] initWithRosterStorage:self.xmppRoserStore];
    [_roster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    //初始化消息模块
    _xmppMsgArchStore = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    _xmppMegArch = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:self.xmppMsgArchStore];
    //激活电子名片和头像模块
    [self.xmppvCard activate:self.stream];
    [self.xmppvCardAvtar activate:self.stream];
    //激活花名册模块
    [self.roster activate:self.stream];
    //激活消息模块
    [self.xmppMegArch activate:self.stream];
}
//连接服务器
- (void)connectToServer {
    
    [self.stream disconnect];
    if (self.stream == nil) {
        [self setupXMPPStream];
    }
    
    self.stream.hostName = CZYXMPPHOSTNAME;
    self.stream.hostPort = CZYXMPPPORT;
    
    NSString *userName = nil;
    if ([CZYUserInfo sharedCZYUserInfo].isRegister) {
        userName = [CZYUserInfo sharedCZYUserInfo].registerName;
    }else {
        userName = [CZYUserInfo sharedCZYUserInfo].username;
    }
    NSString *jidStr = [NSString stringWithFormat:@"%@@%@",userName,CZYXMPPDOMAIN];
    XMPPJID *myjid = [XMPPJID jidWithString:jidStr];
    self.stream.myJID = myjid;
    NSError *error = nil;
    [self.stream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    if (error) {
        MYLog(@"连接出错,原因:%@",error.userInfo);
    }
}
//发送密码
- (void)sendMessage {
    NSError *error = nil;
    NSString *userPwd = nil;
    CZYUserInfo *userInfo = [CZYUserInfo sharedCZYUserInfo];
    if (userInfo.isRegister) {
        userPwd = userInfo.registerPwd;
        [self.stream registerWithPassword:userPwd error:&error];
    }else {
        userPwd = userInfo.userpwd;
        [self.stream authenticateWithPassword:userPwd error:&error];
    }
    
    if (error) {
        MYLog(@"发送出错,原因:%@",error.userInfo);
    }
}

//发送在线消息
- (void)sendOnline {
    XMPPPresence *presence = [XMPPPresence presence];
    [self.stream sendElement:presence];
}

#pragma mark - XMPPStreamDelegate

//连接成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    [self sendMessage];
    MYLog(@"连接成功");
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    if (error) {
        _resultBlock(CZYXMPPResultTypeNetError);
        MYLog(@"连接失败,原因:%@",error);
    }else {
        MYLog(@"正常断开");
    }
}
//授权成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    _resultBlock(CZYXMPPResultTypeLoginSuccess);
    [self sendOnline];
    MYLog(@"授权成功");
    
}

//授权失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    _resultBlock(CZYXMPPResultTypeLoginFailed);
    MYLog(@"授权失败,原因:%@",error);
    
}

- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    _resultBlock(CZYXMPPResultTypeRegisterSuccess);
    MYLog(@"注册成功");
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error {
    _resultBlock(CZYXMPPResultTypeRegisterFailed);
    MYLog(@"注册失败");
}
- (void)userLogin:(CZYXMPPResultBlock)block {
    _resultBlock = block;
    [self connectToServer];
}

//用户注册
- (void)userRegister:(CZYXMPPResultBlock)block {
    _resultBlock = block;
    
    [self connectToServer];
}
@end
