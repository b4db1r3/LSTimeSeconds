// Importing the necessary headers for UIKit, custom rootless header, Foundation, CoreFoundation, and SpringBoard.
#import <UIKit/UIKit.h>
#import "rootless.h"
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <SpringBoard/SpringBoard.h>
#import <objc/runtime.h>
#import <substrate.h>

NSString *AudioCanvasChange = @"AudioCanvasChange";
NSString *AudioCanvasChange2 = @"AudioCanvasChange2";

BOOL isUsingADO = NO;
BOOL isEnable = NO;
NSString *timeFormat;
int timeFormatCase;
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

BOOL isIOS15() {
    // Get the current system version
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    // Check if the system version starts with "15"
    return [systemVersion hasPrefix:@"15"];
}

BOOL isIOS16() {
    // Get the current system version
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    // Check if the system version starts with "16"
    return [systemVersion hasPrefix:@"16"];
}

%group iOS15
// Implementation hook for SBFLockScreenDateView to customize its behavior.
%hook SBFLockScreenDateView

// LayoutSubviews is overridden to ensure the timer is setup and the time label is updated accordingly.
- (void)layoutSubviews {
    [self updateTimeLabel];

    if (secondsTimer == nil && ![secondsTimer isValid]) {
        secondsTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(updateTimeLabel) userInfo:nil repeats:YES];
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

    Ivar labelViewIvar = class_getInstanceVariable([self class], "_timeLabel");
    SBUILegibilityLabel *timeLabel = object_getIvar(self, labelViewIvar);


    switch (timeFormatCase) {
        case 0: // ExtraLight
            timeFormat = @"HH:mm:ss";
            break;
        case 1: // Light
            timeFormat = @"hh:mm:ss";
            break;
    }


    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:timeFormat];
    NSString *currentTimeString = [dateFormatter stringFromDate:[NSDate date]];
    [timeLabel setString:currentTimeString];
    [timeLabel setFrame:CGRectMake(timeLabel.frame.origin.x, timeLabel.frame.origin.y, [self expectedLabelWidth:timeLabel], timeLabel.frame.size.height)];
}

%end

%end




@interface CSProminentElementView : UIView

@end

@interface CSProminentTextElementView : CSProminentElementView   {

    NSDate* _date;
    NSString* _overrideString;
    UIFont* _primaryFont;
    UIColor* _primaryTextColor;
    UILabel* _textLabel;
}
- (void)updateTimeFormatter;
- (float)expectedLabelWidth:(SBUILegibilityLabel *)label;
@end

@interface CSProminentTimeView : CSProminentTextElementView {

    BOOL _usesLightTimeFontVariant;
    BOOL _usesLandscapeTimeFontVariant;
    BOOL _fourDigitTime;
    UIFont* _baseFont;
    NSString* _numberingSystem;
    NSDateFormatter* _timeFormatter;
}
-(void)updateTimeLabel;
-(id)_updateTimeString;
-(id)_timeString;
@property(nonatomic, retain) NSDateFormatter* timeFormatter; // Declare the property if not publicly declared
- (void)updateTimeFormatter;
- (float)expectedLabelWidth:(UILabel *)label;
@end
NSTimer *secondsTimer2 = nil; // Declare the timer at a scope where it's accessible by the methods that need it


@interface CSProminentDisplayView : UIView
{
        CSProminentTimeView* _timeView;

}
- (void)updateTimeFormatter ;
  @property (nonatomic,retain) NSTimer* waqtSecondsTimer;
-(void)updateTimeLabel;
-(NSString *)currentTimeFormat;
@end

@class CSProminentTimeView;

@interface CSProminentDisplayViewController : UIViewController
-(void)nonProIphonesWithoutAOD;
-(void)updateTimeLabel;
-(void)updateTimeLabel2;
-(void)deviceUnlocked;
-(void)deviceLocked;
-(void)setupTimerWithSelector:(SEL)selector;
-(void)updateTimeWithSeconds ;
-(void)updateTimeWithoutSeconds ;
-(void)updateTimeLabel:(BOOL)showSeconds;
-(void)setupTimerWithInterval:(NSTimeInterval)interval selector:(SEL)selector ;
@property (nonatomic, assign) BOOL isShowingSeconds;
-(void)setupOrUpdateTimer;
-(void)updateTimerInterval:(NSTimeInterval)interval;
-(void)updateTimerInterval2:(NSTimeInterval)interval;
@end

%group iOS16

%hook SBDashBoardBiometricUnlockController
- (void)setAuthenticated:(BOOL)arg1 {
    %orig;

   [[NSNotificationCenter defaultCenter] postNotificationName:AudioCanvasChange object:nil];

}
%end

%hook SBBacklightController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"AudioCanvasChange"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"AudioCanvasChange2"
                                                  object:nil];
    %orig;
}


- (void)backlight:(id)arg1 didCompleteUpdateToState:(long long)arg2 forEvent:(id)arg3 {
    %orig;

    // Assuming state constants are defined elsewhere or need to be determined
    // const long long InactiveOnState = 1;
    const long long ActiveOnState = 2;

    if (arg2 != ActiveOnState) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AudioCanvasChange2" object:nil];
        // NSLog(@"Backlight transitioning to InactiveOn");
    } else if (arg2 == ActiveOnState) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AudioCanvasChange" object:nil];
        // NSLog(@"Backlight transitioning to ActiveOn");
    }
}

%end


%hook CSProminentDisplayViewController
%property (nonatomic, assign) BOOL isShowingSeconds;


-(void)viewWillAppear:(BOOL)animated {
    %orig;

    // Properly handle timer and notification setup based on conditions
    if(isUsingADO) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceUnlocked) name:AudioCanvasChange object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceLocked) name:AudioCanvasChange2 object:nil];
    } else {
        [self setupOrUpdateTimer];
    }
}
 
%new
// Set up or update timer based on the application state
-(void)setupOrUpdateTimer {
    if (!secondsTimer || ![secondsTimer isValid]) {
        secondsTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(nonProIphonesWithoutAOD) userInfo:nil repeats:YES];
    }
}

%new
- (void)nonProIphonesWithoutAOD {
    CSProminentTimeView *originalTimeView = MSHookIvar<CSProminentTimeView *>(self.view, "_timeView");
    NSDateFormatter *originalTimeFormatter = MSHookIvar<NSDateFormatter *>(originalTimeView, "_timeFormatter");

    NSDate *currentTime = [NSDate date];

    // Create a date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    // Set the date format based on the timeFormatCase
    NSString *timeFormat;
    switch (timeFormatCase) {
        case 0: // ExtraLight
            timeFormat = @"HH:mm:ss";
            break;
        case 1: // Light
            timeFormat = @"hh:mm:ss";
            break;
        default:
            timeFormat = @"HH:mm:ss"; // Default format
            break;
    }
    dateFormatter.dateFormat = timeFormat;

    // Format the current time using the date formatter
    NSString *formattedTime = [dateFormatter stringFromDate:currentTime];

    // Update the original time formatter's date format
    originalTimeFormatter.dateFormat = timeFormat;

    // Perform the time string update
    [originalTimeView performSelector:@selector(_updateTimeString) withObject:formattedTime];
}

%new
-(void)deviceUnlocked {
    [self updateTimerInterval:0.5];
}

%new
-(void)deviceLocked {
    [self updateTimerInterval2:1.0];
}

%new
-(void)updateTimerInterval2:(NSTimeInterval)interval {
    [secondsTimer invalidate];
    secondsTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(updateTimeWithoutSeconds) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:secondsTimer forMode:NSRunLoopCommonModes];
}

%new
-(void)updateTimerInterval:(NSTimeInterval)interval {
    [secondsTimer invalidate];
    secondsTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(updateTimeLabel) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:secondsTimer forMode:NSRunLoopCommonModes];
}

-(void)dealloc {
    [secondsTimer invalidate];
    secondsTimer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];

        // Remove observers to prevent memory leaks
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AudioCanvasChange" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AudioCanvasChange2" object:nil];


    %orig;
}

%new
-(void)updateTimeWithoutSeconds {
    [self updateTimeLabel:NO];
}

%new
-(void)updateTimeLabel {
     CSProminentTimeView* originalTimeView = MSHookIvar<CSProminentTimeView*>(self.view, "_timeView");
    NSDateFormatter* originalTimeFormatter = MSHookIvar<NSDateFormatter*>(originalTimeView, "_timeFormatter");

    NSDate *currentTime = [NSDate date];
    
    // Create a date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    switch (timeFormatCase) {
        case 0: // ExtraLight
            timeFormat = @"HH:mm:ss";
            break;
        case 1: // Light
            timeFormat = @"hh:mm:ss";
            break;
    }

    dateFormatter.dateFormat =timeFormat;
    
    // Format the current time using the date formatter
    NSString *formattedTime = [dateFormatter stringFromDate:currentTime];
    
    originalTimeFormatter.dateFormat = formattedTime;

        if (!self.isShowingSeconds) {

      [UIView transitionWithView:originalTimeView
                          duration:0.3 // Duration of the fade, consider adjusting if too fast
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            // Redundantly set the time again within the animation for visual effect
                            [originalTimeView performSelector:@selector(_updateTimeString) withObject:formattedTime];
                        } completion:^(BOOL finished) {
                            // Ensure the final state is correct
                            if (!finished) {
                                [originalTimeView performSelector:@selector(_updateTimeString) withObject:formattedTime];
                           
                                       self.isShowingSeconds = YES;

                            }
                        }];
self.isShowingSeconds = YES;


}
else
{
[originalTimeView performSelector:@selector(_updateTimeString) withObject:formattedTime];

}
}


%new
-(void)updateTimeLabel:(BOOL)showSeconds {
    dispatch_async(dispatch_get_main_queue(), ^{
        CSProminentTimeView* timeView = MSHookIvar<CSProminentTimeView*>(self.view, "_timeView");
        NSDateFormatter* timeFormatter = MSHookIvar<NSDateFormatter*>(timeView, "_timeFormatter");


    switch (timeFormatCase) {
        case 0: // ExtraLight
            timeFormat = @"HH:mm";
            break;
        case 1: // Light
            timeFormat = @"hh:mm";
            break;
    }


        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSString *newFormat = timeFormatCase == 0 ? @"HH:mm" : @"hh:mm";
        dateFormatter.dateFormat = newFormat;
        NSString *newTimeString = [dateFormatter stringFromDate:[NSDate date]];

//self.isShowingSeconds = NO;

        if (self.isShowingSeconds != showSeconds) {
            [UIView transitionWithView:timeView
                              duration:0.35
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                timeFormatter.dateFormat = newFormat;
                                [timeView performSelector:@selector(_updateTimeString) withObject:newTimeString];
                            } completion:nil];

            // Update the state
            self.isShowingSeconds = showSeconds;
        } else {
            // Update without animation
            timeFormatter.dateFormat = newFormat;
            [timeView performSelector:@selector(_updateTimeString) withObject:newTimeString];
        }
    });
}





%end


%hook CSProminentTimeView

%new
- (float)expectedLabelWidth:(UILabel *)label {
    [label setNumberOfLines:1];
    CGSize expectedLabelSize = [label.text sizeWithAttributes:@{NSFontAttributeName: label.font}];
    return expectedLabelSize.width + 3; // Adjust for a little extra space to prevent truncation.
}

- (void)layoutSubviews {
    %orig;

     Class UIAnimatingLabelClass = NSClassFromString(@"_UIAnimatingLabel");
 
 
     for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:UIAnimatingLabelClass]) {
            UILabel *labelSubview = (UILabel *)subview;
            float newWidth = [self expectedLabelWidth:labelSubview] / 1.2;
            float newX = (self.bounds.size.width - newWidth) / 2.0; // Calculate new X to keep label centered
            

             [labelSubview setFrame:CGRectMake(newX, labelSubview.frame.origin.y, newWidth, labelSubview.frame.size.height)];
            
             break;
        }
    }
}

%end
%end

#define tweakPlist ROOT_PATH_NS(@"/var/mobile/Library/Preferences/com.b4db1r3.lstsprefs.plist")

#define LISTEN_NOTIF(_call, _name) CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)_call, CFSTR(_name), NULL, CFNotificationSuspensionBehaviorCoalesce);

 
void loadPrefs() {
    // Fetch the NSUserDefaults for your tweak
    NSDictionary *prefs = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.b4db1r3.lstsprefs"];
    if (prefs) {
        timeFormatCase = [prefs[@"timeFormatCase"] intValue];
        isUsingADO = [prefs[@"isUsingADO"] boolValue];
    }
}

%ctor {
    loadPrefs();
    
    if (isIOS15()) {
        %init(iOS15);  
    } else if (isIOS16()) {
        %init(iOS16);  
    }

    LISTEN_NOTIF(loadPrefs, "com.b4db1r3.lstsprefs/reloadPrefs")	
}
