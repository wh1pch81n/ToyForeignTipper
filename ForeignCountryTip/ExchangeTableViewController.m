//
//  ExchangeTableViewController.m
//  ForeignCountryTip
//
//  Created by Derrick Ho on 9/5/14.
//  Copyright (c) 2014 dnthome. All rights reserved.
//

#import "ExchangeTableViewController.h"
#import "DHExchangeRates.h"

NSString *const kCurrencyName = @"kCurrencyName";
NSString *const kCurrencyCountry = @"kCurrencyCountry";
NSString *const kCurrencyRate = @"kCurrencyRate";

@interface ExchangeTableViewController ()

@property (strong, nonatomic) NSArray *dataSource;

@end

@implementation ExchangeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSArray *arr = [DHExchangeRates sharedInstance].currencies.allKeys;
    arr = [arr sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSMutableArray *mut = [NSMutableArray new];
    for (int i = 0; i < arr.count; ++i) {
        NSString *name = arr[i];
        NSString *country = [[DHExchangeRates sharedInstance] currencies][name][@"name"];
        NSString *rate = [[DHExchangeRates sharedInstance] currencies][name][@"rate"];
        [mut addObject:@{kCurrencyCountry: country,
                        kCurrencyName: name,
                         kCurrencyRate: rate}];
    }
    self.dataSource = mut;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary *dict = self.dataSource[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@",
                           dict[kCurrencyName],
                           dict[kCurrencyRate]];
    cell.detailTextLabel.text = dict[kCurrencyCountry];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.completionBlock) {
        NSString *key = self.dataSource[indexPath.row][kCurrencyName];
        self.completionBlock(key);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tappedBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
