// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./DefaultOperatorFilterer.sol";



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



contract CLIQU3 is ERC721A, DefaultOperatorFilterer, Ownable  {
    using Strings for uint256;

    uint256 public maxSupply = 3333;
    uint256 public maxMintPerAddressLimit = 1;
    uint256 public percentPerTransfer = 10;
    uint256 public wl333Counter = 0;
    uint256 public wl3000Counter = 0;
    uint256 public seed;
    uint256 public publicCost = 0.036 ether;
    uint256 public wl333Cost = 0.033 ether;
    uint256 public wl3000Cost = 0.033 ether;

    bytes32 public merkleRoot333;
    bytes32 public merkleRoot3000;

    string public notRevealedUri;
    string public prefix = "https://ipfs.io/ipfs/";
    string [] public collections;

    bool public pausedPublic = true;
    bool public pausedWL3000 = true;
    bool public pausedWL333 = true;
    bool public pausedTeamMint = true;
    bool public pausedBurn = true;
    bool public revealed = false;

    address public previosCollection = 0x6411eD216ef6243d115Ac074c20C434D6892c99A;
    address public royaltiesAddress = 0x73F52CacA22C867c4CbB6f1e923AA203B4552d77;
    address private otherContract;
    address [] public teamList;

    mapping(uint256 => uint256) public tokenView;
    mapping(uint256 => bool) public upgradeable;
    mapping(uint256 => bool) public blacklistNFTs;
    mapping(address => uint256) public mintedInWhichWl;

    event ChangeView(uint256 tokenId, uint256 value);
    event Upgraded(uint256 tokenId);

    constructor(
        string memory _name,
        string memory _symbol,
        address _initOtherContract,
        string memory _initNotRevealedUri

    ) ERC721A(_name, _symbol) {
        seed = block.timestamp % 100;
        setOtherContractAddress(_initOtherContract);
        setNotRevealedURI(_initNotRevealedUri);

    }


    function setApprovalForAll(address operator, bool approved) public override onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
    }

    function approve(address operator, uint256 tokenId) public override onlyAllowedOperatorApproval(operator) {
        super.approve(operator, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public override onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function _startTokenId() override internal view virtual returns (uint256){
        return 1;
    }

    function calcWorth(uint256 quantity, bytes32[] calldata _merkleProof) internal returns(uint) {

        if(_merkleProof.length > 0) {

            require(quantity == 1, "For each wl max quantity is 1");
            require(_numberMinted(msg.sender) < 2, "Reached limit of two wls");
            bytes32 leaf = keccak256(abi.encodePacked(msg.sender));

            if(mintedInWhichWl[msg.sender] == 3000){
                require(MerkleProof.verify(_merkleProof, merkleRoot333, leaf), "Exceeded the limit for wl");
                require(!pausedWL333, "WL minting is paused");
                require(wl333Counter + quantity <= 333, "Reached limit of 333 tokens");

                wl333Counter = wl333Counter + quantity;
                return wl333Cost;

            } else if(mintedInWhichWl[msg.sender] == 333){
                require(MerkleProof.verify(_merkleProof, merkleRoot3000, leaf),"Exceeded the limit for wl");
                require(!pausedWL3000, "WL minting is paused");
                require(wl3000Counter + quantity <= 3000, "Reached limit of 3000 tokens");

                wl3000Counter = wl3000Counter + quantity;
                return wl3000Cost;

            } else {

                if(MerkleProof.verify(_merkleProof, merkleRoot3000, leaf)){
                    require(!pausedWL3000, "WL minting is paused");
                    require(wl3000Counter + quantity <= 3000, "Reached limit of 3000 tokens");

                    wl3000Counter = wl3000Counter + quantity;
                    mintedInWhichWl[msg.sender] = 3000;
                    return wl3000Cost;

                } else if(MerkleProof.verify(_merkleProof, merkleRoot333, leaf)){
                    require(!pausedWL333, "WL minting is paused");
                    require(wl333Counter + quantity <= 333, "Reached limit of 333 tokens");

                    wl333Counter = wl333Counter + quantity;
                    mintedInWhichWl[msg.sender] = 333;
                    return wl333Cost;

                } else {
                    revert("You arent registered in wl");
                }
            }

        }

        require(!pausedPublic, "Public minting is paused");
        (,bytes memory response) = previosCollection.call(abi.encodeWithSignature("balanceOf(address)", msg.sender, msg.sender));

        uint256 res = abi.decode(response, (uint256));

        if(res > 0 && _numberMinted(msg.sender) + quantity <= res){
            return 0;
        }

        return publicCost;
    }

    function mint(uint256 quantity, bytes32[] calldata _merkleProof) external payable notContract{
        require(quantity > 0 && quantity <= 6, "Invalid mint amount! (max 6)");
        require(totalSupply() + quantity <= maxSupply, "Not enough tokens left");

        require(msg.value >= calcWorth(quantity, _merkleProof), "Not enough ethers paid");

        _safeMint(msg.sender, quantity);

    }

    function teamMint(uint256 quantity) external {
        if(msg.sender != owner()){
            require(_numberMinted(msg.sender) + quantity <= 1, "Exceeded the limit for team mint");
            require(!pausedTeamMint, "Team mint paused");
            uint256 k = 0;

            for (uint i = 0; i < teamList.length; i++) {
                if(teamList[i] == msg.sender){
                    k = 1;
                }
            }

            require(k == 1, "You arent registered in team list");
        }

        require(totalSupply() + quantity <= maxSupply, "Not enough tokens left");

        _safeMint(msg.sender, quantity);

    }

    function validating(address from, address to, uint256 tokenId) internal virtual override {
        bool isContract = _isContract(to);
        if(!revealed && isContract){
            blacklistNFTs[tokenId] = true;
        }
        if(upgradeable[tokenId] != true && from != address(0)){
            (,bytes memory response) = otherContract.call(abi.encodeWithSignature("isValid(address,uint256)", to, tokenId, msg.sender));

            bool res = abi.decode(response, (bool));
            if(res == true){
                seed = (seed + block.timestamp) % 100;
                if(seed <= percentPerTransfer){
                    upgradeable[tokenId] = true;
                    blacklistNFTs[tokenId] = false;
                    tokenView[tokenId] = 1;
                    emit ChangeView(tokenId, 1);
                    emit Upgraded(tokenId);
                }
            }

        }

    }

    function upgrade(uint256 tokenId) external {
        require(revealed, "No access to upgrade until reveal");
        require(blacklistNFTs[tokenId] == false, "Token was traded until reveal");
        upgradeable[tokenId] = true;
        tokenView[tokenId] = 1;
        emit ChangeView(tokenId, 1);
        emit Upgraded(tokenId);
    }

    function switchView(uint256 tokenId, uint256 num) external {
        require(num - 1 <= collections.length, "Invalid collection number");
        if(num == 1){
            require(upgradeable[tokenId]== true, "Token not upgraded");
        }
        tokenView[tokenId] = num;
        emit ChangeView(tokenId, num);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "URI query for nonexistent token");

        if(revealed == false) {
            return string(abi.encodePacked(prefix, notRevealedUri));
        }

        return string(abi.encodePacked(prefix, collections[tokenView[tokenId]], "/", tokenId.toString(), ".json"));

    }

    function pauseTeamMint(bool _state) public onlyOwner{
        pausedTeamMint = _state;
    }

    function setMerkleRootes(bytes32 _newMerkleRoot3000, bytes32 _newMerkleRoot333) public onlyOwner {
        merkleRoot3000 = _newMerkleRoot3000;
        merkleRoot333 = _newMerkleRoot333;
    }

    function setCost(uint256 _newPublicCost, uint256 _newWl333Cost, uint256 _newWl3000Cost) public onlyOwner {
        publicCost = _newPublicCost;
        wl333Cost = _newWl333Cost;
        wl3000Cost = _newWl3000Cost;
    }

    function setRoyaltiesAddress(address _newAddress) public onlyOwner {
        royaltiesAddress = _newAddress;
    }

    function setPreviousCollectionAddress(address _newAddress) public onlyOwner {
        previosCollection = _newAddress;
    }

    function setOtherContractAddress(address _newOtherContract) public onlyOwner {
        otherContract = _newOtherContract;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    function setUpTeam(address[] memory _newTeam) public onlyOwner {
        teamList = _newTeam;
    }

    function addCollection(string memory _newCollection) public onlyOwner{
        collections.push(_newCollection);
    }

    function modifyCollection(string memory _modified, uint256 indx) public onlyOwner{
        collections[indx] = _modified;
    }

    function reveal() public onlyOwner {
        revealed = true;
    }

    function pausePublicMint(bool _state) public onlyOwner {
        pausedPublic = _state;
    }

    function pauseWl3000(bool _state) public onlyOwner {
        pausedWL3000 = _state;
    }

    function pauseWl333(bool _state) public onlyOwner {
        pausedWL333 = _state;
    }

    function pauseBurn(bool _state) public onlyOwner {
        pausedBurn = _state;
    }

    function burn(uint256 from, uint256 to) public onlyOwner{
        require(!pausedBurn, "Burn is paused");
        for(uint256 i = from; i <= to; i++){
            require(ownerOf(i) == msg.sender, "Not allowed");
            _burn(i);
        }
    }

    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        _;
    }

    function _isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        if(size > 0 || msg.sender != tx.origin){
            return true;
        } else {
            return false;
        }
    }

    function withdraw(address payable _to) external onlyOwner {
        uint256 balance = address(this).balance;
        uint256 royaltis = address(this).balance / 10;
        _to.transfer(balance - royaltis);
        payable(royaltiesAddress).transfer(royaltis);
    }

    receive() external payable {

    }
}

