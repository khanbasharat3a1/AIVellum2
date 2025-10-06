import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static const String appId = 'ca-app-pub-5294128665280219~2632618644';
  static const String bannerId = 'ca-app-pub-5294128665280219/1765156851';
  static const String interstitialId = 'ca-app-pub-5294128665280219/3632772298';
  static const String rewardedId = 'ca-app-pub-5294128665280219/6594989317';

  static bool _isInitialized = false;
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;
  static bool _isLoadingInterstitial = false;
  static bool _isLoadingRewarded = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    await MobileAds.instance.initialize();
    _isInitialized = true;
    
    // Preload ads
    await loadInterstitialAd();
    await loadRewardedAd();
  }

  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
  }

  static Future<void> loadInterstitialAd() async {
    if (_isLoadingInterstitial || _interstitialAd != null) return;
    
    _isLoadingInterstitial = true;
    await InterstitialAd.load(
      adUnitId: interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoadingInterstitial = false;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isLoadingInterstitial = false;
        },
      ),
    );
  }

  static Future<void> showInterstitialAd() async {
    if (_interstitialAd != null) {
      await _interstitialAd!.show();
      _interstitialAd = null;
      // Immediately load next ad
      loadInterstitialAd();
    } else {
      // Try to load if not available
      await loadInterstitialAd();
    }
  }

  static Future<void> loadRewardedAd() async {
    if (_isLoadingRewarded || _rewardedAd != null) return;
    
    _isLoadingRewarded = true;
    await RewardedAd.load(
      adUnitId: rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoadingRewarded = false;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isLoadingRewarded = false;
        },
      ),
    );
  }

  static Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) {
      // Try to load if not available
      await loadRewardedAd();
      if (_rewardedAd == null) return false;
    }

    bool rewarded = false;
    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) => rewarded = true,
    );
    _rewardedAd = null;
    // Immediately load next ad
    loadRewardedAd();
    return rewarded;
  }

  static void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
