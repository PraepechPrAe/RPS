// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./CommitReveal.sol";

contract RPS is CommitReveal{
    struct Player {
        uint choice; // 0 - Rock, 1 - Water , 2 - Air, 3 - Paper, 4 - Sponge, 5 - Scissors, 6 - Fire
        bytes32 hashedInput;
        address addr;
        bool isCommited;
        uint point;
    }
    uint public numPlayer = 0;
    uint public reward = 0;
    mapping (uint => Player) public player;
    uint public numInput = 0;
    mapping (address => uint) public player_idx;
    uint public numReveal = 0;
    uint public expired_time = 10 minutes;
    uint public lastEdit_time = block.timestamp;

    function addPlayer() public payable {
        require(numPlayer < 3);
        require(msg.value == 1 ether);
        reward += msg.value;
        player[numPlayer].addr = msg.sender;
        player[numPlayer].choice = 3;
        player_idx[player[numPlayer].addr] = numPlayer;
        numPlayer++;
        lastEdit_time = block.timestamp;
    }
    
    function hashInput(uint choice, uint salt) public view returns(bytes32){
        return getSaltedHash(bytes32(choice), bytes32(salt));
    }

    function input(bytes32 hashedInput) public  {
        require(numPlayer == 3);
        commit(hashedInput);
        player[player_idx[msg.sender]].isCommited = true;
        numInput++;
        lastEdit_time = block.timestamp;
    }

    function withdrawETH() public {
        require(numPlayer > 0);
        uint current_time = block.timestamp;
        require(current_time > lastEdit_time + expired_time);
        if(numPlayer == 1){
            payable(player[0].addr).transfer(reward);
        }
        else{
            if (numInput == 0){
                payable(player[0].addr).transfer(0);
                payable(player[1].addr).transfer(0);
            }
            else if (numInput == 1){
                if(player[0].isCommited){
                    payable(player[0].addr).transfer(reward);
                }
                else if (player[1].isCommited){
                    payable(player[1].addr).transfer(reward);
                }
            }
            else if (numInput == 2){
                if(commits[player[0].addr].revealed && !commits[player[1].addr].revealed){
                    payable(player[0].addr).transfer(reward);
                }
                else if (commits[player[1].addr].revealed && !commits[player[0].addr].revealed){
                    payable(player[1].addr).transfer(reward);
                }
            }
        }
        resetParam();
    }

    function revealChoice(uint answer,uint salt) public {
        require(numPlayer == 3);
        require(numInput == 3);
        revealAnswer(bytes32(answer), bytes32(salt));
        player[player_idx[msg.sender]].choice = answer;
        numReveal++;
        lastEdit_time = block.timestamp;
        if(numReveal == 3){
            _checkWinnerAndPay();
        }
    }

    function _checkWinnerAndPay() private {
        uint p0Choice = player[0].choice;
        uint p1Choice = player[1].choice;
        uint p2Choice = player[2].choice;
        address payable account0 = payable(player[0].addr);
        address payable account1 = payable(player[1].addr);
        address payable account2 = payable(player[2].addr);
        
        if (p0Choice == p1Choice) {
            // to split reward
            account0.transfer(reward / 2);
            account1.transfer(reward / 2);
        }
        else if ((p0Choice + 1) % 7 == p1Choice || (p0Choice + 2) % 7 == p1Choice || (p0Choice + 3) % 7 == p1Choice){
            // to pay player[1]
            account1.transfer(reward);
        }
        else if ((p1Choice + 1) % 7 == p0Choice || (p1Choice + 2) % 7 == p0Choice || (p1Choice + 3) % 7 == p0Choice){
            // to pay player[0]
            account0.transfer(reward);
        }
        resetParam();
    }

    //tournament
    function tournament() private {
        uint p0Choice = player[0].choice;
        uint p1Choice = player[1].choice;
        uint p2Choice = player[2].choice;
        for(uint i=0; i<numPlayer; i++) {
            if(player[i].choice)
        }

    }



    function resetParam() private {
        delete commits[player[0].addr];
        delete commits[player[1].addr];
        delete player_idx[player[0].addr];
        delete player_idx[player[1].addr];
        delete player[0];
        delete player[1];
        reward = 0;
        numPlayer = 0;
        numInput = 0;
        numReveal = 0;
    }
}
