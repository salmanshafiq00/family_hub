// Firestore rules for the Bazar catalog (P2-05).
//
// Every rule gets an allowed and a denied case, following the template in
// `templates/collection.test.mjs.tmpl`.  Run with the emulator; see README.md.

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  deleteDoc,
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
  FRANK,
  PROJECT_ID,
  asUser,
  categoryDoc,
  familyDoc,
  itemDoc,
  itemUsage,
  permissionsDoc,
  seedWorld,
} from './support.mjs';

const [host, port] = EMULATOR.split(':');

let testEnv;

const as = (uid) => asUser(testEnv, uid);

const categoryPath = (id = 'cat1') => `families/${FAM_A}/bazarCategories/${id}`;
const itemPath = (id = 'item1') => `families/${FAM_A}/bazarItems/${id}`;

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
    const db = ctx.firestore();
    await setDoc(
      doc(db, categoryPath()),
      categoryDoc(ALICE, { builtIn: true, seedKey: 'staples' }),
    );
    await setDoc(
      doc(db, itemPath()),
      itemDoc(ALICE, { useCount: 2, builtIn: true, seedKey: 'rice' }),
    );
  });
});

describe('families/{f}/bazarCategories', () => {
  for (const [label, uid] of [
    ['member', CARA],
    ['moderator', BOB],
    ['admin', ALICE],
  ]) {
    it(`allows an active ${label} to read`, async () => {
      await assertSucceeds(getDoc(doc(as(uid), categoryPath())));
    });
  }

  it('denies a pending member reading', async () => {
    await assertFails(getDoc(doc(as(DAVE), categoryPath())));
  });

  it('denies another family reading', async () => {
    await assertFails(getDoc(doc(as(ERIN), categoryPath())));
  });

  it('allows an admin to create a category', async () => {
    await assertSucceeds(
      setDoc(doc(as(ALICE), categoryPath('cat2')), categoryDoc(ALICE)),
    );
  });

  it('allows a moderator to create a category while finance is on', async () => {
    await assertSucceeds(
      setDoc(doc(as(BOB), categoryPath('cat2')), categoryDoc(BOB)),
    );
  });

  it('denies a moderator creating a category while finance is off', async () => {
    await assertSucceeds(
      setDoc(
        doc(as(ALICE), `families/${FAM_A}/settings/permissions`),
        permissionsDoc(ALICE, { moderatorManagesFinance: false }),
      ),
    );
    await assertFails(
      setDoc(doc(as(BOB), categoryPath('cat2')), categoryDoc(BOB)),
    );
  });

  it('denies a plain member creating a category', async () => {
    await assertFails(
      setDoc(doc(as(CARA), categoryPath('cat2')), categoryDoc(CARA)),
    );
  });

  it('denies an unknown field', async () => {
    await assertFails(
      setDoc(doc(as(ALICE), categoryPath('cat2')), {
        ...categoryDoc(ALICE),
        extra: 1,
      }),
    );
  });

  it('denies colorIndex 24', async () => {
    await assertFails(
      setDoc(
        doc(as(ALICE), categoryPath('cat2')),
        categoryDoc(ALICE, { colorIndex: 24 }),
      ),
    );
  });

  it('denies a hard delete', async () => {
    await assertFails(deleteDoc(doc(as(ALICE), categoryPath())));
  });
});

describe('families/{f}/bazarItems', () => {
  for (const [label, uid] of [
    ['member', CARA],
    ['moderator', BOB],
    ['admin', ALICE],
  ]) {
    it(`allows an active ${label} to read`, async () => {
      await assertSucceeds(getDoc(doc(as(uid), itemPath())));
    });
  }

  it('denies a pending member reading', async () => {
    await assertFails(getDoc(doc(as(DAVE), itemPath())));
  });

  it('denies another family reading', async () => {
    await assertFails(getDoc(doc(as(ERIN), itemPath())));
  });

  it('allows a member to create a custom item', async () => {
    await assertSucceeds(
      setDoc(
        doc(as(CARA), itemPath('item2')),
        itemDoc(CARA, { categoryId: 'cat1', builtIn: false, useCount: 0 }),
      ),
    );
  });

  it('denies a member creating a built-in item', async () => {
    await assertFails(
      setDoc(
        doc(as(CARA), itemPath('item2')),
        itemDoc(CARA, { builtIn: true }),
      ),
    );
  });

  it('allows a member to bump useCount by one', async () => {
    await assertSucceeds(
      updateDoc(doc(as(CARA), itemPath()), itemUsage(CARA, { useCount: 3 })),
    );
  });

  it('denies a member bumping useCount by 100', async () => {
    await assertFails(
      updateDoc(doc(as(CARA), itemPath()), itemUsage(CARA, { useCount: 102 })),
    );
  });

  it('denies a member bumping useCount and renaming in one write', async () => {
    await assertFails(
      updateDoc(doc(as(CARA), itemPath()), {
        ...itemUsage(CARA, { useCount: 3 }),
        nameEn: 'Hacked',
      }),
    );
  });

  it('denies an unknown field on a member item', async () => {
    await assertFails(
      setDoc(doc(as(CARA), itemPath('item2')), {
        ...itemDoc(CARA, { categoryId: 'cat1' }),
        extra: 1,
      }),
    );
  });

  it('denies a hard delete', async () => {
    await assertFails(deleteDoc(doc(as(ALICE), itemPath())));
  });
});

describe('creating a family with the default catalog', () => {
  it('allows 11 categories and 54 items in one batch', async () => {
    const db = as(FRANK);
    const familyId = 'famNew';
    const batch = writeBatch(db);

    batch.set(doc(db, `families/${familyId}`), familyDoc(FRANK, 'New Family'));
    for (let c = 0; c < 11; c++) {
      batch.set(
        doc(db, `families/${familyId}/bazarCategories/cat_c${c}`),
        categoryDoc(FRANK, {
          nameBn: `বিভাগ ${c}`,
          builtIn: true,
          seedKey: `c${c}`,
        }),
      );
    }
    for (let i = 0; i < 54; i++) {
      batch.set(
        doc(db, `families/${familyId}/bazarItems/item_i${i}`),
        itemDoc(FRANK, {
          nameBn: `পণ্য ${i}`,
          categoryId: `cat_c${i % 11}`,
          builtIn: true,
          seedKey: `i${i}`,
          useCount: 0,
        }),
      );
    }

    await assertSucceeds(batch.commit());
  });
});
