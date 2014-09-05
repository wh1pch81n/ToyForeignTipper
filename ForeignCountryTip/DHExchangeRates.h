//
//  DHExchangeRates.h
//  ForeignCountryTip
//
//  Created by Derrick Ho on 9/5/14.
//  Copyright (c) 2014 dnthome. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 subscribe to this to recived notifications of the new exchange rate
 */

extern NSString *const kExchangeRatesNotification;


@interface DHExchangeRates : NSObject

+ (DHExchangeRates *)sharedInstance;


- (void)refreshExchangeRates:(id)sender;

/**
 A dictionary where the currency codes are the keys.  The value is a dictionary with the keys:
 "name"
 "rate"
 
 This is initially nil.  If you call this before the first exchange rates are completed you will get nil.
 If you call this property when it is nil, it will automatically refreshExchangeRates:
 
 If you want to be notified of when the fetch is complete, subscribe to the kExchangeRatesNotification
 */
@property (strong, nonatomic) NSDictionary *currencies;

@end


