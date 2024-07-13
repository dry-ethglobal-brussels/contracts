import express from "express";
import * as ethers from "ethers";
import * as dotenv from "dotenv";
import { addMapping, getMapping } from "./merkle";
dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

// Using ethers.js to connect to Ethereum
const provider = new ethers.JsonRpcProvider(process.env.ETH_NODE_URL);
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY as string, provider);

app.use(express.json());

app.post("/relay", async (req, res) => {
  const { to, value, data } = req.body;

  try {
    const tx = {
      to,
      value: ethers.parseEther(value),
      data,
    };

    const response = await wallet.sendTransaction(tx);
    res.send({ success: true, transactionHash: response.hash });
  } catch (error: any) {
    console.error("Error sending transaction:", error);
    res.status(500).send({ success: false, error: error.message });
  }
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

app.listen(port, () => {
  console.log(`Relayer server listening on port ${port}`);
});
