// const mongoose = require("mongoose")
//
// const Token = new mongoose.Schema({
//     tokenID: {type: Number, required: true},
//     wallet: {type: String, required: true},
//     rarity: {type: String, required: true},
//     view: {type: Number, required: true},
//     upgraded:{type: Boolean, required: true},
//     played: {type: Boolean, required: true},
//     tokensForAnimation: {type: Array, required: true},
//     recovered:{type: Boolean, required: false}
//
// }, {collection: 'tokens'})
//
// module.exports = mongoose.model('tokens', Token);

const Parse = require('parse/node');

Parse.initialize(process.env.PARSE_APP_ID, process.env.PARSE_JS_ID);


Parse.serverURL = 'https://parseapi.back4app.com'


const Token = Parse.Object.extend("tokens", {}, {
    get_tokens_id_by_address: async function (address) {
        try {
            const token = new Token();
            const query = new Parse.Query(token);
            query.equalTo("wallet", address);
            const results = await query.find();

            if (!results.length) {
                return null
            }

            const tokens = []

            for (let object of results) {
                tokens.push({
                    tokenID: object.get('tokenId'),
                    view: object.get('view'),
                    upgraded: object.get('upgraded')
                })
            }

            return tokens
        } catch (e) {
            return null
        }

    },
    get_field_by_tokenId: async function (tokenId, field) {
        try {
            const token = new Token();
            const query = new Parse.Query(token);
            query.equalTo("tokenId", tokenId);
            const results = await query.find();
            if (!results.length) {
                return null
            }
            const object = results[0]
            return object.get(field)
        } catch (e) {
            return null
        }

    },
    get_tokens_by_two_parameters: async function (key1, value1, key2, value2) {
        try {
            const token = new Token();
            const query1 = new Parse.Query(token);
            const query2 = new Parse.Query(token);
            query1.equalTo(key1, value1);
            query2.equalTo(key2, value2);
            const main = Parse.Query.and(query1, query2)
            const results = await main.find();
            if (!results.length) {
                return null
            }
            const tokens = []
            for (let object of results) {
                tokens.push({
                    tokenId: object.get('tokenId'),
                    wallet: object.get('wallet'),
                    view: object.get('view'),
                })
            }
            return tokens
        } catch (e) {
            return null
        }
    },
    update_field_by_tokenId: async function (tokenId, field, value) {
        try {
            const token = new Token();
            const query = new Parse.Query(token);
            query.equalTo("tokenId", tokenId);
            const results = await query.find();
            if (!results.length) {
                return null
            }
            const object = results[0]
            object.set(field, value)
            await object.save()
            return 1
        } catch (e) {
            return null
        }
    },
    create_token: async function (tokenID, wallet, view, upgraded) {
        try {
            const token = new Token();
            token.set("tokenId", tokenID)
            token.set("wallet", wallet)
            token.set("view", view)
            token.set("upgraded", upgraded)

            await token.save()


        } catch (e) {
            console.log(e)

        }
    }
});
module.exports = Token
