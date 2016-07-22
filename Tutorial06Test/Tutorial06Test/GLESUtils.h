//
//  GLESUtils.h
//  Tutorial01Test
//
//  Created by 李明 on 13-1-18.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <OpenGLES/ES2/gl.h>
@interface GLESUtils : NSObject
+(GLuint)loadShader:(GLenum)type withString:(NSString *)shaderstring;
+(GLuint)loadshader:(GLenum)type withFilePath:(NSString *)shaderFilePath;
+(GLuint)loadProgramVertexShaderFilepath:(NSString *)vertexShaderFilePath withFragmentShaderFilepath:(NSString *)fragmentShaderFilePath;
@end
