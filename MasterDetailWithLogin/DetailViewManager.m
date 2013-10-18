/*
 
 Hacked up version from Apple's MultipleDetailViews example code:
 
 Original source: https://developer.apple.com/library/IOS/samplecode/MultipleDetailViews/Introduction/Intro.html
 
 */

#import "DetailViewManager.h"
#import "GVLoadingDetailViewController.h"
#import "GVMasterViewController.h"

@interface DetailViewManager ()
// Holds a reference to the split view controller's bar button item
// if the button should be shown (the device is in portrait).
// Will be nil otherwise.
@property (nonatomic, retain) UIBarButtonItem *navigationPaneButtonItem;
// Holds a reference to the popover that will be displayed
// when the navigation button is pressed.
@property (nonatomic, retain) UIPopoverController *navigationPopoverController;
@end


@implementation DetailViewManager

#pragma mark - SubstitutableDetailViewController

// -------------------------------------------------------------------------------
//	setDetailViewController:
//  Custom implementation of the setter for the detailViewController property.
// -------------------------------------------------------------------------------
- (void)setDetailViewController:(UIViewController<SubstitutableDetailViewController> *)detailViewController
{
    // Clear any bar button item from the detail view controller that is about to
    // no longer be displayed.
    self.detailViewController.navigationPaneBarButtonItem = nil;
    
    
    _detailViewController = detailViewController;
    
    // Set the new detailViewController's navigationPaneBarButtonItem to the value of our
    // navigationPaneButtonItem.  If navigationPaneButtonItem is not nil, then the button
    // will be displayed.
    _detailViewController.navigationPaneBarButtonItem = self.navigationPaneButtonItem;
    
    UIViewController* topLevelController = nil;
    if ([detailViewController class] ==  [GVLoadingDetailViewController class]) {
        topLevelController = _detailViewController;
    } else {
        GVMasterViewController *master = (GVMasterViewController*)[[self.splitViewController.viewControllers firstObject] topViewController];
        //topLevelController = [[UINavigationController alloc] initWithRootViewController:_detailViewController];
        topLevelController = [master detailNavCtrl];
    }
    
    // Update the split view controller's view controllers array.
    // This causes the new detail view controller to be displayed.
    UIViewController *navigationViewController = [self.splitViewController.viewControllers objectAtIndex:0];
    NSArray *viewControllers = [[NSArray alloc] initWithObjects:navigationViewController, topLevelController, nil];
    self.splitViewController.viewControllers = viewControllers;
    
    // Dismiss the navigation popover if one was present.  This will
    // only occur if the device is in portrait.
    if (self.navigationPopoverController)
        [self.navigationPopoverController dismissPopoverAnimated:YES];
}

#pragma mark -
#pragma mark UISplitViewDelegate

// -------------------------------------------------------------------------------
//	splitViewController:shouldHideViewController:inOrientation:
// -------------------------------------------------------------------------------
- (BOOL)splitViewController:(UISplitViewController *)svc 
   shouldHideViewController:(UIViewController *)vc 
              inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

// -------------------------------------------------------------------------------
//	splitViewController:willHideViewController:withBarButtonItem:forPopoverController:
// -------------------------------------------------------------------------------
- (void)splitViewController:(UISplitViewController *)svc 
     willHideViewController:(UIViewController *)aViewController 
          withBarButtonItem:(UIBarButtonItem *)barButtonItem 
       forPopoverController:(UIPopoverController *)pc
{
    // If the barButtonItem does not have a title (or image) adding it to a toolbar
    // will do nothing.
    barButtonItem.title = @"Master";
    
    self.navigationPaneButtonItem = barButtonItem;
    self.navigationPopoverController = pc;
    
    // Tell the detail view controller to show the navigation button.
    self.detailViewController.navigationPaneBarButtonItem = barButtonItem;
}

// -------------------------------------------------------------------------------
//	splitViewController:willShowViewController:invalidatingBarButtonItem:
// -------------------------------------------------------------------------------
- (void)splitViewController:(UISplitViewController *)svc 
     willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationPaneButtonItem = nil;
    self.navigationPopoverController = nil;
    
    // Tell the detail view controller to remove the navigation button.
    self.detailViewController.navigationPaneBarButtonItem = nil;
}


@end
