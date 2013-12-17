//
//  BluetoothAppDelegate.h
//  Bluetooth
//
//  Created by King on 11-8-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BluetoothViewController;

@interface BluetoothAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    BluetoothViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet BluetoothViewController *viewController;

@end

