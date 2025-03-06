# Rock-Paper-Scissors-Lizard-Spock (RPSLS) Smart Contract
This smart contract, writing with Solidity, allows users to bet on games with fixed rules for winning, losing, and drawing. ETH will be automatically paid to the winner or split in the event of a draw. 

## Overview
The contract allows two players to participate in a game of RPSLS. Players must commit their choices using a hashed input (commit-reveal mechanism) to prevent front-running. The contract ensures that:
Only specific allowed accounts can participate.Funds are not locked indefinitely in the contract due to inactivity.Choices are hidden until both players reveal them.The winner is determined based on the RPSLS rules, and rewards are distributed accordingly.

## Key Features
### 1. Preventing Locked Funds
The contract ensures that funds are not locked indefinitely in the following scenarios:
Single Player Joins: If only one player joins and no second player participates, the first player can withdraw their funds after a timeout period.Incomplete Commit/Reveal: If one player fails to commit or reveal their choice, the other player can withdraw the entire reward after the timeout period.

```solidity
    function withdrawETH() public {
        require(numPlayer > 0);
        // uint current_time = block.timestamp;
        // require(current_time > lastEdit_time + expired_time);
        require(elapsedMinutes() > expired_time);
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
```
Timeout Mechanism: The elapsedMinutes() function ensures that players can withdraw funds only after the specified timeout (expired_time).

### 2. Hiding Choices with Commit-Reveal
To prevent front-running (where one player waits to see the other's choice before making their own), the contract uses a commit-reveal mechanism. Players first commit their choice as a hashed value and later reveal it along with a salt.
#### Commit Phrase:
```solidity
    function input(bytes32 hashedInput) public  {
        require(numPlayer == 2);
        commit(hashedInput);
        player[player_idx[msg.sender]].isCommited = true;
        numInput++;
        // lastEdit_time = block.timestamp;
        setStartTime();
    }
```
Players submit a hashed input (hashedInput) generated using their choice and a random salt.The commit function (from CommitReveal.sol) stores the hash securely.

#### Hash Generation:
```solidity
    function hashInput(uint choice, uint salt) public view returns(bytes32){
        return getSaltedHash(bytes32(choice), bytes32(salt));
    }
```
Players can use this function to generate the hash of their choice and salt before committing.

#### Reveal Phase:
```solidity
    function revealChoice(uint answer,uint salt) public {
        require(numPlayer == 2);
        require(numInput == 2);
        revealAnswer(bytes32(answer), bytes32(salt));
        player[player_idx[msg.sender]].choice = answer;
        numReveal++;
        // lastEdit_time = block.timestamp;
        setStartTime();
        if(numReveal == 2){
            _checkWinnerAndPay();
        }
    }
```
Players reveal their choice (answer) and salt, which is verified against the committed hash.The revealAnswer function (from CommitReveal.sol) ensures the revealed values match the committed hash.

### 3. Handling Delays and Inactivity
The contract handles delays caused by incomplete player participation:
If only one player joins, they can withdraw their funds after the timeout.If one player fails to commit or reveal their choice, the other player can claim the reward after the timeout.
```solidity
    function withdrawETH() public {
        require(numPlayer > 0);
        // uint current_time = block.timestamp;
        // require(current_time > lastEdit_time + expired_time);
        require(elapsedMinutes() > expired_time);
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
```

### 4. Reveal and Determining the Winner
Once both players reveal their choices, the contract determines the winner based on the RPSLS rules:  
Rock beats Scissors and Lizard  
Paper beats Rock and Spock  
Scissors beats Paper and Lizard  
Lizard beats Paper and Spock  
Spock beats Rock and Scissors

0 - Rock, 1 - Paper , 2 - Scissors, 3 - Lizard, 4 - Spock

```sol
    if (p0Choice == p1Choice) {
        // Tie case: Split the reward
        account0.transfer(reward / 2);
        account1.transfer(reward / 2);
    } else if ((p0Choice - p1Choice + 5) % 5 == 1 || (p0Choice - p1Choice + 5) % 5 == 3) {
        // Player 0 wins
        account0.transfer(reward);
    } else {
        // Player 1 wins
        account1.transfer(reward);
    }
```
The modulo operation (p0Choice - p1Choice + 5) % 5 determines the winner based on the RPSLS rules.Rewards are distributed to the winner, or split in case of a tie.
