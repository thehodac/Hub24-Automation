import { Page, Locator, expect } from '@playwright/test';
import { BasePage } from '../BasePage';

/**
 * SauceDemo checkout — step one (info), step two (overview), complete.
 * Covers TC_CHK_001–011.
 */
export class CheckoutPage extends BasePage {
  // Step 1
  readonly firstName: Locator;
  readonly lastName: Locator;
  readonly postalCode: Locator;
  readonly continueButton: Locator;
  readonly cancelButton: Locator;
  readonly error: Locator;
  // Step 2 (overview)
  readonly itemNames: Locator;
  readonly subtotalLabel: Locator;
  readonly taxLabel: Locator;
  readonly totalLabel: Locator;
  readonly finishButton: Locator;
  // Complete
  readonly completeHeader: Locator;
  readonly backHomeButton: Locator;

  constructor(page: Page) {
    super(page);
    this.firstName = page.locator('[data-test="firstName"]');
    this.lastName = page.locator('[data-test="lastName"]');
    this.postalCode = page.locator('[data-test="postalCode"]');
    this.continueButton = page.locator('[data-test="continue"]');
    this.cancelButton = page.locator('[data-test="cancel"]');
    this.error = page.locator('[data-test="error"]');
    this.itemNames = page.locator('[data-test="inventory-item-name"]');
    this.subtotalLabel = page.locator('[data-test="subtotal-label"]');
    this.taxLabel = page.locator('[data-test="tax-label"]');
    this.totalLabel = page.locator('[data-test="total-label"]');
    this.finishButton = page.locator('[data-test="finish"]');
    this.completeHeader = page.locator('[data-test="complete-header"]');
    this.backHomeButton = page.locator('[data-test="back-to-products"]');
  }

  async expectStepOne(): Promise<void> {
    await expect(this.page).toHaveURL(/checkout-step-one\.html/);
  }

  async expectStepTwo(): Promise<void> {
    await expect(this.page).toHaveURL(/checkout-step-two\.html/);
  }

  async fillInformation(first: string, last: string, zip: string): Promise<void> {
    if (first) await this.firstName.fill(first);
    if (last) await this.lastName.fill(last);
    if (zip) await this.postalCode.fill(zip);
  }

  async continue(): Promise<void> {
    await this.continueButton.click();
  }

  async cancel(): Promise<void> {
    await this.cancelButton.click();
  }

  async finish(): Promise<void> {
    await this.finishButton.click();
  }

  async backHome(): Promise<void> {
    await this.backHomeButton.click();
  }

  async expectError(text: string): Promise<void> {
    await expect(this.error).toBeVisible();
    await expect(this.error).toContainText(text);
  }

  async expectSummaryVisible(): Promise<void> {
    await expect(this.itemNames.first()).toBeVisible();
    await expect(this.subtotalLabel).toBeVisible();
    await expect(this.taxLabel).toBeVisible();
    await expect(this.totalLabel).toBeVisible();
  }

  /** Parse the numeric value out of a "... $12.34" label. */
  private async amount(label: Locator): Promise<number> {
    const text = (await label.textContent()) ?? '';
    const m = text.match(/\$([0-9.]+)/);
    return m ? Number(m[1]) : NaN;
  }

  async subtotal(): Promise<number> { return this.amount(this.subtotalLabel); }
  async tax(): Promise<number> { return this.amount(this.taxLabel); }
  async total(): Promise<number> { return this.amount(this.totalLabel); }

  async expectConfirmation(): Promise<void> {
    await expect(this.page).toHaveURL(/checkout-complete\.html/);
    await expect(this.completeHeader).toBeVisible();
    await expect(this.completeHeader).toContainText('Thank you for your order');
  }
}
