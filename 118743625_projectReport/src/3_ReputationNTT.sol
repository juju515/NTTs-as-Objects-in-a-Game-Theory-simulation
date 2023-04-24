// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// @openzeppelin libraries 
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Reputation_NTT_Factory is ERC721, ERC721Enumerable {

    // ========== Lifecycle Methods ==========  
    address repNttContractAddress;
    constructor() ERC721("Reputation NonTrassferableToken", "REP_NTT") {
        // Start Token counter
        _tokenIdCounter.increment();
        // Store contract address
        repNttContractAddress = address(this);
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
    // struct type that will store the state of the Reputation NTT Object
    struct reputationObject {
        // Object Attributes 
        address ownerAddr;
        uint objectId;
        bool isMinted;
        // Object Methods
        bytes4 functionSelector; 
    }

    // mapping of the objects
    mapping(uint => reputationObject) mapOfRepObjects;

    // computing bytes4 Function Selector for function mintLicenceNTT
    bytes4 private constant MINT_LICENCE_NTT_SELECTOR = bytes4(keccak256("mintLicenceNTT(address)"));

    // ========== Property variables ========== 
    // using counter to give each token an ID
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter; 

    // ========== Minting Functions ========== 
    mapping(address => bool) public authorizedContracts;

    // Function to add an authorized contract
    function addAuthorizedContract(address _contractAddress) external {
        authorizedContracts[_contractAddress] = true;
    }

    // Modifier to check if the caller is an authorized contract
    modifier onlyAuthorizedContracts() {
        require(authorizedContracts[msg.sender], 
            "Caller is not an authorized contract");
        _;
    }    

    function mintReputationNTT(address player1, address player2) 
                                                external onlyAuthorizedContracts {                    
        // mint token for player 1
        uint256 tokenId1 = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(player1, tokenId1);

        // link the token for player 1 to the struct Object
        reputationObject storage _repObject = mapOfRepObjects[tokenId1];
        _repObject.ownerAddr = player1;
        _repObject.objectId = tokenId1;
        _repObject.isMinted = true;
        _repObject.functionSelector = MINT_LICENCE_NTT_SELECTOR;

        // mint token for player 2
        uint256 tokenId2 = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(player2, tokenId2);

        // link the token for player 2 to the struct Object
        reputationObject storage _repObject2 = mapOfRepObjects[tokenId2];
        _repObject2.ownerAddr = player2;
        _repObject2.objectId = tokenId2;
        _repObject2.isMinted = true;
        _repObject2.functionSelector = MINT_LICENCE_NTT_SELECTOR;
    }

    //  ========== Getter Functions ==========  
    function getObject(uint _tokenId) view public returns (address, uint, bool, bytes4) {
        reputationObject memory _repObject = mapOfRepObjects[_tokenId];
        return (_repObject.ownerAddr, _repObject.objectId, _repObject.isMinted,
                _repObject.functionSelector);    
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

