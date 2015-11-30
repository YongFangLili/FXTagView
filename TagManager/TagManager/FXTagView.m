//
//  FXTagsView.m
//  TagManager
//
//  Created by ftxbird on 15/11/27.
//  Copyright © 2015年 ftxbird. All rights reserved.
//

#import "FXTagView.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]  


CGFloat const columnSpace = 5;        //列间距
CGFloat const rowSpace = 5;           //行间距
CGFloat const rowHeight = 44;         //行高
NSInteger const limitTagCount = 15;     //标签数量限制
NSInteger const limitTagWordCount = 15; //单标签文本字数限制

@interface FXTagTextField : UITextField

@end

@implementation FXTagTextField

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 9 , 0 );
}


- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 9 , 0 );
}

@end


@interface FXTagView()<UITextFieldDelegate>

/**当前容器高度*/
@property (nonatomic,assign) CGFloat currentViewHeight;

/**设置标签字体*/
@property (nonatomic,strong) UIFont  *tagFont;

/**设置标签颜色*/
@property (nonatomic,strong) UIColor *tagFontColor;

/**设置标签左边距*/
@property (nonatomic,assign) CGFloat tagLeftSpace;

/**缓存TagsButton*/
@property (nonatomic,strong) NSArray *tagButtonPool;

/**单击删除按钮*/
@property (nonatomic,strong) UIButton *tagDeleteButton;


@end


@implementation FXTagView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

+ (instancetype)tagViewFrame:(CGRect)frame showType:(ShowViewType)showType {

    FXTagView *tagView = [[FXTagView alloc] initWithFrame:frame];
    tagView.showType = showType;
    
    switch (showType) {
        case ShowViewTypeNormal: {
            
            break;
        }
        case ShowViewTypeEdit: {
            //添加输入框
            [tagView addSubview:tagView.inputTextField];
            break;
        }
        case ShowViewTypeSelected: {
            
            break;
        }
        default: {
            break;
        }
    }
    
    return tagView;
}


+ (instancetype)tagViewFrame:(CGRect)frame showType:(ShowViewType)showType showTagArray:(NSArray *)tags {
    FXTagView *tagView = [self tagViewFrame:frame showType:showType];
    [tagView addTags:tags];
    
    return tagView;
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillShowMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
}


- (void)commonInit {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WillShowMenu:) name:UIMenuControllerWillShowMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HideMenu:) name:UIMenuControllerDidHideMenuNotification object:nil];
    
    _currentViewHeight = self.frame.size.height;
    
    _showType = ShowViewTypeNormal;
    
    _tagFont = [UIFont systemFontOfSize:14.0f];
    
    _tagsArray = [NSMutableArray array];

    self.backgroundColor = [UIColor orangeColor];
    
    //初始化重用池
    [self initReusableButtonPool];
}

/**
 *  点击标签,弹出删除菜单
 *
 *  @param sender 所点击的标签
 */
- (void)tagButtonSelected:(UIButton *)sender {
    
    if (self.showType == ShowViewTypeEdit) {
        [self becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        if (sender.selected) {
            [sender setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [sender setBackgroundColor:UIColorFromRGB(0xf0f0f0)];
            sender.selected=NO;
            [menu setMenuVisible:NO animated:YES];
        }else{
            [menu setMenuVisible:NO];
            [_tagDeleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_tagDeleteButton setBackgroundColor:UIColorFromRGB(0xf0f0f0)];
            _tagDeleteButton.selected=NO;
            _tagDeleteButton=sender;
            [menu setTargetRect:sender.frame inView:self];
            [menu setMenuVisible:YES animated:YES];
        }
    }else if(self.showType == ShowViewTypeSelected) {
    
        sender.selected = !sender.selected;
        
        if (sender.selected) {
            sender.layer.borderColor = [UIColor blueColor].CGColor;
            sender.layer.borderWidth = 2.0f;
            
            if([self.tagDelegate respondsToSelector:@selector(tagDidSelectText:tagView:)]){
                [self.tagDelegate tagDidSelectText:sender.currentTitle tagView:self];
            }
        }else {
            sender.layer.borderColor = [UIColor whiteColor].CGColor;
            sender.layer.borderWidth = 1.0f;
            
            if([self.tagDelegate respondsToSelector:@selector(tagUnSelectText:tagView:)]){
                [self.tagDelegate tagUnSelectText:sender.currentTitle tagView:self];
            }
        }
    }
    
    
}

/**
 *  退格键删除标签 **** 待完成
 *
 *  @param sender
 */
- (void)deleteBackspace:(UIButton *)sender{
    
    if (sender.selected) {
        [self removeTag:sender.currentTitle];
    }else{
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sender setBackgroundColor:[UIColor grayColor]];
        sender.selected=YES;
    }
}

/**
 *  添加一个Tag   ***此处可优化为不用整个遍历创建
 *
 *  @param tagString 待添加Tag文本
 */
- (void)addTag:(NSString *)tagString {

    tagString = [tagString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (tagString.length==0) {
        NSLog(@"不能输入空白标签!");
        return;
    }
    
    if (tagString.length>limitTagWordCount) {
        NSLog(@"最多10个字!");
        return;
    }
    
    for (NSString *title in self.tagsArray)
    {
        if ([tagString isEqualToString:title])
        {
            NSLog(@"已存在相同标签!");
            return;
        }
    }
    
    if (self.tagsArray.count == limitTagCount) {
        NSLog(@"超过标签数量限制,当前限制15个");
        return;
    }

    [self.tagsArray addObject:tagString];

    [self layoutSubviews];

}

/**
 *  添加一个数组字符串
 *
 *  @param tags 待添加字符串数组
 */
- (void)addTags:(NSArray *)tags {
    
    if(!tags || !tags.count) return;
    
    for (NSString *tag in tags)
    {
        NSArray *result = [_tagsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF == %@", tag]];
        if (result.count == 0)
        {
            [_tagsArray addObject:tag];
        }
    }
    
    [self layoutSubviews];
}


/**
 *  移除一个Tag
 *
 *  @param tagString 待移除Tag文本
 */
- (void)removeTag:(NSString *)tagString {
    
    NSInteger foundedIndex = -1;
    for (NSString *tempTagString in self.tagsArray)
    {
        if ([tagString isEqualToString:tempTagString])
        {
            NSLog(@"FOUND!");
            foundedIndex = (NSInteger)[self.tagsArray indexOfObject:tempTagString];
            break;
        }
    }
    
    if (foundedIndex == -1)
    {
        return;
    }
    [self.tagsArray removeObjectAtIndex:foundedIndex];
    
    [self layoutSubviews];
}

/**
 *  判断是否需要换行
 *
 *  @param currentX 当前移动X点
 *  @param btnWidth 当前要添加的宽度
 *
 *  @return Bool 是否需要换行
 */
- (BOOL)ifNeedAddRowCurrentX:(CGFloat)currentX  width:(CGFloat)btnWidth {
    
    //当前剩余宽度
    CGFloat restSpace = self.frame.size.width - currentX - columnSpace;
    
    //判断待加入按钮是否大于剩余宽度
    if (btnWidth > restSpace) {
        return YES;
    }else {
        return NO;
    }
}


- (void)layoutSubviews {

    //移除之前的子控件
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
    //设置tagsArray,创建添加tag控件,并设置Frame
    //设置起点XY
    CGFloat moveX  = columnSpace;
    CGFloat moveY  = rowSpace;
    
    for (NSInteger i=0 ; i<self.tagsArray.count; i++) {
        
        NSString *tagText = (NSString *)[self.tagsArray objectAtIndex:i];
        UIButton *tagBtn = [self tagButtonWithTag:tagText index:i];
        CGFloat btnWidth = [tagBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:_tagFont}].width  + 20.0f;
        
        if([self ifNeedAddRowCurrentX:moveX width:btnWidth]){
            moveX = columnSpace;
            moveY += (44+rowSpace);
        }
        tagBtn.frame = CGRectMake(moveX, moveY, btnWidth, rowHeight);
        moveX += btnWidth + columnSpace;
        [self addSubview:tagBtn];
    }
    
    //更新 输入框 Frame
    if(self.showType == ShowViewTypeEdit) {
        BOOL addRowForTextField = [self ifNeedAddRowCurrentX:moveX width:self.inputTextField.frame.size.width];
        if (addRowForTextField) {
            moveX = columnSpace;
            moveY += (44 +rowSpace);
        }
        self.inputTextField.frame = CGRectMake(moveX, moveY, 80, rowHeight);
    }
    
    //更新容器Frame
    CGRect tempFrame = self.frame;
    
    tempFrame.size.height = moveY + rowHeight + columnSpace;
    
    self.frame = tempFrame;
}

/**
 *  初始化重用池
 */
- (void)initReusableButtonPool {
    NSMutableArray *tempArray = [NSMutableArray array];
    
    for (NSInteger i =0; i< limitTagCount; i++) {
        UIButton *tagBtn = [UIButton new];
        [tagBtn.titleLabel setFont:_tagFont];
        [tagBtn setBackgroundColor:UIColorFromRGB(0xf0f0f0)];
        [tagBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        tagBtn.layer.cornerRadius = 4;
        tagBtn.layer.masksToBounds = YES;
        [tempArray addObject:tagBtn];
    }
    self.tagButtonPool = [tempArray copy];
}

/**
 *  获取重用池中的TagButton
 *
 *  @return Button
 */
- (UIButton *)dequeueReusableTagButton:(NSInteger)tag {

    if (self.tagButtonPool.count<=0) return nil;
    
    UIButton *button = [self.tagButtonPool objectAtIndex:tag];

    return button;
    
}

- (UIButton *)tagButtonWithTag:(NSString *)tagTitle index:(NSInteger)index
{
    //从重用池取
    UIButton *tagBtn = [self dequeueReusableTagButton:index];
    [tagBtn setTitle:tagTitle forState:UIControlStateNormal];
    //选择模式添加 点击事件
    if (self.showType == ShowViewTypeEdit||self.showType == ShowViewTypeSelected) {
        [tagBtn addTarget:self action:@selector(tagButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    }
    return tagBtn;
}


- (FXTagTextField *)inputTextField {

    if (_inputTextField == nil) {
        FXTagTextField* tf = [[FXTagTextField alloc] initWithFrame:CGRectMake(0, 0, 100, rowHeight)];
        tf.backgroundColor = [UIColor whiteColor];
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
        [tf addTarget:self action:@selector(textFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
        tf.delegate = self;
        tf.placeholder=@"请输入标签";
        tf.returnKeyType = UIReturnKeyDone;
        _inputTextField = tf;
    }
    return _inputTextField;
}

#pragma dataCheck






#pragma textField delegate 

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
   
    [self addTag:textField.text];
    _inputTextField.text=nil;
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {

}

- (void)textFieldDidEndEditing:(UITextField *)textField {

    
}

- (void)textFieldDidChange:(FXTagTextField *)textField {


}

#pragma mark - Custom Menu

- (void)HideMenu:(NSNotification *)notification{
    [_tagDeleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_tagDeleteButton setBackgroundColor:UIColorFromRGB(0xf0f0f0)];
    _tagDeleteButton.selected=NO;
    _tagDeleteButton=nil;
}
- (void)WillShowMenu:(NSNotification *)notification{
    [_tagDeleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_tagDeleteButton setBackgroundColor:[UIColor grayColor]];
    _tagDeleteButton.selected=YES;
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (_tagDeleteButton) {
        return action == @selector(delete:);
    }
    return NO;
}

- (void)delete:(id)sender{
    [self removeTag:_tagDeleteButton.currentTitle];
}

@end