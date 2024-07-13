// merkle.ts
import sqlite3 from "sqlite3";
import { DatabaseRow } from "./interfaces";

const db = new sqlite3.Database("./data.db", (err) => {
	if (err) {
		console.error("Error opening database", err);
	} else {
		console.log("Connected to the SQLite database: Merkle");
		db.run(
			'CREATE TABLE IF NOT EXISTS mappings (key TEXT UNIQUE, "values" TEXT)', // Escape 'values' correctly
			(err) => {
				if (err) console.error("Error creating table", err);
			}
		);
	}
});

export const addMapping = (key: string, values: string[]) => {
	return new Promise((resolve, reject) => {
		const valuesString = JSON.stringify(values);
		db.run(
			`INSERT INTO mappings(key, "values") VALUES(?, ?)`, // Note the quotes around 'values'
			[key, valuesString],
			function (err) {
				if (err) reject(err);
				else resolve(this.lastID);
			}
		);
	});
};

export const getMapping = (key: string): Promise<string[]> => {
	return new Promise((resolve, reject) => {
		const query = `SELECT "values" FROM mappings WHERE key = ?`;
		db.get(query, [key], (err, row: DatabaseRow | undefined) => {
			if (err) {
				console.error(
					"Failed to execute query:",
					query,
					"with key:",
					key,
					"Error:",
					err
				);
				reject(err);
			} else if (row) {
				try {
					resolve(JSON.parse(row.values));
				} catch (jsonError) {
					console.error("JSON parsing error:", jsonError);
					reject("Failed to parse JSON data.");
				}
			} else {
				reject("Key not found");
			}
		});
	});
};
