//
//  ViewController.m
//  mobileTeamPushTest
//
//  Created by steve benedick on 8/23/15.
//  Copyright (c) 2015 steve benedick. All rights reserved.
//

#import "ViewController.h"
#import "ADBMobile.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _lblPushToken.text = @"";
    
    NSString *mid = [ADBMobile visitorMarketingCloudID];
    [ADBMobile trackAction:@"user mid" data:@{@"user.mid":mid}];
    _lblMid.text = mid;
    
    _txtKey.delegate = self;
    _txtValue.delegate = self;
}

- (IBAction) trackAction:(id)sender {
    [ADBMobile trackAction:@"suchAction" data:@{_txtKey.text:_txtValue.text}];
}

- (IBAction) copyPushTokenToClipboard:(id)sender {
    [[UIPasteboard generalPasteboard] setString:_lblPushToken.text];
}

- (IBAction) copyMidToClipboard:(id)sender {
    [[UIPasteboard generalPasteboard] setString:_lblMid.text];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([_txtKey isFirstResponder]) {
        [_txtKey resignFirstResponder];
    }
    else if ([_txtValue isFirstResponder]) {
        [_txtValue resignFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}

@end
