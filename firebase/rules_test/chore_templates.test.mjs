// Firestore rules for choreTemplates (P3-08).
//
// Manager or admin write, any active member reads, never deleted, `revision`
// increases by exactly one, `seedKey` / `builtIn` immutable.
//
// Run: npm run test:emulator (from firebase/rules_test).

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { deleteDoc, doc, getDoc, setDoc, updateDoc } from 'firebase/firestore';
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
  nowTs,
  seedWorld,
} from './support.mjs';

const [host, port] = EMULATOR.split(':');

let testEnv;

const as = (uid) => asUser(testEnv, uid);
const templatePath = (id = 'tpl_1') => `families/${FAM_A}/choreTemplates/${id}`;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: { host, port },
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

/** A template with [overrides] applied. */
const template = (uid, overrides = {}) => choreTemplateDoc(uid, overrides);

/** Seeds one template with the rules switched off. */
const seedTemplate = (uid = ALICE, overrides = {}, id = 'tpl_1') =>
  testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), templatePath(id)), template(uid, overrides));
  });

/** An update payload that keeps `revision` valid (current + 1). */
const bump = (uid, overrides = {}) => ({
  ...template(uid, overrides),
  revision: 2,
  updatedAt: nowTs(),
  updatedBy: uid,
});

describe('families/{f}/choreTemplates', () => {
  it('allows an admin to create a template', async () => {
    await assertSucceeds(
      setDoc(doc(as(ALICE), templatePath()), template(ALICE)),
    );
  });

  it('allows a Household Manager to create a template', async () => {
    await assertSucceeds(setDoc(doc(as(BOB), templatePath()), template(BOB)));
  });

  it('denies a plain member', async () => {
    await assertFails(setDoc(doc(as(CARA), templatePath()), template(CARA)));
  });

  it('denies a pending member', async () => {
    await assertFails(setDoc(doc(as(DAVE), templatePath()), template(DAVE)));
  });

  it('denies an admin of another family', async () => {
    await assertFails(
      setDoc(
        doc(as(ERIN), `families/${FAM_B}/choreTemplates/tpl_1`),
        template(ERIN),
      ),
    );
  });

  it('denies a user with no family', async () => {
    await assertFails(setDoc(doc(as(FRANK), templatePath()), template(FRANK)));
  });

  it('lets any active member read a template', async () => {
    await seedTemplate();
    await assertSucceeds(getDoc(doc(as(CARA), templatePath())));
  });

  it('allows a manager to update and bump the revision by one', async () => {
    await seedTemplate();
    await assertSucceeds(
      updateDoc(doc(as(BOB), templatePath()), {
        nameBn: 'নতুন নাম',
        revision: 2,
        updatedAt: nowTs(),
        updatedBy: BOB,
      }),
    );
  });

  it('denies an update that keeps the revision', async () => {
    await seedTemplate();
    await assertFails(
      updateDoc(doc(as(ALICE), templatePath()), {
        nameBn: 'নতুন নাম',
        updatedAt: nowTs(),
        updatedBy: ALICE,
      }),
    );
  });

  it('denies an update that jumps two revisions', async () => {
    await seedTemplate();
    await assertFails(
      setDoc(doc(as(ALICE), templatePath()), bump(ALICE, { revision: 3 })),
    );
  });

  it('denies changing seedKey', async () => {
    await seedTemplate(ALICE, { seedKey: 'dishes', builtIn: true }, 'tpl_dishes');
    await assertFails(
      setDoc(
        doc(as(ALICE), templatePath('tpl_dishes')),
        bump(ALICE, { seedKey: 'other' }),
      ),
    );
  });

  it('denies changing builtIn', async () => {
    await seedTemplate(ALICE, { seedKey: 'dishes', builtIn: true }, 'tpl_dishes');
    await assertFails(
      setDoc(
        doc(as(ALICE), templatePath('tpl_dishes')),
        bump(ALICE, { seedKey: 'dishes', builtIn: false }),
      ),
    );
  });

  it('denies a hard delete', async () => {
    await seedTemplate();
    await assertFails(deleteDoc(doc(as(ALICE), templatePath())));
  });

  describe('shape', () => {
    it('denies an unknown recurrence kind', async () => {
      await assertFails(
        setDoc(
          doc(as(ALICE), templatePath()),
          template(ALICE, {
            recurrence: { kind: 'hourly' },
          }),
        ),
      );
    });

    it('denies an empty name', async () => {
      await assertFails(
        setDoc(doc(as(ALICE), templatePath()), template(ALICE, { nameBn: '' })),
      );
    });

    it('denies an unknown assignee strategy', async () => {
      await assertFails(
        setDoc(
          doc(as(ALICE), templatePath()),
          template(ALICE, {
            assignee: { strategy: 'lottery' },
          }),
        ),
      );
    });

    it('denies seven slots', async () => {
      await assertFails(
        setDoc(
          doc(as(ALICE), templatePath()),
          template(ALICE, {
            slots: Array.from({ length: 7 }, (_, i) => ({
              key: i === 0 ? 'main' : `s${i}`,
              labelBn: 'বার',
              labelEn: null,
              dueMinutes: 540,
            })),
          }),
        ),
      );
    });

    it('denies a first slot that is not main', async () => {
      await assertFails(
        setDoc(
          doc(as(ALICE), templatePath()),
          template(ALICE, {
            slots: [{ key: 'Noon', labelBn: 'দুপুর', labelEn: null, dueMinutes: 840 }],
          }),
        ),
      );
    });

    it('denies an out-of-range colour', async () => {
      await assertFails(
        setDoc(
          doc(as(ALICE), templatePath()),
          template(ALICE, { colorIndex: 24 }),
        ),
      );
    });

    it('denies an unknown field', async () => {
      await assertFails(
        setDoc(doc(as(ALICE), templatePath()), {
          ...template(ALICE),
          extra: true,
        }),
      );
    });

    it('accepts the maximum shape: 6 slots, 30 subtasks, 4000 characters', async () => {
      await assertSucceeds(
        setDoc(
          doc(as(ALICE), templatePath()),
          template(ALICE, {
            slots: Array.from({ length: 6 }, (_, i) => ({
              key: i === 0 ? 'main' : `s${i}`,
              labelBn: 'বার',
              labelEn: 'Slot',
              dueMinutes: 540,
            })),
            subtasks: Array.from({ length: 30 }, (_, i) => ({
              id: `step_${i}`,
              title: 'ধাপ',
              required: i === 0,
              hint: null,
            })),
            instructions: 'x'.repeat(4000),
          }),
        ),
      );
    });

    it('denies 31 subtasks', async () => {
      await assertFails(
        setDoc(
          doc(as(ALICE), templatePath()),
          template(ALICE, {
            subtasks: Array.from({ length: 31 }, (_, i) => ({
              id: `step_${i}`,
              title: 'ধাপ',
              required: false,
              hint: null,
            })),
          }),
        ),
      );
    });

    it('denies 4001 characters of instructions', async () => {
      await assertFails(
        setDoc(
          doc(as(ALICE), templatePath()),
          template(ALICE, { instructions: 'x'.repeat(4001) }),
        ),
      );
    });
  });
});
