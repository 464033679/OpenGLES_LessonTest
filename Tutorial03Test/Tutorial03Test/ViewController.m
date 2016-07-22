//
//  ViewController.m
//  Tutorial03Test
//
//  Created by 李明 on 13-1-20.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize openglView;
@synthesize controlView;
@synthesize posXSlider;
@synthesize posYSlider;
@synthesize posZSlider;
@synthesize AngleXSlider;
@synthesize AngleYSlider;
@synthesize AngleZSlider;
@synthesize ScaleXSlider;
@synthesize ScaleYSlider;
@synthesize ScaleZSlider;

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-150);
    self.openglView = [[[OpenGLView alloc] initWithFrame:frame] autorelease];
    [self.view addSubview: self.openglView];
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
//    [self.openglView cleanup];
    self.openglView = nil;
    self.controlView = nil;
    self.posXSlider = nil;
    self.posYSlider = nil;
    self.posZSlider = nil;
    self.AngleXSlider = nil;
    self.AngleYSlider = nil;
    self.AngleZSlider = nil;
    self.ScaleXSlider = nil;
    self.ScaleYSlider = nil;
    self.ScaleZSlider = nil;
}
-(IBAction)xSliderValueChanged:(UISlider *)sender
{
    self.openglView.trans_x = sender.value;
}
-(IBAction)ySliderValueChanged:(UISlider *)sender
{
    self.openglView.trans_y = sender.value;
}
-(IBAction)zSliderValueChanged:(UISlider *)sender
{
    self.openglView.trans_z = sender.value;
}
-(IBAction)xAngleSliderchanged:(UISlider *)sender
{
    self.openglView.angle_x = sender.value;
}
-(IBAction)yAngleSliderchanged:(UISlider *)sender
{
    self.openglView.angle_y = sender.value;
}
-(IBAction)zAngleSliderchanged:(UISlider *)sender
{
    self.openglView.angle_z = sender.value;
}
-(IBAction)xScaleSliderchanged:(UISlider *)sender
{
    self.openglView.scale_x = sender.value;
}
-(IBAction)yScaleSliderchanged:(UISlider *)sender
{
    self.openglView.scale_y = sender.value;
}
-(IBAction)zScaleSliderchanged:(UISlider *)sender
{
    self.openglView.scale_z = sender.value;
}
-(IBAction)resetButtonclicked:(UIButton *)sender
{
    [self.openglView resetTransform];
    [self.openglView render];
    [self resetcontrols];
    
}
-(void)resetcontrols
{
    self.posXSlider.value = self.openglView.trans_x;
    self.posYSlider.value = self.openglView.trans_y;
    self.posZSlider.value = self.openglView.trans_z;
    
    self.AngleXSlider.value = self.openglView.angle_x;
    self.AngleYSlider.value = self.openglView.angle_y;
    self.AngleZSlider.value = self.openglView.angle_z;
    
    self.ScaleXSlider.value = self.openglView.scale_x;
    self.ScaleYSlider.value = self.openglView.scale_y;
    self.ScaleZSlider.value = self.openglView.scale_z;
}
-(IBAction)autoButtonClicked:(UIButton *)sender
{
    [self.openglView toggleDisplayLink];
    if([sender.titleLabel.text isEqualToString:@"Auto"])
    {
        [sender setTitle:@"Stop" forState:UIButtonTypeRoundedRect];
    }
    else {
        [sender setTitle:@"Auto" forState:UIButtonTypeRoundedRect];
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
