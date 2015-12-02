//
//  ViewController.m
//  TagManager
//
//  Created by johnny on 15/11/27.
//  Copyright © 2015年 ftxbird. All rights reserved.
//

#import "ViewController.h"
#import "FXTagView.h"


@interface ViewController ()<FXTagViewDelegate>

@property (weak, nonatomic) IBOutlet FXTagView *editTagView;
@property (weak, nonatomic) IBOutlet FXTagView *selectTagView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectedHeight;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightTextColor];
    
    /**
     *  以下展示的是比较复杂的页面操作. 每种模式可以单独使用.
     */
    
    //可编辑的 TagView
    self.editTagView.showType   = ShowViewTypeEdit;
    
    //限制只能输入 中文,英文,数字
    self.editTagView.limitChar  = YES;
    
    //可选择的 TagView
    self.selectTagView.showType = ShowViewTypeSelected;
    
    //可强制列等分
    // self.selectTagView.forceColumnNum =YES;
    
    //可选择的 TagView 添加默认展示 字符串数组
    [self.selectTagView addTags:@[@"你好",@"好好学习",@"天天向上",@"大宝天天见",@"好",@"中国",@"你好"]];
    
    //添加代理
    self.editTagView.tagDelegate =self;
    
    self.selectTagView.tagDelegate = self;

}



- (void)tagDidSelectText:(NSString *)selectText tagView:(FXTagView *)tagView{
    NSLog(@"%@",selectText);
    
    [self.editTagView addTag:selectText];
}


- (void)tagUnSelectText:(NSString *)unSelectText tagView:(FXTagView *)tagView{

    NSLog(@"%@",unSelectText);
    [self.editTagView removeTag:unSelectText];
}

- (void)heightDidChangedTagView:(FXTagView *)tagView height:(CGFloat)height {
    if (self.editTagView == tagView) {
        self.editViewHeight.constant = height;
        [self.view layoutIfNeeded];
    }else if (self.selectTagView == tagView) {
    
        self.selectedHeight.constant = height;
        [self.view layoutIfNeeded];
    }
    
}


- (void)tagDeletedText:(NSString *)text tagView:(FXTagView *)tagView {

    [self.selectTagView changeTagStateSpecialTag:text];
    NSLog(@"删除文本%@",text);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
