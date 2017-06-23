//
//  VAKSelectDateController.h
//  ToDoList
//
//  Created by melanu1991 on 04.06.17.
//  Copyright © 2017 melanu1991. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VAKChangedDateDelegate.h"

@interface VAKSelectDateController : UIViewController

@property (nonatomic, weak) id<VAKChangedDateDelegate> delegate;

@end
