
#import "UIGestureRecognizer+Blocks.h"

#import <objc/runtime.h>

@interface UIGestureRecognizer (Blocks_Internal)

@property (nonatomic, copy) void (^actionBlock) (UIGestureRecognizer* gesture);

- (void)handleAction:(UIGestureRecognizer *)recognizer;

@end

@implementation UIGestureRecognizer (Blocks)

static char block_key;

+ (id)instanceWithActionBlock:(void (^) (UIGestureRecognizer* gesture))action;
{
    id instance = [[[self class] alloc] initWithActionBlock:action];
    
    return instance ;
}

- (id)initWithActionBlock:(void (^) (UIGestureRecognizer* gesture))action;
{
    if ((self = [self initWithTarget:self action:@selector(handleAction:)]))
    {
        [self setActionBlock:action];
    }
    
    return self;
}

- (void)handleAction:(UIGestureRecognizer *)recognizer;
{
    void (^action) (UIGestureRecognizer* gesture) = [self actionBlock];
    if(nil != action)
    {
        action(recognizer);
    }
}

- (void (^) (UIGestureRecognizer* gesture))actionBlock;
{
    return objc_getAssociatedObject(self, &block_key);
}

- (void)setActionBlock:(void (^) (UIGestureRecognizer* gesture))block;
{
    objc_setAssociatedObject(self, &block_key, block, OBJC_ASSOCIATION_COPY);
}

@end