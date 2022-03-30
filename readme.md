# Development Instructions

1. Start by cloning the urbit/urbit repository from github.
`git clone git@github.com:urbit/urbit.git`

2. Then, change directory to urbit/pkg.
`cd urbit/pkg`

3. Then, add this repository as a submodule. This is necessary to resolve symbolic
links to other desks, such as base-dev and garden-dev.
`git submodule add git@github.com:uqbar-dao/ziggurat.git ziggurat`

4. To boot your development Urbit, run the following command:
`urbit -F zod`

5. To create a `%zig` desk, run
`|merge %zig our %base`

6. To mount the `%zig` desk to the filesystem, run
`|mount %zig`.

7. Next, remove all the files from the zig directory.
`rm -rf zod/zig/*`

8. Now, copy all the files from our ziggurat repository into the `%zig` desk.
`cp -RL urbit/pkg/ziggurat/* zod/zig/`

9. Commit those files into your Urbit.
`|commit %zig`

10. Now, install the desk in your Urbit, which will run the agents.
`|install our %zig`

### To initialize a blockchain:

1. Poke the wallet agent to generate a private key (where 'XXX' is your seed -- keys generated with seeds `0xdead`, `0xbeef`, and `0xcafe` have zigs tokens already in their wallets).
`:wallet &zig-wallet-poke [%set-keys 'XXX']`

2. Start up a blockchain running solely on your ship:
`:ziggurat|start-testnet now`

3. Start up the sequencer agent to run a town on that chain, where 1 here is the town ID.
`:sequencer|init 1`

### To use the wallet

1. Without starting a blockchain, you can populate the wallet with fake data:
`:wallet &zig-wallet-poke [%populate ~]`

2. The scry paths to receive wallet data:
Your address: `.^(@ux %gx /=wallet=/pubkey/noun)`
Your rice: `.^(json %gx /=wallet=/book/json)`
