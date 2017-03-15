//
//  ViewController.m
//  FQQVideoPlayerViewController
//
//  Created by 冯清泉 on 2017/3/14.
//  Copyright © 2017年 冯清泉. All rights reserved.
//

#import "ViewController.h"
#import "FQQVideoPlayerViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.    
}

- (IBAction)pick:(id)sender {
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString* type = [info objectForKey:UIImagePickerControllerMediaType];
    if([type isEqualToString:(NSString *)kUTTypeMovie]){
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        FQQVideoPlayerViewController *controller = [FQQVideoPlayerViewController new];
        controller.url = videoURL;
        [picker dismissViewControllerAnimated:YES completion:^{
            [self presentViewController:controller animated:YES completion:nil];
        }];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
