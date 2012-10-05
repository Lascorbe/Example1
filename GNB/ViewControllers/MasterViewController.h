//
//  MasterViewController.h
//  GNB
//
//  Created by Luis Ascorbe on 27/07/12.
//  Copyright (c) 2012 Alien Grapes. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomURLConnection;
@class DetailViewController;
@class AppDelegate;

@interface MasterViewController : UITableViewController
{
    NSMutableArray *arrTransactions;
    NSMutableDictionary *dicProducts;
    
    IBOutlet UITableView *productTable;
    IBOutlet UIActivityIndicatorView *spinner;
}

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (nonatomic, retain) NSMutableDictionary *receivedData;

// funcion para crear el objeto que hace la conexión al servidor
- (void)startAsyncLoad:(NSURL *)url tag:(NSString *)tag;
// función para extraer los datos del diccionario de paquetes según una conexión dada
- (NSMutableData *)dataForConnection:(CustomURLConnection *)connection;

//funcion para pedir los arrays JSON de Currency y Transaction
- (void)pedirDatosJSON;
- (void)actualizar;

// extraigo los productos de las transacciones y los muestro en la tabla
- (void)cargarProductos;

@end
