import { Page, Locator, expect } from '@playwright/test';
import { BasePage } from '../BasePage';

/** Sort dropdown option values on SauceDemo. */
export type SortOption = 'az' | 'za' | 'lohi' | 'hilo';

/** Turn a product display name into its data-test slug ("Sauce Labs Backpack" -> "sauce-labs-backpack"). */
export function slug(productName: string): string {
  return productName.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
}

/**
 * SauceDemo inventory / product list page.
 * Covers TC_INV_001–010.
 */
export class InventoryPage extends BasePage {
  readonly pageTitle: Locator;
  readonly items: Locator;
  readonly itemNames: Locator;
  readonly itemPrices: Locator;
  readonly sortSelect: Locator;
  readonly cartLink: Locator;
  readonly cartBadge: Locator;

  constructor(page: Page) {
    super(page);
    this.pageTitle = page.locator('[data-test="title"]');
    this.items = page.locator('[data-test="inventory-item"]');
    this.itemNames = page.locator('[data-test="inventory-item-name"]');
    this.itemPrices = page.locator('[data-test="inventory-item-price"]');
    this.sortSelect = page.locator('[data-test="product-sort-container"]');
    this.cartLink = page.locator('[data-test="shopping-cart-link"]');
    this.cartBadge = page.locator('[data-test="shopping-cart-badge"]');
  }

  async expectLoaded(): Promise<void> {
    await expect(this.page).toHaveURL(/inventory\.html/);
    await expect(this.pageTitle).toHaveText('Products');
  }

  async expectProductCount(n: number): Promise<void> {
    await expect(this.items).toHaveCount(n);
  }

  async sortBy(option: SortOption): Promise<void> {
    await this.sortSelect.selectOption(option);
  }

  async productNames(): Promise<string[]> {
    return (await this.itemNames.allTextContents()).map((s) => s.trim());
  }

  /** Numeric prices in display order (strips the leading $). */
  async productPrices(): Promise<number[]> {
    const raw = await this.itemPrices.allTextContents();
    return raw.map((s) => Number(s.replace(/[^0-9.]/g, '')));
  }

  addToCartButton(productName: string): Locator {
    return this.page.locator(`[data-test="add-to-cart-${slug(productName)}"]`);
  }

  removeButton(productName: string): Locator {
    return this.page.locator(`[data-test="remove-${slug(productName)}"]`);
  }

  async addToCart(productName: string): Promise<void> {
    await this.addToCartButton(productName).click();
  }

  async removeFromInventory(productName: string): Promise<void> {
    await this.removeButton(productName).click();
  }

  async expectBadgeCount(count: string): Promise<void> {
    await expect(this.cartBadge).toHaveText(count);
  }

  async expectNoBadge(): Promise<void> {
    await expect(this.cartBadge).toBeHidden();
  }

  async openProduct(productName: string): Promise<void> {
    await this.page.locator('[data-test="inventory-item-name"]', { hasText: productName }).click();
  }

  async openCart(): Promise<void> {
    await this.cartLink.click();
  }
}
