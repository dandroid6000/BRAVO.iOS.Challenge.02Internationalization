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
@property (weak, nonatomic) IBOutlet UILabel *nowLabel;
@property (weak, nonatomic) IBOutlet UILabel *deltaLabel;
@property (weak, nonatomic) IBOutlet UILabel *calculatedLabel;

// Data
@property (strong, nonatomic) NSDate *now;
@property (strong, nonatomic) NSDateComponents *dateDelta;
@property (assign, nonatomic) BOOL isAdding;

// Localization
@property (strong, nonatomic) NSCalendar *calendar;
@property (strong, nonatomic) NSLocale *locale;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSNumberFormatter *numberFormatter;

- (NSString *)dateFormatForLocale:(NSLocale *)locale;
- (void)initializeFormattersWithLocale:(NSLocale *)locale;

@end

@implementation NRDDateCalcViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.calendar = [NSCalendar autoupdatingCurrentCalendar];
        self.locale = [NSLocale autoupdatingCurrentLocale];
        self.dateDelta = [NSDateComponents new];
        [self.dateDelta setHour:0];
        self.isAdding = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializeFormattersWithLocale:self.locale];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localeDidChange:)
                                                 name:NSCurrentLocaleDidChangeNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSCurrentLocaleDidChangeNotification
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

#pragma mark - IBActions

- (IBAction)didPressDigit:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        // Safety check!
        long long newHours = (long long)self.dateDelta.hour * 10 + (self.isAdding ? 1 : -1) * button.tag;
        if (NSIntegerMin <= newHours && newHours <= NSIntegerMax) {
            [self.dateDelta setHour:(NSInteger)newHours];
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
                [self.dateDelta setHour:0];
                [self updateHoursDisplay];
                [self calculate];
                break;
                
            case kButtonPlus:
                self.isAdding = YES;
                if (self.dateDelta.hour < 0) {
                    [self.dateDelta setHour:-self.dateDelta.hour];
                }
                [self updateHoursDisplay];
                break;
                
            case kButtonMinus:
                self.isAdding = NO;
                if (self.dateDelta.hour > 0) {
                    [self.dateDelta setHour:-self.dateDelta.hour];
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
    self.deltaLabel.text = [NSString stringWithFormat:@"%@ %@ hours", self.isAdding ? @"＋" : @"－", [self.numberFormatter stringFromNumber:@(self.dateDelta.hour)]];
}

- (void)calculate
{
    NSDate *calculatedDate = [self.calendar dateByAddingComponents:self.dateDelta
                                                            toDate:self.now
                                                           options:0];
    self.calculatedLabel.text = [self.dateFormatter stringFromDate:calculatedDate];
}

- (NSString *)dateFormatForLocale:(NSLocale *)locale
{
    // NOTE: THIS WOULD NEED TO BE FLESHED OUT MORE ACCURATELY, BUT THE IDEA IS HERE
    NSString *localeID = [locale objectForKey:NSLocaleIdentifier];
    if ([localeID rangeOfString:@"_US"].location != NSNotFound      // United States
        || [localeID rangeOfString:@"_BZ"].location != NSNotFound   // Belize
        || [localeID rangeOfString:@"_CA"].location != NSNotFound   // Canada (could use either..)
        || [localeID rangeOfString:@"_FM"].location != NSNotFound   // Federated States of Micronesia
        || [localeID rangeOfString:@"_PW"].location != NSNotFound   // Palau
        ) {
        return @"MM/dd/yyyy @ h:mm:ss a";
    } else if ([localeID rangeOfString:@"_CN"].location != NSNotFound   // China
               ) {
        return @"yyyy/MM/dd @ h:mm:ss a";
    } else {
        return @"dd/MM/yyyy @ h:mm:ss a";
    }
}

- (void)initializeFormattersWithLocale:(NSLocale *)locale
{
    self.numberFormatter = [NSNumberFormatter new];
    self.numberFormatter.locale = locale;
    self.numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    // Hide the sign so we can display it explicitly
    self.numberFormatter.negativePrefix = @"";
    self.numberFormatter.positivePrefix = @"";

    self.dateFormatter = [NSDateFormatter new];
    self.dateFormatter.locale = locale;
    self.dateFormatter.dateFormat = [self dateFormatForLocale:locale];
}

#pragma mark - Notification handlers

- (void)didBecomeActive:(NSNotification *)aNotification
{
    // Set date and update UI
    self.now = [NSDate date];
    self.nowLabel.text = [self.dateFormatter stringFromDate:self.now];
    [self calculate];
    [self updateHoursDisplay];
}

- (void)localeDidChange:(NSNotification *)aNotification
{
    // Note: self.locale updates automatically to the current locale
    
    // Re-create formatters (Apple recommends re-creating them)
    [self initializeFormattersWithLocale:self.locale];
    
    // Update UI
    self.nowLabel.text = [self.dateFormatter stringFromDate:self.now];
    [self calculate];
    [self updateHoursDisplay];
}

@end
