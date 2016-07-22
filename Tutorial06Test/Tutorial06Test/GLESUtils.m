//
//  GLESUtils.m
//  Tutorial01Test
//
//  Created by 李明 on 13-1-18.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "GLESUtils.h"

@implementation GLESUtils
+(GLuint)loadShader:(GLenum)type withString:(NSString *)shaderstring
{
    GLuint shader = glCreateShader(type);
    if(shader == 0)
    {
        NSLog(@"fail to create shader");
        return 0;
    }
    const char *shaderStringUTF8 = [shaderstring UTF8String];
    glShaderSource(shader, 1, &shaderStringUTF8, NULL);
    glCompileShader(shader);//编译
    GLint compiled = 0;
    glGetShaderiv(shader, GL_COMPILE_STATUS,&compiled);
    if(!compiled)
    {
        GLint infoLen = 0;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLen);
        if(infoLen > 1)
        {
            char *infoLog = malloc(sizeof(char)*infoLen);
            glGetShaderInfoLog(shader, infoLen, NULL, infoLog);
            NSLog(@"Error compiling shader :\n%s\n",infoLog);
            free(infoLog);
        }
        glDeleteShader(shader);
        return 0;
    }
    return shader;
}
+(GLuint)loadshader:(GLenum)type withFilePath:(NSString *)shaderFilePath
{
    NSError *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:shaderFilePath encoding:NSUTF8StringEncoding error:&error];
    if(!shaderString)
    {
        NSLog(@"Error :Loading shader file :%@ %@",shaderFilePath,error.localizedDescription);
        return 0;
    }
    return [self loadShader:type withString:shaderString];
}
+(GLuint)loadProgramVertexShaderFilepath:(NSString *)vertexShaderFilePath withFragmentShaderFilepath:(NSString *)fragmentShaderFilePath
{
    GLuint vertexShader = [self loadshader:GL_VERTEX_SHADER withFilePath:vertexShaderFilePath];
    if(!vertexShader)
        return 0;
    GLuint fragmentShader = [self loadshader:GL_FRAGMENT_SHADER withFilePath:fragmentShaderFilePath];
    if(!fragmentShader)
        return 0;
    GLuint programHandle = glCreateProgram();
    if(!programHandle)
        return 0;
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    GLint linked;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linked);
    if(!linked)
    {
        GLint infoLen = 0;
        glGetProgramiv(programHandle, GL_INFO_LOG_LENGTH, &infoLen);
        if(infoLen > 1)
        {
            char *infoLog = malloc(sizeof(char)*infoLen);
            glGetProgramInfoLog(programHandle, infoLen, NULL, infoLog);
            NSLog(@"fail to link program:\n%s\n",infoLog);
            free(infoLog);
        }
        glDeleteProgram(programHandle);
        return 0;
        
    }
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    return programHandle;
}
@end
