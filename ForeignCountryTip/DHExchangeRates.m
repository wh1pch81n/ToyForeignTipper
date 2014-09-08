//
//  DHExchangeRates.m
//  ForeignCountryTip
//
//  Created by Derrick Ho on 9/5/14.
//  Copyright (c) 2014 dnthome. All rights reserved.
//

#import "DHExchangeRates.h"


static NSString *const kBaseURL = @"http://openexchangerates.org/api";
static NSString *const kLatestExchangeRatesScript = @"latest.json?";
static NSString *const kNationNamesScript = @"currencies.json?";
static NSString *const kApp_ID = @"app_id=";
static NSString *const kKey = @"7c5015b88a0e48698c3db1b64edadf49";
NSString *const kExchangeRatesNotification = @"kExchangeRatesNotification";

@interface DHExchangeRates ()

@property (strong, nonatomic) NSDictionary *exchangeRates;
@property (strong, nonatomic) NSDictionary *countrynames;

@end

@implementation DHExchangeRates {
    BOOL gettingExchangeRates;
    BOOL gettingCountryNames;
}

+ (DHExchangeRates *)sharedInstance {
    static DHExchangeRates *_instance = nil;
    static dispatch_once_t name;
    dispatch_once(&name, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (void)refreshExchangeRates:(id)sender {
    gettingExchangeRates = YES;
    gettingCountryNames = YES;
    [self fetchExchangeRates];
    [self fetchCountryNames];
}


- (NSDictionary *)currencies {
    if (_currencies) {
        return _currencies;
    }
    [self refreshExchangeRates:self];
    return _currencies;
}



- (void)fetchExchangeRates {
    NSString *_url = [NSString stringWithFormat:@"%@/%@%@%@", kBaseURL,kLatestExchangeRatesScript,kApp_ID,kKey];
    NSURL *url = [NSURL URLWithString:_url];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"Could not Get Exchange Rates: %@", connectionError.description);
            return;
        }
        NSError *err;
        self.exchangeRates = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error:&err];
        if (err) {
            NSLog(@"Could not Get Exchange Rates: %@", err.description);
            return;
        }
        gettingExchangeRates = NO;
        if (gettingCountryNames == NO) {
            //fetch country names has finished therefore broadcast
            [self broadCastExchangeRates];
        }
    }];
}

- (void)fetchCountryNames {
    NSString *_url = [NSString stringWithFormat:@"%@/%@%@%@", kBaseURL,kNationNamesScript,kApp_ID,kKey];
    NSURL *url = [NSURL URLWithString:_url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"Could not Get nation names: %@", connectionError.description);
            return;
        }
        NSError *err;
        self.countrynames = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error:&err];
        if (err) {
            NSLog(@"Could not get nation names: %@", err.description);
            return;
        }
        gettingCountryNames = NO;
        if (gettingExchangeRates == NO) {
            //fetching exchange rates has finsihed therefore broadcast
            [self broadCastExchangeRates];
        }
    }];
}

- (void)broadCastExchangeRates {
    NSMutableDictionary *curr = [NSMutableDictionary new];
    for (NSString *key in self.countrynames.allKeys) {
        if (self.exchangeRates[@"rates"][key] && self.countrynames[key]) {
            curr[key] = @{@"name": self.countrynames[key],
                          @"rate": self.exchangeRates[@"rates"][key]
                          };
        }
    }
    self.currencies = curr;
    [[NSNotificationCenter defaultCenter] postNotificationName:kExchangeRatesNotification
                                                        object:self
                                                      userInfo:curr];
}
@end
