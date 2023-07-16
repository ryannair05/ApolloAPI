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
    
    UITextField *redditTextField = [[UITextField alloc] init];
    redditTextField.placeholder = @"Reddit API Key";
	redditTextField.text = customIdentifier;
    redditTextField.delegate = self;
	redditTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [stackView addArrangedSubview:redditTextField];
    
	UITextField *imgurTextField = [[UITextField alloc] init];
    imgurTextField.placeholder = @"Imgur API Key";
	imgurTextField.tag = 1;
	imgurTextField.text = imgurAPIKey;
    imgurTextField.delegate = self;
	imgurTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [stackView addArrangedSubview:imgurTextField];

	UIButton *websiteButton = [UIButton systemButtonWithPrimaryAction:[UIAction actionWithTitle:@"Reddit API Website" image:nil identifier:nil handler:^(UIAction * action) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://reddit.com/prefs/apps"] options:@{} completionHandler:nil];
	}]];

	UIButton *imgurButton = [UIButton systemButtonWithPrimaryAction:[UIAction actionWithTitle:@"Imgur API Website" image:nil identifier:@"com.ryannair05" handler:^(UIAction * action) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://api.imgur.com/oauth2/addclient"] options:@{} completionHandler:nil];
	}]];

	UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(websiteButtonLongPressed:)];
	UILongPressGestureRecognizer *imgurPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(websiteButtonLongPressed:)];
	[websiteButton addGestureRecognizer:longPressGesture];
	[imgurButton addGestureRecognizer:imgurPressGesture];
    [stackView addArrangedSubview:websiteButton];
	[stackView addArrangedSubview:imgurButton];

    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 0;
	NSAttributedStringMarkdownParsingOptions *markdownOptions = [[NSAttributedStringMarkdownParsingOptions alloc] init];
	markdownOptions.interpretedSyntax = NSAttributedStringMarkdownInterpretedSyntaxInlineOnly;

    label.attributedText = [[NSAttributedString alloc] initWithMarkdownString:
	@"**Use your own API credentials in Apollo**\n\n"
	@"Creating a Reddit API credential:\n"
	@"*You may need to sign out of all accounts in Apollo*\n\n"
	@"1. Sign into your reddit account (on desktop) and go to the link above (reddit.com/prefs/apps) \n"
	@"2. Click the  `are you a developer? create an app...` button\n"
	@"3. Fill in the fields \n\t- Name: *anything* \n\t- Choose `Installed App` \n\t- Description: *anything*\n\t- About url: *anything* \n\t- Redirect uri: `apollo://reddit-oauth`\n"
	@"4. Click `create app`\n"
	@"5. After creating the app you'll get a client identifier which will be a bunch of random characters. **Enter your key above**\n"
	@"\nFor Imgur, go to the website above and register your application using the callback URL `https://www.getpostman.com/oauth2/callback` and fill in the rest of the fields similar to step 3\n\n"
	@"Thanks to Ethan Arbuckle for his contributions" 
	options:markdownOptions baseURL:nil error:nil];

    [stackView addArrangedSubview:label];

	NSURL *githubImageURL = [NSURL URLWithString:@"https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png"];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSData *githubImageData = [NSData dataWithContentsOfURL:githubImageURL];
		UIImage *githubImage = [UIImage imageWithData:githubImageData];
		const CGFloat imageSize = 40;
		UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(imageSize, imageSize)];
		UIImage *smallGithubImage = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull context) {
			[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, imageSize, imageSize) cornerRadius:5.0] addClip];
			[githubImage drawInRect:CGRectMake(0, 0, imageSize, imageSize)];
		}];
			
		dispatch_async(dispatch_get_main_queue(), ^{
			UIButtonConfiguration *buttonConfiguration = [UIButtonConfiguration grayButtonConfiguration];
			buttonConfiguration.imagePadding = 35;

			UIButton *githubButton = [UIButton buttonWithConfiguration:buttonConfiguration primaryAction:
				[UIAction actionWithTitle:@"Open source on Github" image:smallGithubImage identifier:nil handler:^(UIAction * action) {
				NSURL *url = [NSURL URLWithString:@"https://github.com/ryannair05/apolloapi"];
				
				[UIApplication.sharedApplication openURL:url options:@{} completionHandler:nil];
			}]];

			if (stackView.arrangedSubviews.count <= 5) {
				[stackView addArrangedSubview:githubButton];
			}
			else {
				[stackView insertArrangedSubview:githubButton atIndex:5];
			}
		});
	});

	NSURL *twitterImageURL = [NSURL URLWithString:@"https://pbs.twimg.com/profile_images/1161080936836018176/4GUKuGlb_200x200.jpg"];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSData *twitterImageData = [NSData dataWithContentsOfURL:twitterImageURL];
		UIImage *twitterImage = [UIImage imageWithData:twitterImageData];
		const CGFloat imageSize = 40;
		UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(imageSize, imageSize)];
		UIImage *smallTwitterImage = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull context) {
			[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, imageSize, imageSize) cornerRadius:5.0] addClip];
			[twitterImage drawInRect:CGRectMake(0, 0, imageSize, imageSize)];
		}];

		dispatch_async(dispatch_get_main_queue(), ^{
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
	if (textField.tag == 0) {
		customIdentifier = textField.text;
		CFPreferencesSetAppValue(CFSTR("customAPIKey"), (__bridge CFStringRef) customIdentifier, CFSTR("com.ryannair05.apolloapi"));
	}
	else {
		imgurAPIKey = textField.text;
		CFPreferencesSetAppValue(CFSTR("imgurAPIKey"), (__bridge CFStringRef) imgurAPIKey, CFSTR("com.ryannair05.apolloapi"));
	}
}

- (void)websiteButtonLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		NSURL *activityURL;

		if ([[(UIButton *) gestureRecognizer.view currentTitle] compare:@"Reddit" options:NSLiteralSearch | NSAnchoredSearch] == 1) {
			activityURL = [NSURL URLWithString:@"https://reddit.com/prefs/apps"];
		}
		else {
			activityURL = [NSURL URLWithString:@"https://api.imgur.com/oauth2/addclient"];
		}

        [self presentViewController:[[UIActivityViewController alloc] initWithActivityItems:@[activityURL] applicationActivities:nil] animated:YES completion:nil];
    }
}

@end