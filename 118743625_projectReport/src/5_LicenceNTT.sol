// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// @openzeppelin libraries 
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract HuntLicence_NTT_Factory is ERC721, ERC721Enumerable {

    // ========== Lifecycle Methods ==========  
    address nttContractAddress;
    constructor() ERC721("Licence NonTrassferableToken", "HNT_NTT") {
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
    // struct type that will store the state of the Licence NTT Object
    struct licenceObject {
        // Object Attributes 
        address hunterAddr;
        uint licenceID;
        bool isMinted;
        // Object Methods
        bool joinHuntFlag;
    }

    // mapping of the objects
    mapping(uint => licenceObject) mapOfLicObjects;

    // set Object Function flag to True to access Hunting Licence NTT 
    function setFunctionFlagToTrue(uint _tokenId) public {
        licenceObject storage _licenceObject = mapOfLicObjects[_tokenId];
        _licenceObject.joinHuntFlag = true;
    }

    // ========== Property variables ========== 
    // using counter to give each token an ID
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter; 

    // ========== Minting Functions ========== 
    function mintLicenceNTT(address hunter) external {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(hunter, tokenId);

        // link the token to the struct Object
        licenceObject storage _licenceObject = mapOfLicObjects[tokenId];
        _licenceObject.hunterAddr = hunter;
        _licenceObject.licenceID = tokenId;
        _licenceObject.isMinted = true;
        _licenceObject.joinHuntFlag = false;

    }

    //  ========== Getter Functions ==========  
    function getObject(uint _tokenId) view public returns (address, uint, bool, bool) {
        licenceObject memory _licenceObject = mapOfLicObjects[_tokenId];
        return (_licenceObject.hunterAddr, 
                _licenceObject.licenceID, 
                _licenceObject.isMinted,
                _licenceObject.joinHuntFlag);    
    }

    function getMyBalance() public view returns (uint256) {
        return balanceOf(msg.sender);
    }

    //  ========== Other Functions ==========  
    // The following functions are overrides required by Solidity
    // Helping the interoperability of ERC721 standard
    function supportsInterface(bytes4 interfaceId)
        public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}

