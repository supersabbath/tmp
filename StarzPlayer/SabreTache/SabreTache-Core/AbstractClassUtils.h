
#import <Foundation/Foundation.h>

#define ABSTRACT_METHOD \
  [AbstractUtils abstractMethod:_cmd];

@interface AbstractUtils : NSObject

+ (id)abstractMethod:(SEL)selector;

@end

/*!
 * General purpose protocol to unify the interface to objects which might maintain a state.
 * Having this protocol allows to implement more advanced (and less abstract) state managing 
 * classes while still having a unique interface which allows to write login agnostic of the
 * nature of the state itself.
 */
@protocol StateProvider

- (id)currentState;

- (void)updateObjectState:(id)newState;

@end
