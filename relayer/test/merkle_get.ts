function getMerkle(key: string) {
  fetch(`http://localhost:3000/getMapping/${key}`)
    .then((response) => {
      if (!response.ok) {
        return response.text().then((text) => {
          throw new Error(`Network response was not ok: ${text}`);
        });
      }
      return response.json();
    })
    .then((data) => console.log(data))
    .catch((error) =>
      console.error("There was a problem with the fetch operation:", error)
    );
}

getMerkle("0x1234567890123456789012345678901234567890");
