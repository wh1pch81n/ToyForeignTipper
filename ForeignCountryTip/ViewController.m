//
//  ViewController.m
//  ForeignCountryTip
//
//  Created by Derrick Ho on 9/5/14.
//  Copyright (c) 2014 dnthome. All rights reserved.
//

#import "ViewController.h"
#import "DHExchangeRates.h"
#import "ExchangeTableViewController.h"

@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) NSDictionary *currencies;
@property (weak, nonatomic) IBOutlet UIButton *leftCurrency;
@property (weak, nonatomic) IBOutlet UIButton *leftTip;
@property (weak, nonatomic) IBOutlet UITextField *leftSubTotal;
@property (weak, nonatomic) IBOutlet UITextField *leftTipTextField;
@property (weak, nonatomic) IBOutlet UILabel *leftTotal;

@property (weak, nonatomic) IBOutlet UIButton *rightCurrency;
@property (weak, nonatomic) IBOutlet UIButton *rightTip;
@property (weak, nonatomic) IBOutlet UILabel *rightSubTotal;
@property (weak, nonatomic) IBOutlet UITextField *rightTipTextField;
@property (weak, nonatomic) IBOutlet UILabel *rightTotal;

@property (strong, nonatomic) NSString *leftCurrencyKey;
@property (strong, nonatomic) NSString *rightCurrencKey;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedLatestExchangeRates:)
                                                 name:kExchangeRatesNotification object:nil];
    
    [[DHExchangeRates sharedInstance] refreshExchangeRates:self];
    
    self.leftCurrencyKey = @"USD";
    self.rightCurrencKey = @"USD";
    
    [self.leftCurrency setTitle:self.leftCurrencyKey forState:UIControlStateNormal];
    [self.rightCurrency setTitle:self.rightCurrencKey forState:UIControlStateNormal];
    
    [self.leftSubTotal setText:@"10.00"];
    [self.rightSubTotal setText:@"10.00"];
    
    [self.leftTipTextField setText:@"8.25"];
    [self.rightTipTextField setText:@"8.25"];
    
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(leftCurrencyKey)) options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(rightCurrencKey)) options:NSKeyValueObservingOptionNew context:nil];
    
    //[self leftValueChanged:self];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(leftCurrencyKey))];
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(rightCurrencKey))];
   
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kExchangeRatesNotification object:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(leftCurrencyKey))]) {
        [self.leftCurrency setTitle:self.leftCurrencyKey forState:UIControlStateNormal];
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(rightCurrencKey))]) {
        [self.rightCurrency setTitle:self.rightCurrencKey forState:UIControlStateNormal];
    }
}

- (IBAction)textfieldValueChanged:(id)sender {
    [self convertLeftToRightCurrency];
    float leftSubtotal = self.leftSubTotal.text.floatValue;
    float leftTip = self.leftTipTextField.text.floatValue * 0.01;
    float leftAmount = leftSubtotal + leftTip;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.leftTotal.text = [NSString stringWithFormat:@"%.2f %@", leftAmount, _leftCurrencyKey];
    });
    
    float rightSubTotal = self.rightSubTotal.text.floatValue;
    float rightTip = self.rightTipTextField.text.floatValue * 0.01;
    float rightAmount = rightSubTotal + rightTip;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.rightTotal.text = [NSString stringWithFormat:@"%.2f %@", rightAmount, _rightCurrencKey];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if([string isEqualToString:@"0"]||
       [string isEqualToString:@"1"]||
       [string isEqualToString:@"2"]||
       [string isEqualToString:@"3"]||
       [string isEqualToString:@"4"]||
       [string isEqualToString:@"5"]||
       [string isEqualToString:@"6"]||
       [string isEqualToString:@"7"]||
       [string isEqualToString:@"8"]||
       [string isEqualToString:@"9"]||
       [string isEqualToString:@"."]||
       [string isEqualToString:@""]) {
        return YES;
    }
    return NO;
}


#pragma mark - prepar segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"leftButton"]) {
        ExchangeTableViewController *tv = [segue destinationViewController];
        tv.currencyName = self.leftCurrencyKey;
        [tv setCompletionBlock:^(NSString *key) {
            self.leftCurrencyKey = key;
            [self textfieldValueChanged:self];
        }];
    } else if ([segue.identifier isEqualToString:@"rightButton"]) {
        ExchangeTableViewController *tv = [segue destinationViewController];
        tv.currencyName = self.rightCurrencKey;
        [tv setCompletionBlock:^(NSString *key) {
            self.rightCurrencKey = key;
            [self textfieldValueChanged:self];
        }];
    }
}

- (void)convertLeftToRightCurrency {
     float leftRate = [(NSString *)self.currencies[self.leftCurrencyKey][@"rate"] floatValue];
     float rightRate = [(NSString *)self.currencies[self.rightCurrencKey][@"rate"] floatValue];
    
    float rightSubTotal = self.leftSubTotal.text.floatValue *(1.0/leftRate) *(rightRate);
    self.rightSubTotal.text = [NSString stringWithFormat:@"%.2f", rightSubTotal];
}

- (IBAction)tappedSwap:(id)sender {
    NSString *temp = self.rightCurrencKey;
    self.rightCurrencKey = self.leftCurrencyKey;
    self.leftCurrencyKey = temp;
    [self textfieldValueChanged:self];
}

- (IBAction)tappedRefreshRates:(id)sender {
    [[DHExchangeRates sharedInstance] refreshExchangeRates:sender];
}

#pragma mark - notifications
- (void)receivedLatestExchangeRates:(NSNotification *)notification {
    self.currencies = [[DHExchangeRates sharedInstance] currencies];
    [self textfieldValueChanged:self];
}

@end
