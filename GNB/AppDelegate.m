//
//  AppDelegate.m
//  GNB
//
//  Created by Luis Ascorbe on 27/07/12.
//  Copyright (c) 2012 Alien Grapes. All rights reserved.
//

#import "AppDelegate.h"

#import "MasterViewController.h"
#import "MyReachability.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize arrCurrencies;

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [arrCurrencies release];
    
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    arrCurrencies = [[NSArray alloc] init];

    MasterViewController *masterViewController = [[[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil] autorelease];
    self.navigationController = [[[UINavigationController alloc] initWithRootViewController:masterViewController] autorelease];
    self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [internetReachable stopNotifier];
    [internetReachable release];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    // inicio la variable de internet
    hayInternet = NO;
    // Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
    // method "reachabilityChanged" will be called. 
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(checkNetworkStatus) name: kReachabilityChangedNotification object: nil];
    // check for internet connection
    internetReachable = [[MyReachability reachabilityForInternetConnection] retain];
	[internetReachable startNotifier];
	[self checkNetworkStatus];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - FUNCIONES

// devuelvo un objeto que apunta al delegado
+(AppDelegate *) sharedApplicationDelegate
{
	return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

// Funcion que cambia el boolean hayInternet si el establecimiento de la conexion a internet cambia
- (void) checkNetworkStatus
{
    // called after network status changes
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            hayInternet = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI.");
            hayInternet = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            // muestro un mensaje el label de salida y habilito el boton de actualizar
            hayInternet = YES;
            
            break;
        }
    }
}

// funcion que devuelve una variable para saber si hay internet
- (BOOL)hayInternet
{
    return hayInternet;
}

@end
