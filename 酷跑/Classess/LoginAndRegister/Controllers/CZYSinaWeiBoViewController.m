//
//  CZYSinaWeiBoViewController.m
//  酷跑
//
//  Created by hzxsdz030 on 15/12/4.
//  Copyright © 2015年 hzxsdz030. All rights reserved.
//

#import "CZYSinaWeiBoViewController.h"
#import "AFNetworking.h"
#import "CZYUserInfo.h"
#import "CZYXMPPTool.h"
#import "MBProgressHUD+KR.h"
#define APPKEY @"2978822907"
#define REDIRECT_URI @"http://www.baidu.com"
#define APPSECRET @"00acefed96b477f4312a593e3c33bd05"
@interface CZYSinaWeiBoViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation CZYSinaWeiBoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CZYUserInfo *userInfo = [CZYUserInfo sharedCZYUserInfo];
    userInfo.sinaLogin = YES;
    self.webView.delegate = self;
    NSString *url = [NSString stringWithFormat:@"https://api.weibo.com/oauth2/authorize?client_id=%@&redirect_uri=%@",APPKEY,REDIRECT_URI];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.webView loadRequest:request];
}

#pragma mark - UiWebViewDelagate
//加载请求之后调用
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlPath = request.URL.absoluteString;
    MYLog(@"绝对路径:%@",urlPath);
    NSRange range = [urlPath rangeOfString:[NSString stringWithFormat:@"%@%@",REDIRECT_URI,@"/?code="]];
    MYLog(@"urlPath = %@",urlPath);
    NSString *code = nil;
    if (range.length > 0) {
        code = [urlPath substringFromIndex:range.length];
        MYLog(@"%@",code);
        [self accessTokenWithCode:code];
        return NO;
    }
    
    return YES;
}

//获取accessToken
- (void) accessTokenWithCode:(NSString *)code {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *urlStr = @"https://api.weibo.com/oauth2/access_token";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    /*
     必选	类型及范围	说明
     client_id	true	string	申请应用时分配的AppKey。
     client_secret	true	string	申请应用时分配的AppSecret。
     grant_type	true	string	请求的类型，填写authorization_code
     
     grant_type为authorization_code时
     必选	类型及范围	说明
     code	true	string	调用authorize获得的code值。
     redirect_uri	true	string	回调地址，需需与注册应用里的回调地址一致。
     */

    parameters[@"client_id"] = APPKEY;
    parameters[@"client_secret"] = APPSECRET;
    parameters[@"grant_type"] = @"authorization_code";
    parameters[@"code"] = code;
    parameters[@"redirect_uri"] = REDIRECT_URI;
    
    
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        MYLog(@"%@",responseObject);
        /* 根据返回数据的uid生成系统内部帐号 之前生成过就使用帐号登录*/
        NSString *innerName = [NSString stringWithFormat:@"sina%@",responseObject[@"uid"]];
        CZYUserInfo *userInfo = [CZYUserInfo sharedCZYUserInfo];
        userInfo.sinaToken = responseObject[@"access_Token"];
        if (userInfo.sinaLogin) {
            //不管用户是否注册过，都要注册
            userInfo.registerName = innerName;
            userInfo.registerPwd = userInfo.sinaToken;
            //将是否注册判定为YES
            userInfo.isRegister = YES;
            //注册的状态
            __weak typeof(self) sinaVC = self;
            [[CZYXMPPTool sharedCZYXMPPTool] userRegister:^(CZYXMPPResultType type) {
                [sinaVC handleRegisterResultType:type];
            }];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MYLog(@"获取token失败");
        [self dismissViewControllerAnimated:YES completion:nil];
    }];


}

//注册结果
- (void)handleRegisterResultType:(CZYXMPPResultType)type {
    switch (type) {
        case CZYXMPPResultTypeRegisterSuccess:
            [self handleLoginResultType:type];
            break;
        case CZYXMPPResultTypeRegisterFailed:
            [MBProgressHUD showError:@"注册失败"];
            [self handleLoginResultType:type];
            break;
        case CZYXMPPResultTypeNetError:
            [MBProgressHUD showError:@"联网失败"];
            break;
        default:
            break;
    }

}

- (void)handleLoginResultType:(CZYXMPPResultType)type {
    switch (type) {
        case CZYXMPPResultTypeLoginSuccess:
        {
            //登录成功
            [CZYUserInfo sharedCZYUserInfo].sinaLogin = YES;
            [self dismissViewControllerAnimated:YES completion:nil];
            //切换主界面
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            [UIApplication sharedApplication].keyWindow.rootViewController = [storyboard instantiateInitialViewController];
            break;
        }
            
        case CZYXMPPResultTypeLoginFailed:
            [MBProgressHUD showError:@"登录失败"];
            break;
        case CZYXMPPResultTypeNetError:
            [MBProgressHUD showError:@"联网失败"];
            break;
        default:
            break;
    }

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
