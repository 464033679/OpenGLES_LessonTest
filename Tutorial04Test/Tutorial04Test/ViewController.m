//
//  ViewController.m
//  Tutorial04Test
//
//  Created by 李明 on 13-1-22.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize openGlview;
- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-90);
	self.openGlview = [[[OpenGLView alloc] initWithFrame:rect] autorelease];
    [self.view addSubview:self.openGlview];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.openGlview = nil;
    
}
-(IBAction)OnShoulderSliderValueChanged:(UISlider *)sender
{
    self.openGlview.angleShoulder = sender.value;
}
-(IBAction)OnElbowSliderValueChanged:(UISlider *)sender
{
    self.openGlview.angleEblow = sender.value;
}
-(IBAction)OnRotateButtonClicked:(UIButton *)sender
{
    if([sender.titleLabel.text isEqualToString:@"Rotate"])
    {
        [sender setTitle:@"Stop" forState:UIControlStateNormal];
    }
    else {
        [sender setTitle:@"Rotate" forState:UIControlStateNormal];
    }
    [self.openGlview toggleDisplayLink];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
