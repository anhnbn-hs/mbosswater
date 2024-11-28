const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendNotifications = onSchedule(
  {
    schedule: "0 10 * * *", 
    timeZone: "Asia/Ho_Chi_Minh",
  },
  async (event) => {
    try {
      const now = new Date().toLocaleString("vi-VN", { timeZone: "Asia/Ho_Chi_Minh" });
      console.log(`Đang gửi thông báo lúc ${now}`);


      // Handle 
      const guaranteesSnapshot = await admin.firestore().collection("guarantees").get();
      

      const usersSnapshot = await admin.firestore().collection("users").get();

      if (usersSnapshot.empty) {
        console.log("Không có người dùng nào để gửi thông báo.");
        return;
      }

      const tokens = [];


      // Lấy tất cả FCM tokens
      usersSnapshot.forEach((doc) => {
        const userData = doc.data();
        if (userData.fcmToken) {
          tokens.push(userData.fcmToken);
        }
      });

      if (tokens.length === 0) {
        console.log("Không có token nào hợp lệ để gửi thông báo.");
        return;
      }

      // Thông tin thông báo
      const message = {
        notification: {
          title: "Thông báo mới",
          body: "Đây là nội dung thông báo tự động!",
        },
        tokens: tokens
      };

       // Gửi thông báo đến tất cả tokens
       const response = await admin.messaging().sendEachForMulticast(message);

       console.log("Kết quả gửi thông báo:", {
        successCount: response.successCount,
        failureCount: response.failureCount
      });

      // Xử lý các token không hợp lệ
      if (response.failureCount > 0) {
        const failedTokens = [];
        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            failedTokens.push(tokens[idx]);
          }
        });
        console.log("Các token gửi thất bại:", failedTokens);
      }

    } catch (error) {
      console.error("Lỗi khi gửi thông báo:", error);
      return null;
    }
  }
);
