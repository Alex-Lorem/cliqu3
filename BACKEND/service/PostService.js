const Token = require("./Token.js")
const contract = require("../ethereum/contract.js")


class PostService {


    async verifyAddress(address) {
        const isPresent = await Token.get_tokens_id_by_address(address)
        return isPresent === null;
    }

    async checkOwnerAndGetTokenView(address, tokenID) {

        let token = await Token.get_tokens_by_two_parameters('wallet', address, 'tokenId', tokenID)

        if (token === null) {
            throw new Error('3')
        }

        return token[0].view
    }

    async recoverTokens(array, address) {
        for (let tokenID of array) {
                const res = await Token.update_field_by_tokenId(tokenID, "wallet", address)

                if (!res) {

                    try{
                        const upgraded = await contract.functions.upgradeable(tokenID)

                        if(upgraded){
                            await Token.create_token(tokenID, address, 1, true)
                        } else {
                            await Token.create_token(tokenID, address, 0, false)
                        }
                    } catch (e) {
                        await Token.create_token(tokenID, address, 0, false)
                    }

                    await Token.update_field_by_tokenId(tokenID, "recovered", true)
                }

        }
    }

    async getTokensIdForInventory(address) {
        return await Token.get_tokens_id_by_address(address);
    }

}

module.exports = new PostService();
