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
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.logoutButton.enabled = false;
    self.refreshButton.enabled = false;

}
- (IBAction)loginButtonPressed:(id)sender {
    [[NXOAuth2AccountStore sharedStore]requestAccessToAccountWithType:@"Instagram"];
    self.loginButton.enabled = false;
    self.logoutButton.enabled = true;
    self.refreshButton.enabled = true;


}
- (IBAction)logoutButtonPressed:(id)sender {
    NXOAuth2AccountStore *share = [NXOAuth2AccountStore sharedStore];
    NSArray *instagramAccounts = [share accountsWithAccountType:@"Instagram"];
    for(id acct in instagramAccounts){
        [share removeAccount:acct];
        
    }
    self.loginButton.enabled = true;
    self.logoutButton.enabled = false;
    self.refreshButton.enabled = false;


}
- (IBAction)refreshButtonPressed:(id)sender {
    NSArray *instagramAccounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:@"Instagram"];
    if ([instagramAccounts count] == 0){
        NSLog(@"Warning %ld instagram accounts logged in.", (long)[instagramAccounts count]);
        return;
    }
    NXOAuth2Account *acct = instagramAccounts[0];
    NSString *token = acct.accessToken.accessToken;
    //Profile
    //NSString *urlString = [@"https://api.instagram.com/v1/users/self/?access_token=" stringByAppendingString:token];
    //Recent Liked Media
    NSString *urlString = [@"https://api.instagram.com/v1/users/self/?access_token=" stringByAppendingString:token];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    //    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
    //    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    //        NSString *text = [[NSString alloc]initWithContentsOfURL:location encoding:NSUTF8StringEncoding error:nil];
    //        NSLog(@"text: %@", text);
    //    }];
    //    [task resume];
    [[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        
        //Check for network error
        if(error){
            NSLog(@"Error! Couldn't finish request! %@", error);
            return;
        }
        
        //Check for Http error
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
        if(httpResp.statusCode <200 || httpResp.statusCode >=300){
            NSLog(@"Error! Get status code %ld ", (long)httpResp.statusCode);
            return;
        }
        //Check for Json parse error
        NSError *parseError;
        id pkg = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        if(!pkg){
            NSLog(@"Error! Couldn't parse response! %@", parseError);
            return;
        }
        // NSString *imgURLStr = pkg[@"data"][@"images"][@"standard_resolution"][@"url"];
        NSString *imgURLStr = pkg[@"data"][@"profile_picture"];
        NSString *usernameStr = pkg[@"data"][@"username"];
        NSString *fullnameStr = pkg[@"data"][@"full_name"];
        NSURL *imageURL = [NSURL URLWithString:imgURLStr];
        // NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        
        // self.imageView.image = [UIImage imageWithData:imageData];
        [[session dataTaskWithURL:imageURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            //
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = [UIImage imageWithData:data];
               self.usernameLabel.text = [NSString stringWithFormat:@"Welcome, %@!", usernameStr];
               self.fullnameLabel.text = fullnameStr;
            });
        }]resume];
        
    }]resume];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
