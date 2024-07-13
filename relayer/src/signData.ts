import sqlite3 from "sqlite3";

// Use the same `data.db` for both purposes
const db = new sqlite3.Database("./data.db", (err) => {
	if (err) {
		console.error("Error opening database", err);
	} else {
		console.log("Connected to the SQLite database: SingData");
		// Ensure the necessary table for signData is created
		db.run(
			"CREATE TABLE IF NOT EXISTS sign_data (key TEXT PRIMARY KEY, value TEXT)",
			(err) => {
				if (err) console.error("Error creating table", err);
			}
		);
	}
});

// Function to initialize the sign_data table
export type SignData = {
	signers: string[];
	proofs: string[];
	txData: {
		to: string;
		value: string;
		data: string;
	};
};

export type AccountExecHashToSignDataMap = {
	[hash: string]: SignData;
};

export async function addSignData(
	account: string,
	execHash: string,
	signer: string,
	proof: string,
	txData: { to: string; value: string; data: string }
) {
	const key = `${account}_${execHash}`;
	console.log(key);

	db.get(
		"SELECT value FROM sign_data WHERE key = ?",
		[key],
		(err, row: any) => {
			if (err) {
				console.error(err.message);
				return;
			}
			console.log("row: ", row);

			let signData: SignData;
			if (row) {
				signData = JSON.parse(row.value);
				if (
					signData.signers.includes(signer) ||
					signData.proofs.includes(proof)
				) {
					console.log("signer already exists");
				} else {
					signData.signers.push(signer);
					signData.proofs.push(proof);
				}
			} else {
				signData = {
					signers: [signer],
					proofs: [proof],
					txData,
				};
			}

			console.log("signData: ", signData);

			const value = JSON.stringify(signData);

			db.run(
				"INSERT OR REPLACE INTO sign_data (key, value) VALUES (?, ?)",
				[key, value],
				function (err) {
					if (err) {
						console.error(err.message);
					} else {
						console.log(`Data has been updated with rowid ${this.lastID}`);
					}
				}
			);
		}
	);
}

export function getSignData(
	account: string,
	execHash: string
): Promise<SignData | null> {
	return new Promise((resolve, reject) => {
		const key = `${account}_${execHash}`;

		db.get(
			"SELECT value FROM sign_data WHERE key = ?",
			[key],
			(err, row: string) => {
				if (err) {
					reject(err.message);
					return;
				}

				if (row) {
					const signData: SignData = JSON.parse(row);
					resolve(signData);
				} else {
					resolve(null); // Or you could resolve an empty SignData object if that suits your logic better
				}
			}
		);
	});
}

// async function addSignData(
// 	account: string,
// 	execHash: string,
// 	signer: string,
// 	proof: string,
// 	txData: { to: string; value: string; data: string }
// ) {
// 	const key = `${account}_${execHash}`;
// 	// get existing data
// 	const value = JSON.stringify({ signer, proof, txData });

// 	db.run(
// 		`INSERT INTO sign_data (key, value) VALUES (?, ?)`,
// 		[key, value],
// 		function (err) {
// 			if (err) {
// 				return console.log(err.message);
// 			}
// 			console.log(`A row has been inserted with rowid ${this.lastID}`);
// 		}
// 	);
// }

// export type ExecuHashToSignerMap = {
// 	[execHash: string]: SignData;
// };

// export type AccountMap = {
// 	[address: string]: ExecuHashToSignerMap;
// };
