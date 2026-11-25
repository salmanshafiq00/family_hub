# 0020 - Push sending is deferred on Spark; Cloud Functions on Blaze is a future option (D-P4-21)

**Status:** **Spark chosen; push sender deferred** (owner decision,
2026-11-06). No sender is deployed or required. Every notification type
effectively remains Normal (ADR 0015); the client-side choice and receive path
stay dormant until a sender is selected. Sender options and prerequisites are
summarised below.
This decision backs CLAUDE.md rules 74 and 75.

**Context (F-6, F-21).** Receiving FCM is free, but *sending* needs a trusted
server that holds a service account and calls the HTTP v1 API. The legacy
server-key API is shut down, so a phone cannot safely push to another phone. The
only first-party server on Firebase is Cloud Functions, which needs the **Blaze**
plan (a billing account with a payment method). Blaze has no automatic spending
cap, whereas Spark simply stops at its quota. The family currently runs on Spark
for everything.

**Alternatives considered.**

1. **No push.** Spark only; a swap request or a reassigned chore is learned when
   the app opens, as in Phase 3. Free and simple, but it is the weakest part of
   the product for time-sensitive changes. This stays the fallback for every
   family and every type.
2. **A third-party push relay** (a hosted service that stores the service account
   and exposes a send API). Needs no Blaze, but moves a credential that can
   message every device to a company outside the project, adds an account, a
   privacy review and another point of failure, and the client would still have to
   trigger it, which a member could abuse.
3. **A self-hosted sender** (a small always-on server or home machine). Avoids
   billing, but someone must run, patch and secure it, it must hold the service
   account, and a family app should not depend on a server that sleeps.
4. **Cloud Functions on Blaze (deferred option).** The service account never leaves
   Google; the trigger is a Firestore write that already happens (`notificationInbox`
   create, and a pending `members` create), so the app's write path does not
   change (D-P4-22); one policy document gates every send; cost for one family is
   expected to stay inside the free tier **[VERIFY]**.

**Decision.**
- Remain on Spark. Do not build or deploy a sender in the current Phase 4 plan.
  The FCM client can receive Firebase-console test messages; automated push
  sending remains deferred.
- If push sending is reconsidered, choose an Appendix I option and complete its
  billing/security prerequisites before implementing or deploying it.

The requirements above are design constraints for a future sender, not
implemented behavior. If a sender is selected, it must keep credentials
server-side, honor the saved delivery policy, and carry no personal names,
amounts, or person ids in push payloads (CLAUDE.md rules 74-75).

**Consequences.** No billing account or service credential is required for the
current Spark-only plan. P4-15 and the optional P4-26 are deferred; P4-16 and
other Normal delivery behavior remain available. The app keeps
`FeatureFlags.pushBackend` false until a sender exists.
