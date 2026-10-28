// Firestore rules for dutyGroups (P3-10).
//
// Manager or admin write, any active member reads, never deleted, and the
// rotation's first/last version plus the `versions` count are shape-checked
// (rules cannot loop).  A group with 20 versions passes; 21 fails.
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
  dutyGroupDoc,
  nowTs,
  seedWorld,
} from './support.mjs';

const [host, port] = EMULATOR.split(':');

let testEnv;

const as = (uid) => asUser(testEnv, uid);
const groupPath = (id = 'group_1') => `families/${FAM_A}/dutyGroups/${id}`;

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

/** A duty group with [overrides] applied. */
const group = (uid, overrides = {}) => dutyGroupDoc(uid, overrides);

/** Seeds one group with the rules switched off. */
const seedGroup = (uid = ALICE, overrides = {}, id = 'group_1') =>
  testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), groupPath(id)), group(uid, overrides));
  });

/** [count] valid rotation versions with increasing dates. */
const versions = (count) =>
  Array.from({ length: count }, (_, i) => ({
    from: `2026-01-${String(i + 1).padStart(2, '0')}`,
    members: ['alice', 'cara'],
    anchorDate: '2026-01-03',
    anchorIndex: 0,
    cycleUnit: 'week',
    weekStartDay: 6,
  }));

describe('families/{f}/dutyGroups', () => {
  it('allows an admin to create a group', async () => {
    await assertSucceeds(setDoc(doc(as(ALICE), groupPath()), group(ALICE)));
  });

  it('allows a Household Manager to create a group', async () => {
    await assertSucceeds(setDoc(doc(as(BOB), groupPath()), group(BOB)));
  });

  it('denies a plain member', async () => {
    await assertFails(setDoc(doc(as(CARA), groupPath()), group(CARA)));
  });

  it('denies a pending member', async () => {
    await assertFails(setDoc(doc(as(DAVE), groupPath()), group(DAVE)));
  });

  it('denies an admin of another family', async () => {
    await assertFails(
      setDoc(
        doc(as(ERIN), `families/${FAM_B}/dutyGroups/group_1`),
        group(ERIN),
      ),
    );
  });

  it('denies a user with no family', async () => {
    await assertFails(setDoc(doc(as(FRANK), groupPath()), group(FRANK)));
  });

  it('lets any active member read a group', async () => {
    await seedGroup();
    await assertSucceeds(getDoc(doc(as(CARA), groupPath())));
  });

  it('denies another family reading a group', async () => {
    await seedGroup();
    await assertFails(getDoc(doc(as(ERIN), groupPath())));
  });

  it('allows a manager to rename and deactivate a group', async () => {
    await seedGroup();
    await assertSucceeds(
      updateDoc(doc(as(BOB), groupPath()), {
        nameBn: 'নতুন নাম',
        active: false,
        updatedAt: nowTs(),
        updatedBy: BOB,
      }),
    );
  });

  it('denies a plain member updating a group', async () => {
    await seedGroup();
    await assertFails(
      updateDoc(doc(as(CARA), groupPath()), {
        nameBn: 'নতুন নাম',
        updatedAt: nowTs(),
        updatedBy: CARA,
      }),
    );
  });

  it('denies a hard delete', async () => {
    await seedGroup();
    await assertFails(deleteDoc(doc(as(ALICE), groupPath())));
  });

  describe('shape', () => {
    it('denies an unknown field', async () => {
      await assertFails(
        setDoc(doc(as(ALICE), groupPath()), {
          ...group(ALICE),
          extra: true,
        }),
      );
    });

    it('denies an empty name', async () => {
      await assertFails(
        setDoc(doc(as(ALICE), groupPath()), group(ALICE, { nameBn: '' })),
      );
    });

    it('denies an 81-character name', async () => {
      await assertFails(
        setDoc(
          doc(as(ALICE), groupPath()),
          group(ALICE, { nameBn: 'x'.repeat(81) }),
        ),
      );
    });

    it('denies an out-of-range colour', async () => {
      await assertFails(
        setDoc(
          doc(as(ALICE), groupPath()),
          group(ALICE, { colorIndex: 12 }),
        ),
      );
    });

    it('denies an unknown cycle unit', async () => {
      await assertFails(
        setDoc(
          doc(as(ALICE), groupPath()),
          group(ALICE, {
            rotation: {
              versions: [{ ...versions(1)[0], cycleUnit: 'fortnight' }],
            },
          }),
        ),
      );
    });

    it('denies an anchor index outside the roster', async () => {
      await assertFails(
        setDoc(
          doc(as(ALICE), groupPath()),
          group(ALICE, {
            rotation: {
              versions: [{ ...versions(1)[0], anchorIndex: 2 }],
            },
          }),
        ),
      );
    });

    it('denies 13 members', async () => {
      await assertFails(
        setDoc(
          doc(as(ALICE), groupPath()),
          group(ALICE, {
            rotation: {
              versions: [
                {
                  ...versions(1)[0],
                  members: Array.from({ length: 13 }, (_, i) => `m${i}`),
                  anchorIndex: 0,
                },
              ],
            },
          }),
        ),
      );
    });

    it('denies an empty rotation', async () => {
      await assertFails(
        setDoc(
          doc(as(ALICE), groupPath()),
          group(ALICE, { rotation: { versions: [] } }),
        ),
      );
    });

    it('allows the maximum rotation: 20 versions', async () => {
      await assertSucceeds(
        setDoc(
          doc(as(ALICE), groupPath()),
          group(ALICE, { rotation: { versions: versions(20) } }),
        ),
      );
    });

    it('denies 21 versions', async () => {
      await assertFails(
        setDoc(
          doc(as(ALICE), groupPath()),
          group(ALICE, { rotation: { versions: versions(21) } }),
        ),
      );
    });
  });
});
