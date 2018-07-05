//
//  SuperLoggerPreviewView.m
//  SuperLoggerDemo
//
//  Created by YourtionGuo on 12/24/14.
//  Copyright (c) 2014 GYX. All rights reserved.
//

#import "SuperLoggerPreviewView.h"
#import <MessageUI/MessageUI.h>
#import "SuperLogger.h"

@interface SuperLoggerPreviewView ()<MFMailComposeViewControllerDelegate>

@end

@implementation SuperLoggerPreviewView

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = _logFilename;
    UIBarButtonItem *backBtn=[[UIBarButtonItem alloc] initWithTitle: SLLocalizedString(@"SL_Back",@"Back") style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    [self.navigationItem setLeftBarButtonItem:backBtn];
    UIBarButtonItem *sendBtn=[[UIBarButtonItem alloc] initWithTitle:SLLocalizedString(@"SL_Send",@"Send") style:UIBarButtonItemStylePlain target:self action:@selector(send)];
    [self.navigationItem setRightBarButtonItem:sendBtn];
    
    NSString* newStr = [[NSString alloc] initWithData:self.logData encoding:NSUTF8StringEncoding];
    UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(0, 44+20, self.view.frame.size.width, self.view.frame.size.height -44)];
    textView.tag = 999;
    textView.editable = NO;
    textView.text = newStr;
    [self.view addSubview:textView];
    // Do any additional setup after loading the view.
}

-(void)done
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)send
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        SuperLogger *logger = [SuperLogger sharedInstance];
        if (self.logData != nil) {
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            [picker setSubject:logger.mailTitle];
            [picker setToRecipients:logger.mailRecipients];
            [picker addAttachmentData:self.logData mimeType:@"application/text" fileName:_logFilename];
            [picker setToRecipients:@[]];
            [picker setMessageBody:logger.mailContect isHTML:NO];
            [picker setMailComposeDelegate:self];
            @try {
                [self presentViewController:picker animated:YES completion:nil];
            }
            @catch (NSException * e)
                { NSLog(@"Exception: %@", e); }
        }
    }];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
