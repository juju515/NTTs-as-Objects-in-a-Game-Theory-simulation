// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import @openzeppelin libraries 
// inheriting the IdentityNTT minting contract
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./1_IdentityNTT.sol";

// creating interface pointing to the next game's NTT minting function 
interface Ireputation {
    function mintReputationNTT(address player1, address player2) external;
    function addAuthorizedContract(address _callingContractAddress) external;
}

contract CentipedeGame is AccessControl, Identity_NTT_Factory {

    // Interface function calls to Reputation NTT Factory Contract
    function callMintReputationNTT(address _reputationContract) external {
        require(reputationSet, 
            "You can't call Reputation NTT Minting Contract. Finish the game.");
        // add this contract address to authorized contracts
        Ireputation(_reputationContract).addAuthorizedContract(address(this));   
        // mint Reputation Token for both players
        Ireputation(_reputationContract).mintReputationNTT(player1, player2);
        reputationSet = false;
    }

    // ========== Variables =============
    bytes32 public constant PLAYER_ROLE = keccak256("PLAYER_ROLE");

    address public player1;
    address public player2;
    uint public player1payoff;
    uint public player2payoff;

    uint public roundsPlayed;
    bool public isGameEnded;
    bool public reputationSet;

    // Function to set player roles for the Centipede game
    // Require ID NTT Token to get access to player roles
    function setPlayerRolesCent(uint _player1idNum, uint _player2idNum) public {
        idObject memory _idObject1 = mapOfObjects[_player1idNum];
        idObject memory _idObject2 = mapOfObjects[_player2idNum];

        require(_idObject1.personIdNum != 0, "Player 1 has to have an ID Token");
        require(_idObject2.personIdNum != 0, "Player 2 has to have an ID Token");
        require(_player1idNum != _player2idNum, "Players cannot have the same ID Token");
        
        _setupRole(PLAYER_ROLE, ownerOf(_player1idNum));
        _setupRole(PLAYER_ROLE, ownerOf(_player2idNum));
        
        player1 = ownerOf(_player1idNum);
        player2 = ownerOf(_player2idNum);
    }

    // =========== Game Logic ===========
    function continueGame() public onlyRole(PLAYER_ROLE) {
        roundsPlayed++;
        require(!isGameEnded, "The game has already ended");

        if (roundsPlayed < 2) { // TODO - edit to 10 rounds
            require(msg.sender == getLastPlayer(), 
                "The same player cannot play twice in a row");
            calculateCurrentPayoffs();  
        } else {
            player1payoff = roundsPlayed;
            player2payoff = roundsPlayed;
            isGameEnded = true;
            reputationSet = true; 
        }
    }

    function stopGame() public onlyRole(PLAYER_ROLE) {
        require(!isGameEnded, "The game has already ended");
        
        roundsPlayed++;
        isGameEnded = true;
        calculateCurrentPayoffs();
    }

    function readCurrentPayoffs() public view returns (uint, uint) {
        return (player1payoff, player2payoff);
    }

    function calculateCurrentPayoffs() private {
        if (msg.sender == player1) {
            player1payoff = roundsPlayed + 1;
            player2payoff = roundsPlayed - 1;
        } else {
            player1payoff = roundsPlayed - 1;
            player2payoff = roundsPlayed + 1;
        }
    }

    function getLastPlayer() public view returns (address) {
        if (roundsPlayed % 2 == 1) {
            return player1;
        } else {
            return player2;
        }
    }

    //  ========== Other Functions ==========  
    // The following functions are overrides required by Solidity
    // Helping the interoperability of ERC721 standard
    function supportsInterface(bytes4 interfaceId) 
    public view override(AccessControl, Identity_NTT_Factory) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}