#import "AIHApplicationIconHerald.h"


#define AIH_BADGE_HEIGHT_DIVISOR 2.6
#define AIH_BADGE_PRERENDERED_SIZE 40.0
#define AIH_BADGE_PRERENDERED_PADDING 8.0
#define AIH_BADGE_PRERENDERED_SHADOW_BLUR_RADIUS 3.0


NSString *AIHAnnouncementNotificationName = @"com.manytricks.AIHAnnouncementNotification";
NSString *AIHRequestNotificationName = @"com.manytricks.AIHRequestNotification";

NSString *AIHFormatKey = @"Format";
NSString *AIHBundleUserNameKey = @"User";
NSString *AIHBundleIdentifierKey = @"Identifier";
NSString *AIHBadgeKey = @"Badge";
NSString *AIHImageKey = @"Image";


static NSImage *_Nonnull AIHCreateBadgeImage(NSString *_Nonnull badge, NSColor *_Nullable textColor, NSColor *_Nullable backgroundColor) {
	NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[paragraphStyle setAlignment: NSCenterTextAlignment];
	[paragraphStyle setLineBreakMode: NSLineBreakByTruncatingMiddle];
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
		((textColor) ? textColor : [NSColor whiteColor]), NSForegroundColorAttributeName,
		[NSFont systemFontOfSize: AIH_BADGE_PRERENDERED_SIZE], NSFontAttributeName,
		paragraphStyle, NSParagraphStyleAttributeName,
	nil];
	NSRect badgeBounds;
	badgeBounds.origin = NSZeroPoint;
	badgeBounds.size = [badge sizeWithAttributes: attributes];
	if (NSIsEmptyRect(badgeBounds)) {
		badgeBounds.size = NSMakeSize(AIH_BADGE_PRERENDERED_PADDING, AIH_BADGE_PRERENDERED_PADDING);
	}
	badgeBounds.size.width += AIH_BADGE_PRERENDERED_PADDING + AIH_BADGE_PRERENDERED_PADDING + AIH_BADGE_PRERENDERED_SHADOW_BLUR_RADIUS + AIH_BADGE_PRERENDERED_SHADOW_BLUR_RADIUS;
	badgeBounds.size.height += AIH_BADGE_PRERENDERED_PADDING + AIH_BADGE_PRERENDERED_PADDING + AIH_BADGE_PRERENDERED_SHADOW_BLUR_RADIUS + AIH_BADGE_PRERENDERED_SHADOW_BLUR_RADIUS;
	if (badgeBounds.size.width<badgeBounds.size.height) {
		badgeBounds.size.width = badgeBounds.size.height;
	} else {
		badgeBounds.size.width += AIH_BADGE_PRERENDERED_PADDING + AIH_BADGE_PRERENDERED_PADDING;
		CGFloat maximumWidth = badgeBounds.size.height * AIH_BADGE_HEIGHT_DIVISOR;
		if (badgeBounds.size.width>maximumWidth) {
			badgeBounds.size.width = maximumWidth;
		}
	}
	CGFloat radius = badgeBounds.size.height / 2.0;
	NSImage *badgeImage = [[NSImage alloc] initWithSize: badgeBounds.size];
	[badgeImage lockFocus];
	[NSGraphicsContext saveGraphicsState];
	[((backgroundColor) ? backgroundColor : [NSColor colorWithCalibratedRed: 1.0 green: 0.0 blue: 0.0 alpha: 0.9]) set];
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowOffset: NSMakeSize(0.0, -1.0)];
	[shadow setShadowBlurRadius: AIH_BADGE_PRERENDERED_SHADOW_BLUR_RADIUS];
	[shadow setShadowColor: [NSColor colorWithCalibratedWhite: 0.0 alpha: 0.4]];
	[shadow set];
	[[NSBezierPath bezierPathWithRoundedRect: NSInsetRect(badgeBounds, AIH_BADGE_PRERENDERED_SHADOW_BLUR_RADIUS, AIH_BADGE_PRERENDERED_SHADOW_BLUR_RADIUS) xRadius: radius yRadius: radius] fill];
	[NSGraphicsContext restoreGraphicsState];
	[badge drawInRect: NSInsetRect(badgeBounds, AIH_BADGE_PRERENDERED_PADDING + AIH_BADGE_PRERENDERED_SHADOW_BLUR_RADIUS, AIH_BADGE_PRERENDERED_PADDING + AIH_BADGE_PRERENDERED_SHADOW_BLUR_RADIUS) withAttributes: attributes];
	[badgeImage unlockFocus];
	#if !__has_feature(objc_arc)
		[paragraphStyle release];
		[shadow release];
	#endif
	return badgeImage;
}

static void AIHDrawBadgeImage(NSImage *_Nonnull badgeImage, NSRect iconRect, BOOL alignWithTopEdge, BOOL alignWithRightEdge) {
	NSSize badgeImageSize = [badgeImage size];
	NSRect badgeRect;
	badgeRect.size.height = iconRect.size.height / AIH_BADGE_HEIGHT_DIVISOR;
	badgeRect.size.width = badgeImageSize.width * badgeRect.size.height / badgeImageSize.height;
	badgeRect.origin = iconRect.origin;
	if (alignWithTopEdge) {
		badgeRect.origin.y += iconRect.size.height - badgeRect.size.height;
	}
	if (alignWithRightEdge) {
		badgeRect.origin.x += iconRect.size.width - badgeRect.size.width;
	}
	[badgeImage drawInRect: badgeRect fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1.0];
}

void AIHDrawBadge(NSString *_Nonnull badge, NSColor *_Nullable textColor, NSColor *_Nullable backgroundColor, NSRect iconRect, BOOL alignWithTopEdge, BOOL alignWithRightEdge) {
	@autoreleasepool {
		NSImage *badgeImage = AIHCreateBadgeImage(badge, textColor, backgroundColor);
		if (badgeImage) {
			AIHDrawBadgeImage(badgeImage, iconRect, alignWithTopEdge, alignWithRightEdge);
			#if !__has_feature(objc_arc)
				[badgeImage release];
			#endif
		}
	}
}

static NSDictionary *_Nullable AIHCreateTransportDictionary(NSDictionary *_Nullable iconDictionary) {
	NSMutableDictionary *transportDictionary = nil;
	@autoreleasepool {
		NSString *userName = NSUserName();
		if (userName) {
			NSString *bundleIdentifier = [iconDictionary objectForKey: AIHBundleIdentifierKey];
			if ((bundleIdentifier) || (bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier])) {
				transportDictionary = [[NSMutableDictionary alloc] init];
				[transportDictionary setObject: @"1" forKey: AIHFormatKey];
				[transportDictionary setObject: userName forKey: AIHBundleUserNameKey];
				[transportDictionary setObject: bundleIdentifier forKey: AIHBundleIdentifierKey];
				NSImage *image = [iconDictionary objectForKey: AIHImageKey];
				if (image) {
					NSData *imageData = [image TIFFRepresentationUsingCompression: NSTIFFCompressionLZW factor: 0];
					if (imageData) {
						#if __MAC_OS_X_VERSION_MIN_REQUIRED<__MAC_10_9
							NSString *imageString = ([imageData respondsToSelector: @selector(base64EncodedStringWithOptions:)] ? [imageData base64EncodedStringWithOptions: 0] : [imageData base64Encoding]);
						#else
							NSString *imageString = [imageData base64EncodedStringWithOptions: 0];
						#endif
						if (imageString) {
							[transportDictionary setObject: imageString forKey: AIHImageKey];
						} else {
							NSLog(@"[AIH] cannot encode image");
						}
					} else {
						NSLog(@"[AIH] cannot compress image");
					}
				}
				NSString *badge = [iconDictionary objectForKey: AIHBadgeKey];
				if ((badge) && (![badge isEqualToString: @"0"])) {
					[transportDictionary setObject: badge forKey: AIHBadgeKey];
				}
			} else {
				NSLog(@"[AIH] cannot determine bundle identifier");
			}
		} else {
			NSLog(@"[AIH] cannot determine user name");
		}
	}
	return transportDictionary;
}

static BOOL AIHProcessTransportDictionary(NSDictionary *_Nonnull transportDictionary, NSString *_Nullable *_Nullable bundleIdentifierPointer, NSImage *_Nullable *_Nullable imagePointer, NSString *_Nullable *_Nullable badgePointer, NSImage *_Nullable *_Nullable compositeIconPointer) {
	NSString *bundleIdentifier = [transportDictionary objectForKey: AIHBundleIdentifierKey];
	if (bundleIdentifier) {
		NSImage *compositeIcon = nil;
		NSImage *image = nil;
		NSString *imageString = [transportDictionary objectForKey: AIHImageKey];
		if (imageString) {
			NSData *imageData = [[NSData alloc] initWithBase64EncodedString: imageString options: 0];
			if (imageData) {
				image = [[NSImage alloc] initWithData: imageData];
				if (image) {
					#if !__has_feature(objc_arc)
						[image autorelease];
					#endif
				} else {
					NSLog(@"[AIH] cannot generate image");
				}
				#if !__has_feature(objc_arc)
					[imageData release];
				#endif
			} else {
				NSLog(@"[AIH] cannot decode image");
			}
		}
		NSString *badge = [transportDictionary objectForKey: AIHBadgeKey];
		if (badge) {
			NSImage *baseIcon = ((image) ? image : [[[NSRunningApplication runningApplicationsWithBundleIdentifier: bundleIdentifier] firstObject] icon]);
			if (baseIcon) {
				NSImage *badgeImage = AIHCreateBadgeImage(badge, nil, nil);
				compositeIcon = [NSImage imageWithSize: [baseIcon size] flipped: NO drawingHandler: ^(NSRect targetRect) {
					[baseIcon drawInRect: targetRect fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1.0];
					AIHDrawBadgeImage(badgeImage, targetRect, YES, YES);
					return YES;
				}];
				#if !__has_feature(objc_arc)
					[badgeImage release];
				#endif
			} else {
				NSLog(@"[AIH] cannot identify base icon");
			}
		}
		if (bundleIdentifierPointer) {
			(*bundleIdentifierPointer) = bundleIdentifier;
		}
		if (imagePointer) {
			(*imagePointer) = image;
		}
		if (badgePointer) {
			(*badgePointer) = badge;
		}
		if (compositeIconPointer) {
			(*compositeIconPointer) = ((compositeIcon) ? compositeIcon : image);
		}
		return YES;
	}
	NSLog(@"[AIH] missing bundle identifier");
	return NO;
}


@interface AIHSerialQueueOwner: NSObject

	{
		dispatch_queue_t _serialQueue;
	}

@end

@implementation AIHSerialQueueOwner

	- (instancetype)init {
		self = [super init];
		if (self) {
			_serialQueue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
		}
		return self;
	}

	#if !__has_feature(objc_arc) || OS_OBJECT_HAVE_OBJC_SUPPORT==0
		- (void)dealloc {
			if (_serialQueue) {
				dispatch_release(_serialQueue);
			}
			[super dealloc];
		}
	#endif

@end


@interface AIHAnnouncer: AIHSerialQueueOwner

@end

@implementation AIHAnnouncer

	{
		NSString *_latestTransportString;
	}

	+ (AIHAnnouncer *)defaultAnnouncer {
		static AIHAnnouncer *staticDefaultAnnouncer = nil;
		static dispatch_once_t staticToken;
		dispatch_once(&staticToken, ^{
			staticDefaultAnnouncer = [[self alloc] init];
		});
		return staticDefaultAnnouncer;
	}

	- (instancetype)init {
		self = [super init];
		if (self) {
			[[NSDistributedNotificationCenter defaultCenter] addObserver: self selector: @selector(reannounce:) name: AIHRequestNotificationName object: nil];
		}
		return self;
	}

	- (void)announce: (NSDictionary *_Nullable)iconDictionary {
		dispatch_async(_serialQueue, ^{
			NSDictionary *transportDictionary = AIHCreateTransportDictionary(iconDictionary);
			if (transportDictionary) {
				@autoreleasepool {
					NSError *error = nil;
					NSData *transportData = [NSJSONSerialization dataWithJSONObject: transportDictionary options: 0 error: &error];
					if (transportData) {
						NSString *transportString = [[NSString alloc] initWithData: transportData encoding: NSUTF8StringEncoding];
						if (transportString) {
							@synchronized (self) {
								_latestTransportString = transportString;
								[[NSDistributedNotificationCenter defaultCenter] postNotificationName: AIHAnnouncementNotificationName object: transportString userInfo: nil options: NSDistributedNotificationDeliverImmediately | NSDistributedNotificationPostToAllSessions];
							}
						} else {
							NSLog(@"[AIH] cannot encode");
						}
					} else {
						NSLog(@"[AIH] cannot serialize: %@", error);
					}
				}
				#if !__has_feature(objc_arc)
					[transportDictionary release];
				#endif
			}
		});
	}

	- (void)reannounce: (NSNotification *_Nullable)notification {
		@synchronized (self) {
			[[NSDistributedNotificationCenter defaultCenter] postNotificationName: AIHAnnouncementNotificationName object: _latestTransportString userInfo: nil options: NSDistributedNotificationDeliverImmediately | NSDistributedNotificationPostToAllSessions];
		}
	}

	- (void)dealloc {
		[[NSDistributedNotificationCenter defaultCenter] removeObserver: self];
		#if !__has_feature(objc_arc)
			[_latestTransportString release];
		#endif
		[super dealloc];
	}

@end


@interface AIHListener: AIHSerialQueueOwner

@end

@implementation AIHListener

	{
		AIHListeningBlock _listeningBlock;
	}

	+ (AIHListener *)defaultListener {
		static AIHListener *staticDefaultListener = nil;
		static dispatch_once_t staticToken;
		dispatch_once(&staticToken, ^{
			staticDefaultListener = [[self alloc] init];
		});
		return staticDefaultListener;
	}

	- (void)setListeningBlock: (AIHListeningBlock _Nullable)listeningBlock {
		@synchronized (self) {
			NSDistributedNotificationCenter *distributedNotificationCenter = [NSDistributedNotificationCenter defaultCenter];
			BOOL didListen = NO;
			if (_listeningBlock) {
				#if !__has_feature(objc_arc)
					[_listeningBlock release];
				#endif
				didListen = YES;
			}
			_listeningBlock = [listeningBlock copy];
			if (_listeningBlock) {
				if (!didListen) {
					[distributedNotificationCenter addObserver: self selector: @selector(listen:) name: AIHAnnouncementNotificationName object: nil suspensionBehavior: NSNotificationSuspensionBehaviorDeliverImmediately];
				}
				[distributedNotificationCenter postNotificationName: AIHRequestNotificationName object: nil userInfo: nil options: NSDistributedNotificationDeliverImmediately | NSDistributedNotificationPostToAllSessions];
			} else if (didListen) {
				[distributedNotificationCenter removeObserver: self];
			}
		}
	}

	- (void)listen: (NSNotification *_Nullable)notification {
		NSString *transportString = [notification object];
		if ([transportString length]>0) {
			dispatch_async(_serialQueue, ^{
				@autoreleasepool {
					NSData *transportData = [transportString dataUsingEncoding: NSUTF8StringEncoding];
					if (transportData) {
						NSError *error = nil;
						NSDictionary *transportDictionary = [NSJSONSerialization JSONObjectWithData: transportData options: 0 error: &error];
						if (transportDictionary) {
							NSString *userName = [transportDictionary objectForKey: AIHBundleUserNameKey];
							if ((userName) && [NSUserName() isEqualToString: userName]) {
								NSString *bundleIdentifier;
								NSImage *compositeIcon;
								if (AIHProcessTransportDictionary(transportDictionary, &bundleIdentifier, NULL, NULL, &compositeIcon)) {
									@synchronized (self) {
										if (_listeningBlock) {
											_listeningBlock(bundleIdentifier, compositeIcon);
										}
									}
								}
							}
						} else {
							NSLog(@"[AIH] cannot deserialize: %@", error);
						}
					} else {
						NSLog(@"[AIH] cannot decode");
					}
				}
			});
		}
	}

	- (void)dealloc {
		if (_listeningBlock) {
			[[NSDistributedNotificationCenter defaultCenter] removeObserver: self];
			#if !__has_feature(objc_arc)
				[_listeningBlock release];
			#endif
		}
		[super dealloc];
	}

@end


void AIHAnnounceBadgeCount(NSInteger count) {
	@autoreleasepool {
		[[AIHAnnouncer defaultAnnouncer] announce: ((count==0) ? nil : [NSDictionary dictionaryWithObject: [NSString stringWithFormat: @"%ld", (long)count] forKey: AIHBadgeKey])];
	}
}

void AIHAnnounceBadge(NSString *_Nullable badge) {
	@autoreleasepool {
		[[AIHAnnouncer defaultAnnouncer] announce: ((badge) ? [NSDictionary dictionaryWithObject: badge forKey: AIHBadgeKey] : nil)];
	}
}

void AIHAnnounceImage(NSImage *_Nullable image) {
	@autoreleasepool {
		[[AIHAnnouncer defaultAnnouncer] announce: ((image) ? [NSDictionary dictionaryWithObject: image forKey: AIHImageKey] : nil)];
	}
}

void AIHAnnounceIcon(NSDictionary *_Nullable iconDictionary) {
	[[AIHAnnouncer defaultAnnouncer] announce: iconDictionary];
}

void AIHSetListeningBlock(AIHListeningBlock _Nullable listeningBlock) {
	[[AIHListener defaultListener] setListeningBlock: listeningBlock];
}

NSImage *_Nullable AIHCreateCompositeIcon(NSDictionary *_Nonnull iconDictionary) {
	NSImage *compositeIcon = nil;
	@autoreleasepool {
		NSDictionary *transportDictionary = AIHCreateTransportDictionary(iconDictionary);
		if (transportDictionary) {
			AIHProcessTransportDictionary(transportDictionary, NULL, NULL, NULL, &compositeIcon);
			#if !__has_feature(objc_arc)
				[transportDictionary release];
				[compositeIcon retain];
			#endif
		}
	}
	return compositeIcon;
}
