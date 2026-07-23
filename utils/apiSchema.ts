import { expect } from '@playwright/test';

/**
 * Helper kiểm "SCHEMA" (khuôn dạng) của response API.
 *
 * Schema = mô tả response phải CÓ những field nào và mỗi field thuộc KIỂU gì.
 * Hàm này KHÔNG kiểm giá trị cụ thể — chỉ kiểm "đủ field + đúng kiểu".
 *
 * Ví dụ schema cho thông tin tài khoản:
 *   { id: 'number', name: 'string', balance: 'number', currency: 'string' }
 */
export type FieldType = 'string' | 'number' | 'boolean';
export type Schema = Record<string, FieldType>;

export function expectSchema(body: unknown, schema: Schema): void {
  expect(body, 'Response phải là một object JSON').toEqual(expect.any(Object));
  const obj = body as Record<string, unknown>;

  for (const [field, type] of Object.entries(schema)) {
    // 1) Phải CÓ field này
    expect(obj, `Response thiếu field "${field}"`).toHaveProperty(field);
    // 2) Field phải đúng KIỂU (số/chuỗi/boolean)
    expect(
      typeof obj[field],
      `Field "${field}" sai kiểu: cần ${type}, nhận ${typeof obj[field]}`
    ).toBe(type);
  }
}
