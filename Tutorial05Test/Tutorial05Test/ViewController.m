//
//  ViewController.m
//  Tutorial05Test
//
//  Created by 李明 on 13-1-24.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize openGLview;
- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-150);
	self.openGLview = [[[OpenGLView alloc] initWithFrame:rect] autorelease];
    [self.view addSubview:self.openGLview];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.openGLview = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
-(IBAction)SegmentChanged:(UISegmentedControl *)sender
{
    self.openGLview.selectedSegment = sender.selectedSegmentIndex;
}
@end
