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

@property (weak, nonatomic) IBOutlet UILabel *todayLabel;
@property (weak, nonatomic) IBOutlet UILabel *deltaLabel;
@property (weak, nonatomic) IBOutlet UILabel *calculatedLabel;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDate *calculated;
@property (strong, nonatomic) NSDateComponents *delta;

@end

@implementation NRDDateCalcViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.dateFormatter = [NSDateFormatter new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // TODO:
    self.dateFormatter.dateFormat = @"MM/dd/yyyy";
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)didPressDigit:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        NSLog(@"New Digit: %@", button.titleLabel.text);
    }
}

- (IBAction)didPressOperator:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        switch (button.tag) {
            case kButtonClear:
                // Do a thing
                NSLog(@"CLEAR");
                break;
                
            case kButtonPlus:
                // Do a thing
                NSLog(@"PLUS");
                break;
                
            case kButtonMinus:
                // Do a thing
                NSLog(@"MINUS");
                break;
                
            case kButtonEquals:
                // Do a thing
                NSLog(@"EQUALS");
                break;
                
            default:
                break;
        }
    }
}

@end
