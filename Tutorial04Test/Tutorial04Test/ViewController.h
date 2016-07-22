//
//  ViewController.h
//  Tutorial04Test
//
//  Created by 李明 on 13-1-22.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"
@interface ViewController : UIViewController
{
    OpenGLView *_openGlview;
}
@property(nonatomic,strong)OpenGLView *openGlview;
-(IBAction)OnShoulderSliderValueChanged:(UISlider *)sender;
-(IBAction)OnElbowSliderValueChanged:(UISlider *)sender;
-(IBAction)OnRotateButtonClicked:(UIButton *)sender;

@end
