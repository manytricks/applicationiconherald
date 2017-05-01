#import "AIHApplicationIconHerald.h"
#import <CommonCrypto/CommonDigest.h>


#define AIH_BADGE_HEIGHT_DIVISOR 2.7
#define AIH_BADGE_PRERENDERED_SIZE 40.0
#define AIH_BADGE_PRERENDERED_PADDING 8.0
#define AIH_BADGE_PRERENDERED_SHADOW_BLUR_RADIUS 3.0


NSString *AIHAnnouncementNotificationName = @"com.manytricks.AIHAnnouncementNotification";
NSString *AIHRequestNotificationName = @"com.manytricks.AIHRequestNotification";

NSString *AIHFormatKey = @"Format";
NSString *AIHBundleUserNameHashKey = @"User";
NSString *AIHBundleIdentifierKey = @"Identifier";
NSString *AIHBadgeKey = @"Badge";
NSString *AIHImageKey = @"Image";


NSImage *_Nonnull AIHCreateBadgeImage(NSString *_Nonnull badge, NSColor *_Nullable textColor, NSColor *_Nullable backgroundColor, NSColor *_Nullable borderColor) {
	NSImage *badgeImage = nil;
	@autoreleasepool {
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
		badgeImage = [[NSImage alloc] initWithSize: badgeBounds.size];
		[badgeImage lockFocus];
		[NSGraphicsContext saveGraphicsState];
		[((backgroundColor) ? backgroundColor : [NSColor colorWithCalibratedRed: 1.0 green: 0.0 blue: 0.0 alpha: 0.9]) set];
		NSShadow *shadow = [[NSShadow alloc] init];
		[shadow setShadowOffset: NSMakeSize(0.0, -1.0)];
		[shadow setShadowBlurRadius: AIH_BADGE_PRERENDERED_SHADOW_BLUR_RADIUS];
		[shadow setShadowColor: [NSColor colorWithCalibratedWhite: 0.0 alpha: 0.4]];
		[shadow set];
		NSRect innerBadgeRect = NSInsetRect(badgeBounds, AIH_BADGE_PRERENDERED_SHADOW_BLUR_RADIUS, AIH_BADGE_PRERENDERED_SHADOW_BLUR_RADIUS);
		[[NSBezierPath bezierPathWithRoundedRect: innerBadgeRect xRadius: innerBadgeRect.size.height * 0.5 yRadius: innerBadgeRect.size.height * 0.5] fill];
		[NSGraphicsContext restoreGraphicsState];
		if ((borderColor) || (NSAppKitVersionNumber<1343/*NSAppKitVersionNumber10_10*/)) {
			[NSGraphicsContext saveGraphicsState];
			[((borderColor) ? borderColor : [NSColor whiteColor]) set];
			CGFloat borderWidth = floor(innerBadgeRect.size.height * 0.05);
			if (borderWidth<1) {
				borderWidth = 1.0;
			}
			NSRect borderRect = NSInsetRect(innerBadgeRect, borderWidth * 0.5, borderWidth * 0.5);
			NSBezierPath *borderPath = [NSBezierPath bezierPathWithRoundedRect: borderRect xRadius: borderRect.size.height * 0.5 yRadius: borderRect.size.height * 0.5];
			[borderPath setLineWidth: borderWidth];
			[borderPath stroke];
			[NSGraphicsContext restoreGraphicsState];
		}
		[badge drawInRect: NSInsetRect(badgeBounds, AIH_BADGE_PRERENDERED_PADDING + AIH_BADGE_PRERENDERED_SHADOW_BLUR_RADIUS, AIH_BADGE_PRERENDERED_PADDING + AIH_BADGE_PRERENDERED_SHADOW_BLUR_RADIUS) withAttributes: attributes];
		[badgeImage unlockFocus];
		#if !__has_feature(objc_arc)
			[paragraphStyle release];
			[shadow release];
		#endif
	}
	return badgeImage;
}

void AIHDrawBadgeImage(NSImage *_Nonnull badgeImage, NSRect iconRect, BOOL alignWithTopEdge, BOOL alignWithRightEdge) {
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

void AIHDrawBadge(NSString *_Nonnull badge, NSColor *_Nullable textColor, NSColor *_Nullable backgroundColor, NSColor *_Nullable borderColor, NSRect iconRect, BOOL alignWithTopEdge, BOOL alignWithRightEdge) {
	NSImage *badgeImage = AIHCreateBadgeImage(badge, textColor, backgroundColor, borderColor);
	if (badgeImage) {
		AIHDrawBadgeImage(badgeImage, iconRect, alignWithTopEdge, alignWithRightEdge);
		#if !__has_feature(objc_arc)
			[badgeImage release];
		#endif
	}
}

static NSString *_Nonnull AIHTransportStringFromData(NSData *_Nonnull data) {
	#if __MAC_OS_X_VERSION_MIN_REQUIRED<__MAC_10_9
		return ([data respondsToSelector: @selector(base64EncodedStringWithOptions:)] ? [data base64EncodedStringWithOptions: 0] : [data base64Encoding]);
	#else
		return [data base64EncodedStringWithOptions: 0];
	#endif
}

static NSString *_Nullable AIHUserNameHash(void) {
	NSData *data = [NSUserName() dataUsingEncoding: NSUTF8StringEncoding];
	if (data) {
		unsigned char buffer[CC_SHA1_DIGEST_LENGTH];
		CC_SHA1(data.bytes, (CC_LONG)data.length, buffer);
		return AIHTransportStringFromData([NSData dataWithBytes: buffer length: CC_SHA1_DIGEST_LENGTH]);
	}
	return nil;
}

static NSDictionary *_Nullable AIHCreateTransportDictionary(NSDictionary *_Nullable iconDictionary) {
	NSMutableDictionary *transportDictionary = nil;
	@autoreleasepool {
		NSString *userNameHash = AIHUserNameHash();
		if (userNameHash) {
			NSString *bundleIdentifier = [iconDictionary objectForKey: AIHBundleIdentifierKey];
			if ((bundleIdentifier) || (bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier])) {
				transportDictionary = [[NSMutableDictionary alloc] init];
				[transportDictionary setObject: @"1" forKey: AIHFormatKey];
				[transportDictionary setObject: userNameHash forKey: AIHBundleUserNameHashKey];
				[transportDictionary setObject: bundleIdentifier forKey: AIHBundleIdentifierKey];
				NSImage *image = [iconDictionary objectForKey: AIHImageKey];
				if (image) {
					NSData *imageData = [image TIFFRepresentationUsingCompression: NSTIFFCompressionLZW factor: 0];
					if (imageData) {
						[transportDictionary setObject: AIHTransportStringFromData(imageData) forKey: AIHImageKey];
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
			#if __MAC_OS_X_VERSION_MIN_REQUIRED<__MAC_10_9
				NSData *imageData = ([NSData instancesRespondToSelector: @selector(initWithBase64EncodedString:)] ? [[NSData alloc] initWithBase64EncodedString: imageString options: 0] : [[NSData alloc] initWithBase64Encoding: imageString]);
			#else
				NSData *imageData = [[NSData alloc] initWithBase64EncodedString: imageString options: 0];
			#endif
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
				NSImage *badgeImage = AIHCreateBadgeImage(badge, nil, nil, nil);
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

static void AIHPostNotification(NSString *_Nonnull name, NSString *_Nullable object) {
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName: name object: object userInfo: nil options: NSNotificationDeliverImmediately | NSNotificationPostToAllSessions];
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

	{
		NSString *_latestTransportString;
	}

@end

@implementation AIHAnnouncer

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
								AIHPostNotification(AIHAnnouncementNotificationName, _latestTransportString);
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
			AIHPostNotification(AIHAnnouncementNotificationName, _latestTransportString);
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

	{
		AIHListeningBlock _listeningBlock;
	}

@end

@implementation AIHListener

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
					[[NSDistributedNotificationCenter defaultCenter] addObserver: self selector: @selector(listen:) name: AIHAnnouncementNotificationName object: nil suspensionBehavior: NSNotificationSuspensionBehaviorDeliverImmediately];
				}
				AIHPostNotification(AIHRequestNotificationName, nil);
			} else if (didListen) {
				[[NSDistributedNotificationCenter defaultCenter] removeObserver: self];
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
							NSString *userNameHash = [transportDictionary objectForKey: AIHBundleUserNameHashKey];
							if ((userNameHash) && [AIHUserNameHash() isEqualToString: userNameHash]) {
								NSString *bundleIdentifier;
								NSImage *image;
								NSString *badge;
								NSImage *compositeIcon;
								if (AIHProcessTransportDictionary(transportDictionary, &bundleIdentifier, &image, &badge, &compositeIcon)) {
									@synchronized (self) {
										if (_listeningBlock) {
											_listeningBlock(bundleIdentifier, image, badge, compositeIcon);
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
