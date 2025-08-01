import { test, expect } from '@playwright/test';

const BASE_URL = process.env.BASE_URL || 'https://dev-cxr-satis-server.pantheonsite.io';

test.describe('Does the site still work?', () => {
  test('Homepage renders without error', async ({ page }) => {
    const res = await page.goto(BASE_URL);
    if (res?.status() !== 200) {
        console.error('Non-200 response:', res?.status());
        console.error('Body:', await page.content());
    }

    expect(res?.status()).toBe(200);
    const content = await page.content();
	expect(content).not.toMatch(/^(Fatal error|Warning:|Notice:)/im);
    await expect(page.locator('body')).toBeVisible();
  });

  test('jazzsequence/satis-server loads', async ({ page }) => {
    const res = await page.goto(`${BASE_URL}/`);
    expect(res?.status()).toBe(200);
    await page.waitForLoadState('networkidle');
    await expect(page.locator('h1')).toContainText(/jazzsequence\/satis-server/i);
	const content = await page.content();
	expect(content).not.toMatch(/^(Fatal error|Warning:|Notice:)/im);
  });

  test('fair/fair-plugin loads', async ({ page }) => {
    const res = await page.goto(`${BASE_URL}/#fair/fair-plugin`);
    expect(res?.status()).toBe(200);
    await page.waitForLoadState('networkidle');
    await expect(page.locator('body')).toContainText(/fair\/fair-plugin/i);
	const content = await page.content();
	expect(content).not.toMatch(/^(Fatal error|Warning:|Notice:)/im);
  });

  test('Headers expected', async ({ page }) => {
	const res = await page.goto(BASE_URL);
	const headers = res?.headers();
	expect(headers?.['x-pantheon-styx-hostname']).toBeDefined();
	expect(headers?.['content-type']).toMatch(/text\/html/);
  });

});
