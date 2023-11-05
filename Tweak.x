// Importing the necessary headers for UIKit, custom rootless header, Foundation, CoreFoundation, and SpringBoard.
#import <UIKit/UIKit.h>
#import "rootless.h"
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <SpringBoard/SpringBoard.h>

// Declare a static timer for updating the seconds.
static NSTimer *secondsTimer = nil;

// Interface declaration for SBUILegibilityLabel, a UIView subclass for legible text.
@interface SBUILegibilityLabel : UIView
@property (nonatomic, copy) NSString *string;
@property (nonatomic, retain) UIFont *font;
- (void)setNumberOfLines:(long long)arg1;
- (void)setString:(NSString *)arg1;
- (void)setFrame:(CGRect)arg1;
@end

// Interface for SBLockStateAggregator to track the lock state.
@interface SBLockStateAggregator : NSObject
@property (nonatomic, assign) unsigned long long lockState;
+ (instancetype)sharedInstance;
@end

// Interface for SBFLockScreenDateView to manage the display of date and time on the lock screen.
@interface SBFLockScreenDateView : UIView
@property (nonatomic, strong) SBUILegibilityLabel *timeLabel;
- (float)expectedLabelWidth:(SBUILegibilityLabel *)label;
- (void)updateTimeLabel;
- (void)handleTap:(UITapGestureRecognizer *)recognizer;
@end

// Implementation hook for SBFLockScreenDateView to customize its behavior.
%hook SBFLockScreenDateView

// LayoutSubviews is overridden to ensure the timer is setup and the time label is updated accordingly.
- (void)layoutSubviews {
    [self updateTimeLabel];

    if (secondsTimer == nil && ![secondsTimer isValid]) {
        secondsTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimeLabel) userInfo:nil repeats:YES];
    }

    %orig;
}

// A new method to handle tap gestures, updating the time label to show the current date.
%new
- (void)handleTap:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        Ivar labelViewIvar = class_getInstanceVariable([self class], "_timeLabel");
        SBUILegibilityLabel *timeLabel = object_getIvar(self, labelViewIvar);

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM"];
        NSString *currentDateString = [dateFormatter stringFromDate:[NSDate date]];
        [timeLabel setString:currentDateString];

        [timeLabel setFrame:CGRectMake(timeLabel.frame.origin.x, timeLabel.frame.origin.y, [self expectedLabelWidth:timeLabel], timeLabel.frame.size.height)];
    }
}

// Calculates the expected width of the label based on its contents.
%new
- (float)expectedLabelWidth:(SBUILegibilityLabel *)label {
    [label setNumberOfLines:1];
    CGSize expectedLabelSize = [[label string] sizeWithAttributes:@{NSFontAttributeName: label.font}];
    return expectedLabelSize.width + 2; // Add a little extra to prevent truncation.
}

// Updates the time label with the current time down to the seconds.
%new
- (void)updateTimeLabel {
    Ivar lockStateIvar = class_getInstanceVariable(objc_getClass("SBLockStateAggregator"), "_lockState");
    unsigned long long lockState = *(unsigned long long *)((__bridge void *)self + ivar_getOffset(lockStateIvar));

    if (!(lockState == 3) && secondsTimer != nil && [secondsTimer isValid]) {
        [secondsTimer invalidate];
        secondsTimer = nil;
    }

    Ivar labelViewIvar = class_getInstanceVariable([self class], "_timeLabel");
    SBUILegibilityLabel *timeLabel = object_getIvar(self, labelViewIvar);

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString *currentTimeString = [dateFormatter stringFromDate:[NSDate date]];
    [timeLabel setString:currentTimeString];
    [timeLabel setFrame:CGRectMake(timeLabel.frame.origin.x, timeLabel.frame.origin.y, [self expectedLabelWidth:timeLabel], timeLabel.frame.size.height)];
}

%end
