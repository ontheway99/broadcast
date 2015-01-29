//
//  ConfigViewController.h
//  broadcast
//
//  Created by Mark on 14/12/19.
//  Copyright (c) 2014年 cv. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PassConfigValueDelegate
- (void)PassConfigValues:(NSString *)values;
@end


@interface ConfigViewController : UIViewController
{
    UITextField *strRTMPURL;
}
@property (nonatomic,retain)id<PassConfigValueDelegate> passConfig;
@property (nonatomic, retain)IBOutlet UITextField *strRTMPURL;
- (IBAction)OKButtionPressed:(id)sender;
- (IBAction)DidEndOnExit:(id)sender;
- (IBAction)CancelButtonPressed:(id)sender;
@end
