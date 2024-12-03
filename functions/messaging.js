const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onCall } = require("firebase-functions/v2/https");
const { onDocumentUpdated } = require('firebase-functions/v2/firestore');
const { onDocumentCreated } = require('firebase-functions/v2/firestore');

const admin = require("firebase-admin");



exports.sendNotificationWhenGuaranteeActivated = onDocumentCreated('guarantees/{docId}', async (event) => {
    try {
        // Get guarantee created
        const guaranteeId = event.params.docId;

        const guaranteeSnapshot = await admin.firestore().collection('guarantees').doc(guaranteeId).get();

        if (!guaranteeSnapshot.exists) {
            console.log(`Guarantee with ID ${guaranteeId} does not exist.`);
            return;
        }

        const guaranteeData = guaranteeSnapshot.data();

        // Get User Implement Activate
        const technicalID = guaranteeData["technicalID"];
        const userSnapshot = await admin.firestore().collection('users').doc(technicalID).get();
        if (!userSnapshot.exists) {
            console.log(`User with ID ${technicalID} does not exist.`);
            return;
        }

        const technicalName = (userSnapshot.data())["fullName"];

        // Get agency
        const agencyID = (userSnapshot.data())["agency"];
        const agencySnapshot = await admin.firestore().collection('agency').doc(agencyID).get();

        if (!agencySnapshot.exists) {
            console.log(`Agency with ID ${agencyID} does not exist.`);
            return;
        }

        // const agencyName = (agencySnapshot.data())["name"];

        /** 1. Send notification to Agency Admin when staff creating guarantee */

        // Get agency admin user
        const agencyAdminSnapshot = await admin.firestore().collection("users")
            .where("role", "==", "agency-admin")
            .where("agency", "==", agencyID)
            .get();

        if (agencyAdminSnapshot.empty) {
            console.log("No users with Agency Admin role found.");
            return;
        }


        const tokens = [];

        agencyAdminSnapshot.docs.forEach(userDoc => {
            const userData = userDoc.data();
            if (userData.fcmToken) {
                tokens.push(userData.fcmToken);
            }
        });

        if (tokens.length === 0) {
            console.log("No FCM tokens found for MBOSS users.");
            return;
        }

        // Tạo payload FCM
        const payload = {
            notification: {
                title: "Thông báo kích hoạt bảo hành thành công",
                body: `1 khách hàng đã được kích hoạt bảo hành thành công tại đại lý của bạn.\n Nhân viên phụ trách: Kỹ thuật viên ${technicalName}`,
            },
            data: {
                guaranteeId: guaranteeId,
            },
        };

        // Gửi thông báo đến nhiều thiết bị cùng lúc và xử lý kết quả riêng biệt cho từng người dùng
        const response = await admin.messaging().sendEachForMulticast({
            tokens: tokens,
            notification: payload.notification,
            data: payload.data,
        });

        console.log(`${response.successCount} messages were sent successfully.`);
        console.log(`${response.failureCount} messages failed.`);

        // Log thêm để chi tiết hơn về những thông báo đã thành công và thất bại
        response.responses.forEach((response, index) => {
            if (response.success) {
                console.log(`Notification sent successfully to user with token ${tokens[index]}`);
            } else {
                console.log(`Failed to send notification to user with token ${tokens[index]}: ${response.error}`);
            }
        });
    } catch (error) {
        console.error("Error sending notification:", error);
    }
});