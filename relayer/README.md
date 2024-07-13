# Relayer

## run relayer server

add your private key to `.env`

```shell
npx ts-node src/index.ts
```

we use ngrok, get your auth-token [here](https://dashboard.ngrok.com/get-started/your-authtoken)

```shell
ngrok config add-authtoken <your-ngrok-authtoken>
```

```shell
ngrok http 3000
```

upadte `NGROK_URL` in `test/constants.ts`

### test

```shell
ts-node test/sendTx.ts
```

```shell
ts-node test/merkle_add.ts
```

```shell
ts-node test/merkle_get.ts
```
