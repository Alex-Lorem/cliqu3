// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";



//    ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⣫⣿⣿⣿⣿
//    ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⠛⣩⣾⣿⣿⣿⣿⣿
//    ⣿⣿⣿⣿⣿⣿⣿⣿⡛⠛⠛⠛⠛⠛⠛⢿⢻⣿⡿⠟⠋⣴⣾⣿⣿⣿⣿⣿⣿⣿
//    ⣿⣿⣿⣿⡿⢛⣋⠉⠁⠄⢀⠠⠄⠄⠄⠈⠄⠋⡂⠠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
//    ⣿⣿⣿⣛⣛⣉⠄⢀⡤⠊⠁⠄⠄⠄⢀⠄⠄⠄⠄⠲⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿
//    ⣿⡿⠟⠋⠄⠄⡠⠊⠄⠄⠄⠄⠄⣀⣼⣤⣤⣤⣀⠄⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿
//    ⣿⠛⣁⡀⠄⡠⠄⠄⠄⠄⠄⠄⢠⣿⣿⣿⣿⣿⣿⣷⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿
//    ⣿⠿⢟⡉⠰⠁⠄⠄⠄⠄⠄⠄⠄⠙⠿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
//    ⡇⠄⠄⠙⠃⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠈⠉⠉⠛⠛⠛⠻⢿⣿⣿⣿⣿
//    ⣇⠄⢰⣄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠉⠻⣿⣿
//    ⣿⠄⠈⠻⣦⣤⡀⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⣦⠙⣿
//    ⣿⣄⠄⠚⢿⣿⡟⠄⠄⠄⢀⡀⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢀⣿⣧⠸
//    ⣿⣿⣆⠄⢸⡿⠄⠄⢀⣴⣿⣿⣿⣿⣷⣶⣶⣶⣶⠄⠄⠄⠄⠄⠄⢀⣾⣿⣿⠄
//    ⣿⣿⣿⣷⡞⠁⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⡀⠄⠄⣠⣾⣿⣿⣿⣿⢀
//    ⣿⣿⣿⡿⠁⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠄⠄⠘⣿⣿⡿⠟⢃⣼
//    ⣿⣿⠏⠄⠠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⠉⢀⡠⢄⡠⡭⠄⣠⢠⣾⣿
//    ⠏⠄⠄⣸⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠁⠄⢀⣦⣒⣁⣒⣩⣄⣃⢀⣮⣥⣼⣿
//    ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿




contract CLIQU3_ADDITIONAL is Ownable {

    address private mainContract;
    mapping(uint256 => mapping(address => uint256)) private counter;
    mapping(uint256 => uint256) private timeCounter;
    function setMainContractAddress(address otherAddress) external onlyOwner{
        mainContract = otherAddress;
    }

    function random(address to, uint256 token) internal returns(uint256) {

        if(block.timestamp - timeCounter[token] >= 86400){
            counter[token][to] = 1;
            timeCounter[token] = block.timestamp;
        } else {
            counter[token][to] = counter[token][to] + 1;
        }

        if(counter[token][to] <= 2) {
            return 1;
        } else {
            return 0;
        }
    }

    function isValid(address to, uint256 token) external returns(bool){

        uint256 success = random(to, token);
        if(success == 1){
            return true;
        } else {
            return false;
        }
    }
}
