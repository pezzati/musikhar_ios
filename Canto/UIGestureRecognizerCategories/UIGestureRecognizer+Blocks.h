
#import <UIKit/UIGestureRecognizer.h>

@interface UIGestureRecognizer (Blocks)

+ (id)instanceWithActionBlock:(void (^) (UIGestureRecognizer* gesture))action;

- (id)initWithActionBlock:(void (^) (UIGestureRecognizer* gesture))action;


@end