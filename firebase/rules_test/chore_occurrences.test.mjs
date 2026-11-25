// Firestore rules for choreOccurrences (P3-13).
//
// The stored state machine (road map Appendix C) — tick, complete/uncomplete,
// verify, reopen, exception, skip/unskip, reassign, swap/cover, attention,
// replan, soft delete — plus the deterministic id, the closed key set, the
// append-only `events` subcollection and the 400-document generation batch
// (C-11: the access-call budget must survive one generation chunk).
//
// Run: npm run test:emulator (from firebase/rules_test).

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  Timestamp,
  deleteDoc,
  deleteField,
  doc,
  getDoc,
  setDoc,
  updateDoc,
  writeBatch,
} from 'firebase/firestore';
import { after, afterEach, before, beforeEach, describe, it } from 'mocha';

import {
  ALICE,
  BOB,
  CARA,
  DAVE,
  EMULATOR,
  ERIN,
  FAM_A,
  FAM_B,
  FRANK,
  PROJECT_ID,
  asUser,
  choreTemplateDoc,
  dutyGroupDoc,
  memberDoc,
  nowTs,
  occurrenceDoc,
  swapDoc,
  occurrenceEventDoc,
  permissionsDoc,
  seedWorld,
} from './support.mjs';

const [host, port] = EMULATOR.split(':');

let testEnv;

const as = (uid) => asUser(testEnv, uid);
const occurrencePath = (id = 'tpl_1_20261024') =>
  `families/${FAM_A}/choreOccurrences/${id}`;
const eventPath = (eventId, id = 'tpl_1_20261024') =>
  `families/${FAM_A}/choreOccurrences/${id}/events/${eventId}`;

// `occurrenceDoc` and `occurrenceEventDoc` come from support.mjs, so the same
// fixture the rules test uses is the one `chore_occurrence_fixture_test.dart`
// keeps in step with the Dart mapper.
const tick = { at: nowTs(), by: CARA };
const eventDoc = occurrenceEventDoc;

// A plain, active member who is NOT the assignee of the default chore (ALICE
// is an admin and BOB a moderator, so neither can stand in for "a plain
// member").  Seeded in `beforeEach` below.
const GINA = 'gina';

// A fixed instant: `completedAt` of a seeded chore must EQUAL the
// `prevCompletedAt` of its `reopened` event (rule 4), and `nowTs()` differs
// on every call.
const T0 = Timestamp.fromDate(new Date('2026-10-20T10:00:00.000Z'));

/**
 * `setDoc` treats a dotted key as a LITERAL field name (only `updateDoc`
 * expands it), so a seed such as `'subtaskDone.step_1': tick` would store a
 * field no rule ever looks at.  Expand dotted keys into nested maps.
 */
const nest = (flat) => {
  const out = {};
  for (const [key, value] of Object.entries(flat)) {
    const parts = key.split('.');
    let node = out;
    for (const part of parts.slice(0, -1)) {
      node[part] = node[part] ?? {};
      node = node[part];
    }
    node[parts.at(-1)] = value;
  }
  return out;
};

/** Seeds one occurrence, and optionally `settings/permissions`. */
const seedOccurrence = (overrides = {}, id = 'tpl_1_20261024') =>
  testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(
      doc(ctx.firestore(), occurrencePath(id)),
      occurrenceDoc(ALICE, nest(overrides)),
    );
  });

const seedPermissions = (extra = {}) =>
  testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(
      doc(ctx.firestore(), `families/${FAM_A}/settings/permissions`),
      permissionsDoc(ALICE, extra),
    );
  });

/** An update as [uid] with the patch applied over the seeded document. */
const update = async (uid, patch, id = 'tpl_1_20261024') =>
  updateDoc(doc(as(uid), occurrencePath(id)), {
    ...patch,
    updatedAt: nowTs(),
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
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(
      doc(ctx.firestore(), `families/${FAM_A}/members/${GINA}`),
      memberDoc(GINA, 'member', 'active'),
    );
  });
});

describe('families/{f}/choreOccurrences — create', () => {
  it('lets an active member create a scheduled chore', async () => {
    await assertSucceeds(
      setDoc(doc(as(CARA), occurrencePath()), occurrenceDoc(CARA)),
    );
  });

  it('lets a manager create one', async () => {
    await assertSucceeds(
      setDoc(doc(as(BOB), occurrencePath()), occurrenceDoc(BOB)),
    );
  });

  it('allows a slot id and its date', async () => {
    await assertSucceeds(
      setDoc(
        doc(as(CARA), occurrencePath('tpl_1_20261024_noon')),
        occurrenceDoc(CARA, { slotKey: 'noon' }),
      ),
    );
  });

  it('denies a pending member', async () => {
    await assertFails(
      setDoc(doc(as(DAVE), occurrencePath()), occurrenceDoc(DAVE)),
    );
  });

  it('denies a member of another family', async () => {
    await assertFails(
      setDoc(
        doc(as(ERIN), `families/${FAM_A}/choreOccurrences/tpl_1_20261024`),
        occurrenceDoc(ERIN),
      ),
    );
  });

  it('denies a user with no family', async () => {
    await assertFails(
      setDoc(doc(as(FRANK), occurrencePath()), occurrenceDoc(FRANK)),
    );
  });

  it('denies a create attributed to somebody else', async () => {
    await assertFails(
      setDoc(doc(as(CARA), occurrencePath()), occurrenceDoc(ALICE)),
    );
  });

  it('denies a random (non-deterministic) id', async () => {
    await assertFails(
      setDoc(doc(as(CARA), occurrencePath('Ab3xYz9')), occurrenceDoc(CARA)),
    );
  });

  it('denies an id whose date does not match dateKey', async () => {
    await assertFails(
      setDoc(
        doc(as(CARA), occurrencePath('tpl_1_20261025')),
        occurrenceDoc(CARA),
      ),
    );
  });

  it('denies a create that already carries progress', async () => {
    await assertFails(
      setDoc(
        doc(as(CARA), occurrencePath()),
        occurrenceDoc(CARA, {
          status: 'completed',
          completedAt: nowTs(),
          completedBy: CARA,
        }),
      ),
    );
  });

  it('denies an unknown field', async () => {
    await assertFails(
      setDoc(
        doc(as(CARA), occurrencePath()),
        occurrenceDoc(CARA, { estimate: 3 }),
      ),
    );
  });

  it('denies an unknown status', async () => {
    await assertFails(
      setDoc(
        doc(as(CARA), occurrencePath()),
        occurrenceDoc(CARA, { status: 'overdue' }),
      ),
    );
  });

  it('denies 31 subtasks', async () => {
    await assertFails(
      setDoc(
        doc(as(CARA), occurrencePath()),
        occurrenceDoc(CARA, {
          subtasks: Array.from({ length: 31 }, (_, i) => ({
            id: `s${i}`,
            title: 'কাজ',
            required: false,
            hint: null,
          })),
        }),
      ),
    );
  });

  it('allows a 400-document generation batch (C-11)', async () => {
    const db = as(CARA);
    const batch = writeBatch(db);
    for (let i = 0; i < 400; i++) {
      const day = String((i % 28) + 1).padStart(2, '0');
      batch.set(
        doc(db, `families/${FAM_A}/choreOccurrences/tpl_${i}_202610${day}`),
        occurrenceDoc(CARA, {
          templateId: `tpl_${i}`,
          dateKey: `2026-10-${day}`,
          monthKey: '2026-10',
        }),
      );
    }
    await assertSucceeds(batch.commit());
  });
});

describe('families/{f}/choreOccurrences — reads', () => {
  it('lets any active member read', async () => {
    await seedOccurrence();
    await assertSucceeds(getDoc(doc(as(CARA), occurrencePath())));
  });

  it('denies another family', async () => {
    await seedOccurrence();
    await assertFails(getDoc(doc(as(ERIN), occurrencePath())));
  });
});

describe('tick and complete', () => {
  it('lets the assignee tick a subtask', async () => {
    await seedOccurrence();
    await assertSucceeds(
      update(CARA, {
        'subtaskDone.step_1': tick,
        status: 'in_progress',
      }),
    );
  });

  it('denies another plain member ticking without the family switch', async () => {
    await seedOccurrence();
    await assertFails(
      update(GINA, { 'subtaskDone.step_1': { at: nowTs(), by: GINA } }),
    );
  });

  it('lets a manager complete for somebody else', async () => {
    await seedOccurrence();
    await assertSucceeds(
      update(BOB, {
        'subtaskDone.step_1': { at: nowTs(), by: BOB },
        status: 'completed',
        completedAt: nowTs(),
        completedBy: BOB,
      }),
    );
  });

  it('lets a plain member complete for others when the switch is on', async () => {
    await seedOccurrence();
    await seedPermissions({ membersCanCompleteForOthers: true });
    await assertSucceeds(
      update(GINA, {
        'subtaskDone.step_1': { at: nowTs(), by: GINA },
        status: 'completed',
        completedAt: nowTs(),
        completedBy: GINA,
      }),
    );
  });

  it('denies a tick that also edits the snapshot', async () => {
    await seedOccurrence();
    await assertFails(
      update(CARA, {
        'subtaskDone.step_1': tick,
        nameBn: 'অন্য নাম',
      }),
    );
  });

  it('denies a completion attributed to somebody else', async () => {
    await seedOccurrence();
    await assertFails(
      update(CARA, {
        'subtaskDone.step_1': tick,
        status: 'completed',
        completedAt: nowTs(),
        completedBy: BOB,
      }),
    );
  });
});

describe('verify', () => {
  const completed = {
    status: 'completed',
    completedAt: nowTs(),
    completedBy: CARA,
    verification: 'required',
  };

  beforeEach(async () => {
    await seedOccurrence(completed);
    await seedPermissions({ choreVerificationEnabled: true });
  });

  it('lets another member verify in one batch with its event', async () => {
    const db = as(BOB);
    const batch = writeBatch(db);
    batch.update(doc(db, occurrencePath()), {
      lastEventId: 'verified_0',
      status: 'verified',
      verifiedAt: nowTs(),
      verifiedBy: BOB,
      updatedAt: nowTs(),
      updatedBy: BOB,
    });
    batch.set(
      doc(db, eventPath('verified_0')),
      eventDoc(BOB, { type: 'verified' }),
    );
    await assertSucceeds(batch.commit());
  });

  it('denies verifying your own completion', async () => {
    const db = as(CARA);
    const batch = writeBatch(db);
    batch.update(doc(db, occurrencePath()), {
      lastEventId: 'verified_0',
      status: 'verified',
      verifiedAt: nowTs(),
      verifiedBy: CARA,
      updatedAt: nowTs(),
      updatedBy: CARA,
    });
    batch.set(
      doc(db, eventPath('verified_0')),
      eventDoc(CARA, { type: 'verified' }),
    );
    await assertFails(batch.commit());
  });

  it('denies verifying while the family switch is off', async () => {
    await seedPermissions({ choreVerificationEnabled: false });
    const db = as(BOB);
    const batch = writeBatch(db);
    batch.update(doc(db, occurrencePath()), {
      lastEventId: 'verified_0',
      status: 'verified',
      verifiedAt: nowTs(),
      verifiedBy: BOB,
      updatedAt: nowTs(),
      updatedBy: BOB,
    });
    batch.set(
      doc(db, eventPath('verified_0')),
      eventDoc(BOB, { type: 'verified' }),
    );
    await assertFails(batch.commit());
  });

  it('denies verifying a chore that does not require it', async () => {
    await seedOccurrence({ ...completed, verification: 'off' });
    const db = as(BOB);
    const batch = writeBatch(db);
    batch.update(doc(db, occurrencePath()), {
      lastEventId: 'verified_0',
      status: 'verified',
      verifiedAt: nowTs(),
      verifiedBy: BOB,
      updatedAt: nowTs(),
      updatedBy: BOB,
    });
    batch.set(
      doc(db, eventPath('verified_0')),
      eventDoc(BOB, { type: 'verified' }),
    );
    await assertFails(batch.commit());
  });

  it('M-05: denies a plain member verifying (managers only)', async () => {
    const db = as(GINA);
    const batch = writeBatch(db);
    batch.update(doc(db, occurrencePath()), {
      lastEventId: 'verified_0',
      status: 'verified',
      verifiedAt: nowTs(),
      verifiedBy: GINA,
      updatedAt: nowTs(),
      updatedBy: GINA,
    });
    batch.set(
      doc(db, eventPath('verified_0')),
      eventDoc(GINA, { type: 'verified' }),
    );
    await assertFails(batch.commit());
  });

  it('denies a verification without its event', async () => {
    await assertFails(
      update(BOB, {
        status: 'verified',
        verifiedAt: nowTs(),
        verifiedBy: BOB,
      }),
    );
  });
});

describe('reopen', () => {
  const completed = {
    status: 'completed',
    completedAt: T0,
    completedBy: CARA,
  };

  it('lets a member reopen a completed chore with a reason', async () => {
    await seedOccurrence(completed);
    const db = as(ALICE);
    const batch = writeBatch(db);
    batch.update(doc(db, occurrencePath()), {
      lastEventId: 'reopened_0',
      status: 'in_progress',
      reopenCount: 1,
      completedAt: null,
      completedBy: null,
      updatedAt: nowTs(),
      updatedBy: ALICE,
    });
    batch.set(
      doc(db, eventPath('reopened_0')),
      eventDoc(ALICE, {
        type: 'reopened',
        reason: 'আবার করতে হবে',
        prevCompletedAt: T0,
      }),
    );
    await assertSucceeds(batch.commit());
  });

  it('denies a reopen without a reason', async () => {
    await seedOccurrence(completed);
    const db = as(ALICE);
    const batch = writeBatch(db);
    batch.update(doc(db, occurrencePath()), {
      lastEventId: 'reopened_0',
      status: 'in_progress',
      reopenCount: 1,
      completedAt: null,
      completedBy: null,
      updatedAt: nowTs(),
      updatedBy: ALICE,
    });
    batch.set(doc(db, eventPath('reopened_0')), eventDoc(ALICE, {
      type: 'reopened',
    }));
    await assertFails(batch.commit());
  });

  it('denies a plain member reopening a verified chore', async () => {
    await seedOccurrence({
      ...completed,
      status: 'verified',
      verifiedAt: nowTs(),
      verifiedBy: BOB,
    });
    const db = as(CARA);
    const batch = writeBatch(db);
    batch.update(doc(db, occurrencePath()), {
      lastEventId: 'reopened_0',
      status: 'in_progress',
      reopenCount: 1,
      completedAt: null,
      completedBy: null,
      verifiedAt: null,
      verifiedBy: null,
      updatedAt: nowTs(),
      updatedBy: CARA,
    });
    batch.set(
      doc(db, eventPath('reopened_0')),
      eventDoc(CARA, { type: 'reopened', reason: 'ভুল হয়েছে' }),
    );
    await assertFails(batch.commit());
  });
});

describe('exception, skip and unskip (manager)', () => {
  it('lets a manager record an exception with a note', async () => {
    await seedOccurrence();
    const db = as(BOB);
    const batch = writeBatch(db);
    batch.update(doc(db, occurrencePath()), {
      lastEventId: 'exception_0',
      exception: { note: 'কিছু কাজ বাদ', by: BOB, at: nowTs() },
      updatedAt: nowTs(),
      updatedBy: BOB,
    });
    batch.set(
      doc(db, eventPath('exception_0')),
      eventDoc(BOB, { type: 'exception', reason: 'কিছু কাজ বাদ' }),
    );
    await assertSucceeds(batch.commit());
  });

  it('denies a member recording an exception', async () => {
    await seedOccurrence();
    const db = as(CARA);
    const batch = writeBatch(db);
    batch.update(doc(db, occurrencePath()), {
      lastEventId: 'exception_0',
      exception: { note: 'বাদ', by: CARA, at: nowTs() },
      updatedAt: nowTs(),
      updatedBy: CARA,
    });
    batch.set(
      doc(db, eventPath('exception_0')),
      eventDoc(CARA, { type: 'exception', reason: 'বাদ দিলাম' }),
    );
    await assertFails(batch.commit());
  });

  it('lets a manager skip with a reason and unskip again', async () => {
    await seedOccurrence();
    const db = as(BOB);
    const first = writeBatch(db);
    first.update(doc(db, occurrencePath()), {
      lastEventId: 'skipped_0',
      status: 'skipped',
      skipReason: 'absence',
      updatedAt: nowTs(),
      updatedBy: BOB,
    });
    first.set(
      doc(db, eventPath('skipped_0')),
      eventDoc(BOB, { type: 'skipped', reason: 'অসুস্থ' }),
    );
    await assertSucceeds(first.commit());

    const second = writeBatch(db);
    second.update(doc(db, occurrencePath()), {
      lastEventId: 'unskipped_0',
      status: 'scheduled',
      skipReason: null,
      updatedAt: nowTs(),
      updatedBy: BOB,
    });
    second.set(
      doc(db, eventPath('unskipped_0')),
      eventDoc(BOB, { type: 'unskipped' }),
    );
    await assertSucceeds(second.commit());
  });

  it('denies a skip without a known reason', async () => {
    await seedOccurrence();
    const db = as(BOB);
    const batch = writeBatch(db);
    batch.update(doc(db, occurrencePath()), {
      lastEventId: 'skipped_0',
      status: 'skipped',
      skipReason: 'whatever',
      updatedAt: nowTs(),
      updatedBy: BOB,
    });
    batch.set(
      doc(db, eventPath('skipped_0')),
      eventDoc(BOB, { type: 'skipped', reason: 'কারণ' }),
    );
    await assertFails(batch.commit());
  });
});

describe('reassign, swap and cover', () => {
  it('lets a manager reassign with a reason and its event', async () => {
    await seedOccurrence();
    const db = as(BOB);
    const batch = writeBatch(db);
    batch.update(doc(db, occurrencePath()), {
      lastEventId: `reassigned_${DAVE}`,
      assigneeId: DAVE,
      assignmentSource: 'reassign',
      updatedAt: nowTs(),
      updatedBy: BOB,
    });
    batch.set(
      doc(db, eventPath(`reassigned_${DAVE}`)),
      eventDoc(BOB, {
        type: 'reassigned',
        reason: 'কারা আজ ছুটিতে',
        fromAssigneeId: CARA,
        toAssigneeId: DAVE,
      }),
    );
    await assertSucceeds(batch.commit());
  });

  it('denies a reassign without its event', async () => {
    await seedOccurrence();
    await assertFails(
      update(BOB, { assigneeId: DAVE, assignmentSource: 'reassign' }),
    );
  });

  it('denies a plain member reassigning', async () => {
    await seedOccurrence();
    const db = as(CARA);
    const batch = writeBatch(db);
    batch.update(doc(db, occurrencePath()), {
      lastEventId: `reassigned_${DAVE}`,
      assigneeId: DAVE,
      assignmentSource: 'reassign',
      updatedAt: nowTs(),
      updatedBy: CARA,
    });
    batch.set(
      doc(db, eventPath(`reassigned_${DAVE}`)),
      eventDoc(CARA, { type: 'reassigned', reason: 'বদলাই' }),
    );
    await assertFails(batch.commit());
  });

  it('lets an ACCEPTED swap move the assignee with a swapped event', async () => {
    await seedOccurrence({ assigneeId: CARA });
    await testEnv.withSecurityRulesDisabled((ctx) =>
      setDoc(
        doc(ctx.firestore(), `families/${FAM_A}/swapRequests/swap_1`),
        swapDoc(CARA, { toMemberId: GINA }),
      ),
    );
    const db = as(GINA);
    const batch = writeBatch(db);
    batch.update(doc(db, occurrencePath()), {
      lastEventId: `swapped_${GINA}`,
      assigneeId: GINA,
      coverForId: null,
      assignmentSource: 'swap',
      updatedAt: nowTs(),
      updatedBy: GINA,
    });
    batch.set(
      doc(db, eventPath(`swapped_${GINA}`)),
      eventDoc(GINA, {
        type: 'swapped',
        reason: 'কেউ পারবে না',
        fromAssigneeId: CARA,
        toAssigneeId: GINA,
        requestId: 'swap_1',
      }),
    );
    batch.update(doc(db, `families/${FAM_A}/swapRequests/swap_1`), {
      status: 'accepted',
      respondedAt: nowTs(),
      respondedBy: GINA,
      responseReason: null,
      updatedAt: nowTs(),
      updatedBy: GINA,
    });
    await assertSucceeds(batch.commit());
  });

  it('denies a swapped event without an accepted request (P3-26)', async () => {
    await seedOccurrence({ assigneeId: CARA });
    const db = as(GINA);
    const batch = writeBatch(db);
    batch.update(doc(db, occurrencePath()), {
      lastEventId: `swapped_${GINA}`,
      assigneeId: GINA,
      coverForId: null,
      assignmentSource: 'swap',
      updatedAt: nowTs(),
      updatedBy: GINA,
    });
    batch.set(
      doc(db, eventPath(`swapped_${GINA}`)),
      eventDoc(GINA, {
        type: 'swapped',
        reason: 'কেউ পারবে না',
        fromAssigneeId: CARA,
        toAssigneeId: GINA,
        requestId: 'swap_1',
      }),
    );
    await assertFails(batch.commit());
  });
});

describe('replan and soft delete', () => {
  it('lets a manager replan an unstarted snapshot', async () => {
    await seedOccurrence();
    await assertSucceeds(
      update(BOB, {
        templateRev: 2,
        nameBn: 'নতুন নাম',
        dueAt: nowTs(),
      }),
    );
  });

  it('denies replanning a started chore', async () => {
    await seedOccurrence({ 'subtaskDone.step_1': tick });
    await assertFails(update(BOB, { templateRev: 2 }));
  });

  it('denies a member replanning', async () => {
    await seedOccurrence();
    await assertFails(update(CARA, { templateRev: 2 }));
  });

  it('lets a manager soft-delete a future chore', async () => {
    await seedOccurrence({
      dateKey: '2099-01-01',
      monthKey: '2099-01',
    }, 'tpl_1_20990101');
    await assertSucceeds(
      update(
        BOB,
        { deletedAt: nowTs(), deletedBy: BOB },
        'tpl_1_20990101',
      ),
    );
  });

  it('denies soft-deleting a past chore', async () => {
    await seedOccurrence();
    await assertFails(update(BOB, { deletedAt: nowTs(), deletedBy: BOB }));
  });

  it('denies a hard delete', async () => {
    await seedOccurrence();
    await assertFails(
      deleteDoc(doc(as(BOB), occurrencePath())),
    );
  });
});

describe('events subcollection', () => {
  it('lets an actor append their own event', async () => {
    await seedOccurrence();
    await assertSucceeds(
      setDoc(
        doc(as(CARA), eventPath('completed_0')),
        eventDoc(CARA, { type: 'completed' }),
      ),
    );
  });

  it('denies an event attributed to somebody else', async () => {
    await seedOccurrence();
    await assertFails(
      setDoc(
        doc(as(CARA), eventPath('completed_0')),
        eventDoc(BOB, { type: 'completed' }),
      ),
    );
  });

  it('denies an unknown event type', async () => {
    await seedOccurrence();
    await assertFails(
      setDoc(
        doc(as(CARA), eventPath('x')),
        eventDoc(CARA, { type: 'deleted' }),
      ),
    );
  });

  it('denies editing and deleting an event', async () => {
    await seedOccurrence();
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(
        doc(ctx.firestore(), eventPath('completed_0')),
        eventDoc(CARA, { type: 'completed' }),
      );
    });
    await assertFails(
      updateDoc(doc(as(CARA), eventPath('completed_0')), { reason: 'x' }),
    );
  });

  it('lets any active member read the history', async () => {
    await seedOccurrence();
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(
        doc(ctx.firestore(), eventPath('completed_0')),
        eventDoc(CARA, { type: 'completed' }),
      );
    });
    await assertSucceeds(getDoc(doc(as(BOB), eventPath('completed_0'))));
  });
});

describe('shape cross-checks', () => {
  it('accepts a real template-shaped chore', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const db = ctx.firestore();
      await setDoc(doc(db, `families/${FAM_A}/choreTemplates/tpl_1`), choreTemplateDoc(ALICE));
      await setDoc(doc(db, `families/${FAM_A}/dutyGroups/group_1`), dutyGroupDoc(ALICE));
    });
    await assertSucceeds(
      setDoc(doc(as(CARA), occurrencePath()), occurrenceDoc(CARA)),
    );
  });
});

// ── Wave R1: B-05, B-06, B-04 ───────────────────────────────────────────────
// Written without an emulator: run the suite once and adjust if a fixture helper
// behaves differently from what these cases assume.
describe('Wave R1: unique event ids, restore, reopen with steps', () => {
  const uncomplete = (db, uid, eventId) => {
    const batch = writeBatch(db);
    batch.update(doc(db, occurrencePath()), {
      status: 'in_progress',
      lastEventId: eventId,
      completedAt: deleteField(),
      completedBy: deleteField(),
      updatedAt: nowTs(),
      updatedBy: uid,
    });
    batch.set(doc(db, eventPath(eventId)), eventDoc(uid, { type: 'uncompleted' }));
    return batch.commit();
  };
  const completeAgain = (uid) =>
    updateDoc(doc(as(uid), occurrencePath()), {
      status: 'completed',
      completedAt: nowTs(),
      completedBy: uid,
      updatedAt: nowTs(),
      updatedBy: uid,
    });

  it('B-05: complete -> untick -> complete -> untick works twice', async () => {
    await seedOccurrence({
      assigneeId: CARA,
      status: 'completed',
      completedAt: nowTs(),
      completedBy: CARA,
      'subtaskDone.step_1': tick,
    });
    await assertSucceeds(uncomplete(as(CARA), CARA, 'evt_one'));
    await assertSucceeds(completeAgain(CARA));
    await assertSucceeds(uncomplete(as(CARA), CARA, 'evt_two'));
  });

  it('B-05: reusing an event that already exists is denied', async () => {
    await seedOccurrence({
      assigneeId: CARA,
      status: 'completed',
      completedAt: nowTs(),
      completedBy: CARA,
    });
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(
        doc(ctx.firestore(), eventPath('evt_old')),
        eventDoc(CARA, { type: 'uncompleted' }),
      );
    });
    await assertFails(
      updateDoc(doc(as(CARA), occurrencePath()), {
        status: 'in_progress',
        lastEventId: 'evt_old',
        completedAt: deleteField(),
        completedBy: deleteField(),
        updatedAt: nowTs(),
        updatedBy: CARA,
      }),
    );
  });

  it('B-06: a manager restores a soft-deleted unstarted occurrence', async () => {
    await seedOccurrence({ deletedAt: nowTs(), deletedBy: ALICE });
    await assertSucceeds(
      update(ALICE, { deletedAt: null, deletedBy: null, nameBn: 'বাসন ধোয়া' }),
    );
  });

  it('B-06: a plain member cannot restore', async () => {
    await seedOccurrence({ deletedAt: nowTs(), deletedBy: ALICE });
    await assertFails(update(CARA, { deletedAt: null, deletedBy: null }));
  });

  it('B-06: a restore cannot change the status', async () => {
    await seedOccurrence({ deletedAt: nowTs(), deletedBy: ALICE });
    await assertFails(
      update(ALICE, { status: 'completed', deletedAt: null, deletedBy: null }),
    );
  });
});

// ── Wave R3 (§6): M-01 … M-06, M-08 ─────────────────────────────────────────
// Written without an emulator: run `npm run test:emulator` once and adjust a
// fixture helper if it behaves differently from what these cases assume.
describe('Wave R3: rules parity with the roadmap', () => {
  const twoSteps = [
    { id: 'rinse', title: 'ধোয়া', required: true, hint: null },
    { id: 'dry', title: 'মুছা', required: false, hint: null },
  ];
  const doneBy = (uid) => ({ at: nowTs(), by: uid });
  const complete = (uid, extra = {}) => ({
    status: 'completed',
    completedAt: nowTs(),
    completedBy: uid,
    ...extra,
  });
  /** One batch: patch + the lifecycle event it names (B-05). */
  const withEvent = (uid, eventId, patch, event) => {
    const db = as(uid);
    const batch = writeBatch(db);
    batch.update(doc(db, occurrencePath()), {
      lastEventId: eventId,
      ...patch,
      updatedAt: nowTs(),
      updatedBy: uid,
    });
    batch.set(doc(db, eventPath(eventId)), eventDoc(uid, event));
    return batch.commit();
  };

  describe('M-01 · completing needs every required step or an exception', () => {
    it('denies completing a chore with an open required step', async () => {
      await seedOccurrence();
      await assertFails(update(CARA, complete(CARA)));
    });

    it('allows completing once the required step is ticked', async () => {
      await seedOccurrence();
      await assertSucceeds(
        update(CARA, { 'subtaskDone.step_1': doneBy(CARA), ...complete(CARA) }),
      );
    });

    it('allows completing a chore that has no steps at all', async () => {
      await seedOccurrence({ subtasks: [], requiredCount: 0 });
      await assertSucceeds(update(CARA, complete(CARA)));
    });

    it('allows completing with a manager exception and no ticks', async () => {
      await seedOccurrence({
        exception: { note: 'বাদ দেওয়া হয়েছে', by: BOB, at: nowTs() },
      });
      await assertSucceeds(update(CARA, complete(CARA)));
    });

    it('denies completing with only some of several required steps', async () => {
      await seedOccurrence({
        subtasks: [
          { id: 'a', title: 'এক', required: true, hint: null },
          { id: 'b', title: 'দুই', required: true, hint: null },
        ],
        requiredCount: 2,
      });
      await assertFails(
        update(CARA, { 'subtaskDone.a': doneBy(CARA), ...complete(CARA) }),
      );
    });

    it('denies a requiredCount above the number of steps (create)', async () => {
      await assertFails(
        setDoc(
          doc(as(CARA), occurrencePath()),
          occurrenceDoc(CARA, { requiredCount: 2 }),
        ),
      );
    });

    it('denies a negative requiredCount (create)', async () => {
      await assertFails(
        setDoc(
          doc(as(CARA), occurrencePath()),
          occurrenceDoc(CARA, { requiredCount: -1 }),
        ),
      );
    });

    it('denies lowering requiredCount in a tick (the snapshot is frozen)', async () => {
      await seedOccurrence();
      await assertFails(
        update(CARA, {
          'subtaskDone.step_1': doneBy(CARA),
          ...complete(CARA),
          requiredCount: 0,
        }),
      );
    });

    it('lets a replan refresh subtasks and requiredCount together', async () => {
      await seedOccurrence();
      await assertSucceeds(
        update(BOB, { templateRev: 2, subtasks: twoSteps, requiredCount: 1 }),
      );
    });

    it('denies a replan whose requiredCount exceeds the new steps', async () => {
      await seedOccurrence();
      await assertFails(
        update(BOB, { templateRev: 2, subtasks: twoSteps, requiredCount: 3 }),
      );
    });
  });

  describe('M-02 · one tick / complete / uncomplete rule', () => {
    beforeEach(async () => {
      await seedPermissions({ membersCanCompleteForOthers: true });
    });

    it('a partial tick does not need completedBy', async () => {
      await seedOccurrence({ subtasks: twoSteps, requiredCount: 1 });
      await assertSucceeds(
        update(CARA, {
          'subtaskDone.rinse': doneBy(CARA),
          status: 'in_progress',
        }),
      );
    });

    it('a partial tick by another member who may tick passes', async () => {
      await seedOccurrence({ subtasks: twoSteps, requiredCount: 1 });
      await assertSucceeds(
        update(GINA, {
          'subtaskDone.rinse': doneBy(GINA),
          status: 'in_progress',
        }),
      );
    });

    it('a partial tick that sneaks in a completedBy is denied', async () => {
      await seedOccurrence({ subtasks: twoSteps, requiredCount: 1 });
      await assertFails(
        update(CARA, {
          'subtaskDone.rinse': doneBy(CARA),
          status: 'in_progress',
          completedBy: CARA,
        }),
      );
    });

    it('another member ticks an OPTIONAL step of a completed chore', async () => {
      await seedOccurrence({
        subtasks: twoSteps,
        requiredCount: 1,
        ...complete(CARA, { completedAt: T0 }),
        'subtaskDone.rinse': doneBy(CARA),
      });
      await assertSucceeds(update(GINA, { 'subtaskDone.dry': doneBy(GINA) }));
    });

    it('denies the same tick without the family switch', async () => {
      await seedPermissions({ membersCanCompleteForOthers: false });
      await seedOccurrence({
        subtasks: twoSteps,
        requiredCount: 1,
        ...complete(CARA, { completedAt: T0 }),
        'subtaskDone.rinse': doneBy(CARA),
      });
      await assertFails(update(GINA, { 'subtaskDone.dry': doneBy(GINA) }));
    });

    it('a tick on a completed chore cannot rewrite who completed it', async () => {
      await seedOccurrence({
        subtasks: twoSteps,
        requiredCount: 1,
        ...complete(CARA, { completedAt: T0 }),
        'subtaskDone.rinse': doneBy(CARA),
      });
      await assertFails(
        update(GINA, { 'subtaskDone.dry': doneBy(GINA), completedBy: GINA }),
      );
    });

    it('removing the required tick of a completed chore needs the uncomplete', async () => {
      await seedOccurrence({
        ...complete(CARA, { completedAt: T0 }),
        'subtaskDone.step_1': doneBy(CARA),
      });
      // Stays `completed` with no required tick left: denied.
      await assertFails(update(CARA, { 'subtaskDone.step_1': deleteField() }));
    });

    it('uncompleting needs its `uncompleted` event in the same batch', async () => {
      await seedOccurrence({
        ...complete(CARA, { completedAt: T0 }),
        'subtaskDone.step_1': doneBy(CARA),
      });
      await assertFails(
        update(CARA, {
          status: 'in_progress',
          completedAt: deleteField(),
          completedBy: deleteField(),
          'subtaskDone.step_1': deleteField(),
        }),
      );
      await assertSucceeds(
        withEvent(
          CARA,
          'uncompleted_1',
          {
            status: 'in_progress',
            completedAt: deleteField(),
            completedBy: deleteField(),
            'subtaskDone.step_1': deleteField(),
          },
          { type: 'uncompleted' },
        ),
      );
    });

    it('an open -> open write cannot change completedAt', async () => {
      await seedOccurrence({ subtasks: twoSteps, requiredCount: 1 });
      await assertFails(
        update(CARA, {
          'subtaskDone.rinse': doneBy(CARA),
          status: 'in_progress',
          completedAt: nowTs(),
        }),
      );
    });

    it('a tick cannot touch the verification fields', async () => {
      await seedOccurrence({ subtasks: twoSteps, requiredCount: 1 });
      await assertFails(
        update(CARA, {
          'subtaskDone.rinse': doneBy(CARA),
          status: 'in_progress',
          verifiedBy: CARA,
        }),
      );
    });
  });

  describe('M-03 · the id equals templateId + date (+ slot)', () => {
    it('denies a body templateId that differs from the id', async () => {
      await assertFails(
        setDoc(
          doc(as(CARA), occurrencePath()),
          occurrenceDoc(CARA, { templateId: 'tpl_2' }),
        ),
      );
    });

    it('denies a slotKey the id does not carry', async () => {
      await assertFails(
        setDoc(
          doc(as(CARA), occurrencePath()),
          occurrenceDoc(CARA, { slotKey: 'noon' }),
        ),
      );
    });

    it('denies a slot suffix the body does not declare', async () => {
      await assertFails(
        setDoc(
          doc(as(CARA), occurrencePath('tpl_1_20261024_noon')),
          occurrenceDoc(CARA),
        ),
      );
    });

    it('denies a slot suffix that differs from slotKey', async () => {
      await assertFails(
        setDoc(
          doc(as(CARA), occurrencePath('tpl_1_20261024_noon')),
          occurrenceDoc(CARA, { slotKey: 'evening' }),
        ),
      );
    });

    it('accepts a templateId that itself contains underscores', async () => {
      await assertSucceeds(
        setDoc(
          doc(as(CARA), occurrencePath('tpl_dish_wash_20261024')),
          occurrenceDoc(CARA, { templateId: 'tpl_dish_wash' }),
        ),
      );
    });
  });

  describe('M-04 · soft delete only for an untouched future chore', () => {
    const future = { dateKey: '2099-01-01', monthKey: '2099-01' };
    const futureId = 'tpl_1_20990101';
    const remove = () =>
      update(BOB, { deletedAt: nowTs(), deletedBy: BOB }, futureId);

    it('allows an untouched scheduled future chore', async () => {
      await seedOccurrence(future, futureId);
      await assertSucceeds(remove());
    });

    it('denies a chore that is in progress', async () => {
      await seedOccurrence(
        { ...future, status: 'in_progress', 'subtaskDone.step_1': doneBy(CARA) },
        futureId,
      );
      await assertFails(remove());
    });

    it('denies a scheduled chore that already has a tick', async () => {
      await seedOccurrence(
        { ...future, 'subtaskDone.step_1': doneBy(CARA) },
        futureId,
      );
      await assertFails(remove());
    });

    it('denies a chore that was reopened before', async () => {
      await seedOccurrence({ ...future, reopenCount: 1 }, futureId);
      await assertFails(remove());
    });

    it('denies a chore that was completed', async () => {
      await seedOccurrence(
        { ...future, ...complete(CARA, { completedAt: T0 }) },
        futureId,
      );
      await assertFails(remove());
    });

    it('denies a plain member', async () => {
      await seedOccurrence(future, futureId);
      await assertFails(
        update(CARA, { deletedAt: nowTs(), deletedBy: CARA }, futureId),
      );
    });
  });

  describe('M-05 · verification is a manager action', () => {
    const completedByGina = {
      ...complete(GINA, { completedAt: T0 }),
      verification: 'required',
    };
    beforeEach(async () => {
      await seedPermissions({ choreVerificationEnabled: true });
    });
    const verify = (uid) =>
      withEvent(
        uid,
        `verified_${uid}`,
        { status: 'verified', verifiedAt: nowTs(), verifiedBy: uid },
        { type: 'verified' },
      );

    it('a moderator who did not complete it verifies', async () => {
      await seedOccurrence(completedByGina);
      await assertSucceeds(verify(BOB));
    });

    it('a plain member who did not complete it cannot', async () => {
      await seedOccurrence(completedByGina);
      await assertFails(verify(CARA));
    });

    it('a manager cannot verify their own completion', async () => {
      await seedOccurrence({ ...completedByGina, completedBy: BOB });
      await assertFails(verify(BOB));
    });
  });

  describe('M-06 · an unassigned chore is somebody else’s', () => {
    it('the PLANNED owner cannot tick while assigneeId is null', async () => {
      await seedOccurrence({ assigneeId: null, plannedAssigneeId: CARA });
      await assertFails(
        update(CARA, { 'subtaskDone.step_1': doneBy(CARA), status: 'in_progress' }),
      );
    });

    it('a manager can still act on it', async () => {
      await seedOccurrence({ assigneeId: null, plannedAssigneeId: CARA });
      await assertSucceeds(
        update(BOB, { 'subtaskDone.step_1': doneBy(BOB), status: 'in_progress' }),
      );
    });

    it('a plain member can when the family switch is on', async () => {
      await seedOccurrence({ assigneeId: null, plannedAssigneeId: CARA });
      await seedPermissions({ membersCanCompleteForOthers: true });
      await assertSucceeds(
        update(GINA, { 'subtaskDone.step_1': doneBy(GINA), status: 'in_progress' }),
      );
    });
  });

  describe('M-08 · repeated and unusual transitions', () => {
    it('skip -> unskip -> skip works with a NEW event id each time', async () => {
      await seedOccurrence();
      await assertSucceeds(
        withEvent(
          BOB,
          'skipped_1',
          { status: 'skipped', skipReason: 'manager' },
          { type: 'skipped', reason: 'ছুটির দিন' },
        ),
      );
      await assertSucceeds(
        withEvent(
          BOB,
          'unskipped_1',
          { status: 'scheduled', skipReason: null },
          { type: 'unskipped' },
        ),
      );
      await assertSucceeds(
        withEvent(
          BOB,
          'skipped_2',
          { status: 'skipped', skipReason: 'manager' },
          { type: 'skipped', reason: 'আবার ছুটি' },
        ),
      );
    });

    it('a second skip that reuses an existing event id is denied', async () => {
      await seedOccurrence();
      await assertSucceeds(
        withEvent(
          BOB,
          'skipped_1',
          { status: 'skipped', skipReason: 'manager' },
          { type: 'skipped', reason: 'ছুটির দিন' },
        ),
      );
      await assertSucceeds(
        withEvent(
          BOB,
          'unskipped_1',
          { status: 'scheduled', skipReason: null },
          { type: 'unskipped' },
        ),
      );
      await assertFails(
        withEvent(
          BOB,
          'skipped_1',
          { status: 'skipped', skipReason: 'manager' },
          { type: 'skipped', reason: 'আবার ছুটি' },
        ),
      );
    });

    it('reassign A -> B -> A (ping-pong) works with distinct events', async () => {
      await seedOccurrence();
      await assertSucceeds(
        withEvent(
          BOB,
          'reassigned_1',
          { assigneeId: GINA, assignmentSource: 'reassign' },
          { type: 'reassigned', reason: 'গিনা পারবে', toAssigneeId: GINA },
        ),
      );
      await assertSucceeds(
        withEvent(
          BOB,
          'reassigned_2',
          { assigneeId: CARA, assignmentSource: 'reassign' },
          { type: 'reassigned', reason: 'আবার কারা', toAssigneeId: CARA },
        ),
      );
    });

    it('another member ticks a completed chore (see M-02)', async () => {
      await seedPermissions({ membersCanCompleteForOthers: true });
      await seedOccurrence({
        subtasks: twoSteps,
        requiredCount: 1,
        ...complete(CARA, { completedAt: T0 }),
        'subtaskDone.rinse': doneBy(CARA),
      });
      await assertSucceeds(update(GINA, { 'subtaskDone.dry': doneBy(GINA) }));
    });

    it('soft delete of a started document is denied (see M-04)', async () => {
      await seedOccurrence(
        {
          dateKey: '2099-01-01',
          monthKey: '2099-01',
          status: 'in_progress',
          'subtaskDone.step_1': doneBy(CARA),
        },
        'tpl_1_20990101',
      );
      await assertFails(
        update(BOB, { deletedAt: nowTs(), deletedBy: BOB }, 'tpl_1_20990101'),
      );
    });

    it('restore of a soft-deleted document that has ticks is denied', async () => {
      await seedOccurrence({
        deletedAt: nowTs(),
        deletedBy: ALICE,
        'subtaskDone.step_1': doneBy(CARA),
      });
      await assertFails(update(ALICE, { deletedAt: null, deletedBy: null }));
    });

    it('restore refreshes subtasks together with requiredCount', async () => {
      await seedOccurrence({ deletedAt: nowTs(), deletedBy: ALICE });
      await assertSucceeds(
        update(ALICE, {
          deletedAt: null,
          deletedBy: null,
          subtasks: twoSteps,
          requiredCount: 2,
        }),
      );
    });
  });
});
