//
//  BluetoothViewController.h
//  Bluetooth
//
//  Created by King on 11-8-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "SlideToCancelViewController.h"

@interface BluetoothViewController : UIViewController <GKPeerPickerControllerDelegate, GKSessionDelegate, SlideToCancelDelegate> {
	/*GKSession对象用于表现两个蓝牙设备之间连接的一个会话，你也可以使用它在两个设备之间发送和接收数据。*/
	GKSession				*currentSession;
	GKPeerPickerController	*picker;
	
	SlideToCancelViewController *slideToCancel;
	UIScrollView			*scrollView;
	
	UITextField				*bankField;
	UITextField				*cnumberField;

	UITextField				*moneyField;
	
	
	
	UIButton				*connectionButton;

	
	NSData					*myData;
	NSDictionary			*msg;
	
	


}
@property (nonatomic, retain) GKSession *currentSession;
@property (nonatomic, retain) GKPeerPickerController *picker;
@property (nonatomic, retain) SlideToCancelViewController *slideToCancel;

@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;

@property (nonatomic, retain) IBOutlet UITextField *bankField;
@property (nonatomic, retain) IBOutlet UITextField *cnumberField;
@property (nonatomic, retain) IBOutlet UITextField *moneyField;


@property (nonatomic, retain) IBOutlet UIButton *connectionButton;




- (IBAction) connectionButtonTapped:(id) sender;
- (void)showSlide;
- (void)checkData;

@end

