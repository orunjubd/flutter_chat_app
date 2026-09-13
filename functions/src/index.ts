/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import { setGlobalOptions } from "firebase-functions";
import { onDocumentUpdated } from "firebase-functions/firestore";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";

admin.initializeApp();
setGlobalOptions({ maxInstances: 10 });

export const onCallRinging = onDocumentUpdated("calls/{callId}", async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();

    if (!before || !after) {
        logger.warn(`Missing before/after data for call ${event.params.callId}`);
        return;
    }

    // Only fire the push the moment a call transitions INTO ringing.
    if (before.state === after.state || after.state !== "ringing") {
        return;
    }

    const callId = event.params.callId;
    const calleeId = after.calleeId as string | undefined;
    const callerId = after.callerId as string | undefined;
    const roomName = (after.roomName as string | undefined) ?? callId;
    const callType = (after.type as string | undefined) ?? "voice";

    if (!calleeId) {
        logger.warn(`Missing calleeId for call ${callId}`);
        return;
    }

    if (!callerId) {
        logger.warn(`Missing callerId for call ${callId}`);
        return;
    }

    const calleeDoc = await admin.firestore().collection("users").doc(calleeId).get();
    const fcmToken = calleeDoc.data()?.fcmToken as string | undefined;

    if (!fcmToken) {
        logger.warn(`No fcmToken for callee ${calleeId} — cannot push.`);
        return;
    }

    const callerDoc = await admin.firestore().collection("users").doc(callerId).get();
    const callerName = (callerDoc.data()?.username as string | undefined) ?? "Unknown";

    await admin.messaging().send({
        token: fcmToken,
        data: {
            type: "incoming_call",
            callId,
            roomName,
            callerName,
            callType,
        },
        android: {
            priority: "high",
        },
    });

    logger.info(`Incoming-call push sent to ${calleeId} for call ${callId}`);
});
