//
//  ViewController.h
//  Tutorial07Test
//
//  Created by 李明 on 13-2-1.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"
@interface ViewController : UIViewController
{
    ksVec3 lightPosition;
    ksColor ambient;
    ksColor diffuse;
    ksColor specular;
    UIButton *_btn;
}
@property (nonatomic,strong)OpenGLView *openGLView;
@property (nonatomic,retain) IBOutlet UIButton *btn;
-(IBAction)lightSliderX:(UISlider *)sender;
-(IBAction)lightSliderY:(UISlider *)sender;
-(IBAction)lightSliderZ:(UISlider *)sender;
-(IBAction)ambientSliderR:(UISlider *)sender;
-(IBAction)ambientSliderG:(UISlider *)sender;
-(IBAction)ambientSliderB:(UISlider *)sender;
-(IBAction)diffuseSliderR:(UISlider *)sender;
-(IBAction)diffuseSliderG:(UISlider *)sender;
-(IBAction)diffuseSliderB:(UISlider *)sender;
-(IBAction)specularSliderR:(UISlider *)sender;
-(IBAction)specularSliderG:(UISlider *)sender;
-(IBAction)specularSliderB:(UISlider *)sender;
-(IBAction)shininessSlider:(UISlider*)sender;
-(IBAction)buttonClicked:(UIButton *)sender;
@end
