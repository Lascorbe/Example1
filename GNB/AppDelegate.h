//
//  AppDelegate.h
//  GNB
//
//  Created by Luis Ascorbe on 27/07/12.
//  Copyright (c) 2012 Alien Grapes. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyReachability;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    // comprueba si hay internet
    MyReachability* internetReachable;
    BOOL hayInternet;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) NSArray *arrCurrencies;

// devuelvo un objeto que apunta al delegado
+ (AppDelegate *) sharedApplicationDelegate;
// funcion para comprobar el estado de la red, que es llamada con un observador, cambia el estado de hayInternet
- (void) checkNetworkStatus;
// funcion que devuelve una variable para saber si hay internet
- (BOOL) hayInternet;

@end
