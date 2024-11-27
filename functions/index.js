const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

exports.updateGuaranteeStatus = functions.pubsub.schedule('every 5 minutes')
  .timeZone('Asia/Ho_Chi_Minh')
  .onRun(async (context) => {
    try {

      const now = new Date();
      const nowUTC7 = new Date(now.getTime() + 7 * 60 * 60 * 1000); // Adjust to UTC+7

      // Fetch all documents in the guarantees collection
      const guaranteesSnapshot = await db.collection("guarantees").get();

      if (guaranteesSnapshot.empty) {
        console.log("Không có tài liệu nào cần cập nhật.");
        return null;
      }

      const BATCH_SIZE = 500;
      let batch = db.batch();
      let operationCounter = 0;
      let updatedCount = 0;

      guaranteesSnapshot.forEach((doc) => {
        const data = doc.data();
        const endDateString = data.endDate;

        if (!endDateString) {
          console.warn(`Tài liệu ${doc.id} không có trường endDate.`);
          return;
        }

        // Convert endDate string to Date object
        const endDate = new Date(endDateString);

        if (isNaN(endDate)) {
          console.error(`Không thể phân tích ngày từ chuỗi: ${endDateString}`);
          return;
        }

        // Check if the endDate has passed and status is not "Hết hạn"
        if (endDate < nowUTC7) {
          const docRef = db.collection("guarantees").doc(doc.id);
          batch.update(docRef, { status: "Hết hạn" });
          updatedCount++;
          operationCounter++;

          if (operationCounter === BATCH_SIZE) {
            batch.commit();
            batch = db.batch();
            operationCounter = 0;
          }
        }
      });

      if (operationCounter > 0) {
        await batch.commit();
      }

      console.log(`Cập nhật trạng thái thành công cho ${updatedCount} tài liệu.`);
      return null;
    } catch (error) {
      console.error("Lỗi khi cập nhật trạng thái:", error);
      return null;
    }
  });
