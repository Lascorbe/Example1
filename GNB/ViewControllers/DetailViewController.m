//
//  DetailViewController.m
//  GNB
//
//  Created by Luis Ascorbe on 27/07/12.
//  Copyright (c) 2012 Alien Grapes. All rights reserved.
//

#import "DetailViewController.h"
#import "AppDelegate.h"

@interface DetailViewController ()
- (void)configureView;
@end

@implementation DetailViewController

@synthesize detailDescriptionLabel = _detailDescriptionLabel;

#pragma mark - LifeCycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Product", @"Detail");
    }
    return self;
}

- (void)dealloc
{
    [arrTransactions release];
    [_detailDescriptionLabel release];
    [super dealloc];
}

- (void)configureView
{
    // Update the user interface for the detail item.
    if (arrTransactions) {
        self.title = [[arrTransactions objectAtIndex:0] objectForKey:@"sku"];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.detailDescriptionLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrTransactions count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *dicTemp = [arrTransactions objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [dicTemp objectForKey:@"amount"], [dicTemp objectForKey:@"currency"]];
    return cell;
}

#pragma mark - FUNCIONES

- (void)setArray:(NSArray *)newArray
{
    if (arrTransactions != newArray) {
        [arrTransactions release];
        arrTransactions = [newArray retain];
        
        // Update the view.
        [self configureView];
    }
}

- (void)calcularSuma
{
    // creo una piscina para los objetos autorelease
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    double suma = 0.0;
    // extraigo los diccionarios
    for (NSDictionary *dicTrans in arrTransactions) 
    {
        // voy sumando, los que no sean EUR los convierto y los sumo
        if ([[dicTrans objectForKey:@"currency"] isEqualToString:@"EUR"]) 
        {
            // sumo el amount
            suma += [[dicTrans objectForKey:@"amount"] doubleValue];
        }
        else 
        {
            double amount = [[dicTrans objectForKey:@"amount"] doubleValue];
            NSString *currency = [dicTrans objectForKey:@"currency"];
            
            while (![currency isEqualToString:@"EUR"]) 
            {
                for (NSDictionary *dicCurren in [AppDelegate sharedApplicationDelegate].arrCurrencies) 
                {
                    if ([[dicCurren objectForKey:@"from"] isEqualToString:currency] && ![currency isEqualToString:@"EUR"]) 
                    {
                        amount = amount * [[dicCurren objectForKey:@"rate"] doubleValue];
                        currency = [dicCurren objectForKey:@"to"];
                    }
                }
            }
            
            // sumo el amount
            suma += amount;
        }
    }
    
    // redondeo
    suma = round(suma);
    
    // establezco la suma en el label en el MainThread porque modificamos la UI
    [self.detailDescriptionLabel performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"TOTAL: %.2f EUR", suma] waitUntilDone:YES];
    
    // dreno la piscina para liberar la memoria de los autoreleased, ya que trabajo en segundo plano en esta funcion
    [pool drain];
}
							
@end
