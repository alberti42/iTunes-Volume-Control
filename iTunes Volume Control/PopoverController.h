#import "PopoverView.h"
#import "StatusItemView.h"

@class PopoverController;

@protocol PopoverControllerDelegate <NSObject>

@optional

- (StatusItemView *)statusItemViewForPanelController:(PopoverController *)controller;

@end

#pragma mark -

@interface PopoverController : NSWindowController <NSWindowDelegate>
{
    BOOL _hasActivePanel;
    __unsafe_unretained PopoverView *_popoverView;
    __unsafe_unretained id<PopoverControllerDelegate> _delegate;
    __unsafe_unretained NSSearchField *_searchField;
    __unsafe_unretained NSTextField *_textField;
}

@property (nonatomic, unsafe_unretained) IBOutlet PopoverView *popoverView;
@property (nonatomic, unsafe_unretained) IBOutlet NSSearchField *searchField;
@property (nonatomic, unsafe_unretained) IBOutlet NSTextField *textField;

@property (nonatomic) BOOL hasActivePanel;
@property (nonatomic, unsafe_unretained, readonly) id<PopoverControllerDelegate> delegate;

- (id)initWithDelegate:(id<PopoverControllerDelegate>)delegate;

- (void)openPopover;
- (void)closePopover;

@end
