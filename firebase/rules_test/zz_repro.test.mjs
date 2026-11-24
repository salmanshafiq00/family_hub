// Repro: starter pack customise batch → PERMISSION_DENIED on activity doc.
//
// The batch mirrors what `replaceAll` does: N starterPackItems + 1 activity
// + 1 auditLog, all as a single batch from an admin.

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, serverTimestamp, setDoc, writeBatch } from 'firebase/firestore';
import { after, afterEach, before, beforeEach, describe, it } from 'mocha';

import {
  ALICE,
  BOB,
  EMULATOR,
  FAM_A,
  PROJECT_ID,
  asUser,
  choreTemplateDoc,
  eventDoc,
  familyDoc,
  memberDoc,
  seedWorld,
} from './support.mjs';

const [host, port] = EMULATOR.split(':');

let testEnv;
const as = (uid) => asUser(testEnv, uid);

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: { host, port },
  });
});
after(async () => { await testEnv.cleanup(); });
afterEach(async () => { await testEnv.clearFirestore(); });
beforeEach(async () => { await seedWorld(testEnv); });

/** Build a batch that creates N starterPackItems + activity + auditLog. */
function customiseBatch(db, uid, n) {
  const batch = writeBatch(db);
  for (let i = 0; i < n; i++) {
    const id = `item_${i}`;
    batch.set(
      doc(db, `families/${FAM_A}/starterPackItems/${id}`),
      choreTemplateDoc(uid, { seedKey: id, sortOrder: i }),
    );
  }
  const evtId = 'evt_repro';
  batch.set(
    doc(db, `families/${FAM_A}/activity/${evtId}`),
    eventDoc(uid, {
      type: 'chores.settings_updated',
      refType: 'choreSettings',
      refId: FAM_A,
      params: { name: 'starter_list' },
    }),
  );
  batch.set(
    doc(db, `families/${FAM_A}/auditLogs/${evtId}`),
    eventDoc(uid, {
      type: 'chores.settings_updated',
      refType: 'choreSettings',
      refId: FAM_A,
      params: { name: 'starter_list' },
    }),
  );
  return batch;
}

describe('starterPackItems customise batch repro', () => {
  it('admin: 1 item + activity + audit succeeds', async () => {
    const batch = customiseBatch(as(ALICE), ALICE, 1);
    await assertSucceeds(batch.commit());
  });

  it('admin: 5 items + activity + audit succeeds', async () => {
    const batch = customiseBatch(as(ALICE), ALICE, 5);
    await assertSucceeds(batch.commit());
  });

  it('admin: 9 items + activity + audit succeeds (11 docs)', async () => {
    const batch = customiseBatch(as(ALICE), ALICE, 9);
    await assertSucceeds(batch.commit());
  });

  it('admin: 10 items + activity + audit (12 docs)', async () => {
    const batch = customiseBatch(as(ALICE), ALICE, 10);
    await assertSucceeds(batch.commit());
  });

  it('admin: 17 items + activity + audit (19 docs, the real pack)', async () => {
    const batch = customiseBatch(as(ALICE), ALICE, 17);
    await assertSucceeds(batch.commit());
  });

  it('moderator: 17 items + activity + audit', async () => {
    const batch = customiseBatch(as(BOB), BOB, 17);
    await assertSucceeds(batch.commit());
  });

  // Narrow repro: just activity alone
  it('admin: a single activity doc with chores.settings_updated', async () => {
    const db = as(ALICE);
    await assertSucceeds(
      writeBatch(db)
        .set(
          doc(db, `families/${FAM_A}/activity/evtSingle`),
          eventDoc(ALICE, {
            type: 'chores.settings_updated',
            refType: 'choreSettings',
            refId: FAM_A,
            params: { name: 'starter_list' },
          }),
        )
        .commit(),
    );
  });

  // A REAL family id is a 20-char randomId(); the suite's fixture is `famA`.
  const REAL_FAM = 'v1ii9o8my59wo52plltt';
  const realWorld = () =>
    testEnv.withSecurityRulesDisabled(async (ctx) => {
      const db = ctx.firestore();
      await setDoc(doc(db, `families/${REAL_FAM}`), familyDoc(ALICE));
      await setDoc(
        doc(db, `families/${REAL_FAM}/members/${ALICE}`),
        memberDoc(ALICE, 'admin', 'active'),
      );
    });

  it('admin: 17 items + activity + audit, 20-char family id', async () => {
    await realWorld();
    const db = as(ALICE);
    const batch = writeBatch(db);
    for (let i = 0; i < 17; i++) {
      const id = `item_${i}`;
      batch.set(
        doc(db, `families/${REAL_FAM}/starterPackItems/${id}`),
        choreTemplateDoc(ALICE, { seedKey: id, sortOrder: i }),
      );
    }
    const evt = eventDoc(ALICE, {
      type: 'chores.settings_updated',
      refType: 'choreSettings',
      refId: REAL_FAM,
      params: { name: 'starter_list' },
    });
    batch.set(doc(db, `families/${REAL_FAM}/activity/evtReal`), evt);
    batch.set(doc(db, `families/${REAL_FAM}/auditLogs/evtReal`), evt);
    await assertSucceeds(batch.commit());
  });

  it('admin: a single activity doc, 21-char (auto-id length) refId', async () => {
    const db = as(ALICE);
    await assertSucceeds(
      writeBatch(db)
        .set(
          doc(db, `families/${FAM_A}/activity/evtLen`),
          eventDoc(ALICE, {
            type: 'chores.settings_updated',
            refType: 'choreSettings',
            refId: 'a'.repeat(21),
          }),
        )
        .commit(),
    );
  });

  // Bisect the event shape: which part does the deployed rules file refuse?
  const oneEvent = async (name, overrides) => {
    const db = as(ALICE);
    await setDoc(
      doc(db, `families/${FAM_A}/activity/${name}`),
      eventDoc(ALICE, overrides),
    );
  };
  const cases = [
    ['member.approved / family (known good)', {}],
    ['type only: chores.settings_updated', { type: 'chores.settings_updated' }],
    ['type: chores.template_created', { type: 'chores.template_created' }],
    ['type: chores.occurrence_completed', { type: 'chores.occurrence_completed' }],
    ['refType only: choreSettings', { refType: 'choreSettings' }],
    ['refType: choreTemplate', { refType: 'choreTemplate' }],
    ['refType: engagementSettings', { refType: 'engagementSettings' }],
    ['negative param value', { params: { count: '-1' } }],
    ['refId: 20-char auto id', { refId: 'v1ii9o8my59wo52plltt' }],
  ];
  for (const [name, overrides] of cases) {
    it(`bisect: ${name}`, async () => {
      let ok = true;
      try {
        await oneEvent(`evt_${cases.indexOf(cases.find((c) => c[0] === name))}`, overrides);
      } catch (e) {
        ok = false;
      }
      console.log(`      ${ok ? 'ALLOWED' : 'DENIED '}  ${name}`);
    });
  }
});
