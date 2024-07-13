import { NGROK_URL } from "./constants";

function sendTransaction(to: string, value: string, data: string) {
  const requestOptions = {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ to, value, data }),
  };

  fetch(NGROK_URL + "/relay", requestOptions)
    .then((response) => response.json())
    .then((data) => console.log(data));
}

sendTransaction("0x1234567890123456789012345678901234567890", "0.0001", "0x");
