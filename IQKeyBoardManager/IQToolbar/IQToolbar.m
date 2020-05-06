//
//  IQToolbar.m
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-16 Iftekhar Qurashi.
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

#import "IQToolbar.h"
#import "IQKeyboardManagerConstantsInternal.h"
#import "IQTitleBarButtonItem.h"
#import "IQUIView+Hierarchy.h"

#import <UIKit/UIViewController.h>

@implementation IQToolbar
@synthesize titleFont = _titleFont;
@synthesize title = _title;

Class IQUIToolbarTextButtonClass;
Class IQUIToolbarButtonClass;


+(void)load
{
    IQUIToolbarTextButtonClass = NSClassFromString(@"UIToolbarTextButton");
    IQUIToolbarButtonClass = NSClassFromString(@"UIToolbarButton");

    //Tint Color
    [[self appearance] setTintColor:nil];

    [[self appearance] setBarTintColor:nil];
    
    //Background image
    [[self appearance] setBackgroundImage:nil forToolbarPosition:UIBarPositionAny           barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forToolbarPosition:UIBarPositionBottom        barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forToolbarPosition:UIBarPositionTop           barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forToolbarPosition:UIBarPositionTopAttached   barMetrics:UIBarMetricsDefault];
    
    //Shadow image
    [[self appearance] setShadowImage:nil forToolbarPosition:UIBarPositionAny];
    [[self appearance] setShadowImage:nil forToolbarPosition:UIBarPositionBottom];
    [[self appearance] setShadowImage:nil forToolbarPosition:UIBarPositionTop];
    [[self appearance] setShadowImage:nil forToolbarPosition:UIBarPositionTopAttached];
    
    //Background color
    [[self appearance] setBackgroundColor:nil];
}

-(void)initialize
{
    [self sizeToFit];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;// | UIViewAutoresizingFlexibleHeight;
    self.translucent = YES;
    [self setTintColor:[UIColor blackColor]];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self initialize];
    }
    return self;
}

-(CGSize)sizeThatFits:(CGSize)size
{
    CGSize sizeThatFit = [super sizeThatFits:size];

    sizeThatFit.height = 44;
    
    return sizeThatFit;
}

-(void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];

    for (UIBarButtonItem *item in self.items)
    {
        [item setTintColor:tintColor];
    }
}

-(void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    
    for (UIBarButtonItem *item in self.items)
    {
        if ([item isKindOfClass:[IQTitleBarButtonItem class]])
        {
            [(IQTitleBarButtonItem*)item setFont:titleFont];
        }
    }
}

-(void)setTitle:(NSString *)title
{
    _title = title;
    
    for (UIBarButtonItem *item in self.items)
    {
        if ([item isKindOfClass:[IQTitleBarButtonItem class]])
        {
            [(IQTitleBarButtonItem*)item setTitle:title];
        }
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect leftRect = CGRectNull;
    CGRect rightRect = CGRectNull;
    BOOL isIOS_11 = [[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0;
    BOOL isTitleBarButtonFound = NO;
    if (isIOS_11) {
        if( CGRectIsNull(leftRect) == true && CGRectIsNull(rightRect) == true){
            if(isTitleBarButtonFound == false){
                NSArray *itemA = self.items;
                for (id sub in itemA){
                    NSLog(@"%@",sub);
                    if([sub isKindOfClass:[IQBarButtonItem class]] && isTitleBarButtonFound == false ){
                        IQBarButtonItem *left = ((IQBarButtonItem*)sub);
                        SEL selector = NSSelectorFromString(@"previousAction:");
                        if(left.action == selector){
                            leftRect = [self getFrameOfBarItem:left];
                            isTitleBarButtonFound = YES;
                        }
                    }else if ([sub isKindOfClass:[IQBarButtonItem class]] && isTitleBarButtonFound == true){
                        IQBarButtonItem *done = ((IQBarButtonItem*)sub);
                        SEL selector = NSSelectorFromString(@"doneAction:");
                        if(done.action == selector){
                            rightRect = [self getFrameOfBarItem:done];
                            break;
                        }
                    }
                }
            }
        }
        
    }else{
        NSArray *subviews = [self.subviews sortedArrayUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2) {
            
            CGFloat x1 = CGRectGetMinX(view1.frame);
            CGFloat y1 = CGRectGetMinY(view1.frame);
            CGFloat x2 = CGRectGetMinX(view2.frame);
            CGFloat y2 = CGRectGetMinY(view2.frame);
            
            if (x1 < x2)  return NSOrderedAscending;
            
            else if (x1 > x2) return NSOrderedDescending;
            
            //Else both y are same so checking for x positions
            else if (y1 < y2)  return NSOrderedAscending;
            
            else if (y1 > y2) return NSOrderedDescending;
            
            else    return NSOrderedSame;
        }];
        
        static Class IQUIToolbarTextButtonClass = Nil;
        static Class IQUIToolbarButtonClass     = Nil;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            IQUIToolbarTextButtonClass = NSClassFromString(@"UIToolbarTextButton");
            IQUIToolbarButtonClass = NSClassFromString(@"UIToolbarButton");
        });
        for (UIView *barButtonItemView in subviews)
        {
            if (isTitleBarButtonFound == YES)
            {
                rightRect = barButtonItemView.frame;
                break;
            }
            else if ([barButtonItemView isMemberOfClass:[UIView class]])
            {
                isTitleBarButtonFound = YES;
            }
            else if ([barButtonItemView isKindOfClass:IQUIToolbarTextButtonClass] ||
                     [barButtonItemView isKindOfClass:IQUIToolbarButtonClass])
            {
                leftRect = barButtonItemView.frame;
            }
        }
    }
    CGFloat x = 16;
    if (CGRectIsNull(leftRect) == false)
    {
        x = CGRectGetMaxX(leftRect) + 16;
    }
    if (((CGRectIsNull(leftRect) == true) || (CGRectEqualToRect(leftRect, CGRectZero))) && isIOS_11 ){
        return;
    }
    //320 -32 - 37 - (320 - 254) // for IPhone 5s
    CGFloat width = CGRectGetWidth(self.frame) - 32 - (CGRectIsNull(leftRect)?0:CGRectGetMaxX(leftRect)) - (CGRectIsNull(rightRect)?0:CGRectGetWidth(self.frame)-CGRectGetMinX(rightRect));
    
    if(width == INFINITY) {
        width = 120; // for future If some logic failed we have some  static width available
        // NSLog(@"Width of title is not adjusted perfectly, Please spare some time to fix that");
    }
    // we can fix this logic in ios 11 check but i beleive we are ok to go with current ongoing
    for (UIBarButtonItem *item in self.items)
    {
        if ([item isKindOfClass:[IQTitleBarButtonItem class]])
        {
            CGRect titleRect = CGRectMake(x, 0, width, self.frame.size.height);
            if(CGRectIsNull(titleRect) == true)
                break;
            if(isIOS_11){
                if(CGRectEqualToRect(item.customView.frame, CGRectZero) ){
                    item.customView.frame =titleRect;
                    // item.customView.backgroundColor = [UIColor orangeColor];
                }
            }else{
                item.customView.frame =titleRect;
            }
            
        }
    }
}

#pragma mark - UIInputViewAudioFeedback delegate
- (BOOL) enableInputClicksWhenVisible
{
    return YES;
}

-(CGRect)getFrameOfBarItem:(UIBarButtonItem*)item{
    UIView *view = [item valueForKey:@"view"];
    CGRect rect;
    if(view){
        rect = [view frame];
    }
    else{
        rect=CGRectZero ;
    }
    return rect;
}

@end
