// jq '.abi' out/P256MultiSigExecutor.sol/P256MultiSigExecutor.json > relayer/sr/abis/P256MultiSigExecutorAbi.json
import p256MultiSigExecutorABI from "./abis/P256MultiSigExecutorAbi.json";
import UltraVerifierABI from "./abis/UltraVerifierAbi.json";
import * as ethers from "ethers";
import * as dotenv from "dotenv";
dotenv.config();

export const provider = new ethers.JsonRpcProvider(process.env.ETH_NODE_URL);
export const wallet = new ethers.Wallet(
	process.env.PRIVATE_KEY as string,
	provider
);

const abiCoder = new ethers.AbiCoder();

const verifierAddress = "0x49118cD82280580b074b8d961a3243E03Dc42f15";
const p256MultiSigExecutorAddress =
	"0x1106BfA02614A4D9a514a545d3Aa7E5fd3Dbc9F4";

const ultraVerifier = new ethers.Contract(
	verifierAddress,
	UltraVerifierABI,
	wallet
);

const p256MultiSigExecutor = new ethers.Contract(
	p256MultiSigExecutorAddress,
	p256MultiSigExecutorABI,
	wallet
);

export const isRequestExecutable = async (
	account: string,
	execHash: string
): Promise<boolean> => {
	const approvalCount = await getApprovalCount(account, execHash);
	const multisigConfig = await getMultisigConfig(account);

	return approvalCount + 1 >= multisigConfig;
};

const getApprovalCount = async (
	account: string,
	execHash: string
): Promise<number> => {
	const approvalCount = await p256MultiSigExecutor.getCurrentApprovalCount(
		account,
		execHash
	);
	return approvalCount.toNumber();
};

const getMultisigConfig = async (account: string): Promise<number> => {
	const multisigConfig = await p256MultiSigExecutor.getMultisigConfig(account);
	return multisigConfig.threshold.toNumber();
};

export const executeFromValidator = async (
	account: string,
	txData: { to: string; value: string; data: string },
	proofs: string[]
): Promise<ethers.TransactionReceipt> => {
	const _proofs = proofs.map((proof) => "0x" + proof);

	console.log("proofs before	 encoding ", proofs);
	const encoder = new ethers.AbiCoder();
	const proofData = encoder.encode(["bytes[]"], [_proofs]);
	console.log("proofData: ", proofData);

	const config = await p256MultiSigExecutor.getMultisigConfig(account);
	console.log("config: ", config);
	const execHash = ethers.keccak256(
		abiCoder.encode(
			["address", "address", "uint256", "bytes", "uint256"],
			[account, txData.to, BigInt(txData.value), txData.data, "11155111"]
		)
	);
	console.log("execHash: ", execHash);
	const root = config[0];
	console.log("root: ", root);
	const publicInputs = expandTwoBytes32(ethers.sha256(execHash), root);
	console.log("publicInputs: ", publicInputs);

	const ret = await ultraVerifier.verify("0x" + proofs[0], publicInputs);
	console.log("ret: ", ret);

	const tx = await p256MultiSigExecutor.execute(
		account,
		txData.to,
		BigInt(txData.value),
		txData.data,
		proofData,
		{
			gasLimit: "1100000",
		}
	);

	console.log("tx hash: ", tx.hash);

	return await tx.wait();
};

export const getExecHash = async (
	account: string,
	to: string,
	value: string,
	data: string
): Promise<string> => {
	const chainId = await getChainId();
	return ethers.keccak256(
		abiCoder.encode(
			["address", "address", "uint", "bytes", "uint256"],
			[account, to, value, data, chainId.toString()]
		)
	);
};

export const getChainId = async (): Promise<number> => {
	return Number(await provider.getNetwork().then((network) => network.chainId));
};

function expandTwoBytes32(data1: string, data2: string): string[] {
	// Ensure both inputs are properly formatted as bytes32 hex strings
	if (data1.length !== 66 || data2.length !== 66) {
		throw new Error("Each input must be a bytes32.");
	}

	let expanded: string[] = new Array(64);
	for (let i = 2; i <= 64; i += 2) {
		// Start at 2 to skip '0x', iterate by 2 for each byte
		// Process first bytes32
		// Extract a byte, pad it to bytes32, and store in the array
		let byteIndex = (i - 2) / 2;
		let temp1 = "0x" + data1.substring(i, i + 2).padStart(64, "0");
		expanded[byteIndex] = temp1;

		// Process second bytes32
		let temp2 = "0x" + data2.substring(i, i + 2).padStart(64, "0");
		expanded[byteIndex + 32] = temp2;
	}
	return expanded;
}
