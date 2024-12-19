const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onCall } = require("firebase-functions/v2/https");
const { onDocumentUpdated } = require('firebase-functions/v2/firestore');
const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const admin = require("firebase-admin");
admin.initializeApp();


const { sendNotificationWhenGuaranteeActivated } = require('./messaging');

exports.sendNotificationWhenGuaranteeActivated = sendNotificationWhenGuaranteeActivated;

// exports.sendNotificationToMbossOnGuaranteeCreated = onDocumentCreated('guarantees/{docId}', async (event) => {
//   try {
//     const guaranteeId = event.params.docId;
//     const message = `A new guarantee with ID ${guaranteeId} has been added!`;

//     const mbossUsersSnapshot = await admin.firestore().collection("users")
//       // .where("role", "==", "MBOSS") // Lọc người dùng có role là MBOSS
//       .get();

//     if (mbossUsersSnapshot.empty) {
//       console.log("No users with MBOSS role found.");
//       return;
//     }


//     const tokens = [];
//     mbossUsersSnapshot.docs.forEach(userDoc => {
//       const userData = userDoc.data();
//       if (userData.fcmToken) {
//         tokens.push(userData.fcmToken);
//       }
//     });

//     if (tokens.length === 0) {
//       console.log("No FCM tokens found for MBOSS users.");
//       return;
//     }

//     // Tạo payload FCM
//     const payload = {
//       notification: {
//         title: "New Guarantee Added",
//         body: message,
//       },
//       data: {
//         guaranteeId: guaranteeId,
//       },
//     };

//     // Gửi thông báo đến nhiều thiết bị cùng lúc và xử lý kết quả riêng biệt cho từng người dùng
//     const response = await admin.messaging().sendEachForMulticast({
//       tokens: tokens,
//       notification: payload.notification,
//       data: payload.data,
//     });

//     console.log(`${response.successCount} messages were sent successfully.`);
//     console.log(`${response.failureCount} messages failed.`);

//     // Log thêm để chi tiết hơn về những thông báo đã thành công và thất bại
//     response.responses.forEach((response, index) => {
//       if (response.success) {
//         console.log(`Notification sent successfully to user with token ${tokens[index]}`);
//       } else {
//         console.log(`Failed to send notification to user with token ${tokens[index]}: ${response.error}`);
//       }
//     });
//   } catch (error) {
//     console.error("Error sending notification:", error);
//   }
// });

// Fetch customers and related guarantees
exports.fetchCustomersWithGuarantees = onCall(async (request) => {
  try {
    const customersSnapshot = await admin.firestore().collection("customers").get();
    const customers = [];

    for (const doc of customersSnapshot.docs) {
      const customer = { id: doc.id, ...doc.data() };

      const guaranteesSnapshot = await admin.firestore()
        .collection("guarantees")
        .where("customerID", "==", customer.id)
        .get();

      const guarantees = guaranteesSnapshot.docs.map(guaranteeDoc => ({
        id: guaranteeDoc.id,
        ...guaranteeDoc.data(),
      }));

      customers.push({ customer, guarantees });
    }

    return customers;
  } catch (error) {
    console.error("Error fetching customers and guarantees:", error);
    throw new Error("Failed to fetch customer data");
  }
});

exports.deleteUser = onCall(async (request) => {
  const { userId } = request.data;

  if (!userId) {
    throw new Error("User ID is required");
  }

  try {
    await admin.auth().updateUser(userId, {
        disabled: true,
    });
    
    console.log(`User with UID ${userId} disabled in Authentication`);

    await admin.firestore().collection("users").doc(userId).update({
        isDelete: true, 
    });

    console.log(`User with UID ${userId} marked as disabled in Firestore`);

    return { message: `User with UID ${userId} deleted successfully` };
  } catch (error) {
    console.error(`Error deleting user with UID ${userId}:`, error);
    throw new Error(error.message);
  }
});



// exports.sendNotifications = onSchedule(
//   {
//     schedule: "0 10 * * *", 
//     timeZone: "Asia/Ho_Chi_Minh",
//   },
//   async (event) => {
//     try {
//       const now = new Date().toLocaleString("vi-VN", { timeZone: "Asia/Ho_Chi_Minh" });
//       console.log(`Đang gửi thông báo lúc ${now}`);


//       // Handle 
//       const guaranteesSnapshot = await admin.firestore().collection("guarantees").get();
      

//       const usersSnapshot = await admin.firestore().collection("users").get();

//       if (usersSnapshot.empty) {
//         console.log("Không có người dùng nào để gửi thông báo.");
//         return;
//       }

//       const tokens = [];


//       // Lấy tất cả FCM tokens
//       usersSnapshot.forEach((doc) => {
//         const userData = doc.data();
//         if (userData.fcmToken) {
//           tokens.push(userData.fcmToken);
//         }
//       });

//       if (tokens.length === 0) {
//         console.log("Không có token nào hợp lệ để gửi thông báo.");
//         return;
//       }

//       // Thông tin thông báo
//       const message = {
//         notification: {
//           title: "Thông báo mới",
//           body: "Đây là nội dung thông báo tự động!",
//         },
//         tokens: tokens
//       };

//        // Gửi thông báo đến tất cả tokens
//        const response = await admin.messaging().sendEachForMulticast(message);

//        console.log("Kết quả gửi thông báo:", {
//         successCount: response.successCount,
//         failureCount: response.failureCount
//       });

//       // Xử lý các token không hợp lệ
//       if (response.failureCount > 0) {
//         const failedTokens = [];
//         response.responses.forEach((resp, idx) => {
//           if (!resp.success) {
//             failedTokens.push(tokens[idx]);
//           }
//         });
//         console.log("Các token gửi thất bại:", failedTokens);
//       }

//     } catch (error) {
//       console.error("Lỗi khi gửi thông báo:", error);
//       return null;
//     }
//   }
// );
