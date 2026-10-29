// H5 contract test: the Dart ↔ rules seam.
//
// `test/contract/rules_fixtures_test.dart` builds REAL payloads with the
// FamilyMappers and writes them to `firebase/rules_test/fixtures/*.json`.  This
// test loads each one, rehydrates the Timestamps / serverTimestamp markers and
// pushes the whole batch through the emulator as the fixture's actor.  If a
// mapper writes a key the rules do not allow (or a required field is missing),
// this fails — and CI runs the Dart generator first plus
// `git diff --exit-code firebase/rules_test/fixtures`, so the two cannot drift.
//
//   firebase/rules_test> npm install
//   (repo root)> npx firebase emulators:exec --only firestore \
//                  --project demo-family-hub "npm --prefix firebase/rules_test test"

import { strict as assert } from 'node:assert';
import { readFileSync, readdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

import {
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { Timestamp, deleteField, doc, serverTimestamp, setDoc, writeBatch, increment } from 'firebase/firestore';
import { after, before, describe, it } from 'mocha';

import {
  EMULATOR,
  PROJECT_ID,
  asUser,
  categoryDoc,
  expenseDoc,
  familyDoc,
  inviteCodeDoc,
  itemDoc,
  memberDoc,
  nowTs,
  occurrenceDoc,
} from './support.mjs';

const ADMIN = 'fixAdmin';
const JOINER = 'fixJoiner';
const MEMBER = 'fixMember';
const FAMILY = 'fixFam';
const CODE = 'ABCD2345';
const CATEGORY = 'cat_fixStaples';
const ITEM = 'item_fixRice';

const [host, port] = EMULATOR.split(':');
const fixturesDir = join(dirname(fileURLToPath(import.meta.url)), 'fixtures');

/** `{"__ts": iso}` -> Timestamp, `{"__serverTime": true}` -> serverTimestamp(). */
const rehydrate = (value) => {
  if (Array.isArray(value)) return value.map(rehydrate);
  if (value && typeof value === 'object') {
    if (value.__ts !== undefined) return Timestamp.fromDate(new Date(value.__ts));
    if (value.__serverTime === true) return serverTimestamp();
    if (value.__delete === true) return deleteField();
    if (value.__increment !== undefined) return increment(value.__increment);
    const out = {};
    for (const [k, v] of Object.entries(value)) out[k] = rehydrate(v);
    return out;
  }
  return value;
};

/** Prerequisite world for each scenario, seeded with the rules switched off. */
const seeders = {
  create_family: async () => {},
  create_family_catalog: async () => {},
  profile: async () => {},
  join: async (db) => {
    await setDoc(doc(db, `families/${FAMILY}`), familyDoc(ADMIN));
    await setDoc(
      doc(db, `families/${FAMILY}/members/${ADMIN}`),
      memberDoc(ADMIN, 'admin', 'active'),
    );
    // A live code (expiresAt is relative to the RUN time, not the fixture).
    await setDoc(doc(db, `inviteCodes/${CODE}`), inviteCodeDoc(ADMIN, FAMILY, CODE));
    await setDoc(
      doc(db, `families/${FAMILY}/invitations/${CODE}`),
      inviteCodeDoc(ADMIN, FAMILY, CODE),
    );
  },
  approve: async (db) => {
    await seedFamilyWithAdmin(db);
    await setDoc(
      doc(db, `families/${FAMILY}/members/${JOINER}`),
      memberDoc(JOINER, 'member', 'pending'),
    );
  },
  role_change: async (db) => {
    await seedFamilyWithAdmin(db);
    await setDoc(
      doc(db, `families/${FAMILY}/members/${JOINER}`),
      memberDoc(JOINER, 'member', 'active'),
    );
  },
  transfer_admin: async (db) => {
    await seedFamilyWithAdmin(db);
    await setDoc(
      doc(db, `families/${FAMILY}/members/${JOINER}`),
      memberDoc(JOINER, 'member', 'active'),
    );
  },
  create_invitation: async (db) => {
    await seedFamilyWithAdmin(db);
  },
  revoke_invitation: async (db) => {
    await seedFamilyWithAdmin(db);
    await setDoc(doc(db, `inviteCodes/${CODE}`), inviteCodeDoc(ADMIN, FAMILY, CODE));
    await setDoc(
      doc(db, `families/${FAMILY}/invitations/${CODE}`),
      inviteCodeDoc(ADMIN, FAMILY, CODE),
    );
  },
  category: async (db) => {
    await seedFamilyWithAdmin(db);
  },
  item: async (db) => {
    await seedFamilyWithAdmin(db);
    await setDoc(
      doc(db, `families/${FAMILY}/bazarCategories/${CATEGORY}`),
      categoryDoc(ADMIN, { builtIn: true, seedKey: 'staples' }),
    );
  },
  settings_bazar: async (db) => {
    await seedFamilyWithAdmin(db);
  },
  budget: async (db) => {
    await seedFamilyWithAdmin(db);
  },
  item_usage: async (db) => {
    await seedFamilyWithAdmin(db);
    await setDoc(
      doc(db, `families/${FAMILY}/members/${MEMBER}`),
      memberDoc(MEMBER, 'member', 'active'),
    );
    await setDoc(
      doc(db, `families/${FAMILY}/bazarCategories/${CATEGORY}`),
      categoryDoc(ADMIN, { builtIn: true, seedKey: 'staples' }),
    );
    await setDoc(
      doc(db, `families/${FAMILY}/bazarItems/${ITEM}`),
      itemDoc(ADMIN, { useCount: 2, builtIn: true, seedKey: 'rice' }),
    );
  },
  expense_fund: async (db) => {
    await seedFamilyWithMember(db);
  },
  expense_member_advance: async (db) => {
    await seedFamilyWithMember(db);
  },
  expense_personal: async (db) => {
    await seedFamilyWithMember(db);
  },
  expense_edit: async (db) => {
    await seedFamilyWithMember(db);
    await setDoc(
      doc(db, `families/${FAMILY}/expenses/exp_fix4`),
      expenseDoc(MEMBER, { totalPaisa: 12000 }),
    );
  },
  expense_soft_delete: async (db) => {
    await seedFamilyWithMember(db);
    await setDoc(
      doc(db, `families/${FAMILY}/expenses/exp_fix5`),
      expenseDoc(MEMBER),
    );
  },
  expense_restore: async (db) => {
    await seedFamilyWithMember(db);
    await setDoc(
      doc(db, `families/${FAMILY}/expenses/exp_fix6`),
      expenseDoc(MEMBER, { deletedAt: nowTs(), deletedBy: MEMBER }),
    );
  },
  revision: async (db) => {
    await seedFamilyWithMember(db);
    await setDoc(
      doc(db, `families/${FAMILY}/expenses/exp_fix7`),
      expenseDoc(MEMBER),
    );
  },
  trip: async (db) => {
    await seedFamilyWithMember(db);
  },
  fundtx_expense: async (db) => {
    await seedFamilyWithMember(db);
  },
  fundtx_contribution: async (db) => {
    await seedFamilyWithAdmin(db);
  },
  fundtx_reimbursement: async (db) => {
    await seedFamilyWithAdmin(db);
  },
  fundtx_opening: async (db) => {
    await seedFamilyWithAdmin(db);
  },
  fundtx_adjustment: async (db) => {
    await seedFamilyWithMember(db);
  },
  advance: async (db) => {
    await seedFamilyWithMember(db);
  },
  settlement: async (db) => {
    await seedFamilyWithMember(db);
  },
  month_closing: async (db) => {
    await seedFamilyWithAdmin(db);
  },
  contribution_request: async (db) => {
    await seedFamilyWithMember(db);
  },
  contribution_recorded: async (db) => {
    await seedFamilyWithMember(db);
  },
  contribution_plan: async (db) => {
    await seedFamilyWithMember(db);
  },
  chore_template: async (db) => {
    await seedFamilyWithAdmin(db);
  },
  duty_group: async (db) => {
    await seedFamilyWithAdmin(db);
  },
  // P3-13: the fixture's actor is a plain member who COMPLETED the chore, so
  // the family needs that member (the seed's `MEMBER` is the planned owner).
  chore_occurrence: async (db) => {
    await seedFamilyWithAdmin(db);
    await setDoc(
      doc(db, `families/${FAMILY}/members/fixCara`),
      memberDoc('fixCara', 'member', 'active'),
    );
  },
  // B-04 / B-05: the reopen patch + its `reopened` event run as ONE batch on a
  // completed chore with two ticks (the actor is the admin, a manager).
  chore_occurrence_reopen: async (db) => {
    await seedFamilyWithAdmin(db);
    await setDoc(
      doc(db, `families/${FAMILY}/members/fixCara`),
      memberDoc('fixCara', 'member', 'active'),
    );
    await setDoc(
      doc(db, `families/${FAMILY}/choreOccurrences/tpl_fixDishes_20261019`),
      occurrenceDoc('fixCara', {
        templateId: 'tpl_fixDishes',
        dateKey: '2026-10-19',
        monthKey: '2026-10',
        status: 'completed',
        completedAt: nowTs(),
        completedBy: 'fixCara',
        'subtaskDone.rinse': { at: nowTs(), by: 'fixCara' },
        'subtaskDone.dry': { at: nowTs(), by: 'fixCara' },
        redoSubtaskIds: [],
      }),
    );
  },
  // B-06: a soft-deleted, never-started future day that a resumed template
  // restores (rule 12 · RESTORE).
  chore_occurrence_restore: async (db) => {
    await seedFamilyWithAdmin(db);
    await setDoc(
      doc(db, `families/${FAMILY}/choreOccurrences/tpl_fixDishes_20261102`),
      occurrenceDoc(ADMIN, {
        templateId: 'tpl_fixDishes',
        dateKey: '2026-11-02',
        monthKey: '2026-11',
        deletedAt: nowTs(),
        deletedBy: ADMIN,
      }),
    );
  },
};

const seedFamilyWithAdmin = async (db) => {
  await setDoc(doc(db, `families/${FAMILY}`), familyDoc(ADMIN));
  await setDoc(
    doc(db, `families/${FAMILY}/members/${ADMIN}`),
    memberDoc(ADMIN, 'admin', 'active'),
  );
};

const seedFamilyWithMember = async (db) => {
  await seedFamilyWithAdmin(db);
  await setDoc(
    doc(db, `families/${FAMILY}/members/${MEMBER}`),
    memberDoc(MEMBER, 'member', 'active'),
  );
};

/** Applies the fixture's writes in one batch, exactly like the repository. */
const applyWrites = (db, writes) => {
  const batch = writeBatch(db);
  for (const write of writes) {
    const ref = doc(db, write.path);
    const data = rehydrate(write.data);
    if (write.op === 'set') batch.set(ref, data);
    else if (write.op === 'merge') batch.set(ref, data, { merge: true });
    else if (write.op === 'update') batch.update(ref, data);
    else throw new Error(`unknown write op: ${write.op}`);
  }
  return batch.commit();
};

const fixtures = readdirSync(fixturesDir)
  .filter((name) => name.endsWith('.json'))
  .sort()
  .map((name) => JSON.parse(readFileSync(join(fixturesDir, name), 'utf8')));

describe('H5 mapper ↔ rules contract', () => {
  let testEnv;

  before(async () => {
    testEnv = await initializeTestEnvironment({
      projectId: PROJECT_ID,
      firestore: { host, port: Number(port) },
    });
  });

  after(async () => {
    await testEnv.cleanup();
  });

  assert.ok(fixtures.length > 0, 'no contract fixtures found — run flutter test');

  for (const fixture of fixtures) {
    it(`allows the real ${fixture.scenario} batch`, async () => {
      await testEnv.clearFirestore();
      const seed = seeders[fixture.scenario];
      assert.ok(seed, `no seeder for scenario ${fixture.scenario}`);
      await testEnv.withSecurityRulesDisabled(async (ctx) => {
        await seed(ctx.firestore());
      });
      const db = asUser(testEnv, fixture.actor);
      await assertSucceeds(applyWrites(db, fixture.writes));
    });
  }
});
