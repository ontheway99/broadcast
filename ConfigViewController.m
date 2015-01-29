//
//  ConfigViewController.m
//  broadcast
//
//  Created by Mark on 14/12/19.
//  Copyright (c) 2014年 cv. All rights reserved.
//

#import "ConfigViewController.h"
#import "ViewController.h"

@interface ConfigViewController ()

@end

@implementation ConfigViewController

@synthesize strRTMPURL;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)OKButtionPressed:(id)sender {
   // ViewController *MainViewControler = [[ViewController alloc]initWithNibName:@"main" bundle:nil];
   // ViewController *MainViewControler = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"main"];
    ViewController* MainViewController = (ViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    self.passConfig = MainViewController;
    if( self.passConfig != nil )
    {
        NSLog(@"Pass configuration values to main view controller");
        [self.passConfig PassConfigValues:strRTMPURL.text];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        NSLog(@"Can't get main view controller");
    }
}

- (IBAction)DidEndOnExit:(id)sender {
}

- (IBAction)CancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
