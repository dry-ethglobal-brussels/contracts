// function storeMerkle(key: string, values: string[]) {
//   fetch("http://localhost:3000/addMapping", {
//     method: "POST",
//     headers: { "Content-Type": "application/json" },
//     body: JSON.stringify({ key, values }),
//   });
// }
function storeMerkle(key: string, values: string[]) {
  fetch("http://localhost:3000/addMapping", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ key, values }),
  })
    .then((response) => response.json()) // Convert the response to JSON
    .then((data) => {
      console.log("Response from server:", data);
    })
    .catch((error) => {
      console.error("Error posting data:", error);
    });
}

const values = [
  "0x1234567890123456789012345678901234567891",
  "0x1234567890123456789012345678901234567892",
];

storeMerkle("0x1234567890123456789012345678901234567891", values);
