const ethers = require("ethers");
const PostService = require("./PostService.js")
const contract = require("../ethereum/contract");
let verifiedAddress = undefined
let methodsWhereNumberNeed = ['image-for-inventory', 'get-upgraded-image']

const verify = async (req, res) => {

    try {


        const sign = req.headers.sign
        let method = req.route.path
        method = method.substring(1, method.length - 1);

            if (await verifyAddress(sign)) {
                throw new Error('4')
            } else {

                if (methodsWhereNumberNeed.includes(method)) {
                    const number = parseInt(req.headers.number)
                    await PostService.checkOwnerAndGetTokenView(getVerifiedAddress(), number)
                    if (isNaN(number) || !(number <= 3333) || number <= 0) {
                        throw new Error('1')
                    }
                }
            }


        return true


    } catch (e) {
        let message;

        if (e.message === '1') {
            e.status = 1
            message = 'bad request'
        } else if (e.message === '4') {
            e.status = 4
            message = 'doesn\'t seem that you have tokens'
        } else if (e.message === '3') {
            e.status = 3
            message = 'invalid owner for token'
        } else {
            e.status = 0
            message = 'something went wrong'

        }
        const err = {
            message: message,
            code: e.status
        }

        res.status(404).json(err)
        return false
    }

}

async function verifyAddress(sign) {
    verifiedAddress = ethers.utils.verifyMessage(contract.message, sign)

    return await PostService.verifyAddress(verifiedAddress)
}

function getVerifiedAddress() {
    return verifiedAddress
}


module.exports = {verify, getVerifiedAddress}
