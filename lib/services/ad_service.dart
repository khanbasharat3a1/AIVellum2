import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static const String _bannerId = 'ca-app-pub-5294128665280219/1765156851';
  static const String _interstitialId = 'ca-app-pub-5294128665280219/3632772298';
  static const String _rewardedId = 'ca-app-pub-5294128665280219/6594989317';

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: _bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => print('Banner ad loaded'),
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load: $error');
          ad.dispose();
        },
      ),
    );
  }

  static Future<InterstitialAd?> loadInterstitialAd() async {
    InterstitialAd? ad;
    await InterstitialAd.load(
      adUnitId: _interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd loadedAd) {
          ad = loadedAd;
          print('Interstitial ad loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Interstitial ad failed to load: $error');
        },
      ),
    );
    return ad;
  }

  static Future<RewardedAd?> loadRewardedAd() async {
    RewardedAd? ad;
    await RewardedAd.load(
      adUnitId: _rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd loadedAd) {
          ad = loadedAd;
          print('Rewarded ad loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Rewarded ad failed to load: $error');
        },
      ),
    );
    return ad;
  }
}
