//
//  ExchangeTableViewController.h
//  ForeignCountryTip
//
//  Created by Derrick Ho on 9/5/14.
//  Copyright (c) 2014 dnthome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExchangeTableViewController : UITableViewController

@property (strong, nonatomic) NSString *currencyName;
@property (copy, nonatomic) void(^completionBlock)(NSString *key);

@end
