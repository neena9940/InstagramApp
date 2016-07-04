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
@property (strong, nonatomic)NSString *isFirsttime;
@property (strong, nonatomic)NSString *usernameStr;
@property (strong, nonatomic)NSString *fullnameStr;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    self.isFirsttime = [[NSUserDefaults standardUserDefaults]objectForKey:@"isFirstTime"];
    self.usernameStr = [[NSUserDefaults standardUserDefaults]objectForKey:@"username"];
    self.fullnameStr = [[NSUserDefaults standardUserDefaults]objectForKey:@"fullname"];

    if([self.isFirsttime isEqualToString:@"NO"] == YES){
        self.loginButton.enabled = false;
        self.logoutButton.enabled = true;
        self.refreshButton.enabled = true;
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:
                          @"profilePhoto" ];
        
        self.imageView.image = [UIImage imageWithContentsOfFile:path];
        self.usernameLabel.text = self.usernameStr;
        self.fullnameLabel.text = self.fullnameStr;

    }else{
        self.loginButton.enabled = true;
        self.logoutButton.enabled = false;
        self.refreshButton.enabled = false;
       
    }
    

}
//-(void)viewDidAppear:(BOOL)animated{
//    self.refreshButton.enabled = true;
//}
- (IBAction)loginButtonPressed:(id)sender {
    [[NXOAuth2AccountStore sharedStore]requestAccessToAccountWithType:@"Instagram"];
    NSArray *instagramAccounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:@"Instagram"];
    if ([instagramAccounts count] == 0){
        NSLog(@"Warning %ld instagram accounts logged in.", (long)[instagramAccounts count]);
        return;
    }

    NXOAuth2Account *acct = instagramAccounts[0];
    NSString *token = acct.accessToken.accessToken;
    //Profile
    // https://api.instagram.com/v1/users/self/media/recent/?access_token=
    //NSString *urlString = [@"https://api.instagram.com/v1/users/self/?access_token=" stringByAppendingString:token];
    //Recent Liked Media
    NSString *urlString = [@"https://api.instagram.com/v1/users/self/?access_token=" stringByAppendingString:token];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[NSUserDefaults standardUserDefaults]setObject:@"NO" forKey:@"isFirstTime"];

    
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
        [[NSUserDefaults standardUserDefaults]setObject:usernameStr forKey:@"username"];
        [[NSUserDefaults standardUserDefaults]setObject:fullnameStr forKey:@"fullname"];

        NSURL *imageURL = [NSURL URLWithString:imgURLStr];
        // NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        
        // self.imageView.image = [UIImage imageWithData:imageData];
        [[session dataTaskWithURL:imageURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            //
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = [UIImage imageWithData:data];
                self.usernameLabel.text = [NSString stringWithFormat:@"Welcome, %@!", usernameStr];
                self.fullnameLabel.text = fullnameStr;
                
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSLog(@"doc: %@", documentsDirectoryPath);
                
                NSString *writablePath = [documentsDirectoryPath stringByAppendingPathComponent:@"profilePhoto"];
                 NSError *error = nil;
                if(![fileManager fileExistsAtPath:writablePath]){
                    // file doesn't exist
                    
                    NSLog(@"file doesn't exist");
                    //save Image From URL
                    
                    [data writeToFile:[documentsDirectoryPath stringByAppendingPathComponent:@"profilePhoto"] options:NSAtomicWrite error:&error];
                }else{
                    // [self.booksCollectionView reloadData];
                    
                    // file exist
                    NSLog(@"file exists");
                    
                }

            });
        }]resume];
        
    }]resume];

    self.loginButton.enabled = false;
    self.logoutButton.enabled = true;
    self.refreshButton.enabled = true;


}
- (IBAction)logoutButtonPressed:(id)sender {
//    NXOAuth2AccountStore *share = [NXOAuth2AccountStore sharedStore];
//    NSArray *instagramAccounts = [share accountsWithAccountType:@"Instagram"];
//    for(id acct in instagramAccounts){
//        [share removeAccount:acct];
//        
//    }
    self.loginButton.enabled = true;
    self.logoutButton.enabled = false;
    self.refreshButton.enabled = false;
    self.usernameLabel.text = @"";
    self.fullnameLabel.text = @"";
    self.imageView.image = [UIImage imageNamed:@"default"];
    [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"isFirstTime"];



}
- (IBAction)refreshButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"showPosts" sender:self];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
