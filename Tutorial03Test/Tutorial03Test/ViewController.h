//
//  ViewController.h
//  Tutorial03Test
//
//  Created by 李明 on 13-1-20.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"
@interface ViewController : UIViewController
{
    
}
@property (nonatomic,strong) IBOutlet UIView *controlView;
@property (nonatomic,strong) OpenGLView *openglView;
@property (nonatomic,strong) IBOutlet UISlider *posXSlider;
@property (nonatomic,strong) IBOutlet UISlider *posYSlider;
@property (nonatomic,strong) IBOutlet UISlider *posZSlider;
@property (nonatomic,strong) IBOutlet UISlider *AngleXSlider;
@property (nonatomic,strong) IBOutlet UISlider *AngleYSlider;
@property (nonatomic,strong) IBOutlet UISlider *AngleZSlider;
@property (nonatomic,strong) IBOutlet UISlider *ScaleXSlider;
@property (nonatomic,strong) IBOutlet UISlider *ScaleYSlider;
@property (nonatomic,strong) IBOutlet UISlider *ScaleZSlider;
-(IBAction)xSliderValueChanged:(UISlider *)sender;
-(IBAction)ySliderValueChanged:(UISlider *)sender;
-(IBAction)zSliderValueChanged:(UISlider *)sender;
-(IBAction)resetButtonclicked:(UIButton *)sender;
-(IBAction)autoButtonClicked:(UIButton *)sender;
-(void)resetcontrols;
@end
