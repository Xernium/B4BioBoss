// B4BioBoss: runtime fixes for BioShock 1.3.5 on iOS 10
// https://github.com/Xernium/B4BioBoss. Maintainer: Xernium. See README.md for credits.
//
// 1. Menu / cutscenes: -[IPhoneAppDelegate playVideoWithURL:showControls:] sends -stop to the MPMoviePlayerController instance 
//    used in the menu, that corrupts the player since PlaybackDidFinish is now wrong.
//    Effect is that the menu never shows (is behind the movie controller)
//    Different fix here as the community NOP fix at 0x018A4518 but has the same effect
//
// 2. This took a while to figure out: FMOD EX 4.44 has a (for this version) wrong thread stack size (8KB). 
//    That fails on modern (maybe 10+, idk) iOS because pthread_attr_setstacksize throws you a brick (EINVAL) if you do
//    dare request something that small (yea page alignment is at 16KB but anyway)
//    Effect is that the stream is never created but does create a ton of other errors that obscure the origin (FMOD_ERR_INTERNAL among others)
//    Fix is simple, force it to use 16KB. Very dumb. Should also work / not create a conflict on iOS 7/8 but I don't know honestly.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <substrate.h>
#include <pthread.h>
#include <limits.h>
#include <errno.h>
#include <unistd.h>
#include <dlfcn.h>
#include <mach-o/dyld.h>

static int gInPlayVideo = 0;
static const void *gMainHeader = NULL;

%hook IPhoneAppDelegate
- (void)playVideoWithURL:(NSURL *)url showControls:(BOOL)show {
    gInPlayVideo++;
    %orig;
    gInPlayVideo--;
}
%end

%hook MPMoviePlayerController
- (void)stop {
    MPMoviePlaybackState st = self.playbackState;
    // Make this not stop MPMoviePlayerController 
    if (gInPlayVideo && [NSThread isMainThread] && st != MPMoviePlaybackStatePlaying && st != MPMoviePlaybackStatePaused) {
        return; 
    }
    %orig;
}
%end

static int (*orig_setstacksize)(pthread_attr_t *, size_t);
static int fixed_setstacksize(pthread_attr_t *attr, size_t size) {
    int r = orig_setstacksize(attr, size);
    if (r != EINVAL || !gMainHeader) return r;
    Dl_info info;
    if (!dladdr(__builtin_return_address(0), &info) || info.dli_fbase != gMainHeader) return r; // only the game's own calls
    size_t page = (size_t)getpagesize();
    size_t want = size < PTHREAD_STACK_MIN ? PTHREAD_STACK_MIN : size;
    if (want < 16384) want = 16384;
    want = (want + page - 1) & ~(page - 1);
    return orig_setstacksize(attr, want);
}

// Not so nice but it works
%ctor {
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const char *n = _dyld_get_image_name(i);
        if (n && strstr(n, "/bioshock.app/bioshock")) { gMainHeader = _dyld_get_image_header(i); break; }
    }
    MSHookFunction((void *)pthread_attr_setstacksize, (void *)fixed_setstacksize, (void **)&orig_setstacksize);
}
