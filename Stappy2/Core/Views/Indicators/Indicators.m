//
//  Indicators.m
//  Stappy2
//
//  Created by Denis Grebennicov on 26/03/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "Indicators.h"

@interface Indicators ()
@property (nonatomic) NSInteger currentPage;
@end

@implementation Indicators

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviewFromNib];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addSubviewFromNib];
    }
    return self;
}

- (UIView *)viewFromNib
{
    Class class = [self class];
    NSString *nibName = NSStringFromClass(class);
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    UIView *view = [nibViews objectAtIndex:0];
    return view;
}

- (void)addSubviewFromNib
{
    UIView *view = [self viewFromNib];
    view.frame = self.bounds;
    [self addSubview:view];
    
    self.maxNumberOfIndicatorsPerPage = 3;
    self.totalNumberOfPages = 0;
    self.currentIndicator = 0;
}

#pragma mark - Setters

- (void)setCurrentIndicator:(NSInteger)currentIndicator
{
    _currentIndicator = currentIndicator;
    
    [self setCurrentPage:_currentIndicator / _maxNumberOfIndicatorsPerPage];
    
    _pageControl.currentPage = _currentIndicator % _maxNumberOfIndicatorsPerPage;
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    _currentPage = currentPage;
    
    NSInteger lastPage = (_totalNumberOfPages - 1) / _maxNumberOfIndicatorsPerPage;
    
    if (currentPage == lastPage) {
        _pageControl.numberOfPages = _totalNumberOfPages == _maxNumberOfIndicatorsPerPage ? _maxNumberOfIndicatorsPerPage : _totalNumberOfPages % _maxNumberOfIndicatorsPerPage;
    } else {
        _pageControl.numberOfPages = MIN(_maxNumberOfIndicatorsPerPage, _totalNumberOfPages);
    }
    
    if (currentPage < lastPage) {
        _rightArrow.hidden = NO;
    } else {
        _rightArrow.hidden = YES;
    }
    
    if (currentPage > 0) {
        _leftArrow.hidden = NO;
    } else {
        _leftArrow.hidden = YES;
    }
}

- (void)setTotalNumberOfPages:(NSInteger)totalNumberOfPages
{
    _totalNumberOfPages = totalNumberOfPages;
    
    _pageControl.numberOfPages = MIN(_maxNumberOfIndicatorsPerPage, _totalNumberOfPages);
}

@end
