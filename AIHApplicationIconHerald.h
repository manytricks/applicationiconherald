#import <AppKit/AppKit.h>


// announcing badges or custom icons

void AIHAnnounceBadgeCount(NSInteger count);	// if all you have is a standard numeric badge, use this (0 => no badge)
void AIHAnnounceBadge(NSString *_Nullable badge);	// if you'd rather specify your badge as a string, use this (nil => no badge)
void AIHAnnounceImage(NSImage *_Nullable image);	// if you set your icon image at runtime and don't have a badge, use this (nil => no longer different from the corresponding NSRunningApplication's icon)

void AIHAnnounceIcon(NSDictionary *_Nullable iconDictionary);	// if you want to announce both badge and icon image, or if you need to specify a bundle identifier (e.g., because you call this from a helper that is its own separate main bundle), populate the dictionary using some of the keys listed below

extern NSString *_Nonnull AIHBundleIdentifierKey;	// value: NSString (main bundle's identifier if omitted)
extern NSString *_Nonnull AIHBadgeKey;	// value: NSString (omit if there's no badge or if the badge is already rendered in your icon)
extern NSString *_Nonnull AIHImageKey;	// value: NSImage (omit unless you're drawing a custom icon image at runtime)


// displaying other apps' icons

typedef void (^AIHListeningBlock)(NSString *_Nonnull, NSImage *_Nullable, NSString *_Nullable, NSImage *_Nullable);	// parameters: bundle identifier, base icon (no badge, often nil), badge (or nil), composite icon (includes badge, nil when both base icon and badge are nil)

void AIHSetListeningBlock(AIHListeningBlock _Nullable listeningBlock);	// think of your listening block as similar to a delegate method; it will get executed on a dedicated serial queue whenever an app announces a change via one of the AIHAnnounce...() functions

NSImage *_Nullable AIHCreateCompositeIcon(NSDictionary *_Nonnull iconDictionary);	// short-circuit the announcement => listening process in cases where you only want to get badged icons rendered, e.g., after getting another app's badge via script (you are responsible for releasing the returned NSImage)


// drawing your own badges

NSImage *_Nonnull AIHCreateBadgeImage(NSString *_Nonnull badge, NSColor *_Nullable textColor, NSColor *_Nullable backgroundColor, NSColor *_Nullable borderColor);	// create your own badge image (you are responsible for releasing the returned NSImage)
void AIHDrawBadgeImage(NSImage *_Nonnull badgeImage, NSRect iconRect, BOOL alignWithTopEdge, BOOL alignWithRightEdge);	// draw a badge image
void AIHDrawBadge(NSString *_Nonnull badge, NSColor *_Nullable textColor, NSColor *_Nullable backgroundColor, NSColor *_Nullable borderColor, NSRect iconRect, BOOL alignWithTopEdge, BOOL alignWithRightEdge);	// convenience: both of the above
