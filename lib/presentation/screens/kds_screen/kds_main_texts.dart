class KdsMainTexts {
  static const appTitle = 'KDS SYSTEM';
  static const orderPrefix = 'NO.';
  static const completeCooking = 'Done Cooking';
  static const completePickup = 'Pickup Done';
  static const completeCookingFailed = 'Failed to mark cooking as complete.';
  static const completePickupFailed = 'Failed to mark pickup as complete.';

  static String cookingSignalSent(String orderNo) {
    return 'Order $orderNo cooking complete signal sent.';
  }
}
