//
//  CZYChatViewController.m
//  酷跑
//
//  Created by hzxsdz030 on 15/12/9.
//  Copyright © 2015年 hzxsdz030. All rights reserved.
//

#import "CZYChatViewController.h"
#import "CZYXMPPTool.h"
#import "CZYUserInfo.h"
#import "CZYMeTextCell.h"
#import "CZYFriendTextCell.h"
#import "XMPPvCardTemp.h"
#import "XMPPMessage.h"
#import "UIImageView+CZYImageView.h"
@interface CZYChatViewController ()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIImage *meImage;
@property (nonatomic, strong) UIImage *friendImage;
@property (nonatomic, strong) NSFetchedResultsController *fetchResultController;
@property (weak, nonatomic) IBOutlet UITextField *msgText;

@end

@implementation CZYChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //适应自动布局
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80.0;
    
}

//加载信息
- (void)loadMessage {
    
    //获取上下文
    NSManagedObjectContext *context = [CZYXMPPTool sharedCZYXMPPTool].xmppMsgArchStore.mainThreadManagedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr=%@ and streamBareJidStr=%@", [self.friendJid bare],[CZYUserInfo sharedCZYUserInfo].jid];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    self.fetchResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    self.fetchResultController.delegate = self;
    NSError *error = nil;
    [self.fetchResultController performFetch:&error];
    if (error) {
        MYLog(@"提取数据失败");
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.fetchResultController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XMPPMessageArchiving_Message_CoreDataObject *message = self.fetchResultController.fetchedObjects[indexPath.row];
    static NSString *meIdent = @"MeTextCell";
    static NSString *friendIdent = @"FriendTextCell";
    CZYMeTextCell *cell = [tableView dequeueReusableCellWithIdentifier:message.isOutgoing ? meIdent : friendIdent forIndexPath:indexPath];
    //text
    NSString *base64Str = [message.body substringFromIndex:4];
    NSData * base64Data = [[NSData alloc]initWithBase64EncodedString:base64Str options:0];
    //image
    
    //MeCell
    [cell.headImageView setRoundLayer];
    ;
    cell.headImageView.image = self.meImage;
    cell.chatTextLabel.text = [[NSString alloc]initWithData:base64Data encoding:NSUTF8StringEncoding];
//    cell.popImageView.image = ;
    //FriendCell
    [cell.friendHeadImageView setRoundLayer];
    cell.friendHeadImageView.image = self.friendImage;
    cell.friendChatTextLabel.text = [[NSString alloc]initWithData:base64Data encoding:NSUTF8StringEncoding];
//    cell.friendPopImageView;
    return cell;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
    [self scrollTabel];
}

#pragma mark - 键盘
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openKeyboard: ) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    NSData *meData = [CZYXMPPTool sharedCZYXMPPTool].xmppvCard.myvCardTemp.photo;
    if (meData == nil) {
        self.meImage = [UIImage imageNamed:@"微信"];
    }else {
        self.meImage = [UIImage imageWithData:meData];
    }
    
    NSData *friendData = [[CZYXMPPTool sharedCZYXMPPTool].xmppvCardAvtar photoDataForJID:self.friendJid];
    if (friendData == nil) {
        self.friendImage = [UIImage imageNamed:@"微信"];
    }else {
        self.friendImage = [UIImage imageWithData:friendData];
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (void)openKeyboard:(NSNotification *)notification{
    //获得keyboard的Frame
    CGRect keyboard = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //改变约束
    self.heightForBottom.constant = keyboard.size.height;
    //    self.tableViewToViewBottomConstraint.constant = 1;
    //获取时长
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //获取options
    int options = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        [self.view layoutIfNeeded];
        [self scrollTabel];
    } completion:nil];
}
- (void)closeKeyboard:(NSNotification *)notification{
    self.heightForBottom.constant = 0;
    //获取时长
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //获取options
    int options = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        //更改约束
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)scrollTabel {
    NSInteger index = self.fetchResultController.fetchedObjects.count - 1;
    if (index < 0) {
        return;
    }
    NSIndexPath *lastPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
- (IBAction)sendMessage:(UITextField *)sender {
    
    //判断输入的内容是否为空
    if (sender.text.length > 0) {
        NSString *msgText = self.msgText.text;
        XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
        [msg addBody:msgText];
        [[CZYXMPPTool sharedCZYXMPPTool].stream sendElement:msg];
        //更新表格
//        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.fetchResultController.fetchedObjects.count - 1 inSection:0];
//        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewAutomaticDimension];
//        [self.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    self.msgText.text = @"";
    [self.msgText resignFirstResponder];
    [self.tableView reloadData];
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    UIImage *smallImage = [self thumbnailWithImage:image size:CGSizeMake(100, 100)];
    NSData *data = UIImageJPEGRepresentation(smallImage, 0.05);
    [self sendMessageWithData:data bodyName:@"image:"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//生成缩略图
- (UIImage *)thumbnailWithImage:(UIImage *)image size:(CGSize)asize {
    UIImage *newImage;
    if (nil == image) {
        newImage = nil;
    }else {
        UIGraphicsBeginImageContext(asize);
        [image drawInRect:CGRectMake(0, 0, asize.width, asize.height)];
        
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newImage;
}
//发送图片
- (void)sendMessageWithData:(NSData *)data bodyName:(NSString *)name {
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    //转换成base64编码
    NSString *base64Str = [data base64EncodedStringWithOptions:0];
    [message addBody:[name stringByAppendingString:base64Str]];
    //发送消息
    [[CZYXMPPTool sharedCZYXMPPTool].stream sendElement:message];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
