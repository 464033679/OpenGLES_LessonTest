//
//  ViewController.m
//  Tutorial07Test
//
//  Created by 李明 on 13-2-1.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize openGLView;
@synthesize btn = _btn;
-(IBAction)lightSliderX:(UISlider *)sender
{
    lightPosition = self.openGLView.lightPosition;
    lightPosition.x = sender.value;
    self.openGLView.lightPosition = lightPosition;
    
}
-(IBAction)lightSliderY:(UISlider *)sender
{
    lightPosition = self.openGLView.lightPosition;
    lightPosition.y = sender.value;
    self.openGLView.lightPosition = lightPosition;
}
-(IBAction)lightSliderZ:(UISlider *)sender
{
    lightPosition = self.openGLView.lightPosition;
    lightPosition.z = sender.value;
    self.openGLView.lightPosition = lightPosition;
}
-(IBAction)ambientSliderR:(UISlider *)sender
{
    ambient.r = sender.value;
    self.openGLView.ambient = ambient;
}
-(IBAction)ambientSliderG:(UISlider *)sender
{
    ambient = self.openGLView.ambient;
    ambient.g = sender.value;
    self.openGLView.ambient = ambient;
}
-(IBAction)ambientSliderB:(UISlider *)sender
{
    ambient = self.openGLView.ambient;
    ambient.b = sender.value;
    self.openGLView.ambient = ambient;
}
-(IBAction)diffuseSliderR:(UISlider *)sender
{
    diffuse = self.openGLView.diffuse;
    diffuse.r = sender.value;
    self.openGLView.diffuse = diffuse;
}
-(IBAction)diffuseSliderG:(UISlider *)sender
{
    diffuse = self.openGLView.diffuse;
    diffuse.g = sender.value;
    self.openGLView.diffuse = diffuse;
}
-(IBAction)diffuseSliderB:(UISlider *)sender
{
    diffuse = self.openGLView.diffuse;
    diffuse.b = sender.value;
    self.openGLView.diffuse = diffuse;
}
-(IBAction)specularSliderR:(UISlider *)sender
{
    specular = self.openGLView.specular;
    specular.r = sender.value;
    self.openGLView.specular = specular;
}
-(IBAction)specularSliderG:(UISlider *)sender
{
    specular = self.openGLView.specular;
    specular.g = sender.value;
    self.openGLView.specular = specular;
}
-(IBAction)specularSliderB:(UISlider *)sender
{
    specular = self.openGLView.specular;
    specular.b = sender.value;
    self.openGLView.specular = specular;
}
-(IBAction)shininessSlider:(UISlider*)sender
{
    self.openGLView.shininess = sender.value;
}
-(IBAction)buttonClicked:(UIButton *)sender
{
    NSLog(@"sender'tag = %d",sender.tag);
    if(sender.tag ==1)
    {
         
        self.openGLView.shaderflag = sender.tag;
        sender.tag = 2;
    }
    else {
        self.openGLView.shaderflag = sender.tag;
        sender.tag = 1;
        NSLog(@"123123");
    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-200);
	self.openGLView = [[[OpenGLView alloc] initWithFrame:rect] autorelease];
    [self.view addSubview:self.openGLView];
    NSLog(@"tag = %d",self.btn.tag);
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
