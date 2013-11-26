//
//  NRDDateCalcViewController.m
//  HourCalc
//
//  Created by Dan Kane on 11/12/13.
//  Copyright (c) 2013 The Nerdery. All rights reserved.
//

#import "NRDDateCalcViewController.h"

static const NSUInteger kButtonClear = 1;
static const NSUInteger kButtonPlus = 2;
static const NSUInteger kButtonMinus = 3;
static const NSUInteger kButtonEquals = 4;

@interface NRDDateCalcViewController ()

// UI
@property (weak, nonatomic) IBOutlet UILabel *todayLabel;
@property (weak, nonatomic) IBOutlet UILabel *deltaLabel;
@property (weak, nonatomic) IBOutlet UILabel *calculatedLabel;

// Data
@property (strong, nonatomic) NSDateComponents *delta;
@property (assign, nonatomic) BOOL isAdding;

// Localization
@property (strong, nonatomic) NSCalendar *calendar;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSNumberFormatter *numberFormatter;

@end

@implementation NRDDateCalcViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.dateFormatter = [NSDateFormatter new];
        self.delta = [NSDateComponents new];
        self.numberFormatter = [NSNumberFormatter new];
        [self.delta setHour:0];
        self.isAdding = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    // Hide the sign so we can display it explicitly
    self.numberFormatter.negativePrefix = @"";
    self.numberFormatter.positivePrefix = @"";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

//#pragma mark - Setters
//
//- (void)setToday:(NSDate *)today
//{
//    _today = today;
//    self.todayLabel.text = [self.dateFormatter stringFromDate:self.today];
//    [self calculate];
//}

#pragma mark - IBActions

- (IBAction)didPressDigit:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        long long newHours = (long long)self.delta.hour * 10 + (self.isAdding ? 1 : -1) * button.tag;
        if (NSIntegerMin <= newHours && newHours <= NSIntegerMax) {
            [self.delta setHour:(NSInteger)newHours];
            [self updateHoursDisplay];
        }
    }
}

- (IBAction)didPressOperator:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        switch (button.tag) {
            case kButtonClear:
                [self.delta setHour:0];
                [self updateHoursDisplay];
                [self calculate];
                break;
                
            case kButtonPlus:
                self.isAdding = YES;
                if (self.delta.hour < 0) {
                    [self.delta setHour:-self.delta.hour];
                }
                [self updateHoursDisplay];
                break;
                
            case kButtonMinus:
                self.isAdding = NO;
                if (self.delta.hour > 0) {
                    [self.delta setHour:-self.delta.hour];
                }
                [self updateHoursDisplay];
                break;
                
            case kButtonEquals:
                [self calculate];
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - Private Methods

- (void)updateHoursDisplay
{
    self.deltaLabel.text = [NSString stringWithFormat:@"%@ %@ hours", self.isAdding ? @"＋" : @"－", [self.numberFormatter stringFromNumber:@(self.delta.hour)]];
//    self.deltaLabel.text = [NSString stringWithFormat:@"%@ hours", [self.numberFormatter stringFromNumber:@(self.delta.hour)]];
}

- (void)calculate
{
    NSDate *calculatedDate = [self.calendar dateByAddingComponents:self.delta
                                                            toDate:self.today
                                                           options:0];
    self.calculatedLabel.text = [self.dateFormatter stringFromDate:calculatedDate];
}

- (void)dateFormatForLocale:(NSLocale *)locale
{
    
}

#pragma mark - Notification handlers

- (void)didBecomeActive:(NSNotification *)aNotification
{
    // Set formatting from the current calendar/locale here in case the user changes it
    self.calendar = [NSCalendar currentCalendar];
    NSLog(@"Calendar: %@", self.calendar.calendarIdentifier);
    
    NSLog(@"Locale ID: %@", [self.calendar.locale objectForKey:NSLocaleIdentifier]);
    
    self.numberFormatter.locale = self.calendar.locale;
    
    self.dateFormatter.locale = self.calendar.locale;
    self.dateFormatter.dateFormat = @"MM/dd/yyyy @ h:mm:ss a";
    
    self.today = [NSDate date];
    self.todayLabel.text = [self.dateFormatter stringFromDate:self.today];
    [self calculate];
    [self updateHoursDisplay];
}

- (void)localeDidChange:(NSNotification *)aNotification
{
    
}

@end
