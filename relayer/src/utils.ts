// jq '.abi' out/P256MultiSigExecutor.sol/P256MultiSigExecutor.json > relayer/sr/abis/P256MultiSigExecutorAbi.json
import p256MultiSigExecutorABI from "./abis/P256MultiSigExecutorAbi.json";
import * as ethers from "ethers";
import * as dotenv from "dotenv";
dotenv.config();

export const provider = new ethers.JsonRpcProvider(process.env.ETH_NODE_URL);
export const wallet = new ethers.Wallet(
	process.env.PRIVATE_KEY as string,
	provider
);

const abiCoder = new ethers.AbiCoder();

const p256MultiSigExecutorAddress =
	"0x1234567890123456789012345678901234567890";

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
	const proofData = ethers.solidityPacked(["bytes[]"], proofs);

	const tx = await p256MultiSigExecutor.execute(
		account,
		txData.to,
		txData.value,
		txData.data,
		proofData
	);

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
