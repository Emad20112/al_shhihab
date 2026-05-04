import { Injectable, NotFoundException, OnModuleInit } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { LessThanOrEqual, MoreThanOrEqual, Repository } from "typeorm";

import { CreateAdvertDto, UpdateAdvertDto } from "./dto/upsert-advert.dto";
import { Advert } from "./entities/advert.entity";

@Injectable()
export class AdvertsService implements OnModuleInit {
  constructor(
    @InjectRepository(Advert)
    private readonly advertsRepository: Repository<Advert>,
  ) {}

  async onModuleInit() {
    await this.seedLocalFashionCampaigns();
  }

  async findActive() {
    const now = new Date();
    return this.advertsRepository.find({
      where: {
        active: true,
        startsAt: LessThanOrEqual(now),
        endsAt: MoreThanOrEqual(now),
      },
      order: { priority: "ASC", id: "ASC" },
    });
  }

  async findAll() {
    return this.advertsRepository.find({
      order: { priority: "ASC", id: "DESC" },
    });
  }

  async findOne(id: number) {
    const advert = await this.advertsRepository.findOne({ where: { id } });
    if (!advert) throw new NotFoundException("الإعلان غير موجود");
    return advert;
  }

  async create(dto: CreateAdvertDto) {
    const advert = this.advertsRepository.create(this.toAdvertInput(dto));
    return this.advertsRepository.save(advert);
  }

  async update(id: number, dto: UpdateAdvertDto) {
    const advert = await this.findOne(id);
    Object.assign(advert, this.toAdvertInput(dto));
    return this.advertsRepository.save(advert);
  }

  async remove(id: number) {
    const advert = await this.findOne(id);
    await this.advertsRepository.remove(advert);
    return { id };
  }

  private toAdvertInput(dto: CreateAdvertDto | UpdateAdvertDto) {
    const input: Partial<Advert> = {};
    if (dto.slug !== undefined) input.slug = dto.slug;
    if (dto.title !== undefined) input.title = dto.title;
    if (dto.title_ar !== undefined) input.titleAr = dto.title_ar;
    if (dto.subtitle !== undefined) input.subtitle = dto.subtitle;
    if (dto.subtitle_ar !== undefined) input.subtitleAr = dto.subtitle_ar;
    if (dto.image_url !== undefined) input.imageUrl = dto.image_url;
    if (dto.cta_label !== undefined) input.ctaLabel = dto.cta_label;
    if (dto.cta_label_ar !== undefined) input.ctaLabelAr = dto.cta_label_ar;
    if (dto.placement !== undefined) input.placement = dto.placement;
    if (dto.campaign_type !== undefined) input.campaignType = dto.campaign_type;
    if (dto.discount_percent !== undefined) {
      input.discountPercent = dto.discount_percent;
    }
    if (dto.product_id !== undefined) input.productId = dto.product_id || null;
    if (dto.category_id !== undefined)
      input.categoryId = dto.category_id || null;
    if (dto.active !== undefined) input.active = dto.active;
    if (dto.priority !== undefined) input.priority = dto.priority;
    if (dto.starts_at !== undefined) input.startsAt = new Date(dto.starts_at);
    if (dto.ends_at !== undefined) input.endsAt = new Date(dto.ends_at);
    return input;
  }

  private async seedLocalFashionCampaigns() {
    const count = await this.advertsRepository.count();
    if (count > 0) return;

    await this.advertsRepository.save([
      this.advertsRepository.create({
        slug: "new-season-edit",
        title: "New Season Edit",
        titleAr: "تشكيلة الموسم الجديدة",
        subtitle:
          "Fresh shirts, dresses, and sneakers curated for everyday style.",
        subtitleAr: "قمصان وفساتين وأحذية مختارة لإطلالة يومية أنيقة ومتجددة.",
        imageUrl:
          "https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=1200",
        ctaLabel: "Shop the Edit",
        ctaLabelAr: "تسوق التشكيلة",
        placement: "home_hero",
        campaignType: "seasonal",
        discountPercent: null,
        productId: null,
        categoryId: "women",
        active: true,
        priority: 1,
        startsAt: new Date("2026-01-01T00:00:00.000Z"),
        endsAt: new Date("2027-01-01T00:00:00.000Z"),
      }),
      this.advertsRepository.create({
        slug: "sneaker-week",
        title: "Sneaker Week",
        titleAr: "أسبوع الأحذية الرياضية",
        subtitle: "Up to 25% off running and street sneakers.",
        subtitleAr: "خصومات حتى 25% على أحذية الجري والأحذية اليومية.",
        imageUrl:
          "https://images.unsplash.com/photo-1491553895911-0055eca6402d?w=1200",
        ctaLabel: "Find Your Pair",
        ctaLabelAr: "اختر حذاءك",
        placement: "home_strip",
        campaignType: "offer",
        discountPercent: 25,
        productId: "p003",
        categoryId: "sneakers",
        active: true,
        priority: 2,
        startsAt: new Date("2026-01-01T00:00:00.000Z"),
        endsAt: new Date("2027-01-01T00:00:00.000Z"),
      }),
      this.advertsRepository.create({
        slug: "workday-essentials",
        title: "Workday Essentials",
        titleAr: "أساسيات الدوام",
        subtitle:
          "Polished shoes, watches, and refined pieces for a clean look.",
        subtitleAr: "أحذية وساعات وقطع أنيقة لإطلالة عملية مرتبة.",
        imageUrl:
          "https://images.unsplash.com/photo-1506629905607-d9d297d3af20?w=1200",
        ctaLabel: "Explore Picks",
        ctaLabelAr: "استكشف الاختيارات",
        placement: "home_strip",
        campaignType: "collection",
        discountPercent: null,
        productId: "p004",
        categoryId: "formal_shoes",
        active: true,
        priority: 3,
        startsAt: new Date("2026-01-01T00:00:00.000Z"),
        endsAt: new Date("2027-01-01T00:00:00.000Z"),
      }),
    ]);
  }
}
