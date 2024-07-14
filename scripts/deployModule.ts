import * as ethers from "ethers";
import UltraVerifierAbi from "./contracts/UltraVerifierAbi.json";
import UltraVerifierAbiBytecode from "./contracts/UltraVerifierAbiBytecode.json";
import P256MultiSigExecutorAbi from "./contracts/P256MultiSigExecutorAbi.json";
import P256MultiSigExecutorBytecode from "./contracts/P256MultiSigExecutorBytecode.json";

import dotenv from "dotenv";
dotenv.config();

// jq '.abi' out/P256MultiSigExecutor.sol/P256MultiSigExecutor.json > scripts/contracts/P256MultiSigExecutorAbi.json
// jq '.bytecode' out/P256MultiSigExecutor.sol/P256MultiSigExecutor.json > scripts/contracts/P256MultiSigExecutorBytecode.json

// jq '.abi' out/plonk_vk.sol/UltraVerifier.json > scripts/contracts/UltraVerifierAbi.json
// jq '.bytecode' out/plonk_vk.sol/UltraVerifier.json > scripts/contracts/UltraVerifierAbiBytecode.json

const NETWORKS = ["sepolia", "polygon", "base", "arbitrum", "scroll_alpha"];
const RPC_URLS = [
	// process.env.SEPOLIA_RPC_URL as string,
	// process.env.POLYGON_RPC_URL as string,
	// process.env.BASE_RPC_URL as string,
	// process.env.ARBITRUM_RPC_URL as string,
	"https://sepolia-rpc.scroll.io",
];

async function deploy() {
	const deployerPrivateKey = process.env.PRIVATE_KEY;
	if (!deployerPrivateKey) {
		throw new Error("PRIVATE_KEY not set");
	}

	for (let i = 0; i < RPC_URLS.length; i++) {
		console.log("newtork:", NETWORKS[i]);
		const provider = new ethers.JsonRpcProvider(RPC_URLS[i]);
		const deployer = new ethers.Wallet(deployerPrivateKey, provider);

		const verifierFactory = new ethers.ContractFactory(
			UltraVerifierAbi,
			UltraVerifierAbiBytecode,
			deployer
		);

		const moduleFactory = new ethers.ContractFactory(
			P256MultiSigExecutorAbi,
			P256MultiSigExecutorBytecode,
			deployer
		);

		const verifier = await verifierFactory.deploy();
		console.log("verifier deployed to:", verifier);

		const contract = await moduleFactory.deploy(verifier);
		console.log("contract deployed to:", contract);
	}
}

deploy().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});

// sepolia
// verifier: 0x91cf2e8b57790b6a6533f47df5323db7c4dc98a9
// module: 0x082964A9C93d8261e7a34cEfAA11d0FdA0fedC15

// polygon
// verifier: 0xd32204301d34bbc6528c61ac020f4beb4c079fce
// module: 0x5dceacfc4ff52849e1ebc5fb5162e09162b26bc3

// base
// verifier: 0x5dceacfc4ff52849e1ebc5fb5162e09162b26bc3
// module: 0xb60d7f7ec0a92da8deb34e8255c31ace45faedf4

// arbitrum
// verifier: 0xd32204301d34bbc6528c61ac020f4beb4c079fce
// module: 0x5dceacfc4ff52849e1ebc5fb5162e09162b26bc3

// scroll sepolia
// verifier: 0x356fccd97b3d5145eac952ccfcf692ebd6bab3f9
// module: 0xdd778234147cd03c20e9ad4d236a57674bd8ece8
