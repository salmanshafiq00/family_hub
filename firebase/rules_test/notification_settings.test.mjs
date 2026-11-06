import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc } from 'firebase/firestore';
import { after, afterEach, before, beforeEach, describe, it } from 'mocha';

import {
  ALICE,
  BOB,
  CARA,
  EMULATOR,
  FAM_A,
  PROJECT_ID,
  asUser,
  notificationDefaultsDoc,
  notificationDeliveryDoc,
  seedWorld,
} from './support.mjs';

const [host, port] = EMULATOR.split(':');
let testEnv;
const as = (uid) => asUser(testEnv, uid);
const defaultsPath = `families/${FAM_A}/settings/notificationDefaults`;
const deliveryPath = `families/${FAM_A}/settings/notificationDelivery`;
const userPath = (uid) => `users/${uid}`;
const notificationPrefs = (uid, notifications) => ({
  preferences: { notifications },
  updatedBy: uid,
});

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: { host, port: Number(port) },
  });
});

after(async () => {
  await testEnv.cleanup();
});

afterEach(async () => {
  await testEnv.clearFirestore();
});

beforeEach(async () => {
  await seedWorld(testEnv);
});

describe('families/{f}/settings/notificationDelivery', () => {
  it('allows admins to create/update and active members to read', async () => {
    await assertSucceeds(
      setDoc(doc(as(ALICE), deliveryPath), notificationDeliveryDoc(ALICE)),
    );
    await assertSucceeds(
      setDoc(
        doc(as(ALICE), deliveryPath),
        notificationDeliveryDoc(ALICE, { pushEnabled: true }),
      ),
    );
    await assertSucceeds(getDoc(doc(as(CARA), deliveryPath)));
  });

  it('denies a Household Manager and a plain member', async () => {
    await assertFails(
      setDoc(doc(as(BOB), deliveryPath), notificationDeliveryDoc(BOB)),
    );
    await assertFails(
      setDoc(doc(as(CARA), deliveryPath), notificationDeliveryDoc(CARA)),
    );
  });

  it('denies unknown type ids, unsupported types, and unknown modes', async () => {
    for (const modes of [
      { made_up: 'push' },
      { morning_summary: 'push' },
      { swap_request: 'later' },
    ]) {
      await assertFails(
        setDoc(
          doc(as(ALICE), deliveryPath),
          notificationDeliveryDoc(ALICE, { modes }),
        ),
      );
    }
  });

  it('denies oversized mode maps and unknown settings keys', async () => {
    await assertFails(
      setDoc(
        doc(as(ALICE), deliveryPath),
        notificationDeliveryDoc(ALICE, { modes: Object.fromEntries(
          Array.from({ length: 21 }, (_, index) => [`type_${index}`, 'normal']),
        ) }),
      ),
    );
    await assertFails(
      setDoc(
        doc(as(ALICE), deliveryPath),
        notificationDeliveryDoc(ALICE, { unexpected: true }),
      ),
    );
  });
});

describe('families/{f}/settings/notificationDefaults', () => {
  it('allows admins and Household Managers to write defaults', async () => {
    await assertSucceeds(
      setDoc(doc(as(BOB), defaultsPath), notificationDefaultsDoc(BOB)),
    );
    await assertSucceeds(
      setDoc(
        doc(as(ALICE), defaultsPath),
        notificationDefaultsDoc(ALICE, { chores: false }),
      ),
    );
  });

  it('denies a plain member', async () => {
    await assertFails(
      setDoc(doc(as(CARA), defaultsPath), notificationDefaultsDoc(CARA)),
    );
  });

  it('denies invalid offset counts, values, duplicates, and equal quiet bounds', async () => {
    const invalid = [
      { defaultOffsetsMinutes: [1, 2, 3, 4, 5, 6] },
      { defaultOffsetsMinutes: [0] },
      { defaultOffsetsMinutes: [30, 30] },
      { quietStartMinutes: 600, quietEndMinutes: 600 },
    ];
    for (const settings of invalid) {
      await assertFails(
        setDoc(
          doc(as(ALICE), defaultsPath),
          notificationDefaultsDoc(ALICE, settings),
        ),
      );
    }
  });
});

describe('users/{uid}.preferences.notifications', () => {
  it('allows the owner to write bounded notification preferences', async () => {
    await assertSucceeds(
      setDoc(
        doc(as(ALICE), userPath(ALICE)),
        notificationPrefs(ALICE, {
          pushEnabled: true,
          enabled: true,
          chores: false,
          defaultOffsetsMinutes: [15, 30],
          overdueEnabled: true,
          overdueAfterMinutes: 90,
          morningSummaryEnabled: true,
          morningSummaryMinutes: 420,
          quietEnabled: true,
          quietStartMinutes: 1380,
          quietEndMinutes: 360,
        }),
        { merge: true },
      ),
    );
  });

  it('denies another member, oversize offsets, and unknown preference keys', async () => {
    await assertFails(
      setDoc(
        doc(as(CARA), userPath(ALICE)),
        notificationPrefs(CARA, { pushEnabled: false }),
        { merge: true },
      ),
    );
    await assertFails(
      setDoc(
        doc(as(ALICE), userPath(ALICE)),
        notificationPrefs(ALICE, {
          defaultOffsetsMinutes: [1, 2, 3, 4, 5, 6],
        }),
        { merge: true },
      ),
    );
    await assertFails(
      setDoc(
        doc(as(ALICE), userPath(ALICE)),
        notificationPrefs(ALICE, { unexpected: true }),
        { merge: true },
      ),
    );
  });
});
