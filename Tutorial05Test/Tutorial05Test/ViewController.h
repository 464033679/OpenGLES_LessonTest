//
//  ViewController.h
//  Tutorial05Test
//
//  Created by 李明 on 13-1-24.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"
@interface ViewController : UIViewController
{
    OpenGLView *_openGLview;
}
@property(nonatomic,strong)OpenGLView *openGLview;
-(IBAction)SegmentChanged:(UISegmentedControl *)sender;
@end
