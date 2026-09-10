# Tamarin tutorial participant exercise

The 20-minute take-home exercise for *Soundness Is Not Security: Layered Verification of BPMN Collaborations with the Tamarin Prover*, at the Alpine Verification Meeting 2026 (AVM'26).

Martin Farkas (presenter) and Imre Kocsis, Critical Systems Research Group, Budapest University of Technology and Economics.

Write an authenticated channel for the collaboration from the lecture. The process layer and security lemmas are provided; you complete two channel rules.

The [tutorial repository](https://github.com/BlackLight54/avn-tamarin-tutorial) contains the slides, lecture models, and full results matrix. This repository contains everything needed to run the exercise independently.

## Requirements

Use either Docker or a local Tamarin installation:

- Docker. The runner uses `lmandrelli/tamarin-prover:1.10.0` and pulls it on first use.
- A local `tamarin-prover` 1.8 or newer with Maude on your `PATH`. See the [Tamarin installation instructions](https://tamarin-prover.com/install.html).

The exercise was checked with Tamarin 1.10.0.

## Quick start

```sh
git clone https://github.com/BlackLight54/avn-tamarin-tutorial-excercise
cd avn-tamarin-tutorial-excercise
scripts/check-exercise.sh
```

As shipped, the skeleton delivers nothing. The sanity lemma `delivery_works` is falsified, while every safety lemma is verified vacuously. This is the expected starting point, and the checker marks the differences from a working channel.

## The exercise

1. Open `exercise/mychannel.spthy` and read the three requirements at the top.
2. Before writing anything, predict the six-cell column for a dishonest coordinator and write it down.
3. Uncomment and complete the two channel rules.
4. Run `scripts/check-exercise.sh`. It prints your column next to the expected one.

V means verified; F means falsified with a concrete attack trace. The full prover output is in `results/exercise.log`.

To invoke the prover directly:

```sh
scripts/tamarin --prove -D=ADV_A exercise/exercise.spthy
```

For proof trees and attack graphs, run the interactive GUI with a local installation:

```sh
tamarin-prover interactive -D=ADV_A exercise/
```

## What is here

| Path | Purpose |
|---|---|
| `exercise/mychannel.spthy` | The channel skeleton to complete |
| `exercise/exercise.spthy` | Entry point, delivery sanity check, and security lemmas |
| `exercise/solution/mychannel.spthy` | Reference solution for the authenticated channel |
| `model/process.spthy` | The three-pool process from the lecture |
| `model/channels/piLCcrypto.spthy` | Reference solution for the signature-based stretch goal |
| `scripts/check-exercise.sh` | Compare the exercise results with the expected column |
| `scripts/tamarin` | Run Tamarin locally or through Docker |

## The lemmas

| | Name | Meaning |
|---|---|---|
| Sanity | `delivery_works` | At least one message from A can reach B |
| G1 | `no_bifurcation` | Two mutually exclusive messages are never both received in one instance |
| G2 | `non_repudiation` | A message attributed to a pool was sent by that pool |
| G3 | `faithful_history` | Whoever sent a message executed its process up to that point |
| G4 | `authorized_progression` | Nobody advances on a message nobody sent |
| G7 | `instance_isolation` | A message received in an instance was sent in that instance |
| G6a | `value_secrecy` | The network adversary never learns a payload |

## Reference solution and stretch goal

Compare your rules with `exercise/solution/mychannel.spthy`, or check the reference solution without overwriting your work:

```sh
scripts/check-exercise.sh --solution
```

Stretch goal: realize the channel with signatures instead of an ideal fact and re-check. The reference is `model/channels/piLCcrypto.spthy`. To try it, replace the contents of `exercise/mychannel.spthy` with that file, including its adversary rule, and run the checker again.

## License

MIT, see [LICENSE](LICENSE). Extracted from the [tutorial repository](https://github.com/BlackLight54/avn-tamarin-tutorial).
