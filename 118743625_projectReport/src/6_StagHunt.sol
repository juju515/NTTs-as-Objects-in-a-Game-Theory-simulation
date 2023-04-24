// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import @openzeppelin libraries 
// inheriting the LicenceNTT minting contract
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./5_LicenceNTT.sol";

contract StagHuntGame is AccessControl, HuntLicence_NTT_Factory {

    // ========== Variables =============
    bytes32 constant HUNTER_ROLE = keccak256("HUNTER_ROLE");

    address public player1;
    address public player2;

    uint player1Choice;
    uint player2Choice;
    bool public player1MadeChoice;
    bool public player2MadeChoice;

    // Function to set Hunter roles for the Stag Hunt game
    // Require Hunting Licence NTT Token to get access to Hunter role
    function setPayerRolesHunt(uint _p1LicenceNum, uint _p2LicenceNum) public {
        licenceObject memory _licenceObject1 = mapOfLicObjects[_p1LicenceNum];
        licenceObject memory _licenceObject2 = mapOfLicObjects[_p2LicenceNum];

        require(_licenceObject1.joinHuntFlag, "Player 1 has to have a licence");
        require(_licenceObject2.joinHuntFlag, "Player 2 has to have a licence");
        require(_p1LicenceNum != _p2LicenceNum, "Players cannot have the same address");
        
        _setupRole(HUNTER_ROLE, ownerOf(_p1LicenceNum));
        _setupRole(HUNTER_ROLE, ownerOf(_p2LicenceNum));
        
        player1 = ownerOf(_p1LicenceNum);
        player2 = ownerOf(_p2LicenceNum);
    }

    // =========== Game Logic ===========
    function getPlayer1Choice() public view returns (uint) {
        return player1Choice;
    }

    function getPlayer2Choice() public view returns (uint) {
        return player2Choice;
    }

    function setPlayer1Choice(uint choice) public onlyRole(HUNTER_ROLE) {
        require(msg.sender == player1, "Only Player 1 can make a choice");
        require(choice == 0 || choice == 1, "Invalid choice");
        
        player1Choice = choice;
        player1MadeChoice = true;
    }

    function setPlayer2Choice(uint choice) public onlyRole(HUNTER_ROLE) {
        require(msg.sender == player2, "Only Player 2 can make a choice");
        require(choice == 0 || choice == 1, "Invalid choice");
        require(player1MadeChoice, "Player 1 has not made a choice yet");
        
        player2Choice = choice;
        player2MadeChoice = true;
    }

    function gameResult() public onlyRole(HUNTER_ROLE) view returns (string memory, uint, uint){
        require(player1MadeChoice && player2MadeChoice, "Both players must make a choice");
        
        if (player1Choice == 0 && player2Choice == 0) {
            return ("Both players chose to hunt stag. They both receive a payoff of:", 4, 4);
        } else if (player1Choice == 1 && player2Choice == 1) {
            return ("Both players chose to hunt hare. They both receive a payoff of:", 1, 1);
        } else if (player1Choice == 0 && player2Choice == 1) {
            return ("Player 1 hunted stag, but Player 2 hunted hare. Players receive a payoff of:", 0, 2);
        } else {
            return ("Player 1 hunted hare, but Player 2 hunted stag. Players receive a payoff of:", 2, 0);
        }
    }

    //  ========== Other Functions ==========  
    // The following functions are overrides required by Solidity
    // Helping the interoperability of ERC721 standard
    function supportsInterface(bytes4 interfaceId)
        public view virtual override(AccessControl, HuntLicence_NTT_Factory) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
