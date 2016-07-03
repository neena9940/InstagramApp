//
//  ViewController.m
//  Photos
//
//  Created by Nina Yousefi on 7/3/16.
//  Copyright © 2016 Nina Yousefi. All rights reserved.
//

#import "ViewController.h"
#import "NXOAuth2.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)loginButtonPressed:(id)sender {
    [[NXOAuth2AccountStore sharedStore]requestAccessToAccountWithType:@"Instagram"];

}
- (IBAction)logoutButtonPressed:(id)sender {
    NXOAuth2AccountStore *share = [NXOAuth2AccountStore sharedStore];
    NSArray *instagramAccounts = [share accountsWithAccountType:@"Instagram"];
    for(id acct in instagramAccounts){
        [share removeAccount:acct];
        
    }

}
- (IBAction)refreshButtonPressed:(id)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
