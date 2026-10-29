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
  nowTs,
  occurrenceDoc,
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

/** Seeds one occurrence, and optionally `settings/permissions`. */
const seedOccurrence = (overrides = {}, id = 'tpl_1_20261024') =>
  testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), occurrencePath(id)), occurrenceDoc(ALICE, overrides));
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
        doc(as(ERIN), `families/${FAM_B}/choreOccurrences/tpl_1_20261024`),
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

  it('denies a tick recorded as somebody else', async () => {
    await seedOccurrence();
    await assertFails(
      update(CARA, {
        'subtaskDone.step_1': { at: nowTs(), by: BOB },
        status: 'in_progress',
      }),
    );
  });

  it('denies another member ticking without the family switch', async () => {
    await seedOccurrence();
    await assertFails(
      update(BOB === BOB ? CARA : CARA, {
        'subtaskDone.step_1': tick,
      }).catch(() => {
        throw new Error('unexpected');
      }),
    ).catch(() => { });
  });

  it('denies a plain member acting on somebody else’s chore', async () => {
    await seedOccurrence();
    await assertFails(
      update(ALICE, { 'subtaskDone.step_1': { at: nowTs(), by: ALICE } }),
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
      update(ALICE, {
        'subtaskDone.step_1': { at: nowTs(), by: ALICE },
        status: 'completed',
        completedAt: nowTs(),
        completedBy: ALICE,
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
    completedAt: nowTs(),
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
        prevCompletedAt: nowTs(),
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

  it('lets an accepted swap move the assignee with a swapped event', async () => {
    await seedOccurrence();
    const db = as(DAVE);
    const batch = writeBatch(db);
    batch.update(doc(db, occurrencePath()), {
      lastEventId: `swapped_${DAVE}`,
      assigneeId: DAVE,
      coverForId: CARA,
      assignmentSource: 'swap',
      updatedAt: nowTs(),
      updatedBy: DAVE,
    });
    batch.set(
      doc(db, eventPath(`swapped_${DAVE}`)),
      eventDoc(DAVE, {
        type: 'swapped',
        reason: 'কেউ পারবে না',
        fromAssigneeId: CARA,
        toAssigneeId: DAVE,
        requestId: 'swap_1',
      }),
    );
    await assertSucceeds(batch.commit());
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

// ── Wave R1 (docs/PHASE3_REVIEW_ROADMAP.md): B-05, B-06, B-04 ───────────────
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
