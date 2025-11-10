/* web/firebase-messaging-sw.js */
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js');

// Dùng đúng config web (giống DefaultFirebaseOptions.currentPlatform cho Web)
firebase.initializeApp({
  apiKey: "AIzaSyBAvEHOE45EztYw1aPwkd9PJXAtU-puGw4",
  authDomain: "chat-app-d1465.firebaseapp.com",
  projectId: "chat-app-d1465",
  storageBucket: "chat-app-d1465.appspot.com",
  messagingSenderId: "568058583609",
  appId: "1:568058583609:web:9351788c312ecd39d74be8",
});

const messaging = firebase.messaging();

// Nhận push khi tab đóng/ẩn (background)
messaging.onBackgroundMessage((payload) => {
  // Một số server gửi "data-only" => payload.notification có thể undefined
  const n = payload.notification || {};
  const d = payload.data || {};

  const title = n.title || d.title || 'Tin nhắn mới';
  const body  = n.body  || d.body  || '';
  const link  = (payload.fcmOptions && payload.fcmOptions.link) || d.link || '/';

  const options = {
    body,
    icon: d.icon || '/icons/Icon-192.png',   // nên dùng icon 192px
    badge: d.badge || '/icons/Icon-96.png',  // tuỳ chọn
    data: { link, ...d },                    // giữ lại data để click xử lý
    tag: d.tag || `conv-${d.conversationId || 'default'}`, // gộp noti theo hội thoại
    renotify: true,
    vibrate: [100, 50, 100],
    // actions: [{action:'open', title:'Mở'}], // nếu cần
  };

  self.registration.showNotification(title, options);
});

// Click: focus tab nếu đã mở; nếu chưa → mở tab mới
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const data = event.notification.data || {};
  const urlToOpen = data.link || '/';

  event.waitUntil((async () => {
    const allClients = await clients.matchAll({ type: 'window', includeUncontrolled: true });

    // Nếu đã có tab mở đúng URL → focus vào
    for (const client of allClients) {
      // So khớp theo path (tuỳ app bạn muốn so khớp sâu hơn)
      try {
        const u = new URL(client.url);
        if (u.pathname === new URL(urlToOpen, self.location.origin).pathname) {
          await client.focus();
          // Có thể postMessage về tab hiện tại để điều hướng nội bộ
          client.postMessage({ type: 'OPEN_CONVERSATION', payload: data });
          return;
        }
      } catch (_) {}
    }

    // Không có tab phù hợp → mở mới
    await clients.openWindow(urlToOpen);
  })());
});
