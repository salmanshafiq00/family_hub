// Firestore rules for starterPackItems: the family's own, editable starter pack.
//
// Manager or admin write (create, update AND delete), any active member reads.
// An item has the shape of a chore template, so `choreTemplateDoc` builds it.
//
// Run: npm run test:emulator (from firebase/rules_test).

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { deleteDoc, doc, getDoc, setDoc } from 'firebase/firestore';
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
  PROJECT_ID,
  asUser,
  choreTemplateDoc,
  seedWorld,
} from './support.mjs';

const [host, port] = EMULATOR.split(':');

let testEnv;

const as = (uid) => asUser(testEnv, uid);
const itemPath = (id = 'dinner') => `families/${FAM_A}/starterPackItems/${id}`;

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

const item = (uid, overrides = {}) =>
  choreTemplateDoc(uid, { seedKey: 'dinner', ...overrides });

const seedItem = () =>
  testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), itemPath()), item(ALICE));
  });

describe('families/{f}/starterPackItems', () => {
  it('allows an admin to create a line', async () => {
    await assertSucceeds(setDoc(doc(as(ALICE), itemPath()), item(ALICE)));
  });

  it('allows a Household Manager to create a line', async () => {
    await assertSucceeds(setDoc(doc(as(BOB), itemPath()), item(BOB)));
  });

  it('denies a plain member and a pending member', async () => {
    await assertFails(setDoc(doc(as(CARA), itemPath()), item(CARA)));
    await assertFails(setDoc(doc(as(DAVE), itemPath()), item(DAVE)));
  });

  it('denies an admin of another family', async () => {
    await assertFails(
      setDoc(
        doc(as(ERIN), `families/${FAM_B}/starterPackItems/dinner`),
        item(ERIN),
      ),
    );
  });

  it('denies a line the template shape check refuses', async () => {
    await assertFails(
      setDoc(doc(as(ALICE), itemPath()), item(ALICE, { nameBn: '' })),
    );
  });

  it('lets any active member read a line', async () => {
    await seedItem();
    await assertSucceeds(getDoc(doc(as(CARA), itemPath())));
  });

  it('allows a manager to delete a line, but not a plain member', async () => {
    await seedItem();
    await assertFails(deleteDoc(doc(as(CARA), itemPath())));
    await assertSucceeds(deleteDoc(doc(as(BOB), itemPath())));
  });
});
