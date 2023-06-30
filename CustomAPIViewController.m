#import "CustomAPIViewController.h"

@implementation CustomAPIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Apollo API";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone primaryAction:[UIAction actionWithHandler:^(UIAction * action) {
		[self dismissViewControllerAnimated:YES completion:nil];
	}]];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
	scrollView.backgroundColor = [UIColor systemBackgroundColor];
	scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:scrollView];
    
    [NSLayoutConstraint activateConstraints:@[
        [scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
    
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.spacing = 25;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:stackView];
    
    [NSLayoutConstraint activateConstraints:@[
        [stackView.topAnchor constraintEqualToAnchor:scrollView.topAnchor constant:20],
        [stackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [stackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [stackView.bottomAnchor constraintEqualToAnchor:scrollView.bottomAnchor constant:-20],
    ]];
    
    UITextField *textField = [[UITextField alloc] init];
    textField.placeholder = @"Enter API Key";
	textField.text = (__bridge_transfer NSString *) CFPreferencesCopyAppValue(CFSTR("customAPIKey"), CFSTR("com.ryannair05.apolloapi"));
    textField.delegate = self;
	textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [stackView addArrangedSubview:textField];
    
	UIButton *websiteButton = [UIButton systemButtonWithPrimaryAction:[UIAction actionWithTitle:@"Reddit API Website" image:nil identifier:nil handler:^(UIAction * action) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://reddit.com/prefs/apps"] options:@{} completionHandler:nil];
	}]];

	UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(websiteButtonLongPressed:)];
	[websiteButton addGestureRecognizer:longPressGesture];

    [stackView addArrangedSubview:websiteButton];
    
    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 0;
	NSAttributedStringMarkdownParsingOptions *markdownOptions = [[NSAttributedStringMarkdownParsingOptions alloc] init];
	markdownOptions.interpretedSyntax = NSAttributedStringMarkdownInterpretedSyntaxInlineOnly;

    label.attributedText = [[NSAttributedString alloc] initWithMarkdownString:
	@"**Use your own reddit API credentials in Apollo**\n\n"
	@"Creating an API credential:\n"
	@"*You may need to sign out of all accounts in Apollo*\n\n"
	@"1. Sign into your reddit account (on desktop) and go to the link above (reddit.com/prefs/apps) \n"
	@"2. Click the  `are you a developer? create an app...` button\n"
	@"3. Fill in the fields \n\t- Name: *anything* \n\t- Choose `Installed App` \n\t- Description: *anything*\n\t- About url: *anything* \n\t- Redirect uri: `apollo://reddit-oauth`\n"
	@"4. Click `create app`\n"
	@"5. After creating the app you'll get a client identifier which will be a bunch of random characters. **Enter your key above**\n"
	@"For now, Apollo will still use the original API creds for other services (like Imgur), but hopefully a future update will support replacing those as well\n\n"
	@"Thanks to Ethan Arbuckle for his contributions" 
	options:markdownOptions baseURL:nil error:nil];

    [stackView addArrangedSubview:label];

	NSURL *githubImageURL = [NSURL URLWithString:@"https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png"];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSData *githubImageData = [NSData dataWithContentsOfURL:githubImageURL];
		UIImage *githubImage = [UIImage imageWithData:githubImageData];
		dispatch_async(dispatch_get_main_queue(), ^{
			const CGFloat imageSize = 40;
			UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageSize, imageSize), NO, 0.0);
			[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, imageSize, imageSize) cornerRadius:5.0] addClip];
			[githubImage drawInRect:CGRectMake(0, 0, imageSize, imageSize)];
			UIImage *smallGithubImage = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
			
			UIButtonConfiguration *buttonConfiguration = [UIButtonConfiguration grayButtonConfiguration];
			buttonConfiguration.imagePadding = 35;

			UIButton *githubButton = [UIButton buttonWithConfiguration:buttonConfiguration primaryAction:
				[UIAction actionWithTitle:@"Open source on Github" image:smallGithubImage identifier:nil handler:^(UIAction * action) {
				NSURL *url = [NSURL URLWithString:@"https://github.com/ryannair05"];
				
				[UIApplication.sharedApplication openURL:url options:@{} completionHandler:nil];
			}]];

			if (stackView.arrangedSubviews.count <= 3) {
				[stackView addArrangedSubview:githubButton];
			}
			else {
				[stackView insertArrangedSubview:githubButton atIndex:3];
			}
		});
	});

	NSURL *twitterImageURL = [NSURL URLWithString:@"https://pbs.twimg.com/profile_images/1161080936836018176/4GUKuGlb_200x200.jpg"];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSData *twitterImageData = [NSData dataWithContentsOfURL:twitterImageURL];
		UIImage *twitterImage = [UIImage imageWithData:twitterImageData];
		dispatch_async(dispatch_get_main_queue(), ^{
			const CGFloat imageSize = 40;
			UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageSize, imageSize), NO, 0.0);
			[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, imageSize, imageSize) cornerRadius:5.0] addClip];
			[twitterImage drawInRect:CGRectMake(0, 0, imageSize, imageSize)];
			UIImage *smallTwitterImage = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
			
			UIButtonConfiguration *buttonConfiguration = [UIButtonConfiguration grayButtonConfiguration];
			buttonConfiguration.imagePadding = 30;
			buttonConfiguration.subtitle = @"@ryannair05";

			[stackView addArrangedSubview:[UIButton buttonWithConfiguration:buttonConfiguration primaryAction:
				[UIAction actionWithTitle:@"Developed by Ryan Nair" image:smallTwitterImage identifier:nil handler:^(UIAction * action) {
					NSURL *url = [NSURL URLWithString:@"https://twitter.com/ryannair05"];
					
					[UIApplication.sharedApplication openURL:url options:@{} completionHandler:nil];
				}]]
			];
		});
	});
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	CFPreferencesSetAppValue(CFSTR("customAPIKey"), (__bridge CFStringRef) textField.text, CFSTR("com.ryannair05.apolloapi"));
}

- (void)websiteButtonLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL URLWithString:@"https://reddit.com/prefs/apps"]] applicationActivities:nil];
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
}

@end