import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/app_constants.dart';
import 'database_service.dart';

class AdsService {
  static BannerAd? _bannerAd;
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;
  
  static bool _isBannerAdReady = false;
  static bool _isInterstitialAdReady = false;
  static bool _isRewardedAdReady = false;
  
  // Industry standard ad limits
  static const int maxRewardedAdsPerSession = 3;
  static const int sessionCooldownMinutes = 60; // 1 hour after 3 ads
  static const int singleAdCooldownSeconds = 30; // 30 seconds between individual ads

  static void initialize() {
    _loadBannerAd();
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  // Banner Ad
  static void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AppConstants.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isBannerAdReady = true;
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );
    _bannerAd!.load();
  }

  static BannerAd? getBannerAd() {
    return _isBannerAdReady ? _bannerAd : null;
  }

  // Interstitial Ad
  static void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AppConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          _setInterstitialAdListener();
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  static void _setInterstitialAdListener() {
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        print('Interstitial ad showed full screen content.');
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('Interstitial ad dismissed.');
        ad.dispose();
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('Interstitial ad failed to show: $error');
        ad.dispose();
        _loadInterstitialAd();
      },
    );
  }

  static void showInterstitialAd() {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
      _isInterstitialAdReady = false;
    } else {
      print('Interstitial ad not ready');
    }
  }

  // Rewarded Ad
  static void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AppConstants.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          _setRewardedAdListener();
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('RewardedAd failed to load: $error');
          _isRewardedAdReady = false;
        },
      ),
    );
  }

  static void _setRewardedAdListener() {
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        print('Rewarded ad showed full screen content.');
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('Rewarded ad dismissed.');
        ad.dispose();
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('Rewarded ad failed to show: $error');
        ad.dispose();
        _loadRewardedAd();
      },
    );
  }

  static Future<bool> showRewardedAd() async {
    if (_isRewardedAdReady && _rewardedAd != null) {
      bool rewardEarned = false;
      
      final completer = Completer<bool>();
      
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          ad.dispose();
          _loadRewardedAd();
          completer.complete(rewardEarned);
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          ad.dispose();
          _loadRewardedAd();
          completer.complete(false);
        },
      );
      
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) async {
          print('User earned reward: ${reward.amount} ${reward.type}');
          rewardEarned = true;
          await DatabaseService.incrementAdWatchCount();
        },
      );
      
      _isRewardedAdReady = false;
      return await completer.future;
    } else {
      print('Rewarded ad not ready');
      return false;
    }
  }

  static bool get isRewardedAdReady => _isRewardedAdReady;

  static Future<bool> canShowRewardedAd() async {
    final stats = await DatabaseService.getUserStats();
    final lastAdTime = await DatabaseService.getLastAdWatchTime();
    final todayAdCount = stats['ads_watched_today'] ?? 0;
    
    if (lastAdTime != null) {
      final timeSinceLastAd = DateTime.now().difference(lastAdTime);
      
      // Check session limit (3 ads)
      if (todayAdCount >= maxRewardedAdsPerSession) {
        if (timeSinceLastAd.inMinutes < sessionCooldownMinutes) {
          return false;
        } else {
          // Reset daily count after cooldown
          await DatabaseService.resetDailyAdCount();
        }
      }
      
      // Check individual ad cooldown (30 seconds)
      if (timeSinceLastAd.inSeconds < singleAdCooldownSeconds) {
        return false;
      }
    }
    
    return _isRewardedAdReady;
  }

  static Future<String?> getAdLimitMessage() async {
    final stats = await DatabaseService.getUserStats();
    final lastAdTime = await DatabaseService.getLastAdWatchTime();
    final todayAdCount = stats['ads_watched_today'] ?? 0;
    
    if (lastAdTime != null) {
      final timeSinceLastAd = DateTime.now().difference(lastAdTime);
      
      if (todayAdCount >= maxRewardedAdsPerSession && timeSinceLastAd.inMinutes < sessionCooldownMinutes) {
        final remainingTime = sessionCooldownMinutes - timeSinceLastAd.inMinutes;
        return 'You\'ve watched 3 ads today. Try again in $remainingTime minutes.';
      }
      
      if (timeSinceLastAd.inSeconds < singleAdCooldownSeconds) {
        final remainingTime = singleAdCooldownSeconds - timeSinceLastAd.inSeconds;
        return 'Please wait $remainingTime seconds before next ad.';
      }
    }
    
    return null;
  }

  static void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}