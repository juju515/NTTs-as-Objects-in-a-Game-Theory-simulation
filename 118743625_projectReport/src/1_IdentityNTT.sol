// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// @openzeppelin libraries 
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Identity_NTT_Factory is ERC721, ERC721Enumerable {

    // ========== Lifecycle Methods ==========  
    address nttContractAddress;
    constructor() ERC721("Identity NonTrassferableToken", "ID_NTT") {
        // Start Token counter
        _tokenIdCounter.increment();
        // Store contract address
        nttContractAddress = address(this);
    }

    // Override transfer function to make the token Non-Transferable 
    function _beforeTokenTransfer(
        address from, 
        address to, 
        uint256 tokenId, 
        uint256 batchSize) 
        internal override(ERC721, ERC721Enumerable) {
        require(from == address(0) || to == address(0), 
                "ERROR: You can't send NonTransferableTokens :P");
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // ========== NonTransferable Object ========== 
    // struct type that will store the state of the Identity NTT Object
    struct idObject {
        // Object Attributes 
        address ownerAddr;
        uint personIdNum;
        bool isMinted;
        // Object Methods
            // n/a
    }

    // mapping of the objects
    mapping(uint => idObject) mapOfObjects;

    // ========== Property variables ========== 
    // using counter to give each token an ID
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter; 

    // uint256 public MINT_PRICE = 100 gwei; // 0.0000001 ETH

    // ========== Minting Functions ========== 
    function mintIdNTT() public {
        require(balanceOf(msg.sender) < 1, "Only 1 ID token per address allowed");
        // require(msg.value >= MINT_PRICE, "Not enough ether sent");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);

        // link the token to the struct Object
        idObject storage _idObject = mapOfObjects[tokenId];
        _idObject.ownerAddr = msg.sender;
        _idObject.personIdNum = tokenId;
        _idObject.isMinted = true;
    }

    //  ========== Getter Functions ==========  
    function getObject(uint _tokenId) view public returns (address, uint, bool) {
        idObject memory _idObject = mapOfObjects[_tokenId];
        return (_idObject.ownerAddr, _idObject.personIdNum, _idObject.isMinted);    
    }

    //  ========== Other Functions ==========  
    // The following functions are overrides required by Solidity
    // Helping the interoperability of ERC721 standard
    function supportsInterface(bytes4 interfaceId)
        public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
