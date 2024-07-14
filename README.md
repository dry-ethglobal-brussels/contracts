## ERC4337 P256-Multisig module

### deployed contracts onn testnets

| network                                   | verifier                                   | module                                     |
| ----------------------------------------- | ------------------------------------------ | ------------------------------------------ |
| [sepolia](https://sepolia.etherscan.io/)  | 0x91cf2e8b57790b6a6533f47df5323db7c4dc98a9 | 0x082964A9C93d8261e7a34cEfAA11d0FdA0fedC15 |
| [polygon](https://amoy.polygonscan.com/)  | 0xd32204301d34bbc6528c61ac020f4beb4c079fce | 0x5dceacfc4ff52849e1ebc5fb5162e09162b26bc3 |
| [base](https://sepolia.basescan.org/)     | 0x5dceacfc4ff52849e1ebc5fb5162e09162b26bc3 | 0xb60d7f7ec0a92da8deb34e8255c31ace45faedf4 |
| [arbitrum](https://sepolia.arbiscan.io/)  | 0xd32204301d34bbc6528c61ac020f4beb4c079fce | 0x5dceacfc4ff52849e1ebc5fb5162e09162b26bc3 |
| [scroll](https://sepolia.scrollscan.dev/) | 0x356fccd97b3d5145eac952ccfcf692ebd6bab3f9 | 0xdd778234147cd03c20e9ad4d236a57674bd8ece8 |

you can check Safe's singleton and factory addresses deployed on each network [here](https://github.com/safe-global/safe-deployments)

## development

install dependencies

```shell
yarn
```

build contracts

```shell
yarn build
```

test contracts

```shell
yarn test
```

deploy contracts and install modules

```shell
ts-node scripts/deployModule.ts
ts-node scripts/installModule.ts
```
