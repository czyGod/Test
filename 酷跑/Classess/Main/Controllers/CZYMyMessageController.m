//
//  CZYMyMessageController.m
//  酷跑
//
//  Created by hzxsdz030 on 15/12/10.
//  Copyright © 2015年 hzxsdz030. All rights reserved.
//

#import "CZYMyMessageController.h"
#import "CZYXMPPTool.h"
#import "CZYUserInfo.h"
#import "CZYMyMessageCell.h"
#import "UIImageView+CZYImageView.h"
#import "CZYChatViewController.h"
@class NSFetchedResultsController;
@interface CZYMyMessageController ()
@property (nonatomic, strong) NSFetchedResultsController *fetchController;
@property (nonatomic, strong) UIImage *friendHeadImage;
@property (nonatomic, strong) NSArray *friends;
@end

@implementation CZYMyMessageController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadMessage];
    
}

//加载信息
- (void)loadMessage {
    NSManagedObjectContext *context = [CZYXMPPTool sharedCZYXMPPTool].xmppMsgArchStore.mainThreadManagedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"XMPPMessageArchiving_Contact_CoreDataObject"];
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr=%@ and streamBareJidStr=%@",[self.friendJid bare],[CZYUserInfo sharedCZYUserInfo].jid];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"mostRecentMessageTimestamp" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
//    self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    self.friends = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        MYLog(@"%@",error.userInfo);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"MyMessageCell";
    CZYMyMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    XMPPMessageArchiving_Contact_CoreDataObject *contact = self.friends[indexPath.row];
    cell.nikeNameLabel.text = contact.bareJidStr;
    NSData *data = [[CZYXMPPTool sharedCZYXMPPTool].xmppvCardAvtar photoDataForJID:self.friendJid];
    [cell.friendHeadImage setRoundLayer];
    if (data) {
        cell.friendHeadImage.image = [UIImage imageWithData:data];
    }else {
        cell.friendHeadImage.image = [UIImage imageNamed:@"placehoder"];
    }
    
    NSDate *date = contact.mostRecentMessageTimestamp;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"hh:mm";
    cell.timeLabel.text = [formatter stringFromDate:date];
    cell.lastMessageLabel.text = contact.mostRecentMessageBody;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    XMPPMessageArchiving_Contact_CoreDataObject *contact = self.friends[indexPath.row];
    [self performSegueWithIdentifier:@"ChatSegue1" sender:contact.bareJid];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id vc = segue.destinationViewController;
    if ([vc isKindOfClass:[CZYChatViewController class]]) {
        CZYChatViewController *chatVC = (CZYChatViewController *)vc;
        chatVC.friendJid = sender;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
