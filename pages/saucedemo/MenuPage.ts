import { Page, Locator, expect } from '@playwright/test';
import { BasePage } from '../BasePage';

/**
 * SauceDemo burger side-menu (present on all authenticated pages).
 * Covers TC_NAV_001–003 and the logout in TC_LOGIN_008.
 */
export class MenuPage extends BasePage {
  readonly openButton: Locator;
  readonly closeButton: Locator;
  readonly allItemsLink: Locator;
  readonly aboutLink: Locator;
  readonly logoutLink: Locator;
  readonly resetLink: Locator;

  constructor(page: Page) {
    super(page);
    this.openButton = page.locator('#react-burger-menu-btn');
    this.closeButton = page.locator('#react-burger-cross-btn');
    this.allItemsLink = page.locator('#inventory_sidebar_link');
    this.aboutLink = page.locator('#about_sidebar_link');
    this.logoutLink = page.locator('#logout_sidebar_link');
    this.resetLink = page.locator('#reset_sidebar_link');
  }

  async open(): Promise<void> {
    await this.openButton.click();
    await expect(this.logoutLink).toBeVisible();
  }

  async close(): Promise<void> {
    await this.closeButton.click();
    await expect(this.logoutLink).toBeHidden();
  }

  async expectMenuOptions(): Promise<void> {
    await expect(this.allItemsLink).toBeVisible();
    await expect(this.aboutLink).toBeVisible();
    await expect(this.logoutLink).toBeVisible();
    await expect(this.resetLink).toBeVisible();
  }

  async logout(): Promise<void> {
    await this.open();
    await this.logoutLink.click();
  }

  async resetAppState(): Promise<void> {
    await this.open();
    await this.resetLink.click();
  }

  async goToAllItems(): Promise<void> {
    await this.open();
    await this.allItemsLink.click();
  }
}
