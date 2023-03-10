const path = require('path')
const PostService = require("./PostService.js")
const contract = require("../ethereum/contract.js")
const ethers = require("ethers")
const { getVerifiedAddress } = require('./Authentification.js')
const{ Alchemy, Network } = require("alchemy-sdk")

// ERRORS CODE
// 0 - smthg went wrong (500)
// 1 - bad request
// 2 - animation can be played once
// 3 - invalid owner for token
// 4 - doesn't seem that you have tokens
// 5 - firstly change your view to upgraded

class PostController {


    async getUpgradedImage(req, res) {
        try {
            const tokenID = parseInt(req.headers.number)
            const view = await PostService.checkOwnerAndGetTokenView(getVerifiedAddress(), tokenID)
            if(view === 1){
                let pathTo = path.join(root, 'nfts', 'inventory', '1', tokenID.toString() + '.gif')
                res.setHeader('Cache-Control', 'private, max-age=400000')
                res.sendFile(pathTo)
            } else {
                throw new Error('5')
            }
        } catch (e) {
            let message = 'something went wrong'
            e.status = 0
            if (e.message === '5') {
                message = 'firstly change your view to upgraded'
                e.status = 5
            } else if(e.message === '3'){
                message = 'invalid owner for token'
                e.status = 3
            }
            const err = {
                message: message,
                code: e.status
            }
            res.status(404).json(err)
        }
    }

    async getImageForInventory(req, res) {
        try {
            const tokenID = parseInt(req.headers.number)

             await PostService.checkOwnerAndGetTokenView(getVerifiedAddress(), tokenID)

            let pathTo = path.join(root, 'nfts', 'inventory','0', tokenID.toString() + '.png')

            res.setHeader('Cache-Control', 'private, max-age=400')
            res.sendFile(pathTo)
        } catch (e) {
            let message = 'something went wrong'
            e.status = 0
            if (e.message === '3') {
                message = 'seems you dont have any tokens yet'
                e.status = 3
            }
            const err = {
                message: message,
                code: e.status
            }
            res.status(404).json(err)
        }
    }

    async getTokensIdForInventory(req, res) {
        try {
            let items = await PostService.getTokensIdForInventory(getVerifiedAddress())

            res.json(items)
        } catch (e) {
            res.json(e)
        }

    }

    async retrieveTokensForWallet(req, res){
        try{
            const sign = req.headers.sign
            const address = ethers.utils.verifyMessage(contract.message, sign)
            if(!address){
                throw new Error('1')
            }
            const config = {
                apiKey: `${process.env.ALCHEMY_KEY}`,
                network: Network.ETH_GOERLI,
                //ETH_MAINNET
            };

            const alchemy = new Alchemy(config);
            const allNfts = await alchemy.nft.getNftsForOwner(address);
            const ownedInContract = []
            const contractAddress = contract.address
            for(let item of allNfts.ownedNfts){
                if(item.contract.address === contractAddress.toLowerCase()){
                    ownedInContract.push(parseInt(item.tokenId))
                }
            }
            if(ownedInContract.length === 0){
                throw new Error('3')
            }

            PostService.recoverTokens(ownedInContract, address).then(()=>{
                res.json(200)
            }).catch((e)=>{
                console.log(e);
            })

        } catch (e) {
            console.log(e)
            let message = 'something went wrong'
            e.status = 0
            if (e.message === '1') {
                message = 'bad request'
                e.status = 1
            } else if (e.message === '3') {
                message = 'invalid owner for token'
                e.status = 3
            }
            const err = {
                message: message,
                code: e.status
            }
            res.status(404).json(err)
        }
    }
}

module.exports = new PostController();
