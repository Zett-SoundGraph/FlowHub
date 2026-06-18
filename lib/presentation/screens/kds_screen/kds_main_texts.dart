class KdsMainTexts {
  static const appTitle = 'KDS SYSTEM';
  static const orderPrefix = 'NO.';
  static const completeCooking = '제조완료';
  static const completePickup = '픽업완료';
  static const completeCookingFailed = '제조 완료 처리에 실패했습니다.';
  static const completePickupFailed = '픽업 완료 처리에 실패했습니다.';

  static String cookingSignalSent(String orderNo) {
    return '$orderNo번 제조 완료 신호를 보냈습니다.';
  }
}
