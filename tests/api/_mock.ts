import { createServer, type Server } from 'node:http';
import type { AddressInfo } from 'node:net';

/**
 * Một "API giả" (mock) chạy NGAY TRONG MÁY để các test mẫu chạy được OFFLINE,
 * không cần API HUB24 thật. Khi có API thật, các test sẽ trỏ vào API_URL và xoá
 * phần mock này.
 *
 * API giả này mô phỏng endpoint /accounts/:id của một hệ thống tài chính:
 *   - Phải có token đúng mới cho xem  (phục vụ Security testing)
 *   - Trả về đúng khuôn dữ liệu        (phục vụ Schema + Data validation)
 *
 * Tên file bắt đầu bằng "_" và không có đuôi .spec nên Playwright KHÔNG coi đây
 * là file test.
 */
export interface MockApi {
  baseURL: string;
  close: () => void;
}

export async function startMockApi(): Promise<MockApi> {
  const server: Server = createServer((req, res) => {
    res.setHeader('content-type', 'application/json');
    const auth = req.headers['authorization'];

    if (req.url?.startsWith('/accounts')) {
      // --- Bảo mật: chặn người không có token đúng ---
      if (!auth) {
        res.writeHead(401);
        res.end(JSON.stringify({ error: 'unauthorized' }));
        return;
      }
      if (auth !== 'Bearer valid-token') {
        res.writeHead(403);
        res.end(JSON.stringify({ error: 'forbidden' }));
        return;
      }
      // --- Có token đúng: trả về thông tin tài khoản ---
      res.writeHead(200);
      res.end(
        JSON.stringify({
          id: 123,
          name: 'Nguyen Van A',
          balance: 1000000,
          currency: 'VND',
        })
      );
      return;
    }

    res.writeHead(404);
    res.end(JSON.stringify({ error: 'not found' }));
  });

  await new Promise<void>((resolve) => server.listen(0, '127.0.0.1', resolve));
  const port = (server.address() as AddressInfo).port;
  return {
    baseURL: `http://127.0.0.1:${port}`,
    close: () => server.close(),
  };
}
