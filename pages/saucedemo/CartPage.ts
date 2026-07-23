import { Page, Locator, expect } from '@playwright/test';
import { BasePage } from '../BasePage';
import { slug } from './InventoryPage';

/**
 * SauceDemo cart page (cart.html).
 * Covers TC_CART_001–006.
 */
export class CartPage extends BasePage {
  readonly items: Locator;
  readonly itemNames: Locator;
  readonly itemDescriptions: Locator;
  readonly itemPrices: Locator;
  readonly checkoutButton: Locator;
  readonly continueShoppingButton: Locator;
  readonly cartBadge: Locator;

  constructor(page: Page) {
    super(page);
    this.items = page.locator('[data-test="inventory-item"]');
    this.itemNames = page.locator('[data-test="inventory-item-name"]');
    this.itemDescriptions = page.locator('[data-test="inventory-item-desc"]');
    this.itemPrices = page.locator('[data-test="inventory-item-price"]');
    this.checkoutButton = page.locator('[data-test="checkout"]');
    this.continueShoppingButton = page.locator('[data-test="continue-shopping"]');
    this.cartBadge = page.locator('[data-test="shopping-cart-badge"]');
  }

  async expectLoaded(): Promise<void> {
    await expect(this.page).toHaveURL(/cart\.html/);
  }

  async expectItem(name: string): Promise<void> {
    await expect(this.itemNames.filter({ hasText: name })).toBeVisible();
  }

  async expectItemCount(n: number): Promise<void> {
    await expect(this.items).toHaveCount(n);
  }

  async remove(productName: string): Promise<void> {
    await this.page.locator(`[data-test="remove-${slug(productName)}"]`).click();
  }

  async checkout(): Promise<void> {
    await this.checkoutButton.click();
  }

  async continueShopping(): Promise<void> {
    await this.continueShoppingButton.click();
  }

  async expectEmpty(): Promise<void> {
    await expect(this.items).toHaveCount(0);
  }

  async expectNoBadge(): Promise<void> {
    await expect(this.cartBadge).toBeHidden();
  }

  async expectBadgeCount(count: string): Promise<void> {
    await expect(this.cartBadge).toHaveText(count);
  }
}
