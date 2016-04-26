//
//  SZTextView.m
//  SZTextView
//
//  Created by glaszig on 14.03.13.
//  Copyright (c) 2013 glaszig. All rights reserved.
//

#import "SZTextView.h"

#define HAS_TEXT_CONTAINER [self respondsToSelector:@selector(textContainer)]
#define HAS_TEXT_CONTAINER_INSETS(x) [(x) respondsToSelector:@selector(textContainerInset)]

@interface SZTextView () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITextView *_placeholderTextView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *matchingSearchResults;


@end

static NSString * const kAttributedPlaceholderKey = @"attributedPlaceholder";
static NSString * const kPlaceholderKey = @"placeholder";
static NSString * const kFontKey = @"font";
static NSString * const kAttributedTextKey = @"attributedText";
static NSString * const kTextKey = @"text";
static NSString * const kExclusionPathsKey = @"exclusionPaths";
static NSString * const kLineFragmentPaddingKey = @"lineFragmentPadding";
static NSString * const kTextContainerInsetKey = @"textContainerInset";
static NSString * const kTextAlignmentKey = @"textAlignment";

@implementation SZTextView {
    int _currentWordIndex;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self preparePlaceholder];
        [self initialize];
    }
    return self;
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer
{
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self) {
        [self preparePlaceholder];
        [self initialize];
    }
    return self;
}
#else
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self preparePlaceholder];
        [self initialize];
    }
    return self;
}
#endif

- (void)initialize {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:self];
    
    [self setInputAccessoryView:self.tableView];
}

#pragma mark - Methods

- (void)textChanged:(NSNotification *)notification {
    [self setNeedsDisplay];
    
    NSRange selectedRange = self.selectedRange;
    
    UITextPosition *beginning = self.beginningOfDocument;
    UITextPosition *start = [self positionFromPosition:beginning offset:selectedRange.location];
    UITextPosition *end = [self positionFromPosition:start offset:selectedRange.length];
    
    UITextRange* textRange = [self.tokenizer rangeEnclosingPosition:end withGranularity:UITextGranularityWord inDirection:UITextLayoutDirectionLeft];
    
    NSString *wordTyped = [self textInRange:textRange];
    
    NSArray *wordsInSentence = [self.text componentsSeparatedByString:@" "];
    
    
    int indexInSavedArray = 0;
    
    for (NSString *string in wordsInSentence) {
        
        NSRange textRange = [self.text rangeOfString:string];
        
        if (selectedRange.location >= textRange.location && selectedRange.location <= (textRange.location + textRange.length) ) {
            NSLog(@"STRING: %@", string);
            
            if ([string hasPrefix:@"@"]) {
                NSLog(@"USER: %@", wordTyped);
                [self refreshSearchResultsWithUsername:string];
                _currentWordIndex = indexInSavedArray;
            } else if ([string hasPrefix:@"#"]) {
                NSLog(@"Hashtag: %@", wordTyped);
                [self refreshSearchResultsWithHashtag:string];
                _currentWordIndex = indexInSavedArray;
            } else {
                self.matchingSearchResults = [NSMutableArray array];
                [self.tableView reloadData];
            }
        }
        indexInSavedArray++;
    }
}

-(void)refreshSearchResultsWithHashtag: (NSString *)hashtag {
    
    if ([hashtag hasPrefix:@"#"]) {
        hashtag = [hashtag substringFromIndex:1];
    }
    
    NSArray *array = nil;
    
    NSMutableArray *formattedResults = [NSMutableArray array];
    
    if (hashtag.length > 0) {
        array = [self.hashtagsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH[c] %@", hashtag]];
    }
    
    for (NSString *hashtag in array) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:hashtag forKey:@"text"];
        [dictionary setObject:@"hashtag" forKey:@"type"];
        [formattedResults addObject:dictionary];
    }
    
    self.matchingSearchResults = formattedResults;
    [self.tableView reloadData];
    
}

-(void)refreshSearchResultsWithUsername: (NSString *)username {
    
    if ([username hasPrefix:@"@"]) {
        username = [username substringFromIndex:1];
    }
    
    NSArray *array = nil;
    NSMutableArray *formattedResults = [NSMutableArray array];
    
    if (username.length > 0) {
        array = [self.usernamesArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH[c] %@", username]];
    }
    
    for (NSString *username in array) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:username forKey:@"text"];
        [dictionary setObject:@"username" forKey:@"type"];
        [formattedResults addObject:dictionary];
    }
    
    self.matchingSearchResults = formattedResults;
    [self.tableView reloadData];
}

#pragma mark - UITableView Delegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *chosenDictionary = [self.matchingSearchResults objectAtIndex:indexPath.row];
    NSString *chosenWord = [chosenDictionary objectForKey:@"text"];
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:[self.text componentsSeparatedByString:@" "]];
    
    NSString *indexWord = [array objectAtIndex:_currentWordIndex];
    
    
    if ([indexWord hasPrefix:@"@"]) {
        
        [array replaceObjectAtIndex:_currentWordIndex withObject:[NSString stringWithFormat:@"@%@ ",chosenWord]];
        
    } else if ([indexWord hasPrefix:@"#"]) {
        
        [array replaceObjectAtIndex:_currentWordIndex withObject:[NSString stringWithFormat:@"#%@ ",chosenWord]];
    }
    
    NSString *totalString = [array componentsJoinedByString:@" "];
    [self setText:totalString];
    self.matchingSearchResults = nil;
    [self.tableView reloadData];
}


#pragma mark - UITableView Datasource Methods

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.matchingSearchResults.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *chosenDictionary = [self.matchingSearchResults objectAtIndex:indexPath.row];
    NSString *word = [chosenDictionary objectForKey:@"text"];
    NSString *type = [chosenDictionary objectForKey:@"type"];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    if ([type isEqualToString:@"hashtag"]) {
        word = [NSString stringWithFormat:@"#%@",word];
    } else {
        word = [NSString stringWithFormat:@"@%@",word];
    }
    
    [cell.textLabel setText:word];
    cell.transform = CGAffineTransformMakeRotation(M_PI);
    [cell setBackgroundColor:[UIColor whiteColor]];
    
    return cell;
}


#pragma mark - Properties

-(NSMutableArray *)matchingSearchResults {
    if (!_matchingSearchResults) {
        _matchingSearchResults = [NSMutableArray array];
    }
    return _matchingSearchResults;
}

-(UITableView *)tableView {
    if (!_tableView) {
        _tableView= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 88) style:UITableViewStylePlain];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setTransform:CGAffineTransformMakeRotation(-M_PI)];
        [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        [_tableView setBackgroundColor:[UIColor clearColor]];
    }
    return _tableView;
}



- (void)preparePlaceholder
{
    NSAssert(!self._placeholderTextView, @"placeholder has been prepared already: %@", self._placeholderTextView);
    // the label which displays the placeholder
    // needs to inherit some properties from its parent text view

    // account for standard UITextViewPadding

    CGRect frame = self.bounds;
    self._placeholderTextView = [[UITextView alloc] initWithFrame:frame];
    self._placeholderTextView.opaque = NO;
    self._placeholderTextView.backgroundColor = [UIColor clearColor];
    self._placeholderTextView.textColor = [UIColor colorWithWhite:0.7f alpha:0.7f];
    self._placeholderTextView.textAlignment = self.textAlignment;
    self._placeholderTextView.editable = NO;
    self._placeholderTextView.scrollEnabled = NO;
    self._placeholderTextView.userInteractionEnabled = NO;
    self._placeholderTextView.font = self.font;
    self._placeholderTextView.isAccessibilityElement = NO;
    self._placeholderTextView.contentOffset = self.contentOffset;
    self._placeholderTextView.contentInset = self.contentInset;

    if ([self._placeholderTextView respondsToSelector:@selector(setSelectable:)]) {
        self._placeholderTextView.selectable = NO;
    }

    if (HAS_TEXT_CONTAINER) {
        self._placeholderTextView.textContainer.exclusionPaths = self.textContainer.exclusionPaths;
        self._placeholderTextView.textContainer.lineFragmentPadding = self.textContainer.lineFragmentPadding;
    }

    if (HAS_TEXT_CONTAINER_INSETS(self)) {
        self._placeholderTextView.textContainerInset = self.textContainerInset;
    }

    if (_attributedPlaceholder) {
        self._placeholderTextView.attributedText = _attributedPlaceholder;
    } else if (_placeholder) {
        self._placeholderTextView.text = _placeholder;
    }

    [self setPlaceholderVisibleForText:self.text];

    self.clipsToBounds = YES;

    // some observations
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(textDidChange:)
                          name:UITextViewTextDidChangeNotification object:self];

    [self addObserver:self forKeyPath:kAttributedPlaceholderKey
              options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:kPlaceholderKey
              options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:kFontKey
              options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:kAttributedTextKey
              options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:kTextKey
              options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:kTextAlignmentKey
              options:NSKeyValueObservingOptionNew context:nil];

    if (HAS_TEXT_CONTAINER) {
        [self.textContainer addObserver:self forKeyPath:kExclusionPathsKey
                                options:NSKeyValueObservingOptionNew context:nil];
        [self.textContainer addObserver:self forKeyPath:kLineFragmentPaddingKey
                                options:NSKeyValueObservingOptionNew context:nil];
    }

    if (HAS_TEXT_CONTAINER_INSETS(self)) {
        [self addObserver:self forKeyPath:kTextContainerInsetKey
                  options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)setPlaceholder:(NSString *)placeholderText
{
    _placeholder = [placeholderText copy];
    _attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholderText];

    [self resizePlaceholderFrame];
}

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholderText
{
    _placeholder = attributedPlaceholderText.string;
    _attributedPlaceholder = [attributedPlaceholderText copy];

    [self resizePlaceholderFrame];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self resizePlaceholderFrame];
}

- (void)resizePlaceholderFrame
{
    CGRect frame = self._placeholderTextView.frame;
    frame.size = self.bounds.size;
    self._placeholderTextView.frame = frame;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:kAttributedPlaceholderKey]) {
        self._placeholderTextView.attributedText = [change valueForKey:NSKeyValueChangeNewKey];
    }
    else if ([keyPath isEqualToString:kPlaceholderKey]) {
        self._placeholderTextView.text = [change valueForKey:NSKeyValueChangeNewKey];
    }
    else if ([keyPath isEqualToString:kFontKey]) {
        self._placeholderTextView.font = [change valueForKey:NSKeyValueChangeNewKey];
    }
    else if ([keyPath isEqualToString:kAttributedTextKey]) {
        NSAttributedString *newAttributedText = [change valueForKey:NSKeyValueChangeNewKey];
        [self setPlaceholderVisibleForText:newAttributedText.string];
    }
    else if ([keyPath isEqualToString:kTextKey]) {
        NSString *newText = [change valueForKey:NSKeyValueChangeNewKey];
        [self setPlaceholderVisibleForText:newText];
    }
    else if ([keyPath isEqualToString:kExclusionPathsKey]) {
        self._placeholderTextView.textContainer.exclusionPaths = [change objectForKey:NSKeyValueChangeNewKey];
        [self resizePlaceholderFrame];
    }
    else if ([keyPath isEqualToString:kLineFragmentPaddingKey]) {
        self._placeholderTextView.textContainer.lineFragmentPadding = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        [self resizePlaceholderFrame];
    }
    else if ([keyPath isEqualToString:kTextContainerInsetKey]) {
        NSValue *value = [change objectForKey:NSKeyValueChangeNewKey];
        self._placeholderTextView.textContainerInset = value.UIEdgeInsetsValue;
    }
    else if ([keyPath isEqualToString:kTextAlignmentKey]) {
        NSNumber *alignment = [change objectForKey:NSKeyValueChangeNewKey];
        self._placeholderTextView.textAlignment = alignment.intValue;
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setPlaceholderTextColor:(UIColor *)placeholderTextColor
{
    self._placeholderTextView.textColor = placeholderTextColor;
}

- (UIColor *)placeholderTextColor
{
    return self._placeholderTextView.textColor;
}

- (void)textDidChange:(NSNotification *)aNotification
{
    [self setPlaceholderVisibleForText:self.text];
}

- (BOOL)becomeFirstResponder
{
    [self setPlaceholderVisibleForText:self.text];

    return [super becomeFirstResponder];
}

- (void)setPlaceholderVisibleForText:(NSString *)text
{
    if (text.length < 1) {
        if (self.fadeTime > 0.0) {
            if (![self._placeholderTextView isDescendantOfView:self]) {
                self._placeholderTextView.alpha = 0;
                [self addSubview:self._placeholderTextView];
                [self sendSubviewToBack:self._placeholderTextView];
            }
            [UIView animateWithDuration:_fadeTime animations:^{
                self._placeholderTextView.alpha = 1;
            }];
        }
        else {
            [self addSubview:self._placeholderTextView];
            [self sendSubviewToBack:self._placeholderTextView];
            self._placeholderTextView.alpha = 1;
        }
    }
    else {
        if (self.fadeTime > 0.0) {
            [UIView animateWithDuration:_fadeTime animations:^{
                self._placeholderTextView.alpha = 0;
            }];
        }
        else {
            [self._placeholderTextView removeFromSuperview];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:kAttributedPlaceholderKey];
    [self removeObserver:self forKeyPath:kPlaceholderKey];
    [self removeObserver:self forKeyPath:kFontKey];
    [self removeObserver:self forKeyPath:kAttributedTextKey];
    [self removeObserver:self forKeyPath:kTextKey];
    [self removeObserver:self forKeyPath:kTextAlignmentKey];

    if (HAS_TEXT_CONTAINER) {
        [self.textContainer removeObserver:self forKeyPath:kExclusionPathsKey];
        [self.textContainer removeObserver:self forKeyPath:kLineFragmentPaddingKey];
    }

    if (HAS_TEXT_CONTAINER_INSETS(self)) {
        [self removeObserver:self forKeyPath:kTextContainerInsetKey];
    }
}

@end
