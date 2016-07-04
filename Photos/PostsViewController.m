//
//  PostsViewController.m
//  Photos
//
//  Created by Nina Yousefi on 7/3/16.
//  Copyright © 2016 Nina Yousefi. All rights reserved.
//

#import "PostsViewController.h"
#import "PostsCollectionViewCell.h"
#import "NXOAuth2.h"
#import "AppDelegate.h"
#import <SAMCache/SAMCache.h>
#import "AFNetworking/AFURLSessionManager.h"
#import <UIImageView+AFNetworking.h>
#import <sys/socket.h>
#import <netinet/in.h>

@interface PostsViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong,nonatomic)NSArray *tableData;
@property (strong, nonatomic)NSMutableArray *idsArr;
@end


@implementation PostsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.idsArr = [[NSMutableArray alloc]init];
    
    [self.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Roboto-Medium" size:14],UITextAttributeFont, nil] forState:UIControlStateNormal];
    UITabBarController *MyTabController = (UITabBarController *)((AppDelegate*) [[UIApplication sharedApplication] delegate]).window.rootViewController;
    MyTabController = self.tabBarController;
    [MyTabController setSelectedIndex:1];
    [MyTabController setSelectedIndex:0];

    
//    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cover.png"]];
//    [tempImageView setFrame:self.collectionView.frame];
//    
//    self.collectionView.backgroundView = tempImageView;

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
    NSString *urlString = [@"https://api.instagram.com/v1/users/self/media/recent/?access_token=" stringByAppendingString:token];
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
        NSArray *photosUrlArr = [pkg valueForKeyPath:@"data.images.thumbnail.url"];
       // NSArray *idsArray = [pkg valueForKey:@"data.caption.id"];
        for(int i=0; i< photosUrlArr.count;i++) {
            NSArray *partsArr = [photosUrlArr[i] componentsSeparatedByString:@"/"];
            NSArray * lastPart = [[partsArr lastObject] componentsSeparatedByString:@"?"];
            [self.idsArr addObject:lastPart[0]];

        }
                //self.idsArr = [[NSArray alloc]initWithArray:idsArray];
        self.tableData = [NSMutableArray arrayWithArray:photosUrlArr];
        
//        [[session dataTaskWithURL:imageURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//            //
//            dispatch_async(dispatch_get_main_queue(), ^{
////                self.imageView.image = [UIImage imageWithData:data];
////                self.usernameLabel.text = [NSString stringWithFormat:@"Welcome, %@!", usernameStr];
////                self.fullnameLabel.text = fullnameStr;
//            });
//        }]resume];
        [self.collectionView reloadData];
    }]resume];
    
    

}
- (IBAction)backButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"showHome" sender:nil];

}
#pragma mark - Collection view data source
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.tableData count];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"postCell";
    PostsCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
   // cell.postImageView.image = [UIImage imageNamed:@"insta"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:[self.tableData objectAtIndex:indexPath.row]];
//    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
//    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSData *imgData = [[NSData alloc]initWithContentsOfURL:location];
//        UIImage *image = [[UIImage alloc]initWithData:imgData];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            cell.postImageView.image = image;
//            
//                    });
//    }];
//    [task resume];
    
    
//    NSString *key = [[NSString alloc]initWithFormat:@"%ld-thumbnail", indexPath.row];
//    UIImage *photo = [[SAMCache sharedCache]imageForKey:key];
//    if(photo) {
//        cell.postImageView.image = photo;
//    }else{
    
    //Checking if the image is already saved in Documents
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *imgUrlStr = [self.idsArr objectAtIndex:indexPath.row];
    
    NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      imgUrlStr];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    
    if (image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.postImageView.image = image;
             });
        
    } else {
        //Download & Save the image

    [[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       // if([self hasConnectivity]){

        UIImage *image = [[UIImage alloc]initWithData:data];
       // [[SAMCache sharedCache]setImage:image forKey:key];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.postImageView.image = image;
             });
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSLog(@"doc: %@", documentsDirectoryPath);
            
            NSString *writablePath = [documentsDirectoryPath stringByAppendingPathComponent:[self.idsArr objectAtIndex:indexPath.row] ];
            // NSError *error = nil;
            if(![fileManager fileExistsAtPath:writablePath]){
                // file doesn't exist
                
                NSLog(@"file doesn't exist");
                //save Image From URL

                 [data writeToFile:[documentsDirectoryPath stringByAppendingString:[self.idsArr objectAtIndex:indexPath.row]] options:NSAtomicWrite error:&error];
            }else{
                    // [self.booksCollectionView reloadData];
                    
                    // file exist
                    NSLog(@"file exists");
                    
                }


       
     //   }
    
      
    }]resume];
    }
    
    
    //download and save into Documents
    //NSFileManager *fileManager = [NSFileManager defaultManager];
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
      //                                                   NSUserDomainMask, YES);
    //NSString *documentsDirectory = [paths objectAtIndex:0];
   
    
              return cell;
    
}

//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)hasConnectivity {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    if(reachability != NULL) {
        //NetworkStatus retVal = NotReachable;
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
            {
                // if target host is not reachable
                return NO;
            }
            
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
            {
                // if target host is reachable and no connection is required
                //  then we'll assume (for now) that your on Wi-Fi
                return YES;
            }
            
            
            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
            {
                // ... and the connection is on-demand (or on-traffic) if the
                //     calling application is using the CFSocketStream or higher APIs
                
                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                {
                    // ... and no [user] intervention is needed
                    return YES;
                }
            }
            
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
            {
                // ... but WWAN connections are OK if the calling application
                //     is using the CFNetwork (CFSocketStream?) APIs.
                return YES;
            }
        }
    }
    
    return NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
