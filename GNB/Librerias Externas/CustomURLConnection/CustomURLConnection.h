//
//  CustomURLConnection.h
//  catalogo
//
//  Created by JIG.ES on 04/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CustomURLConnection : NSURLConnection {
	
	NSString *tag;
	
}

@property (nonatomic, retain) NSString *tag;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately tag:(NSString*)aTag;


@end