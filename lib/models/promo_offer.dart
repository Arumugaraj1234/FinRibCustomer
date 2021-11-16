class PromoOffer {
  String promoCode;
  PromoType promoType;
  DiscountCalculationType discountCalculationType;
  int value;
  int promoTypeFlag;

  PromoOffer(
      {this.promoCode,
      this.promoType,
      this.discountCalculationType,
      this.value,
      this.promoTypeFlag});
}

enum DiscountCalculationType { rawAmount, percentage }
enum PromoType { coupon, voucher }
