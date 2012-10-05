//
//  CustomURLConnection.m
//  catalogo
//
//  Created by JIG.ES on 04/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CustomURLConnection.h"


@implementation CustomURLConnection

@synthesize tag;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately tag:(NSString*)aTag {
	self = [super initWithRequest:request delegate:delegate startImmediately:startImmediately];
	
	if (self) {
		self.tag = aTag;
	}
	return self;
}

- (void)dealloc {
	[tag release];
	[super dealloc];
}

@end