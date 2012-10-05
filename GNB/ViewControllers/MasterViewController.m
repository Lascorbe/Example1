//
//  MasterViewController.m
//  GNB
//
//  Created by Luis Ascorbe on 27/07/12.
//  Copyright (c) 2012 Alien Grapes. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "NSDictionary_JSONExtensions.h"
#import "CustomURLConnection.h"
#import "Constantes.h"
#import "AppDelegate.h"

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize receivedData = _receivedData;

#pragma mark - LifeCycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"GNU", @"Master");
        dicProducts = [[NSMutableDictionary alloc] init];
        _receivedData = [[NSMutableDictionary alloc] init];
    }
    return self;
}
							
- (void)dealloc
{
    [spinner release];
    [_detailViewController release];
    [_receivedData release];
    
    [dicProducts release];
    if (arrTransactions) [arrTransactions release];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // establezco que el spinner se oculte cuando se pare
    [spinner setHidesWhenStopped:YES];
    // lo pongo en el lado izquierdo de la navigationBar
    UIBarButtonItem *bbiSpinner = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    self.navigationItem.leftBarButtonItem = bbiSpinner;
    [bbiSpinner release];
    
    // pongo un boton para actualizar
    UIBarButtonItem *bbiRefresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(actualizar)];
    self.navigationItem.rightBarButtonItem = bbiRefresh;
    [bbiRefresh release];
    
    // pido los datos de CURRENCY y TRANSACTION
    [self pedirDatosJSON];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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
    return [[dicProducts allKeys] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    cell.textLabel.text = [[dicProducts allKeys] objectAtIndex:indexPath.row];
    return cell;
}

/*- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}*/

/*- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [arrProducts removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.detailViewController) {
        self.detailViewController = [[[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil] autorelease];
    }
    NSArray *arrTemp = [dicProducts objectForKey:[[dicProducts allKeys] objectAtIndex:indexPath.row]];
    [self.detailViewController setArray:arrTemp];
    [self.detailViewController performSelectorInBackground:@selector(calcularSuma) withObject:nil];
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

#pragma mark - CustomURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
	int responseStatusCode = [httpResponse statusCode];
	NSLog(@"HTTP CODE: %d", responseStatusCode);
	// si el codigo no es el 200 no continuo
	if (responseStatusCode == 200)
	{
		// inicio la variable de los datos
		NSMutableData *dataFromConnection = [self dataForConnection:(CustomURLConnection*)connection];
		[dataFromConnection setLength:0];
	}
	else
	{
		// aborto la conexion
		[connection release];
	}
}

// metodo para manejar errores de NSURLConnection
- (void)connection:(NSURLConnection *)aConn didFailWithError:(NSError *)error
{
    NSLog(@"Error al recibir con tag '%@': %@", [(CustomURLConnection*)aConn tag], [error localizedDescription]);
	[aConn release];
    
    // detengo el spinner
    [spinner stopAnimating];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSMutableData *dataFromConnection = [self dataForConnection:(CustomURLConnection*)connection];
	[dataFromConnection appendData:data];
}

// este metodo se ejecuta cuando se reciben los datos
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// extraigo los datos recibidos
	NSMutableData *dataFromConnection = [self dataForConnection:(CustomURLConnection*)connection];
    NSString *responseString = [[NSString alloc] initWithData:dataFromConnection encoding:NSUTF8StringEncoding];
    NSError *theError = NULL;
    NSArray *tempArr = (NSArray *)[NSDictionary dictionaryWithJSONString:responseString error:&theError];
    [responseString release];
    
    if (tempArr == nil)
        NSLog(@"JSON parsing failed: %@", [theError localizedDescription]);
    else 
    {
        NSLog(@"Contenido del diccionario: %@", tempArr);
        
        // comprobamos que datos estamos recibiendo
        if ([[(CustomURLConnection*)connection tag] isEqualToString:@"currency"]) 
        {
            //trozo de codigo que actua cuando me devuelve los datos de URL_CURRENCY
            if ([[AppDelegate sharedApplicationDelegate] arrCurrencies]) 
            {
                [[AppDelegate sharedApplicationDelegate].arrCurrencies release];
            }
            // guardo el array que acabo de recibir en la variable del appdelegate
            [AppDelegate sharedApplicationDelegate].arrCurrencies = [[NSArray alloc] initWithArray:tempArr copyItems:YES];
            
            // pido las transacciones al servidor una vez tengo el array de currency
            [self startAsyncLoad:[NSURL URLWithString:URL_TRANSACTION] tag:@"transaction"];
        }
        else if ([[(CustomURLConnection*)connection tag] isEqualToString:@"transaction"]) 
        {
            //trozo de codigo que actua cuando me devuelve los datos de URL_TRANSACTION
            if (arrTransactions) 
            {
                [arrTransactions release];
            }
            // guardo el array que acabo de recibir en la variable de la clase
            arrTransactions = [[NSMutableArray alloc] initWithArray:tempArr copyItems:YES];
            
            // detengo el spinner
            [spinner stopAnimating];
            
            // extraigo los productos de las transacciones y los muestro en la tabla
            [self cargarProductos];
        }
    }
	[connection release];
}

#pragma mark - FUNCIONES

// crea el objeto que hace la conexión al servidor
- (void)startAsyncLoad:(NSURL*)url tag:(NSString*)tag
{
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setTimeoutInterval:3000.0];
	
	CustomURLConnection *connection = [[CustomURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES tag:tag];
	
	if (connection) {
		NSMutableData *tempData = [[NSMutableData data] retain];
		[_receivedData setObject:tempData forKey:connection.tag];
		[tempData release];
	}
}

// devuelve el contenedor correspondiente a su connection
- (NSMutableData*)dataForConnection:(CustomURLConnection*)connection 
{
	NSMutableData *data = [_receivedData objectForKey:connection.tag];
	return data;
}

// funcion para pedir los arrays JSON de Currency y Transaction
- (void)pedirDatosJSON
{
    // muestro el spinner y le digo que empiece la animacion
    [spinner setHidden:NO];
    [spinner startAnimating];
    
    // hago la llamada al servidor
    [self startAsyncLoad:[NSURL URLWithString:URL_CURRENCY] tag:@"currency"];
}

- (void)actualizar
{
    // si hay conexion a internet hago la llamada al servidor, sino, muestro un mensaje
    if ([[AppDelegate sharedApplicationDelegate] hayInternet]) 
    {
        [self pedirDatosJSON];
    }
    else 
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network", @"Network")
                                                            message:NSLocalizedString(@"Seems to be some problem with the connection", @"err_internet")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Ok", @"aceptar")
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
}

// extraigo los productos de las transacciones y los muestro en la tabla
- (void)cargarProductos
{
    // extraigo las transacciones y las guardo agrupadas en distintos arrays y guardadas en un diccionario diferenciando por el SKU
    for (NSDictionary *dicTrans in arrTransactions) 
    {
        NSMutableArray *arrTransOfProduct = [dicProducts objectForKey:[dicTrans objectForKey:@"sku"]];
        if (arrTransOfProduct == nil) 
        {
            arrTransOfProduct = [NSMutableArray array];
        }
        [arrTransOfProduct addObject:dicTrans];
        [dicProducts setObject:arrTransOfProduct forKey:[dicTrans objectForKey:@"sku"]];
    }
    
    // recargo los datos de la tabla
    [productTable reloadData];
}

@end
