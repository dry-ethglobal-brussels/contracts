import express from "express";
import { addMapping, getMapping } from "./merkle";
import {
	executeFromValidator,
	getExecHash,
	isRequestExecutable,
} from "./utils";
import { addSignData, getSignData } from "./signData";

const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

app.post("/sign", async (req, res) => {
	const {
		account,
		signer,
		proof,
		txData: { to, value, data },
	} = req.body;
	console.log("account: ", account);
	console.log("signer: ", signer);
	console.log("to: ", to);
	console.log("value: ", value);
	console.log("data: ", data);
	console.log("proof: ", proof);

	const execHash = await getExecHash(account, to, value, data);
	// const isExecutable = await isRequestExecutable(account, execHash);
	const isExecutable = true;

	if (isExecutable) {
		// put pending proofs into array and reconstruct data to broadcast
		const signData = await getSignData(account, execHash);
		console.log("signData: ", signData);
		let proofArray: string[] = [];
		if (signData) {
			let { proofs } = signData;
			proofArray.push(...proofs);
		}
		proofArray.push(proof);

		const tx = {
			to,
			value,
			data,
		};

		try {
			console.log("executeFromValidator...");
			const response = await executeFromValidator(account, tx, proofArray);
			console.log("response: ", response);
			res.send({ success: true, transactionHash: response.hash });
		} catch (error: any) {
			console.error("Error sending transaction:", error);
			res.status(500).send({ success: false, error: error.message });
		}
	} else {
		// add to pending requests
		await addSignData(account, execHash, signer, proof, { to, value, data });
	}
});

app.listen(port, () => {
	console.log(`Relayer server listening on port ${port}`);
});

app.post("/addMapping", async (req, res) => {
	try {
		const { key, values } = req.body;
		const result = await addMapping(key, values);
		res.send({ success: true, result });
	} catch (error: any) {
		res.status(500).send({ success: false, error: error.message });
	}
});

// index.ts
app.get("/getMapping/:key", async (req, res) => {
	try {
		const key = req.params.key;
		const values = await getMapping(key); // This function should fetch data based on `key`
		res.json({ success: true, values });
	} catch (error: any) {
		console.error("Error fetching mapping:", error);
		res.status(500).json({ success: false, error: error.message });
	}
});
