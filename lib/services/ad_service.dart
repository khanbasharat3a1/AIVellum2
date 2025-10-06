import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static const String appId = 'ca-app-pub-5294128665280219~2632618644';
  static const String bannerId = 'ca-app-pub-5294128665280219/1765156851';
  static const String interstitialId = 'ca-app-pub-5294128665280219/3632772298';
  static const String rewardedId = 'ca-app-pub-5294128665280219/6594989317';

  static bool _isInitialized = false;
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    await MobileAds.instance.initialize();
    _isInitialized = true;
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
    await InterstitialAd.load(
      adUnitId: interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
  }

  static Future<void> showInterstitialAd() async {
    if (_interstitialAd != null) {
      await _interstitialAd!.show();
      _interstitialAd = null;
      await loadInterstitialAd();
    }
  }

  static Future<void> loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (error) => _rewardedAd = null,
      ),
    );
  }

  static Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) return false;

    bool rewarded = false;
    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) => rewarded = true,
    );
    _rewardedAd = null;
    await loadRewardedAd();
    return rewarded;
  }

  static void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
