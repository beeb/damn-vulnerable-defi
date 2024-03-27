## Damn Vulnerable DeFi

[Official Website](https://www.damnvulnerabledefi.xyz/)

Run `forge install` to get the standard library and dependencies.

To solve a puzzle, copy the relevant contracts from
[the official repo](https://github.com/tinchoabbate/damn-vulnerable-defi/tree/v3.0.0/contracts) into the `src`
directory.

Then, create a new test file in the `test` directory and translate the setup from the
[official tests](https://github.com/tinchoabbate/damn-vulnerable-defi/tree/v3.0.0/test).

The test contract should inherit from the `test/utils/Fixtures.sol:BaseFixture` contract so that the `deployer`,
`player` and `someUser` addresses are available for the setup.

Finally, run the tests with:

```
forge test -vvv
```
