// AKTab.m
//
// Copyright (c) 2012 Ali Karagoz (http://alikaragoz.net)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AKTab.h"

// cross fade animation duration.
static const float kAnimationDuration = 0.15;

// Minimum height that permits the display of the tab's title.
static const float kMinimumHeightTodisplayTabTitle = 35.0;

static const float kPadding = 6.0;
static const float kMargin = 4.0;
static const float kTopMargin = 2.0;

@interface AKTab ()

// Permits the cross fade animation between the two images, duration in seconds.
- (void)animateContentWithDuration:(CFTimeInterval)duration;

// Inverted CGContextClipToMask.
- (void)AKContectClipToMask:(UIImage *)image rect:(CGRect)rect context:(CGContextRef)context offset:(CGPoint)offset;

@end

@implementation AKTab

@synthesize tabImageWithName, tabTitle;

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - Touche handeling

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self animateContentWithDuration:kAnimationDuration];
}

#pragma mark - Animation

- (void)animateContentWithDuration:(CFTimeInterval)duration
{    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"contents"];
    animation.duration = duration;
    [self.layer addAnimation:animation forKey:@"contents"];
}

#pragma mark - Drawing

- (void)AKContectClipToMask:(UIImage *)image rect:(CGRect)rect context:(CGContextRef)context offset:(CGPoint)offset
{
    CGContextTranslateCTM(context, offset.x, offset.y);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, rect, image.CGImage);
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
                
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    // Used to scale the image in landscape mode
    CGFloat scale = 1.0;
    
    // the scale when the device is rotated.
    if (UIDeviceOrientationIsLandscape(orientation)) {
        scale = [UIScreen mainScreen].bounds.size.height / [UIScreen mainScreen].bounds.size.width;
    }
    
    BOOL displayTabTitle = (rect.size.height >= kMinimumHeightTodisplayTabTitle) ? YES : NO;
    
    // Rect containing the title and the image
    CGRect contentRect = CGRectMake(rect.origin.x, rect.origin.y + kTopMargin, rect.size.width, rect.size.height - kTopMargin);
    contentRect.origin.y += floorf(kPadding / 2);
    contentRect.size.height -= kPadding;
    
    // Title label
    UILabel *tabTitleLabel = [[UILabel alloc] init];
    tabTitleLabel.text = self.tabTitle;
    tabTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:11.0];
    [tabTitleLabel sizeToFit];
    
    CGRect labelRect = tabTitleLabel.bounds;
    labelRect.origin.x = floorf(CGRectGetMidX(contentRect) - labelRect.size.width / 2);
    labelRect.origin.y = CGRectGetMaxY(contentRect) - labelRect.size.height;
    
    // We reset the label's rect if we do not want to display the title
    if (!displayTabTitle) labelRect = CGRectZero;
        
    // tab's image
    UIImage *image = [UIImage imageNamed:self.tabImageWithName];
    
    CGFloat ratio = image.size.width / image.size.height;
    CGRect imageRect = CGRectZero;
    imageRect.size.height = floorf((contentRect.size.height - labelRect.size.height - kMargin));
    imageRect.size.width = floorf(imageRect.size.height * ratio);
    imageRect.origin.x = floorf(CGRectGetMidX(contentRect) - imageRect.size.width / 2);
    imageRect.origin.y = contentRect.origin.y;
            
    CGContextRef ctx = UIGraphicsGetCurrentContext();
        
    CGFloat offsetY = rect.size.height - (labelRect.size.height);
    
    if (!self.selected) {
        
        // We draw the vertical lines for the border
        CGContextSaveGState(ctx);
        {
            CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
            CGContextSetRGBFillColor(ctx, 0.7, 0.7, 0.7, 0.1);
            CGContextFillRect(ctx, CGRectMake(0, kTopMargin, 1, rect.size.height - kTopMargin));
            CGContextFillRect(ctx, CGRectMake(rect.size.width - 1, 2, 1, rect.size.height - 2));
        }
        CGContextRestoreGState(ctx);
                    
        // We draw the inner shadow which is just the image mask with an offset of 1 pixel
        CGContextSaveGState(ctx);
        {
            CGContextTranslateCTM(ctx, 0, offsetY - 1);
            CGContextScaleCTM(ctx, 1.0, -1.0);
            CGContextClipToMask(ctx, imageRect, image.CGImage);
            CGContextSetRGBFillColor(ctx, 0, 0, 0, 0.8);
            CGContextFillRect(ctx, imageRect);
        }
        CGContextRestoreGState(ctx);
                
        // We draw the inner gradient
        CGContextSaveGState(ctx);
        {
            CGContextTranslateCTM(ctx, 0, offsetY);
            CGContextScaleCTM(ctx, 1.0, -1.0);
            CGContextClipToMask(ctx, imageRect, image.CGImage);
            
            size_t num_locations = 2;
            CGFloat locations[2] = {1.0, 0.0};
            CGFloat components[8] = {0.353, 0.353, 0.353, 1.0, // Start color
                                    0.612, 0.612, 0.612, 1.0};  // End color
            
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColorComponents (colorSpace, components, locations, num_locations);
            
            CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, imageRect.origin.y + imageRect.size.height), CGPointMake(0, imageRect.origin.y), kCGGradientDrawsAfterEndLocation);

        }
        CGContextRestoreGState(ctx);
        
        if (displayTabTitle) {
            CGContextSaveGState(ctx);
            {
                CGContextSetRGBFillColor(ctx, 0.461, 0.461, 0.461, 1);
                [tabTitleLabel.text drawInRect:labelRect withFont:tabTitleLabel.font];
            }
            CGContextRestoreGState(ctx);
        }
        
    } else if (self.selected) {
        
        // We fill the background with a noise pattern
        CGContextSaveGState(ctx);
        {
            [[UIColor colorWithPatternImage:[UIImage imageNamed:@"noise-pattern"]] set];
            CGContextFillRect(ctx, rect);
            
            // We set the parameters of th gradient multiply blend
            size_t num_locations = 2;
            CGFloat locations[2] = {1.0, 0.0};
            CGFloat components[8] = {0.6, 0.6, 0.6, 1.0,  // Start color
                                    0.2, 0.2, 0.2, 0.4}; // End color
            
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColorComponents (colorSpace, components, locations, num_locations);
            CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
            CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, kTopMargin), CGPointMake(0, rect.size.height - kTopMargin), kCGGradientDrawsAfterEndLocation);
            
            // top dark emboss
            CGContextSetBlendMode(ctx, kCGBlendModeNormal);
            CGContextSetRGBFillColor(ctx, 0.1, 0.1, 0.1, 0.8);
            CGContextFillRect(ctx, CGRectMake(0, 0, rect.size.width, 1));
        }
        CGContextRestoreGState(ctx);
        
        // We draw the vertical lines for the border
        CGContextSaveGState(ctx);
        {
            CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
            CGContextSetRGBFillColor(ctx, 0.7, 0.7, 0.7, 0.4);
            CGContextFillRect(ctx, CGRectMake(0, 2, 1, rect.size.height - 2));
            CGContextFillRect(ctx, CGRectMake(rect.size.width - 1, 2, 1, rect.size.height - 2));
        }
        CGContextRestoreGState(ctx);
        
        // We draw the outer glow
        CGContextSaveGState(ctx);
        {
            CGContextTranslateCTM(ctx, 0.0, offsetY);
            CGContextScaleCTM(ctx, 1.0, -1.0);
            CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 10.0, [UIColor colorWithRed:0.169 green:0.418 blue:0.547 alpha:1].CGColor);
            CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
            CGContextDrawImage(ctx, imageRect, image.CGImage);
            
        }
        CGContextRestoreGState(ctx);
                    
        // We draw the inner gradient
        CGContextSaveGState(ctx);
        {
            CGContextTranslateCTM(ctx, 0, offsetY);
            CGContextScaleCTM(ctx, 1.0, -1.0);
            CGContextClipToMask(ctx, imageRect, image.CGImage);
            
            size_t num_locations = 2;
            CGFloat locations[2] = {1.0, 0.2};
            CGFloat components[8] = {0.082, 0.369, 0.663, 1.0, // Start color
                                    0.537, 0.773, 0.988, 1.0};  // End color
            
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColorComponents (colorSpace, components, locations, num_locations);
            
            CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, imageRect.origin.y + imageRect.size.height), CGPointMake(0, imageRect.origin.y), kCGGradientDrawsAfterEndLocation);
            
        }
        CGContextRestoreGState(ctx);
        
        
        // We draw the glossy effect over the image
        CGContextSaveGState(ctx);
        {   
            // Center of the circle
            CGFloat posX = CGRectGetMinX(rect);
            CGFloat posY = CGRectGetMinY(rect) - rect.size.width;
            
            // Getting the icon center position plus an arbitrary offset
            CGFloat dX = CGRectGetMidX(imageRect) - posX + kTopMargin;
            CGFloat dY = CGRectGetMidY(imageRect) - posY + kTopMargin;
            
            // Calculating the radius
            CGFloat radius = sqrtf((dX * dX) + (dY * dY));
           
            // We draw the circular path
            CGMutablePathRef glossPath = CGPathCreateMutable();
            CGPathAddArc(glossPath, NULL, posX, posY, radius, M_PI, 0, YES);
            CGPathCloseSubpath(glossPath);
            CGContextAddPath(ctx, glossPath);
            CGContextClip(ctx);
            
            // Clipping to the image path
            CGContextTranslateCTM(ctx, 0, offsetY);
            CGContextScaleCTM(ctx, 1.0, -1.0);
            CGContextClipToMask(ctx, imageRect, image.CGImage);
            
            // Drawing the clipped gradient
            size_t num_locations = 2;
            CGFloat locations[2] = {0, 1};
            CGFloat components[8] = {1.0, 1.0, 1.0, 0.4, // Start color
                                    1.0, 1.0, 1.0, 0.1};  // End color
            
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColorComponents (colorSpace, components, locations, num_locations);
            
            CGContextDrawLinearGradient(ctx, gradient, CGPointMake(rect.origin.x, rect.origin.y), CGPointMake(rect.size.width, image.size.height), kCGGradientDrawsAfterEndLocation);
            
        }
        CGContextRestoreGState(ctx);
        
        if (displayTabTitle) {
            CGContextSaveGState(ctx);
            {
                CGContextSetRGBFillColor(ctx, 0.961, 0.961, 0.961, 1);
                [tabTitleLabel.text drawInRect:labelRect withFont:tabTitleLabel.font];
            }
            CGContextRestoreGState(ctx);
        }
        
    }
}

@end
