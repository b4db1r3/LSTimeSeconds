#import "XXXLabeledSliderCell.h"

@implementation XXXLabeledSliderCell {
	UIStackView *_stackView;
	UIStackView *_sliderStackView;
	UILabel *_sliderLabel;
	UILabel *_valueLabel;

}


	-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier {
		self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];

		if(self) {
			[specifier setProperty:@56 forKey:@"height"];

			NSBundle *bundle = [specifier.target bundle];
			NSString *label = [specifier propertyForKey:@"label"];
			NSString *localizationTable = [specifier propertyForKey:@"localizationTable"];

				//Create slider label with label property of specifier
			_sliderLabel = [[UILabel alloc] init];
			_sliderLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
			_sliderLabel.text = [bundle localizedStringForKey:label value:label table:localizationTable];
			_sliderLabel.translatesAutoresizingMaskIntoConstraints = NO;

				//Create value label
			_valueLabel = [[UILabel alloc] init];
			_valueLabel.font = [UIFont monospacedDigitSystemFontOfSize:10 weight:UIFontWeightBold];
			_valueLabel.text = [NSString stringWithFormat:@"%.01f", [[specifier performGetter] floatValue]];
			_valueLabel.userInteractionEnabled = YES;
			_valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
			[_valueLabel sizeToFit];

			_sliderStackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.control, _valueLabel]];
			_sliderStackView.alignment = UIStackViewAlignmentCenter;
			_sliderStackView.axis = UILayoutConstraintAxisHorizontal;
			_sliderStackView.distribution = UIStackViewDistributionFill;
			_sliderStackView.spacing = 5;
			_sliderStackView.translatesAutoresizingMaskIntoConstraints = NO;

			_stackView = [[UIStackView alloc] initWithArrangedSubviews:@[_sliderLabel, _sliderStackView]];
			_stackView.alignment = UIStackViewAlignmentCenter;
			_stackView.axis = UILayoutConstraintAxisVertical;
			_stackView.distribution = UIStackViewDistributionEqualCentering;
			_stackView.spacing = 0;
			_stackView.translatesAutoresizingMaskIntoConstraints = NO;
			[self.contentView addSubview:_stackView];

			[NSLayoutConstraint activateConstraints:@[
				[_stackView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:4],
				[_stackView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:15],
				[_stackView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-15],
				[_stackView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-4],

				[_sliderStackView.widthAnchor constraintEqualToAnchor:_stackView.widthAnchor],

				[_valueLabel.heightAnchor constraintEqualToAnchor:_sliderStackView.heightAnchor],
			]];

				//Add control events to update value label
			[self.control addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventTouchDragInside];
			[self.control addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventTouchDragOutside];
			[self.control addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];

				//Add gesture to value label to set custom value
			UITapGestureRecognizer *enterCustomValueTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setCustomSliderValue)];
			enterCustomValueTap.numberOfTapsRequired = 1;
			[_valueLabel addGestureRecognizer:enterCustomValueTap];

// _infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
// _infoButton.translatesAutoresizingMaskIntoConstraints = NO;
// [_infoButton addTarget:self action:@selector(infoButtonTapped) forControlEvents:UIControlEventTouchUpInside];
// [self.contentView addSubview:_infoButton];

// // Size constraints
// CGFloat buttonSize = 20; // Set the size you want
// [_infoButton addConstraint:[NSLayoutConstraint constraintWithItem:_infoButton
//                                                         attribute:NSLayoutAttributeHeight
//                                                         relatedBy:NSLayoutRelationEqual
//                                                            toItem:nil
//                                                         attribute:NSLayoutAttributeNotAnAttribute
//                                                        multiplier:1.0
//                                                          constant:buttonSize]];
// [_infoButton addConstraint:[NSLayoutConstraint constraintWithItem:_infoButton
//                                                         attribute:NSLayoutAttributeWidth
//                                                         relatedBy:NSLayoutRelationEqual
//                                                            toItem:nil
//                                                         attribute:NSLayoutAttributeNotAnAttribute
//                                                        multiplier:1.0
//                                                          constant:buttonSize]];

// Position constraints
[NSLayoutConstraint activateConstraints:@[
    // [_infoButton.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor constant:-14.5],
    // [_infoButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-105]
]];

		}

		return self;
	}

      //Show alert
  -(IBAction)infoButtonTapped {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *title = ([self.specifier propertyForKey:@"infoTitle"]) ?: [self.specifier propertyForKey:@"label"];
    NSString *message = [self.specifier propertyForKey:@"infoMessage"] ?: @"No information provided for this cell.";
    NSString *localizedMessage = [bundle localizedStringForKey:message value:message table:[self.specifier propertyForKey:@"localizationTable"]];

    UIAlertController *infoAlert = [UIAlertController alertControllerWithTitle:title message:[localizedMessage stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

    [infoAlert addAction:cancelAction];

    UIViewController *rootViewController = self._viewControllerForAncestor;
    if (!rootViewController) {
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        rootViewController = window.rootViewController;
    }
    [rootViewController presentViewController:infoAlert animated:YES completion:nil];
}


		//Present a alert with textfield to let the user enter a custom value
	-(void)setCustomSliderValue {
		UISlider *slider = (UISlider *)self.control;
		NSString *currentValue = [NSString stringWithFormat:@"%.02f", slider.value];

		UIAlertController *enterValueAlert = [UIAlertController alertControllerWithTitle:@"Enter Value" message:nil preferredStyle:UIAlertControllerStyleAlert];
		[enterValueAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
			textField.keyboardType = UIKeyboardTypeDecimalPad;
			textField.text = currentValue;
			textField.textColor = [UIColor orangeColor];
		}];

		UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Set" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			UITextField *textField = enterValueAlert.textFields[0];

			CGFloat newValue = [textField.text floatValue];

				//Check that value doesnt exceed limits
			if(newValue > slider.maximumValue) {
				newValue = slider.maximumValue;
			} else if(newValue < slider.minimumValue) {
				newValue = slider.minimumValue;
			}

 			[self.specifier performSetterWithValue:[NSNumber numberWithFloat:newValue]];
			[slider setValue:newValue animated:YES];
			[self sliderValueChanged:slider];
		}];

		UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

		[enterValueAlert addAction:confirmAction];
		[enterValueAlert addAction:cancelAction];

    UIViewController *rootViewController = [self appropriateViewController];
    [rootViewController presentViewController:enterValueAlert animated:YES completion:nil];
	}

- (UIViewController *)appropriateViewController {
    UIViewController *viewController = self._viewControllerForAncestor;

    if (!viewController) {
        NSArray *windows = [UIApplication sharedApplication].windows;
        for (UIWindow *window in windows) {
            if (window.isKeyWindow) {
                viewController = window.rootViewController;
                break;
            }
        }
    }

    while (viewController.presentedViewController) {
        viewController = viewController.presentedViewController;
    }

    return viewController;
}

		//Update value label when the value changes
	-(void)sliderValueChanged:(UISlider *)slider {
		_valueLabel.text = [NSString stringWithFormat:@"%.01f", slider.value];
	}

		//Tint the title and value labels
	-(void)tintColorDidChange {
		[super tintColorDidChange];

      //_infoButton.tintColor = [UIColor orangeColor];
		_sliderLabel.textColor = [UIColor orangeColor];
		_valueLabel.textColor = [UIColor orangeColor];
  }

	-(void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier {
		[super refreshCellContentsWithSpecifier:specifier];

		if([self respondsToSelector:@selector(tintColor)]) {
			_sliderLabel.textColor = [UIColor orangeColor];
			_valueLabel.textColor = [UIColor orangeColor];
			//_infoButton.tintColor = [UIColor orangeColor];

		}
	}
@end
