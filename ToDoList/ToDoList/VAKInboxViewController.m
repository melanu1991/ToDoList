//
//  VAKInboxViewController.m
//  ToDoList
//
//  Created by melanu1991 on 04.06.17.
//  Copyright © 2017 melanu1991. All rights reserved.
//

#import "VAKInboxViewController.h"
#import "VAKAddTaskController.h"

@interface VAKInboxViewController ()

@end

@implementation VAKInboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addNewTask:(UIBarButtonItem *)sender {
    VAKAddTaskController *addTaskController = [[VAKAddTaskController alloc]initWithNibName:@"VAKAddTaskController" bundle:nil];
    [self.navigationController showViewController:addTaskController sender:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
