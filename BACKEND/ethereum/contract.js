require("dotenv").config();
const ethers = require("ethers")
const abi = require("./abi.json").abi
const address = '0x036eA1bfc7164C9d3F4BDFf7Ca41b9d297FF5210'
const message = "Connect with CLIQU3!"


const provider = new ethers.providers.AlchemyProvider("goerli", process.env.ALCHEMY_KEY);
//homestead
const contract = new ethers.Contract(address, abi, provider);


module.exports = { functions: contract, address: address, abi: abi,  message: message }



