// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import @openzeppelin libraries 
// inheriting the ReputationNTT minting contract
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./3_ReputationNTT.sol";

// creating interface pointing to the next game's NTT minting function 
interface IhuntLicence {
    function mintLicenceNTT(address hunter) external;
}

contract DoubleUltimatumGame is AccessControl, Reputation_NTT_Factory {

    // Interface function call to Reputation NTT Factory Contract
    function callMintLicenceNTT(uint _objectId, address _LicenceContract) external {
        require(balanceOf(msg.sender) >= 2, 
            "You need 2 Reputation Tokens to call Hunting Licence NTT Contract.");
        reputationObject memory _repObject = mapOfRepObjects[_objectId];
        // low level call using functionSelector
        bytes memory data = abi.encodeWithSelector(_repObject.functionSelector, msg.sender);
        (bool success, ) = _LicenceContract.call(data);
        require(success, "Function call failed");
    }

    // variables needed for the constructor initialization
    address public contractAddress;
    Reputation_NTT_Factory reputationNTT;
    // constructor function to initialize the Reputation_NTT_Factory at the same address
    constructor() {
        contractAddress = address(this);
        reputationNTT = Reputation_NTT_Factory(contractAddress);
        authorizedContracts[contractAddress] = true;
    }

    // minting Reputation Tokens
    function getRewardReputationTokens() public {
        reputationNTT.mintReputationNTT(player1, player2);
    }

    // ========== Variables =============
    bytes32 constant PLAYER_ROLE = keccak256("PLAYER_ROLE");

    address public player1;
    address public player2;
    uint public poolOfMoney = 100;

    uint public player1Demand;
    uint public player2Demand;
    bool public player1Accepted;
    bool public player1Rejected;
    bool public player2Accepted;
    bool player1ProposedAnOffer;
    bool player2ProposedAnOffer;

    // Function to set player roles for the Ultimatum game
    // require 1 Reputation NTT Token per player to get access to player roles
    function setPlayerRolesUlt(uint _p1repIdNum, uint _p2repIdNum) public {
        reputationObject memory _repObject1 = mapOfRepObjects[_p1repIdNum];
        reputationObject memory _repObject2 = mapOfRepObjects[_p2repIdNum];

        require(_repObject1.objectId != 0, "Player 1 has to have 1 Reputation Token");
        require(_repObject2.objectId != 0, "Player 2 has to have 1 Reputation Token");
        require(_p1repIdNum != _p2repIdNum, "Players cannot have the same Token");
        
        _setupRole(PLAYER_ROLE, ownerOf(_p1repIdNum));
        _setupRole(PLAYER_ROLE, ownerOf(_p2repIdNum));
        
        player1 = ownerOf(_p1repIdNum);
        player2 = ownerOf(_p2repIdNum);
    }

    // =========== Game Logic OK ===========
    function getPlayer1Demand() public view returns (uint) {
        return player1Demand;
    }

    function getPlayer2Demand() public view returns (uint) {
        return player2Demand;
    }

    function setPlayer1Demand(uint demand) public onlyRole(PLAYER_ROLE) {
        require(msg.sender == player1, "Only Player 1 can set his demand");
        require(demand <= poolOfMoney, "Player 1 demand exceeds pool of money");
        require(demand >= 0, "Demand has to be positive int");
        
        player1Demand = demand;
        player1ProposedAnOffer = true;
    }

    function setPlayer2Demand(uint demand) public onlyRole(PLAYER_ROLE) {
        require(msg.sender == player2, "Only Player 2 can set his demand");
        require(demand <= poolOfMoney, "Player 2 demand exceeds pool of money");
        require(demand >= 0, "Demand has to be positive int");
        require(player1ProposedAnOffer, "Player 1 didn't propose an offer yet");
        
        player2Demand = demand;
        player2ProposedAnOffer = true;
    }

    function p2acceptOfferOfPlayer1() public onlyRole(PLAYER_ROLE) {
        require(player1ProposedAnOffer, "Player 1 didn't propose an offer yet");
        require(msg.sender == player2, "Only Player 2 can accept");

        player2Accepted = true;
    }

    function p1acceptOfferOfPlayer2() public onlyRole(PLAYER_ROLE) {
        require(player2ProposedAnOffer, "Player 2 didn't propose an offer yet");
        require(msg.sender == player1, "Only Player 1 can accept");

        player1Accepted = true;
    }

    function p1rejects() public onlyRole(PLAYER_ROLE) {
        require(player2ProposedAnOffer, "Player 2 didn't propose an offer yet");
        require(msg.sender == player1, "Only Player 1 can accept");

        player1Rejected = true;
    }

    function gameResult() public onlyRole(PLAYER_ROLE) returns (string memory, uint, uint){
        require(player1Accepted || player2Accepted || player1Rejected, "At least one player has to accept");
        
        if (player1Rejected) {
            return ("No agreement was made. Players get:", 0, 0);
        } else if (player1Accepted) {
            getRewardReputationTokens();
            uint poolSplit;
            poolSplit = poolOfMoney - player2Demand;
            return ("Players found an mutually benefitial agreement. Pool split:", poolSplit, player2Demand);
        } else {
            getRewardReputationTokens();
            uint poolSplit;
            poolSplit = poolOfMoney - player1Demand;
            return ("Players found an mutually benefitial agreement. Pool split:", player1Demand, poolSplit);
        } 
    }

    //  ========== Other Functions ==========  
    // The following functions are overrides required by Solidity
    // Helping the interoperability of ERC721 standard
    function supportsInterface(bytes4 interfaceId)
        public view virtual override(AccessControl, Reputation_NTT_Factory) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
