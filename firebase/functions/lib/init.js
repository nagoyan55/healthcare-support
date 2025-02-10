"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.serviceAccountKey = void 0;
const app_1 = require("firebase-admin/app");
exports.serviceAccountKey = require('../firebase-admin-key.json');
(0, app_1.initializeApp)({
    credential: (0, app_1.cert)(exports.serviceAccountKey)
});
//# sourceMappingURL=init.js.map