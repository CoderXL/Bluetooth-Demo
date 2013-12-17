//
//  BluetoothViewController.m
//  Bluetooth
//
//  Created by King on 11-8-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BluetoothViewController.h"

@implementation BluetoothViewController

@synthesize currentSession;
@synthesize picker;
@synthesize slideToCancel;
@synthesize scrollView;

@synthesize bankField;
@synthesize cnumberField;
@synthesize moneyField;


@synthesize connectionButton;



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先连接蓝牙" delegate:self 
										  cancelButtonTitle:@"确定" otherButtonTitles:nil];
	[alert show];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(textFieldTextDidChanged:)
												 name:UITextFieldTextDidChangeNotification
											   object:nil];

	// Create the slider
	slideToCancel = [[SlideToCancelViewController alloc] init];
	slideToCancel.delegate = self;
	
	// Position the slider off the bottom of the view, so we can slide it up
	CGRect sliderFrame = slideToCancel.view.frame;
	sliderFrame.origin.y = self.view.frame.size.height;
	slideToCancel.view.frame = sliderFrame;
	
	// Add slider to the view
	[self.view addSubview:slideToCancel.view];
	
	

	
	[super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self checkData];
}
- (void)viewDidDisappear:(BOOL)animated;  
{
	[super viewDidAppear:animated];
}




//点击其他地方隐藏键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

	[bankField resignFirstResponder];
	[cnumberField resignFirstResponder];
	[moneyField resignFirstResponder];
}


- (void)keyboardWillShow:(NSNotification *)notification
{
	[self.scrollView setContentOffset:CGPointMake(0, 40) animated:YES];
}


- (void)keyboardWillHide:(NSNotification *)notification
{
	[self.scrollView setContentOffset:CGPointZero animated:YES];
}



#pragma mark UITextFieldDelegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == bankField) {
		if ([textField.text length] <= 0) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请确认正确的发卡行" delegate:self 
												  cancelButtonTitle:@"确定" otherButtonTitles:nil];
			[alert show];
			return NO;
		}
		[cnumberField becomeFirstResponder];
	}
	else if(textField == cnumberField) {
		if ([textField.text length] < 16) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请确认输入的为16为的信用卡号" delegate:self 
												  cancelButtonTitle:@"确定" otherButtonTitles:nil];
			[alert show];
			return NO;
		}
		[moneyField becomeFirstResponder];
	}
	else if(textField == moneyField){
		if ([textField.text length] <= 0) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"金额不能为空" delegate:self 
												  cancelButtonTitle:@"确定" otherButtonTitles:nil];
			[alert show];
			return NO;
		}
		[moneyField resignFirstResponder];
		return YES;
	}
	[self showSlide];
	return YES;
}

- (void)textFieldTextDidChanged:(NSNotification *)notification
{
	//	NSLog(@"n : %@", notification);
	[self checkData];
}


//方法功能：开启连接
- (IBAction) connectionButtonTapped:(id) sender{

	
    // allocate and setup the peer picker controller
	picker = [[GKPeerPickerController alloc] init];
    picker.delegate = self;
    picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    [picker show];

}


- (GKSession *) peerPickerController:(GKPeerPickerController *)picker
			sessionForConnectionType:(GKPeerPickerConnectionType)type {
    currentSession = [[GKSession alloc] initWithSessionID:@"FR" displayName:nil sessionMode:GKSessionModePeer];
    currentSession.delegate = self;
	
    return currentSession;
}


//方法功能：判断数据传输状态
-(void)session:(GKSession*)session peer:(NSString*)peerID didChangeState:(GKPeerConnectionState)state
{
	switch (state) {
		case GKPeerStateConnected:
			[self.currentSession setDataReceiveHandler :self withContext:nil];
			[connectionButton setEnabled:NO];
			//[DisconnectButton setEnabled:YES];
			NSLog(@"连接");
			break;
		case GKPeerStateDisconnected:
			[connectionButton setEnabled:YES];
			//[DisconnectButton setEnabled:NO];
			NSLog(@"连接断开");
			[self.currentSession release];
			currentSession=nil;
			break;
	}
}



- (void)peerPickerController:(GKPeerPickerController *)picker didConnectToPeer:(NSString *)peerID {
    printf("连接成功！\n");
}


- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker {
    printf("连接尝试被取消 \n");
}



//发送数据
- (void) sendMessage
{
	msg = nil;

	NSString *bank = bankField.text;
	NSString *cardnumber = cnumberField.text;
	NSString *money = moneyField.text;
	
	
	msg = [NSDictionary dictionaryWithObjectsAndKeys:
		   bank, @"kBank",
		   cardnumber, @"kCardnumber",
		   money, @"kMoney", nil];	
	NSString * myString=[msg JSONRepresentation];
	NSLog(@"%@", myString);
	
	
	if (msg == nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请确认发送的数据不为空" delegate:self 
											  cancelButtonTitle:@"确定" otherButtonTitles:nil];
		[alert show];

	}
	else{
		myData = [myString dataUsingEncoding: NSUTF8StringEncoding];
		[currentSession sendDataToAllPeers :myData withDataMode:GKSendDataReliable error:nil];
		NSLog(@"发送数据: %@" ,myString);
	}
	bankField.text = nil;
	cnumberField.text = nil;
	moneyField.text = nil;
}

//方法功能：接受数据
-(void)receiveData:(NSData*)data fromPeer:(NSString*)peer inSession:(GKSession*)session context:(void*)context
{
    // Read the bytes in data and perform an application-specific action, then free the NSData object

	NSString* aStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
    //receiverTextView.text =aStr;
	
	NSDictionary *ndata = [[aStr JSONValue] retain];
	
	NSLog(@"接受数据: %@", ndata);
	
	
	
}


//方法功能：断开链接
- (IBAction) DisconnectButtonTapped:(id) sender{

	[self.currentSession disconnectFromAllPeers];
	currentSession=nil;
	[connectionButton setEnabled:YES];
	//[DisconnectButton setEnabled:NO];
	
}


//方法功能：发送一个数据包
-(void)mySendDataToPeers:(NSMutableData*)data
{
	if (currentSession) {
		[self.currentSession sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
	}
}


//方法功能：连接失败
-(void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString*)peerID toSession:(GKSession *)session{
	self.currentSession=session;
	session.delegate=self;
	[session setDataReceiveHandler:self withContext:nil];
	picker.delegate=nil;
	[picker dismiss];
	
}



- (void) showSlide{
	// Start the slider animation
	slideToCancel.enabled = YES;
	
	// Slowly move up the slider from the bottom of the screen
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	CGPoint sliderCenter = slideToCancel.view.center;
	sliderCenter.y -= slideToCancel.view.bounds.size.height;
	slideToCancel.view.center = sliderCenter;
	[UIView commitAnimations];
	
	
}

// SlideToCancelDelegate method is called when the slider is slid all the way
// to the right
- (void) cancelled {
	// Disable the slider and re-enable the button
	slideToCancel.enabled = NO;
	//testItButton.enabled = YES;
	
	// Slowly move down the slider off the bottom of the screen
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	CGPoint sliderCenter = slideToCancel.view.center;
	sliderCenter.y += slideToCancel.view.bounds.size.height;
	slideToCancel.view.center = sliderCenter;
	[UIView commitAnimations];
	[self sendMessage];
}

- (void) checkData{
	
	BOOL b = YES;
	
	if ([bankField.text length] <= 0)  {
		b = NO;
		
	}
	else if([cnumberField.text length] < 16) {
		b = NO;
	}
	else if([moneyField.text length] <= 0){
		b = NO;
	}
	if ( !b ) {
		slideToCancel.enabled = NO;

	}
	else {
		slideToCancel.enabled = YES;
	}
	
}





- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	
	self.scrollView = nil;
	self.bankField = nil;
	self.cnumberField = nil;
	self.moneyField = nil ;
}






- (void)dealloc {
    [super dealloc];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
	
	[slideToCancel release];
	[scrollView release];
	[connectionButton release];
	
	

	
	[bankField release];
	[cnumberField release];
	[moneyField release];
	[picker release];


}

@end
