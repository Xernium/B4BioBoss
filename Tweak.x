// B4BioBoss: runtime fixes for BioShock 1.3.5 on iOS 10
// https://github.com/Xernium/B4BioBoss. Maintainer: Xernium. See README.md for credits.
//
//    Menu / cutscenes: -[IPhoneAppDelegate playVideoWithURL:showControls:] sends -stop to the MPMoviePlayerController instance 
//    used in the menu, that corrupts the player since PlaybackDidFinish is now wrong.
//    Effect is that the menu never shows (is behind the movie controller)
//    Different fix here as the community NOP fix at 0x018A4518 but has the same effect
//
//    An audio fix is also provided by a different tweak I made, this one now depends on that one
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <substrate.h>

static int gInPlayVideo = 0;

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
