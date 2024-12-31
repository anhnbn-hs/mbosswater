const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onCall } = require("firebase-functions/v2/https");
const { onDocumentUpdated } = require('firebase-functions/v2/firestore');
const { onDocumentCreated } = require('firebase-functions/v2/firestore');

const admin = require("firebase-admin");

async function sendNotificationToAgencyAdmin(agencyID, guaranteeId, technicalName) {
    const agencyAdminSnapshot = await admin.firestore().collection("users")
        .where("role", "==", "agency-admin")
        .where("agency", "==", agencyID)
        .get();

    if (agencyAdminSnapshot.empty) {
        console.log("No users with Agency Admin role found.");
        return;
    }

    const tokens = [];
    const userIds = [];
    agencyAdminSnapshot.docs.forEach(userDoc => {
        const userData = userDoc.data();
        if (userData.fcmToken) {
            tokens.push(userData.fcmToken);
        }
        userIds.push(userDoc.id);
    });

    const payload = {
        notification: {
            title: "Thông báo kích hoạt bảo hành thành công",
            body: `1 khách hàng đã được kích hoạt bảo hành thành công tại đại lý của bạn. Nhân viên phụ trách: ${technicalName}.`,
        },
        data: {
            guaranteeId: guaranteeId,
        },
    };

    await sendNotifications(tokens, userIds, payload);
}

async function sendNotificationToMbossAdmin(guaranteeId, agencyName) {
    const mbossAdminSnapshot = await admin.firestore().collection("users")
        .where("role", "==", "mboss-admin")
        .get();

    if (mbossAdminSnapshot.empty) {
        console.log("No users with Mboss Admin role found.");
        return;
    }

    const tokens = [];
    const userIds = [];
    mbossAdminSnapshot.docs.forEach(userDoc => {
        const userData = userDoc.data();
        if (userData.fcmToken) {
            tokens.push(userData.fcmToken);
        }
        userIds.push(userDoc.id);
    });

    const payload = {
        notification: {
            title: "Thông báo kích hoạt bảo hành thành công",
            body: `1 khách hàng đã được kích hoạt bảo hành thành công tại đại lý ${agencyName}.`,
        },
        data: {
            guaranteeId: guaranteeId,
        },
    };

    await sendNotifications(tokens, userIds, payload);
}
// Function send notifications & save to firestore
async function sendNotifications(tokens, userIds, payload) {
    const response = await admin.messaging().sendEachForMulticast({
        tokens: tokens,
        notification: payload.notification,
        data: payload.data,
    });

    console.log(`${response.successCount} messages were sent successfully.`);
    console.log(`${response.failureCount} messages failed.`);

    // Lưu thông báo vào Firestore
    response.responses.forEach(async (res, index) => {
        if (res.success) {
            const notification = {
                title: payload.notification.title,
                message: payload.notification.body,
                isRead: false,
                actionUrl: payload.data.guaranteeId,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            };
            await admin.firestore().collection('notifications')
                .doc(userIds[index])
                .collection('userNotifications')
                .add(notification);
        } else {
            console.log(`Failed to send notification to user with token ${tokens[index]}: ${res.error}`);
        }
    });
}

exports.sendNotificationWhenGuaranteeActivated = onDocumentCreated('guarantees/{docId}', async (event) => {
    try {
        const guaranteeId = event.params.docId;
        const guaranteeSnapshot = await admin.firestore().collection('guarantees').doc(guaranteeId).get();

        if (!guaranteeSnapshot.exists) {
            console.log(`Guarantee with ID ${guaranteeId} does not exist.`);
            return;
        }

        const guaranteeData = guaranteeSnapshot.data();
        const technicalID = guaranteeData["technicalID"];

        const userSnapshot = await admin.firestore().collection('users').doc(technicalID).get();
        if (!userSnapshot.exists) {
            console.log(`User with ID ${technicalID} does not exist.`);
            return;
        }

        const userData = userSnapshot.data();

        const technicalName = userData?.fullName;

        var agencyID = userData?.agency;

        if (agencyID === undefined) {
            const customerID = guaranteeData["customerID"];
            const customerSnapshot = await admin.firestore().collection('customers').doc(customerID).get();
            if (!customerSnapshot.exists) {
                console.log(`Customer with ID ${customerID} does not exist.`);
                return;
            }
            agencyID = customerSnapshot.data()["agency"];
        }



        // Gửi thông báo cho Agency Admin
        await sendNotificationToAgencyAdmin(agencyID, guaranteeId, technicalName);

        // Get agency Name & Gửi thông báo cho MBOSS Admin
        const agencySnapshot = await admin.firestore().collection('agency').doc(agencyID).get();
        if (!agencySnapshot.exists) {
            console.log(`Agency with ID ${agencyID} does not exist.`);
            return;
        }

        const agencyName = agencySnapshot.data()?.name;
        await sendNotificationToMbossAdmin(guaranteeId, agencyName);

    } catch (error) {
        console.error("Error sending notifications:", error);
    }
});



