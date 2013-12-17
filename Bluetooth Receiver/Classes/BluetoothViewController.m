//
//  BluetoothViewController.m
//  Bluetooth
//
//  Created by King on 11-8-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BluetoothViewController.h"
#import <QuartzCore/QuartzCore.h>




NSString * const bank						=@"kBank";					
NSString * const cnumber					=@"kCardnumber";								
NSString * const money						=@"kMoney";





@implementation BluetoothViewController


@synthesize currentSession;
@synthesize picker;

@synthesize bankLabel;
@synthesize cnumberLabel;
@synthesize moneyLabel;


@synthesize connectionButton;





#define ANIM_ROTATE		@"animationRotate"
#define ANIM_FALLING	@"animationFalling"
#define ANIM_GROUP		@"animationFallingRotate"



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

	// Create the slider
	[super viewDidLoad];
	bankLabel.text = nil;
	cnumberLabel.text = nil;

	moneyLabel.text = nil;

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


//方法功能：接受数据
-(void)receiveData:(NSData*)data fromPeer:(NSString*)peer inSession:(GKSession*)session context:(void*)context
{
    // Read the bytes in data and perform an application-specific action, then free the NSData object

	[self animationShow];
	NSString* aStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	NSDictionary *ndata = [[aStr JSONValue] retain];
	
	NSLog(@"接受数据: %@", ndata);
	
	bankLabel.text = [ndata objectForKey:bank];
	cnumberLabel.text = [ndata objectForKey:cnumber];
	
	NSString *atr = [ndata objectForKey:money];
	moneyLabel.text =[[NSString alloc] initWithString:[NSString stringWithFormat:@"￥%@.00",atr]];
	
	
	
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





/*****************************************************************************************************/

- (void)animationShow
{
	
	UIImage* image = [UIImage imageNamed:@"image.png"];
	m_pMyImageView = [[UIImageView alloc] initWithImage:image];
	
	m_pMyImageView.center = CGPointMake(160, 0);
	[self.view addSubview:m_pMyImageView];
	
	//在层上做旋转动画
	CAAnimation* myAnimationRotate	= [self animationRotate];;
	CAAnimation* myAnimationFallingDown		= [self animationFallingDown];;
	CAAnimation* myAnimationShrink			= [self animationShrink];
	
#if 0//method1:依次把各个动画加入层中
	[m_pMyImageView.layer addAnimation:myAnimationRotateForever forKey:ANIM_ROTATE];
	[m_pMyImageView.layer addAnimation:myAnimationFallingDown forKey:ANIM_FALLING];
	
#else//work well :)
	//method2:放入动画数组，统一处理！
	m_pGroupAnimation	= [CAAnimationGroup animation];
	
	//设置动画代理
	m_pGroupAnimation.delegate = self;
	
	m_pGroupAnimation.removedOnCompletion = NO;
	
	m_pGroupAnimation.duration			 = 2.0;
	m_pGroupAnimation.timingFunction      = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];	
	m_pGroupAnimation.repeatCount		 = 1;//FLT_MAX;  //"forever";
	m_pGroupAnimation.fillMode			 = kCAFillModeForwards;
	m_pGroupAnimation.animations			 = [NSArray arrayWithObjects:myAnimationRotate, 
												myAnimationFallingDown, 
												myAnimationShrink,
												nil];
	//对视图自身的层添加组动画
	[m_pMyImageView.layer addAnimation:m_pGroupAnimation forKey:ANIM_GROUP];
	
#endif
	
}

//动画结束后的委托函数，移除动画视图
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
	//这边为什么是nil? :(
	NSLog(@"anim = %@", [m_pMyImageView.layer valueForKey:ANIM_GROUP]);
#if 1
	//识别动画
	//？debug发现两者的地址不一样，这个问题很纠结
	if ([anim isEqual:m_pGroupAnimation])//[m_pMyImageView.layer valueForKey:ANIM_GROUP])
	{
		NSLog(@"removeFromSuperview...");
		[m_pMyImageView removeFromSuperview];
		[m_pMyImageView release];
		
	}
#else
	//这种方法，虽然能解决方法，但是处理多个CAAnimationGroup动画或者CAAnimation动画时，就不能有效处理，方法待定
	//这组动画结束，移除视图
	if ([anim isKindOfClass:[CAAnimationGroup class]])
	{
		//这边为什么是nil? :(
		NSLog(@"anim = %@", [m_pMyImageView.layer valueForKey:ANIM_GROUP]);
		
		[m_pMyImageView removeFromSuperview];
		[m_pMyImageView release];
		
	}
#endif	
}

/*
 * 1、make rotate
 */
- (CAAnimation *)animationRotate
{
	// rotate animation
	CATransform3D rotationTransform  = CATransform3DMakeRotation(M_PI, 1.0, 0, 0.0);
	
    CABasicAnimation* animation;
    animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    
	animation.toValue		= [NSValue valueWithCATransform3D:rotationTransform];
    animation.duration		= 0.5;
	animation.autoreverses	= NO;
    animation.cumulative	= YES;
    animation.repeatCount	= FLT_MAX;  //"forever"
	//设置开始时间，能够连续播放多组动画
	animation.beginTime		= 0.5;
	//设置动画代理
	animation.delegate		= self;
	
	return animation;
}

/*
 * 2、fall down
 */
- (CAAnimation *)animationFallingDown
{
	//falling down animation:
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
	
	animation.duration				= 2.0;
	animation.autoreverses			= NO;
	animation.removedOnCompletion	= NO;
	animation.repeatCount			= FLT_MAX;  //"forever"
	animation.fromValue				= [NSNumber numberWithInt: 0];
	animation.toValue				= [NSNumber numberWithInt: 900];
	//设置动画代理
	animation.delegate				= self;
	
	return animation;
}

/*
 * 3、shrink animation
 */
- (CAAnimation *)animationShrink
{
	
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	
    animation.toValue = [NSNumber numberWithDouble:2.0];
	
    animation.duration				= 3.0;
    animation.autoreverses			= YES;
	animation.repeatCount			= FLT_MAX;  //"forever"
	animation.removedOnCompletion	= NO;
	
	//设置动画代理
	animation.delegate				= self;
	
	return animation;
}
/*****************************************************************************************************/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	
	self.connectionButton = nil;
}






- (void)dealloc {
    [super dealloc];
	[bankLabel release];
	[cnumberLabel release];
	[moneyLabel release];
	

	[connectionButton release];
	[picker release];

}

@end
