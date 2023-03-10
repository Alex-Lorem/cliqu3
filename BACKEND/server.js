require("dotenv").config();
const express = require("express")
const cors = require('cors')

const PostController = require("./service/PostController.js");
const Authentification = require("./service/Authentification.js")
const listening = require("./ethereum/listening")
const path = require('path');
global.root = path.resolve(__dirname);

const PORT = 5000;

const app = express()

app.use(express.json())
app.use(cors())



app.get('/get-upgraded-image/', async (req, res,) => {
    if (await Authentification.verify(req, res)) {
        await PostController.getUpgradedImage(req, res)
    }
})

app.get('/retrieve-tokens-for-wallet/', async (req, res,) => {
    await PostController.retrieveTokensForWallet(req, res)
})

app.get('/image-for-inventory/', async (req, res) => {
    if (await Authentification.verify(req, res)) {
        await PostController.getImageForInventory(req, res)
    }
})

app.get('/tokens-for-inventory/', async (req, res) => {
    if (await Authentification.verify(req, res)) {
        await PostController.getTokensIdForInventory(req, res)
    }
})


async function startApp() {
    try {

        app.listen(PORT,() => console.log('SERVER STARTED ON PORT http://localhost:' + PORT))
        app.keepAliveTimeout = 10000;

        await listening


    } catch (e) {
        console.log(e)
    }

}

startApp()

