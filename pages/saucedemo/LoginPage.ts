import { Page, Locator, expect } from '@playwright/test';
import { BasePage } from '../BasePage';

/**
 * SauceDemo login page — https://www.saucedemo.com
 * Covers TC_LOGIN_001–008 (login, errors, error-clear, logout landing).
 */
export class LoginPage extends BasePage {
  readonly username: Locator;
  readonly password: Locator;
  readonly loginButton: Locator;
  readonly error: Locator;
  readonly errorClose: Locator;

  constructor(page: Page) {
    super(page);
    this.username = page.locator('[data-test="username"]');
    this.password = page.locator('[data-test="password"]');
    this.loginButton = page.locator('[data-test="login-button"]');
    this.error = page.locator('[data-test="error"]');
    this.errorClose = page.locator('[data-test="error-button"]');
  }

  /** Open the login page (baseURL = saucedemo). */
  async open(): Promise<void> {
    await this.goto('/');
    await expect(this.loginButton).toBeVisible();
  }

  /** Fill credentials and submit. Leave a value as '' to skip that field. */
  async login(user: string, pass: string): Promise<void> {
    if (user) await this.username.fill(user);
    if (pass) await this.password.fill(pass);
    await this.loginButton.click();
  }

  async expectError(text: string): Promise<void> {
    await expect(this.error).toBeVisible();
    await expect(this.error).toContainText(text);
  }

  async clearError(): Promise<void> {
    await this.errorClose.click();
  }

  async expectOnLoginPage(): Promise<void> {
    await expect(this.loginButton).toBeVisible();
    await expect(this.page).toHaveURL(/saucedemo\.com\/?$/);
  }
}
