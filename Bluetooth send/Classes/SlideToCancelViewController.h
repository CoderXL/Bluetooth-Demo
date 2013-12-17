//
//  SlideToCancelViewController.h
//  SlideToCancel
//

#import <UIKit/UIKit.h>

@protocol SlideToCancelDelegate;

@interface SlideToCancelViewController : UIViewController {
	UIImageView *sliderBackground;
	UISlider *slider;
	UILabel *label;
	NSTimer *animationTimer;
	id <SlideToCancelDelegate> delegate;
	BOOL touchIsDown;
	CGFloat gradientLocations[3];
	int animationTimerCount;
}

@property (nonatomic, assign) id <SlideToCancelDelegate> delegate;


@property (nonatomic) BOOL enabled;

// Access the UILabel, e.g. to change text or color
@property (nonatomic, readonly) UILabel *label;

@end

@protocol SlideToCancelDelegate

@required
- (void) cancelled;

@end
