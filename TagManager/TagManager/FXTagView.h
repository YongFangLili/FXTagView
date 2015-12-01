//
//  FXTagsView.h
//  TagManager
//
//  Created by ftxbird on 15/11/27.
//  Copyright © 2015年 ftxbird. All rights reserved.
//


#import <UIKit/UIKit.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@class FXTagTextField;
@class FXTagView;


@protocol FXTagViewDelegate<NSObject>

@optional
/**
 *  Tags容器 高度改变回调
 *
 *  @param tagView 所在容器
 *  @param height  容器最终高度
 */
-(void)heightDidChangedTagView:(FXTagView*)tagView height:(CGFloat)height;

/**
 *  选择显示模式下,单击点击选择的Tag文本
 *  @param tagView 所在容器
 *  @param text 选择的文本
 */
- (void)tagDidSelectText:(NSString *)text tagView:(FXTagView *)tagView;

/**
 *  选择显示模式下,取消选择的Tag文本
 *  @param tagView 所在容器
 *  @param text 选择的文本
 */
- (void)tagUnSelectText:(NSString *)text tagView:(FXTagView *)tagView;


/**
 *  标签点击删除回调
 *
 *  @param text    删除的文本
 *  @param tagView 所在容器
 */
- (void)tagDeletedText:(NSString *)text tagView:(FXTagView *)tagView;

@end

/**
 *  控件展示类型
 */
typedef NS_ENUM(NSInteger, ShowViewType) {
    /**
     *  纯展示,无交互功能
     */
    ShowViewTypeNormal = 0,
    /**
     *  展示 + 编辑
     */
    ShowViewTypeEdit,
    /**
     *  展示 + 选择
     */
    ShowViewTypeSelected
};



@interface FXTagView : UIView

/**展示类型*/
@property (nonatomic,assign) ShowViewType showType;

/**标签数组*/
@property (nonatomic,strong) NSMutableArray *tagsArray;

/**文本输入控件*/
@property (nonatomic,strong) FXTagTextField *inputTextField;

/**代理*/
@property (nonatomic,weak)   id<FXTagViewDelegate>tagDelegate;

/**标签边框颜色*/
@property (nonatomic,strong) UIColor *tagBorderColor;

/**标签背景颜色*/
@property (nonatomic,strong) UIColor *tagBackGroundColor;

/**标签字体颜色*/
@property (nonatomic,strong) UIColor *tagFontColor;

/**标签字体大小*/
@property (nonatomic,strong) UIFont  *tagFont;

/**标签选择颜色*/
@property (nonatomic,strong) UIColor *tagSeletedColor;



/**
 *  标签View 初始化方法 (仅供纯代码创建使用)
 *
 *  @param frame    tagView初始Frame
 *  @param showType 展示类型
 *
 *  @return 返回TagView实例
 */
+ (instancetype)tagViewFrame:(CGRect)frame showType:(ShowViewType)showType;

/**
 *  标签View 初始化方法 (仅供纯代码创建使用)

 *
 *  @param frame    tagView初始Frame
 *  @param showType 展示类型
 *  @param tags     默认文本数组
 *
 *  @return 返回TagView实例
 */
+ (instancetype)tagViewFrame:(CGRect)frame showType:(ShowViewType)showType showTagArray:(NSArray *)tags;


/**
 *  添加一个Tag   (已优化为从重用池取, 还可以继续优化不用整个遍历!!!)
 *
 *  @param tagString 待添加Tag文本
 */
- (void)addTag:(NSString *)tagString;

/**
 *  添加一个数组字符串
 *
 *  @param tags 待添加字符串数组
 */
- (void)addTags:(NSArray *)tags;

/**
 *  移除一个Tag
 *
 *  @param tagString 待移除Tag文本
 */
- (void)removeTag:(NSString *)tagString;


/**
 *  改变指定字符串 的控件选择状态
 *
 *  @param tagString 待改变状态控件的文本
 */
- (void)changeTagStateSpecialTag:(NSString *)tagString;
@end
