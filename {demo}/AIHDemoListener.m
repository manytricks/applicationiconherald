#import "AIHApplicationIconHerald.h"


@interface AIHDemoIconView: NSView

	@property NSArray <NSImage *> *icons;

@end

@implementation AIHDemoIconView

	- (void)drawRect: (NSRect)rect {
		NSArray <NSImage *> *icons = self.icons;
		NSUInteger numberOfIcons = icons.count;
		if (numberOfIcons>0) {
			CGFloat size = rect.size.width;
			if (numberOfIcons>1) {
				size /= numberOfIcons;
			}
			if (size>rect.size.height) {
				size = rect.size.height;
			}
			NSUInteger offset = 0;
			for (NSImage *icon in icons) {
				[icon drawInRect: NSMakeRect(rect.origin.x + (rect.size.width - numberOfIcons * size) / 2 + offset * size, rect.origin.y + (rect.size.height - size) / 2, size, size) fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1.0];
				offset++;
			}
		}
	}

@end


@interface AIHDemoListener: NSObject <NSApplicationDelegate>

	@property IBOutlet NSWindow *window;
	@property IBOutlet AIHDemoIconView *iconView;

@end

@implementation AIHDemoListener

	{
		NSMutableDictionary <NSString *, NSImage *> *_heraldedIconsByBundleIdentifier;
	}

	- (void)updateIconView {
		NSMutableArray <NSImage *> *icons = [NSMutableArray array];

		// collect icons for (regular) running applications; use cached heralded icons if available
		NSRunningApplication *currentRunningApplication = [NSRunningApplication currentApplication];
		for (NSRunningApplication *runningApplication in [NSWorkspace sharedWorkspace].runningApplications) {
			if ((runningApplication.activationPolicy==NSApplicationActivationPolicyRegular) && (![currentRunningApplication isEqual: runningApplication])) {
				NSString *bundleIdentifier = runningApplication.bundleIdentifier;
				if (bundleIdentifier) {
					NSImage *heraldedIcon = [_heraldedIconsByBundleIdentifier objectForKey: bundleIdentifier];
					if (heraldedIcon) {
						[icons addObject: heraldedIcon];
						continue;
					}
				}
				NSImage *defaultIcon = runningApplication.icon;
				if (defaultIcon) {
					[icons addObject: defaultIcon];
				}
			}
		}

		// update display
		AIHDemoIconView *iconView = self.iconView;
		iconView.icons = icons;
		[iconView setNeedsDisplay: YES];
	}

	- (void)otherApplicationDidLaunch: (NSNotification *)notification {
		[self updateIconView];
	}

	- (void)otherApplicationDidTerminate: (NSNotification *)notification {
		NSString *bundleIdentifier = ((NSRunningApplication *)[notification.userInfo objectForKey: NSWorkspaceApplicationKey]).bundleIdentifier;
		if (bundleIdentifier) {
			[_heraldedIconsByBundleIdentifier removeObjectForKey: bundleIdentifier];
		}
		[self updateIconView];
	}

	- (void)applicationDidFinishLaunching: (NSNotification *)notification {
		[self updateIconView];

		// upate when an app launches or quits
		NSNotificationCenter *notificationCenter = [NSWorkspace sharedWorkspace].notificationCenter;
		[notificationCenter addObserver: self selector: @selector(otherApplicationDidLaunch:) name: NSWorkspaceDidLaunchApplicationNotification object: nil];
		[notificationCenter addObserver: self selector: @selector(otherApplicationDidTerminate:) name: NSWorkspaceDidTerminateApplicationNotification object: nil];

		// update in response to AIH announcements after caching heralded composite icons (cf. -updateIconView)
		AIHSetListeningBlock(^(NSString *bundleIdentifier, NSImage *baseImage, NSString *badge, NSImage *compositeIcon) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (compositeIcon) {
					if (!_heraldedIconsByBundleIdentifier) {
						_heraldedIconsByBundleIdentifier = [NSMutableDictionary dictionary];
					}
					[_heraldedIconsByBundleIdentifier setObject: compositeIcon forKey: bundleIdentifier];
				} else {
					[_heraldedIconsByBundleIdentifier removeObjectForKey: bundleIdentifier];
				}
				[self updateIconView];
			});
		});

		NSWindow *window = self.window;
		[window center];
		[window makeKeyAndOrderFront: nil];
	}

	- (NSApplicationTerminateReply)applicationShouldTerminate: (NSApplication *)application {
		[[NSWorkspace sharedWorkspace].notificationCenter removeObserver: self];
		AIHSetListeningBlock(nil);
		return NSTerminateNow;
	}

@end


int main(int argc, char *argv[]) {
	return NSApplicationMain(argc, (const char **)argv);
}
