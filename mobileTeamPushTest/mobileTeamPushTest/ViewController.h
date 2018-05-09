//
//  ViewController.h
//  mobileTeamPushTest
//
//  Created by steve benedick on 8/23/15.
//  Copyright (c) 2015 steve benedick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, assign) IBOutlet UILabel *lblPushToken;
@property (nonatomic, assign) IBOutlet UILabel *lblMid;
@property (nonatomic, assign) IBOutlet UITextField *txtKey;
@property (nonatomic, assign) IBOutlet UITextField *txtValue;

@end