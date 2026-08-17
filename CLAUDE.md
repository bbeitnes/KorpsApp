# KorpsApp

## Branches and deploys

**Every push to `main` goes straight to production, for all three customers.**
There is no staging step between the two. `main` is not a place to try things.

| Branch | Workflow | Where it lands |
|---|---|---|
| `test` | `deploy-test.yml` | https://beitnes.net/Korpsapp-test |
| `main` | `deploy.yml`, `deploy-kvinner-i-kor.yml`, `deploy-musikkforeningen-suoni.yml`, GitHub Pages | Production, all customers |

So the flow is **feature branch → `test` → verify in the test environment →
`main`**:

1. Branch off `test`.
2. Open the pull request **against `test`**, not `main`. GitHub defaults the
   base to `main` because that is the default branch — change it every time.
3. Merge to `test`, then check the change on
   https://beitnes.net/Korpsapp-test. This is the point of the whole flow;
   skipping it makes `test` a formality.
4. Only once it is verified, merge `test` into `main` to release.

The kanban columns mirror these steps — `3-review/` means "on `test`, awaiting
verification", `4-done/` means "merged to `main`". See the `kanban` skill.

Both `test` and `main` are permanent environment branches. Never delete either,
and do not force-push them.

### Going straight to `main`

Only for changes that cannot be verified on the test site anyway — a README, a
kanban card, a workflow file. Say so explicitly when you do it, and say that it
deploys to production. If in doubt, use `test`.

## Customer configuration

`config/` holds one file per customer, and each deploy workflow copies its own
customer's file to `config.js` and deletes the rest before uploading — the SFTP
step uploads `./*`, so anything left in `config/` would publish one customer's
setup onto another customer's host. Keep that copy-then-remove step intact when
touching a deploy workflow.
