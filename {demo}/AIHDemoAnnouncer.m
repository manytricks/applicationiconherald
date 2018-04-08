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
		AIHAnnounceBadgeCount(arc4random_uniform(9) + 1);
	}

	- (IBAction)announceImage: (id)sender {
		AIHAnnounceImage([NSImage imageNamed: NSImageNameUser]);
	}

	- (IBAction)announceBadgeAndImage: (id)sender {
		AIHAnnounceIcon([NSDictionary dictionaryWithObjectsAndKeys:
			@"AIH", AIHBadgeKey,
			[NSImage imageNamed: NSImageNameAdvanced], AIHImageKey,
		nil]);
	}

	- (IBAction)clear: (id)sender {
		AIHAnnounceIcon(nil);
	}

@end


int main(int argc, char *argv[]) {
	return NSApplicationMain(argc, (const char **)argv);
}
