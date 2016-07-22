//
//  ViewController.h
//  Tutorial06Test
//
//  Created by 李明 on 13-1-31.
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
}
@property (nonatomic,strong)OpenGLView *openGLView;
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
@end
