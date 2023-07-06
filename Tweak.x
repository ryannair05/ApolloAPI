#import "Tweak.h"

static void (*ApolloSettingsGeneralViewController_viewDidLoad_orig)(__unsafe_unretained UIViewController* const, SEL);
static void ApolloSettingsGeneralViewController_viewDidLoad_swizzle(__unsafe_unretained UIViewController* const self, SEL _cmd) {
	ApolloSettingsGeneralViewController_viewDidLoad_orig(self, _cmd);

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithPrimaryAction:
		[UIAction actionWithTitle:@"Custom API" image:nil identifier:nil handler:^(UIAction * action) {
			UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[CustomAPIViewController alloc] init]];
		    [self presentViewController:navController animated:YES completion:nil];
	}]];
}

static void (*ApolloProfileViewController_viewDidLoad_orig)(__unsafe_unretained UIViewController* const, SEL);
static void ApolloProfileViewController_viewDidLoad_swizzle(__unsafe_unretained UIViewController* const self, SEL _cmd) {
	ApolloProfileViewController_viewDidLoad_orig(self, _cmd);

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithPrimaryAction:
        [UIAction actionWithTitle:@"User Agent" image:nil identifier:nil handler:^(UIAction * action) {

            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"User Agent" message:@"Enter a custom user agent" preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.text = (__bridge_transfer NSString *) CFPreferencesCopyAppValue(CFSTR("userAgent"), CFSTR("com.ryannair05.apolloapi")) ?: @"iOS: com.christianselig.Apollo v1.15.12 (by /u/iamthatis)";
            }];
    
            UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                UITextField *textField = alertController.textFields.firstObject;
                if (textField.text.length > 0) {
                    CFPreferencesSetAppValue(CFSTR("userAgent"), (__bridge CFStringRef) textField.text, CFSTR("com.ryannair05.apolloapi"));
                }
                else {
                    CFPreferencesSetAppValue(CFSTR("userAgent"), CFSTR("iOS: com.christianselig.Apollo v1.15.12 (by /u/iamthatis)"), CFSTR("com.ryannair05.apolloapi"));
                }
            }];

            [alertController addAction:doneAction];
        
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:cancelAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
	}]];
}

static void (*ApolloTabBarController_viewDidAppear_orig)(__unsafe_unretained UIViewController* const, SEL, BOOL animated);
static void ApolloTabBarController_viewDidAppear_swizzle(__unsafe_unretained UIViewController* const self, SEL _cmd, BOOL animated) {
	ApolloTabBarController_viewDidAppear_orig(self, _cmd, animated);

	OBWelcomeController* welcomeController = [[objc_getClass("OBWelcomeController") alloc] initWithTitle:@"Apollo API" detailText:@"Apollo API allows you to enter a custom API key " icon:[UIImage systemImageNamed:@"character.cursor.ibeam"]];

    [welcomeController addBulletedListItemWithTitle:@"Settings" description:@"Go to Settings -> General and click \"Custom API\" on the navigation bar" image:[UIImage systemImageNamed:@"1.circle.fill"]];
    [welcomeController addBulletedListItemWithTitle:@"Make an API" description:@"Follow the directions to make an API Key on Reddit's website and insert the key into preferences" image:[UIImage systemImageNamed:@"2.circle.fill"]];
    [welcomeController addBulletedListItemWithTitle:@"Insert New API" description:@"Changes are applied immediately, but it may take logging in and out of accounts to take effect" image:[UIImage systemImageNamed:@"3.circle.fill"]];

    UIButton *continueButton = [UIButton buttonWithConfiguration:[UIButtonConfiguration filledButtonConfiguration] primaryAction:
        [UIAction actionWithTitle:@"Continue" image:nil identifier:nil handler:^(UIAction * action) {
        [self dismissViewControllerAnimated:YES completion:nil];
        
        CFPreferencesSetAppValue(CFSTR("shownWelcomeController"), kCFBooleanTrue, CFSTR("com.ryannair05.apolloapi"));
        method_setImplementation(class_getInstanceMethod([self class], @selector(viewDidAppear:)), (IMP)ApolloTabBarController_viewDidAppear_orig);
    }]];

    [welcomeController.buttonTray addButton:continueButton];
     
    UIVisualEffectView *effectWelcomeView = [[UIVisualEffectView alloc] initWithFrame:welcomeController.viewIfLoaded.bounds];
     
    effectWelcomeView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
     
    [welcomeController.viewIfLoaded insertSubview:effectWelcomeView atIndex:0];

    welcomeController.viewIfLoaded.backgroundColor = [UIColor clearColor];

    [welcomeController.buttonTray addCaptionText:@"Enjoy using Apollo!"];

    welcomeController.modalPresentationStyle = UIModalPresentationPageSheet;
    welcomeController.modalInPresentation = YES;
	[self presentViewController:welcomeController animated:YES completion:nil];
}

%hook RDKOAuthCredential
- (NSString *)clientIdentifier {
	return customIdentifier ?: %orig;
}
%end

%hook RDKClient
- (NSString *)userAgent {
    NSString *customUserAgent = (__bridge_transfer NSString *) CFPreferencesCopyAppValue(CFSTR("userAgent"), CFSTR("com.ryannair05.apolloapi"));
    return customUserAgent ?: %orig;
}
%end

%hook NSURLSession
- (NSURLSessionUploadTask*)uploadTaskWithRequest:(NSURLRequest*)request fromData:(NSData*)bodyData completionHandler:(void (^)(NSData*, NSURLResponse*, NSError*))completionHandler {
    if ([[[request URL] lastPathComponent] isEqualToString:@"image"]) {
        NSMutableURLRequest *modifiedRequest = [request mutableCopy];
        [modifiedRequest setURL:[NSURL URLWithString:[@"https://api.imgur.com/3/image?client_id=" stringByAppendingString:(__bridge_transfer NSString *) CFPreferencesCopyAppValue(CFSTR("imgurAPIKey"), CFSTR("com.ryannair05.apolloapi"))]]];
        return %orig([modifiedRequest copy], bodyData, completionHandler);
    }
    return %orig;
}

- (NSURLSessionDataTask*)dataTaskWithRequest:(NSURLRequest*)request completionHandler:(void (^)(NSData*, NSURLResponse*, NSError*))completionHandler {
    NSURL *urlRequest = [request URL];

    if ([[urlRequest absoluteString] compare:@"imgur-apiv3.p" options:NSLiteralSearch | NSAnchoredSearch range:NSMakeRange(8, 13)] == 0) {
        NSMutableURLRequest *modifiedRequest = [request mutableCopy];
        [modifiedRequest setURL:[NSURL URLWithString:[@"https://api.imgur.com/3/image" stringByAppendingPathComponent:[urlRequest lastPathComponent]]]];
        return %orig([modifiedRequest copy], completionHandler);
    }
    return %orig;
}
%end

%ctor {
	%init;

	MSHookMessageEx(objc_getClass("Apollo.SettingsGeneralViewController"), @selector(viewDidLoad), (IMP)&ApolloSettingsGeneralViewController_viewDidLoad_swizzle, (IMP*)&ApolloSettingsGeneralViewController_viewDidLoad_orig);
    MSHookMessageEx(objc_getClass("Apollo.ProfileViewController"), @selector(viewDidLoad), (IMP)&ApolloProfileViewController_viewDidLoad_swizzle, (IMP*)&ApolloProfileViewController_viewDidLoad_orig);
    customIdentifier = (__bridge_transfer NSString *) CFPreferencesCopyAppValue(CFSTR("customAPIKey"), CFSTR("com.ryannair05.apolloapi"));

	if (!CFPreferencesGetAppBooleanValue(CFSTR("shownWelcomeController"), CFSTR("com.ryannair05.apolloapi"), NULL) && objc_getClass("OBWelcomeController")) {
        ApolloTabBarController_viewDidAppear_orig = (void (*)(UIViewController* const, SEL, BOOL)) method_setImplementation(class_getInstanceMethod(objc_getClass("Apollo.ApolloTabBarController"), @selector(viewDidAppear:)), (IMP)ApolloTabBarController_viewDidAppear_swizzle);
	}
}
