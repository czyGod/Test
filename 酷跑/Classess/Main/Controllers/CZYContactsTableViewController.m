//
//  CZYContactsTableViewController.m
//  酷跑
//
//  Created by hzxsdz030 on 15/12/8.
//  Copyright © 2015年 hzxsdz030. All rights reserved.
//

#import "CZYContactsTableViewController.h"
#import "CZYContactTableViewCell.h"
#import "CZYUserInfo.h"
#import "CZYXMPPTool.h"
#import "XMPPUserCoreDataStorageObject.h"
#import "UIImageView+CZYImageView.h"
#import "CZYChatViewController.h"

@interface CZYContactsTableViewController ()<NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSFetchedResultsController *fetchController;

@end

@implementation CZYContactsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadFriend];
}

- (void)loadFriend {
    //获得上下文
    NSManagedObjectContext *context = [CZYXMPPTool sharedCZYXMPPTool].xmppRoserStore.mainThreadManagedObjectContext;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"XMPPUserCoreDataStorageObject"];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",[CZYUserInfo sharedCZYUserInfo].jid];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    NSError *error = nil;
    self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    self.fetchController.delegate = self;
    [self.fetchController performFetch:&error];
    if (error) {
        MYLog(@"%@",error.userInfo);
    }

}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    return self.fetchController.fetchedObjects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ident = @"ContactCell";
    CZYContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
    [self configureCell:cell indexPath:indexPath];
    // Configure the cell...
    
    return cell;
}

- (void)configureCell:(CZYContactTableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    XMPPUserCoreDataStorageObject *roster = self.fetchController.fetchedObjects[indexPath.row];
    NSData *data = [[CZYXMPPTool sharedCZYXMPPTool].xmppvCardAvtar photoDataForJID:roster.jid];
    if (data) {
        cell.friendHeadImage.image = [UIImage imageWithData:data];
    }else {
        cell.friendHeadImage.image = [UIImage imageNamed:@"placehoder"];
    }
    cell.friendNikeName.text = roster.nickname;
//    NSLog(@"%@",cell.friendNikeName.text);
    [cell.friendHeadImage setRoundLayer];
     cell.selectedBackgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cellselect"]];
    switch (roster.sectionNum.intValue) {
        case 0:
            cell.status.text = @"[在线]";
            break;
        case 1:
            cell.status.text = @"[忙碌]";
            break;
        case 2:
            cell.status.text = @"[离线请留言]";
            break;
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    XMPPUserCoreDataStorageObject *roster = self.fetchController.fetchedObjects[indexPath.row];
    [self performSegueWithIdentifier:@"ChatSegue" sender:roster.jid];

}
//删除模式
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    XMPPUserCoreDataStorageObject *friend = self.fetchController.fetchedObjects[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[CZYXMPPTool sharedCZYXMPPTool].roster removeUser:friend.jid];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id vc = segue.destinationViewController;
    if ([vc isKindOfClass:[CZYChatViewController class]]) {
        CZYChatViewController *chat = (CZYChatViewController *)vc;
        chat.friendJid = sender;
    }
}
- (IBAction)back:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
