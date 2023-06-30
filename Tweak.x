#import "Tweak.h"
#include <objc/runtime.h>

static void (*ApolloSettingsGeneralViewController_viewDidLoad_orig)(__unsafe_unretained UIViewController* const, SEL);
static void ApolloSettingsGeneralViewController_viewDidLoad_swizzle(__unsafe_unretained UIViewController* const self, SEL _cmd) {
	ApolloSettingsGeneralViewController_viewDidLoad_orig(self, _cmd);

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithPrimaryAction:
		[UIAction actionWithTitle:@"Custom API" image:nil identifier:nil handler:^(UIAction * action) {
			CustomAPIViewController *popupVC = [[CustomAPIViewController alloc] init];
			UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:popupVC];
			[self presentViewController:navController animated:YES completion:nil];
	}]];
}

static void (*ApolloTabBarController_viewDidAppear_orig)(__unsafe_unretained UIViewController* const, SEL, BOOL animated);
static void ApolloTabBarController_viewDidAppear_swizzle(__unsafe_unretained UIViewController* const self, SEL _cmd, BOOL animated) {
	ApolloTabBarController_viewDidAppear_orig(self, _cmd, animated);

	OBWelcomeController* welcomeController = [[objc_getClass("OBWelcomeController") alloc] initWithTitle:@"Apollo API" detailText:@"Apollo API allows you to enter a custom API key " icon:[UIImage systemImageNamed:@"character.cursor.ibeam"]];

    [welcomeController addBulletedListItemWithTitle:@"Settings" description:@"Go to Settings -> General and click \"Custom API\" on the navigation bar" image:[UIImage systemImageNamed:@"1.circle.fill"]];
    [welcomeController addBulletedListItemWithTitle:@"Make an API" description:@"Follow the directions to make an API Key on Reddit's website and insert the key into preferences" image:[UIImage systemImageNamed:@"2.circle.fill"]];
    [welcomeController addBulletedListItemWithTitle:@"Insert New API" description:@"Changes are applied immediately, but it may take an app restart or logging out of and in accounts to take effect" image:[UIImage systemImageNamed:@"3.circle.fill"]];

    OBBoldTrayButton* continueButton = [objc_getClass("OBBoldTrayButton") buttonWithType:1];
    [continueButton addTarget:self action:@selector(dismissWelcomeController) forControlEvents:UIControlEventTouchUpInside];
    [continueButton setTitle:@"Continue" forState:UIControlStateNormal];
    [continueButton setClipsToBounds:YES];
    [continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [continueButton.layer setCornerRadius:9];
    [continueButton setBackgroundColor:UIColor.tintColor];
    [welcomeController.buttonTray addButton:continueButton];
    welcomeController._shouldInlineButtontray = YES;
    
    welcomeController.buttonTray.effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
     
    UIVisualEffectView *effectWelcomeView = [[UIVisualEffectView alloc] initWithFrame:welcomeController.viewIfLoaded.bounds];
     
    effectWelcomeView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
     
    [welcomeController.viewIfLoaded insertSubview:effectWelcomeView atIndex:0];

    welcomeController.viewIfLoaded.backgroundColor = [UIColor clearColor];

    [welcomeController.buttonTray addCaptionText:@"Enjoy using Apollo!"];

    welcomeController.modalPresentationStyle = UIModalPresentationPageSheet;
    welcomeController.modalInPresentation = YES;
    welcomeController.view.tintColor = [UIColor systemBlueColor];
	[self presentViewController:welcomeController animated:YES completion:nil];
}

static void ApolloTabBarController_dismissWelcomeController(__unsafe_unretained UIViewController* const self, SEL _cmd) {
    [self dismissViewControllerAnimated:true completion:nil];
	CFPreferencesSetAppValue(CFSTR("shownWelcomeController"), kCFBooleanTrue, CFSTR("com.ryannair05.apolloapi"));
}

%hook RDKOAuthCredential
- (NSString *)clientIdentifier {
	NSString *customIdentifier = (__bridge_transfer NSString *) CFPreferencesCopyAppValue(CFSTR("customAPIKey"), CFSTR("com.ryannair05.apolloapi"));

	return customIdentifier ?: %orig;
}
%end

%ctor {
	%init;

	MSHookMessageEx(objc_getClass("Apollo.SettingsGeneralViewController"), @selector(viewDidLoad), (IMP)&ApolloSettingsGeneralViewController_viewDidLoad_swizzle, (IMP*)&ApolloSettingsGeneralViewController_viewDidLoad_orig);

	Class navigationClass = objc_getClass("Apollo.ApolloTabBarController");

	if (!CFPreferencesGetAppBooleanValue(CFSTR("shownWelcomeController"), CFSTR("com.ryannair05.apolloapi"), NULL) && objc_getClass("OBWelcomeController")) {
		MSHookMessageEx(navigationClass, @selector(viewDidAppear:), (IMP)&ApolloTabBarController_viewDidAppear_swizzle, (IMP*)&ApolloTabBarController_viewDidAppear_orig);
		class_addMethod(navigationClass, @selector(dismissWelcomeController), (IMP)&ApolloTabBarController_dismissWelcomeController, "v@:");
	}
}
