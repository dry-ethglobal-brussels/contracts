import { NGROK_URL } from "./constants";

// deploy smart account ancd module with mock verifier
// send request fake proofs and signers

function signTest1() {
	const request = {
		account: "0x1234567890123456789012345678901234567891",
		signer: "0xSigner2",
		proof: "0xProof2",
		txData: {
			to: "0x1234567890123456789012345678901234567890",
			value: "0x00",
			data: "0x00",
		},
	};

	const requestOptions = {
		method: "POST",
		headers: { "Content-Type": "application/json" },
		body: JSON.stringify(request),
	};

	fetch(NGROK_URL + "/sign", requestOptions)
		.then((response) => response.json())
		.then((data) => console.log(data));
}

signTest1();
