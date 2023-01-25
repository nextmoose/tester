
When we write stuff in a scratch/* branch no checks are required
We can write anything.

When we attempt to Pull Request into the "main" branch, then we should perform standard checks.
If they are successful then the feature should be merged into the main branch.

If they are unsuccessful then the feature should be blocked from merging into the main branch.

When we are working on the testers.
In a similar way we should attempt to Pull Request into the "main" branch if we think everything is OK.
We are adding a new non-breaking test.
In the future every new PR to the implementation will run this new test.

However if we are introducing a new breaking test.
Then we should Pull Request it to branch "test/XXXXXXX".
We should input an error code.
The checks should fail in exactly the manner predicted by the error code.

If it fails in the exact predicted manner there is a success.
If it fails but not in the exact predicted manner then there is a failure.

We should take note of the relevant commit.  Let us call it COMMIT_ID and the specified failure.

Back to the implementation repo.
We have introduced a failing test to test/XXXXXXXX.
We want to code against that.
But in our branch we want to put the COMMIT_ID and the specified failure.
The checker should run twice
1. against the main branch of the tester.  This should fail with the specified failure.  This counts as a success iff there is a failure with the specified failure.  Any other failure is a failure.
2. against the ${COMMIT_IT}.  This should succeed.
3. The COMMIT_ID has not yet been accepted into the main branch of the testing repo.

If it passes all that, then a Pull Request should be triggered for the COMMIT_ID to be merged into the main branch of the testing repo.
Before that the main branch of the implementation repo has the COMMIT_IT and failure attached to it.  As long as this is on it, either
1. changes do not change this and pass or fail as previously described against both
2. changes change this by erasure and pass or fail without regard to the COMMIT_ID
3. changes change this by change and pass or fail as previously described against a different COMMIT_ID


There are three repos
1. Implementation Repo
2. Tester Repo