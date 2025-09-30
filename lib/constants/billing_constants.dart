class BillingConstants {
  // Google Play Console RSA Public Key
  static const String playStorePublicKey = 
      'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnKvOhv0k+1C8JnuGbJT15Y1SiVymB/976SMlbqiJf8xWdv6SGfXgdi0BbXf0wkjJPe6yDYglg9Qe5eSka1I2dgsN38rhJ9IZa30uhm6z4Zk4iVA8rxX40VYrTLvbpdm15ck8r/DfBKIA5sOcxpcOW/K39fYgqZFuzMQsOv1rw2EqiFL8wMsp4s4yO6uvU8haxYlx+Y2+b5oB2fwMdW3iIPIxvOtL1JY07b3jUMdJ+kzgbGkdFJmKzxHUue7bn6Fvvw8IAOs+6zPCv+lcbEr2zTfqJwXkkp/IZSRon0mZk1FleQopDhbX2LpLml44T2g/fAq3SNv8P03KyuwTPmmXJQIDAQAB';
  
  // Product IDs
  static const String unlockAllPromptsId = 'unlock_all_prompts';
  static const String unlockSinglePromptId = 'unlock_prompt';
  static const String premiumMonthlyId = 'premium_monthly';
  
  // Product details for fallback
  static const Map<String, Map<String, dynamic>> productDetails = {
    unlockAllPromptsId: {
      'name': 'Unlock All Prompts',
      'description': 'Get lifetime access to all premium AI prompts in Aivellum.',
      'price': '₹999.00',
    },
    unlockSinglePromptId: {
      'name': 'Unlock Single Prompt',
      'description': 'Unlock access to one premium AI prompt instantly.',
      'price': '₹4.00',
    },
    premiumMonthlyId: {
      'name': 'Premium Monthly',
      'description': 'Get unlimited access to all premium AI prompts with monthly subscription.',
      'price': '₹99.00/month',
    },
  };
}