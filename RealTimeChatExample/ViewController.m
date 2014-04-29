//
//  ViewController.m
//  RealTimeChatExample
//
//  Created by Zhanglei on 14-4-29.
//  Copyright (c) 2014年 SkyStarStudio. All rights reserved.
//

#import "ViewController.h"
#import "SocketIOPacket.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, SocketIODelegate> {
    NSMutableArray *_msgList;
    SocketIO *_io;
}

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _msgList = [NSMutableArray array];
    
    UITextField *_textField = [[UITextField alloc] initWithFrame:CGRectMake(10, self.view.bounds.size.height-50, 300, 50)];
    _textField.backgroundColor = [UIColor whiteColor];
    _textField.placeholder = @"输入信息";
    _textField.delegate = self;
    [self.view addSubview: _textField];

    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height-50)
                                                              style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.separatorColor = [UIColor lightGrayColor];
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView;
    });
    [self.view addSubview: self.tableView];
    
    // 使用SocketIO连接到本地的NodeJS服务器
    _io = [[SocketIO alloc] initWithDelegate:self];
    [_io connectToHost:@"http://localhost" onPort:8124];
    [_io sendEvent:@"addme" withData:@{@"name": @"minibear"}];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _msgList.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor blueColor];
    }
    
    cell.textLabel.text = _msgList[indexPath.row];
    return cell;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length > 0) {
        [_io sendEvent:@"chat" withData:@{@"message": textField.text} andAcknowledge:^(id argsData) {
            NSLog(@"args data is %@", argsData);
            [_msgList addObject:textField.text];
            [_tableView reloadData];
        }];
    }
    
    return NO;
}

- (void) socketIODidConnect:(SocketIO *)socket {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connected"
                                                        message:@"You is online"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void) socketIO:(SocketIO *)socket onError:(NSError *)error {
    NSLog(@"error is %@", error.localizedDescription);
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet {
    [_msgList addObject: packet.data];
}

@end
