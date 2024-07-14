import {
	ENTRYPOINT_ADDRESS_V07,
	createSmartAccountClient,
	bundlerActions,
} from "permissionless";
import { signerToSafeSmartAccount } from "permissionless/accounts";
import { createPimlicoBundlerClient } from "permissionless/clients/pimlico";
import { PublicClient, createPublicClient, encodePacked, http } from "viem";
import { sepolia } from "viem/chains";
import { privateKeyToAccount } from "viem/accounts";
import { erc7579Actions } from "permissionless/actions/erc7579";
import { pimlicoBundlerActions } from "permissionless/actions/pimlico";
import * as dotenv from "dotenv";
import { ethers } from "ethers";
dotenv.config();

export const publicClient: PublicClient = createPublicClient({
	transport: http("https://rpc.ankr.com/eth_sepolia"),
});

const PIMLICO_URL = ("https://api.pimlico.io/v2/sepolia/rpc?apikey=" +
	process.env.PIMLICO_API_KEY) as string;

export const pimlicoBundlerClient = createPimlicoBundlerClient({
	transport: http(PIMLICO_URL),
	entryPoint: ENTRYPOINT_ADDRESS_V07,
})
	.extend(bundlerActions(ENTRYPOINT_ADDRESS_V07))
	.extend(pimlicoBundlerActions(ENTRYPOINT_ADDRESS_V07));

const signer = privateKeyToAccount(process.env.PRIVATE_KEY as `0x${string}`);
const executorAddress = "0x082964A9C93d8261e7a34cEfAA11d0FdA0fedC15";

async function main() {
	console.log("signer: ", signer.address);
	const safeAccount = await signerToSafeSmartAccount(publicClient, {
		entryPoint: ENTRYPOINT_ADDRESS_V07,
		signer: signer,
		safeVersion: "1.4.1",
		safe4337ModuleAddress: "0x3Fdb5BC686e861480ef99A6E3FaAe03c0b9F32e2",
		erc7579LaunchpadAddress: "0xEBe001b3D534B9B6E2500FB78E67a1A137f561CE",
	});

	const smartAccountClient = createSmartAccountClient({
		account: safeAccount,
		entryPoint: ENTRYPOINT_ADDRESS_V07,
		chain: sepolia,
		bundlerTransport: http(PIMLICO_URL),
		middleware: {
			gasPrice: async () =>
				(await pimlicoBundlerClient.getUserOperationGasPrice()).fast, // if using pimlico bundler
		},
	}).extend(erc7579Actions({ entryPoint: ENTRYPOINT_ADDRESS_V07 }));

	const encoder = new ethers.AbiCoder();
	const data = encoder.encode(
		["bytes", "bytes32", "uint256"],
		[
			"0x00",
			"0x15c8b2dc36f64e3ad22a0febb4f662732f40f3307ae6a151fcd49a9511ccf21a",
			1n,
		]
	);
	console.log(data);

	const opHash = await smartAccountClient.installModule({
		type: "executor",
		address: executorAddress,
		context: data as `0x${string}`,
	});

	console.log("opHash: ", opHash);

	const isInstalled = await smartAccountClient.isModuleInstalled({
		type: "executor",
		address: executorAddress,
		context: "0x",
	});

	console.log(isInstalled);
}

main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});
