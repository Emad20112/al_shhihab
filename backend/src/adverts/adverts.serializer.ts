import { Advert } from "./entities/advert.entity";

export function serializeAdvert(advert: Advert) {
  return {
    id: advert.id,
    slug: advert.slug,
    title: advert.title,
    title_ar: advert.titleAr,
    subtitle: advert.subtitle,
    subtitle_ar: advert.subtitleAr,
    image_url: advert.imageUrl,
    cta_label: advert.ctaLabel,
    cta_label_ar: advert.ctaLabelAr,
    placement: advert.placement,
    campaign_type: advert.campaignType,
    discount_percent: advert.discountPercent,
    product_id: advert.productId,
    category_id: advert.categoryId,
    active: advert.active,
    priority: advert.priority,
    starts_at: advert.startsAt,
    ends_at: advert.endsAt,
  };
}
