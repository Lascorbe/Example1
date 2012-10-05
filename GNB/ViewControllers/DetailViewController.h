//
//  DetailViewController.h
//  GNB
//
//  Created by Luis Ascorbe on 27/07/12.
//  Copyright (c) 2012 Alien Grapes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController
{
    NSArray *arrTransactions;
}

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

- (void)setArray:(NSArray *)newArray;
- (void)calcularSuma;

@end
