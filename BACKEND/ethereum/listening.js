require("dotenv").config();
const Token = require("../service/Token.js")
const url = `wss://eth-goerli.g.alchemy.com/v2/${process.env.ALCHEMY_KEY}`;
const ethers = require("ethers")
const contract = require("./contract.js")
const EXPECTED_PONG_BACK = 10000
const KEEP_ALIVE_CHECK_INTERVAL = 5000

async function listening() {
    let pingTimeout = null
    let keepAliveInterval = null
    const provider = new ethers.providers.WebSocketProvider(url)
    const listenedContract = new ethers.Contract(contract.address, contract.abi, provider);
    provider._websocket.on('open', () => {
        keepAliveInterval = setInterval(() => {

            provider._websocket.ping()
            pingTimeout = setTimeout(() => {
                provider._websocket.terminate()
            }, EXPECTED_PONG_BACK)
        }, KEEP_ALIVE_CHECK_INTERVAL)


        listenedContract.on("Transfer", async (from, to, tokenID) => {

            tokenID = parseInt(tokenID)
            if (from === '0x0000000000000000000000000000000000000000') {
                let tkn = await Token.is_token_already_existed(tokenID)
                if (!tkn) {
                    await Token.create_token(tokenID, to, 0, false)
                }
            } else {
                const res = await Token.update_field_by_tokenId(tokenID, 'wallet', to)
                if(res === null){
                    try{
                        const upgraded = await contract.functions.upgraded(tokenID)
                        if(upgraded){
                            await Token.create_token(tokenID, to, 1, true)
                        } else {
                            await Token.create_token(tokenID, to, 0, false)
                        }
                    }
                    catch (e) {
                        await Token.create_token(tokenID, to, 0, false)
                    }

                }
            }
        })
        listenedContract.on("ChangeView", async (tokenID, view) => {
            tokenID = parseInt(tokenID)
            view = parseInt(view)
            const res = await Token.update_field_by_tokenId(tokenID, 'view', view)
            if(res === null){
                await Token.create_token(tokenID, "0x", view, false)
            }
        })

        listenedContract.on("Upgraded", async (tokenID) => {
            tokenID = parseInt(tokenID)
            await Token.update_field_by_tokenId(tokenID, 'upgraded', true)
        })

    })

    provider._websocket.on('close', () => {
        console.log('The websocket connection was closed')
        clearInterval(keepAliveInterval)
        clearTimeout(pingTimeout)
        setTimeout(() => {
            listening()
        }, 3000)
    })

    provider._websocket.on('error', () => {
        console.log('error occurred')

    })

    provider._websocket.on('pong', () => {
        clearInterval(pingTimeout)
    })



}

module.exports = listening()
