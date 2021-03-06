//
//  RootViewController.m
//  TCMinem
//
//  Created by Dominik Wagner on 14.07.11.
//  Copyright 2011 TheCodingMonkeys. All rights reserved.
//

#import "RootViewController.h"
#import "TCMXMLWriter.h"

static NSString * const kTitleKey = @"title";
static NSString * const kBlockKey = @"block";

@interface RootViewController ()
- (void)setupContent;
- (void)addBlock:(void (^)(void))aBlock withTitle:(NSString *)aTitle;
- (void (^)(void))blockAtIndex:(NSUInteger)anIndex;
- (NSString *)titleAtIndex:(NSUInteger)anIndex;
- (NSURL *)tempFileURL;
@end

@implementation RootViewController

- (void)sharedInit {
	contentArray = [NSMutableArray new];
	[self setupContent];
}

- (id)initWithStyle:(UITableViewStyle)aStyle {
	if ((self=[super initWithStyle:aStyle])) {
		[self sharedInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self=[super initWithCoder:aDecoder])) {
		[self sharedInit];
	}
	return self;
}

- (void)setupContent {
	[self addBlock:^{
		TCMXMLWriter *writer = [[TCMXMLWriter alloc] initWithOptions:TCMXMLWriterOptionPrettyPrinted | TCMXMLWriterOptionPrettyBOOL];
		writer.boolNOValue = @"false";
		writer.boolYESValue = @"true";
		[writer instruct:@"xml" attributes:@{@"version": @"1.0",@"encoding": @"UTF-8"}];
		[writer tag:@"loanDatabase" contentBlock:^{
			[writer tag:@"loans" contentBlock:^{
				[writer tag:@"loan" attributes:@{@"id": @"loan-123124",@"itemID": @"item-1231",@"friendID": @"friend-111", @"no": @NO,@"yes": @YES} contentBlock:^{
					[writer text:@"This item has some content text!"];
				}];
			}];
			[writer tag:@"items" contentBlock:^{
				[writer tag:@"item" contentBlock:^{
					[writer tag:@"ImageData" contentBlock:^{
						[writer cdata:@"This is quite literally a end]]> cdata ]]> problem"];
					}];
				}];
			}];
			[writer tag:@"friends" contentBlock:^{
				
			}];
		}];
		NSLog(@"result XML:n\n%@", writer.XMLString);
	}
		withTitle:@"Random XML"];

	
	[self addBlock:^{
		TCMXMLWriter *writer = [[TCMXMLWriter alloc] initWithOptions:TCMXMLWriterOptionPrettyPrinted];
		[writer instructXML];
		[writer tag:@"kml" attributes:@{@"xmlns": @"http://www.opengis.net/kml/2.2"} contentBlock:^{
			[writer tag:@"Document" contentBlock:^{
				[writer tag:@"Placemark" contentBlock:^{
					[writer tag:@"name" contentText:@"NYC"];
					[writer tag:@"description" contentText:@"New York City"];
					[writer tag:@"Point" contentBlock:^{
						[writer tag:@"coordinates" contentText:@"-74.006393,40.714172,0"];
					}];
				}];
			}];
		}];
		NSLog(@"result XML:\n%@", writer.XMLString);
	}
		 withTitle:@"New York KML"];


	NSURL *fileURL = [self tempFileURL];
	[self addBlock:^{
		NSLog(@"auf gehts %s", __FUNCTION__);
		TCMXMLWriter *writer = [[TCMXMLWriter alloc] initWithOptions:TCMXMLWriterOptionPrettyPrinted | TCMXMLWriterOptionPrettyBOOL fileURL:fileURL];
		[writer instructXML];
		[writer tag:@"parent" attributes:@{@"xmlns": @"http://poop.la/parent"} contentBlock:^{
			NSDictionary *attributeDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"abc",@"alphabet",@NO,@"boolean", nil];
			for (int i = 0; i<100000; i++) {
				[writer tag:@"item" attributes:attributeDictionary contentBlock:^{
					NSNumber *numberI = [[NSNumber alloc] initWithInt:i];
					NSDictionary *innerAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:numberI,@"index", nil];
					NSString *commentString = [[NSString alloc] initWithFormat:@"This is entry number: %d",i];
					[writer comment:commentString];
					[writer tag:@"just_tag" attributes:innerAttributes];
					[writer tag:@"text_tag" attributes:innerAttributes contentText:@"Some Content Text"];
					[writer tag:@"cdata_tag" attributes:innerAttributes contentCDATA:@"Some Content CDATA"];
					}
				 ];
			}
			
		}];
		NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileURL.path error:nil];
		NSLog(@"result lengthInBytes:\n%@", fileAttributes);
	}
		 withTitle:@"Big Ass XML File Write"];

}

- (void)addBlock:(void (^)(void))aBlock withTitle:(NSString *)aTitle {
	[contentArray addObject:@{kTitleKey: aTitle,kBlockKey: [aBlock copy]}];
}

- (void (^)(void))blockAtIndex:(NSUInteger)anIndex {
	return (void (^)(void))contentArray[anIndex][kBlockKey];
}

- (NSString *)titleAtIndex:(NSUInteger)anIndex {
	return contentArray[anIndex][kTitleKey];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return contentArray.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

	// Configure the cell.
	cell.textLabel.text = [self titleAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self blockAtIndex:indexPath.row]();
}


- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSURL *)tempFileURL {
	NSURL *result = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"tempFile.xml"]];
	NSLog(@"tempURL %@",result);
	return result;
}

@end
