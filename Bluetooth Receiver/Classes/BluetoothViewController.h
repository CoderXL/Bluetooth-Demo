//
//  BluetoothViewController.h
//  Bluetooth
//
//  Created by King on 11-8-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import <QuartzCore/QuartzCore.h>

extern NSString * const bank;					
extern NSString * const cnumber;									
extern NSString * const money;


@interface BluetoothViewController : UIViewController <GKPeerPickerControllerDelegate, GKSessionDelegate> {
	/*GKSession对象用于表现两个蓝牙设备之间连接的一个会话，你也可以使用它在两个设备之间发送和接收数据。*/
	GKSession				*currentSession;
	GKPeerPickerController	*picker;
	
	UIButton				*connectionButton;
	
	UILabel					*bankLabel;
	UILabel					*cnumberLabel;
	UILabel					*moneyLabel;
	
	UIImageView				*m_pMyImageView;
	CAAnimationGroup		*m_pGroupAnimation;
}
@property (nonatomic, retain) GKSession *currentSession;
@property (nonatomic, retain) GKPeerPickerController *picker;

@property (nonatomic, retain) IBOutlet UIButton *connectionButton;
@property (nonatomic, retain) IBOutlet UILabel *bankLabel;
@property (nonatomic, retain) IBOutlet UILabel *cnumberLabel;
@property (nonatomic, retain) IBOutlet UILabel *moneyLabel;


- (IBAction) connectionButtonTapped:(id) sender;

//动画
- (CAAnimation *)animationRotate;
- (CAAnimation *)animationFallingDown;
- (CAAnimation *)animationShrink;
- (void)animationShow;
@end

