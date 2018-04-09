#import "AIHApplicationIconHerald.h"


@interface AIHDemoAnnouncer: NSObject <NSApplicationDelegate>

	@property IBOutlet NSWindow *window;

@end

@implementation AIHDemoAnnouncer

	- (void)applicationDidFinishLaunching: (NSNotification *)notification {
		NSWindow *window = self.window;
		[window center];
		[window makeKeyAndOrderFront: nil];
	}

	- (IBAction)announceBadge: (id)sender {
		NSUInteger randomBadgeCount = arc4random_uniform(9) + 1;
		NSString *randomBadge = [NSString stringWithFormat: @"%lu", (unsigned long)randomBadgeCount];
		NSApp.dockTile.badgeLabel = randomBadge;
		NSApp.applicationIconImage = nil;
		AIHAnnounceBadgeCount(randomBadgeCount);	// alternatively, AIHAnnounceBadge(randomBadge);
	}

	- (IBAction)announceImage: (id)sender {
		NSImage *image = [NSImage imageNamed: NSImageNameUser];
		NSApp.dockTile.badgeLabel = nil;
		NSApp.applicationIconImage = image;
		AIHAnnounceImage(image);
	}

	- (IBAction)announceBadgeAndImage: (id)sender {
		NSString *badge = @"AIH";
		NSImage *image = [NSImage imageNamed: NSImageNameAdvanced];
		NSApp.dockTile.badgeLabel = badge;
		NSApp.applicationIconImage = image;
		AIHAnnounceIcon([NSDictionary dictionaryWithObjectsAndKeys:
			badge, AIHBadgeKey,
			image, AIHImageKey,
		nil]);
	}

	- (IBAction)clear: (id)sender {
		NSApp.dockTile.badgeLabel = nil;
		NSApp.applicationIconImage = nil;
		AIHAnnounceIcon(nil);
	}

@end


int main(int argc, char *argv[]) {
	return NSApplicationMain(argc, (const char **)argv);
}
