const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onCall } = require("firebase-functions/v2/https");
const { onDocumentUpdated } = require('firebase-functions/v2/firestore');
const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const admin = require("firebase-admin");
admin.initializeApp();


const { sendNotificationWhenGuaranteeActivated } = require('./messaging');

exports.sendNotificationWhenGuaranteeActivated = sendNotificationWhenGuaranteeActivated;

// Function cập nhật danh sách các tỉnh -> metadata
exports.updateProvinces = onDocumentCreated("customers/{customerId}", async (event) => {
  const newValue = event.data.data(); 
  if (!newValue || !newValue.address || !newValue.address.province) {
    console.log("Không tìm thấy 'province'");
    return;
  }

  const newProvince = newValue.address.province; 
  const metadataRef = admin.firestore().collection("metadata").doc("provinces");

  try {
    await admin.firestore().runTransaction(async (transaction) => {
      const metadataDoc = await transaction.get(metadataRef);
      let provinces = [];
      if (metadataDoc.exists) {
        provinces = metadataDoc.data().provinces || [];
      }

      if (!provinces.includes(newProvince)) {
        provinces.push(newProvince);
        transaction.set(metadataRef, { provinces });
        console.log(`Thêm tỉnh mới: ${newProvince}`);
      } else {
        console.log(`Tỉnh '${newProvince}' đã tồn tại`);
      }
    });
  } catch (error) {
    console.error("Lỗi khi cập nhật danh sách tỉnh:", error);
  }
});
