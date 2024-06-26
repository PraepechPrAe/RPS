# Rock, Paper, Scissors (RPS)
This smart contract, writing with Solidity, allows users to bet on games with fixed rules for winning, losing, and drawing. ETH will be automatically paid to the winner or split in the event of a draw. 

## Problems
1. No one wants to go first, because they are afraid of being front-run.
2. It is difficult to know which account is index 0 or 1.
3. Player 0's ETH will be locked if no player 1 comes to contribute.
4. In the case where both players have joined, but only one player has submitted a choice.This will cause the ETH of everyone who contributed to be locked up and no one can withdraw it.
5. How can this contract be played multiple times without having to redeploy it every time?

## Tasks
### 1. Clone RPS GitHub Repository.
Clone the repository and modify the Solidity code.

### 2. Solve front-running problems using the commit-reveal process.
Solve the first problem by 
- Commit: Each player submits a secret commitment to their choice without revealing it to the other player.
- Reveal: Both players reveal their choices after both of them commited thier own choice.
- Validation: The smart contract verifies that the committed choices match the revealed ones.
- Outcome: Based on the revealed choices and predetermined rules, the contract determines the winner and automatically distributes the ETH accordingly.

Solve the second problem by mapping the address to index.

### 3. Solve locking of player's ETH problem.
Solve the third, fourth and other locking case by provide a expired time (after 10 minutes) and set folllowing rules:
After 10 minutes
- If there is only 1 player, the player can refund the ETH.
- If both players didn't commit there choice, both of them won't receive any ETH.
- If only 1 player commited, the player who commited will receive all reward.
- If both players commited, but only 1 revealed. The player who revealed will receive all reward.

Solve the fifth problem by create resetparam() function that can delete all commits, players and other parameters.

### 4. Make the game more complex by having 7 options: Rock, Water, Air, Paper, Sponge, Scissors, and Fire.
<img width="303" alt="image" src="https://github.com/PraepechPrAe/RPS/assets/122012803/32b1cbbf-a3ef-4548-996b-cb64356bf721">

0 - Rock, 1 - Water , 2 - Air, 3 - Paper, 4 - Sponge, 5 - Scissors, 6 - Fire
Using modulo to easily solve the Rock, Water, Air, Paper, Sponge, Scissors, and Fire.
```sol
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
```

### 5. Show winner-loser case and draw case.

Winner-loser Case
![Screenshot 2567-02-13 at 23 55 04](https://github.com/PraepechPrAe/RPS/assets/122012803/8ff90b38-442d-4323-b75d-240972603c4c)

![Screenshot 2567-02-13 at 23 55 16](https://github.com/PraepechPrAe/RPS/assets/122012803/791f10a9-bada-426b-9447-e96c6d8118a0)

Draw Case
![Screenshot 2567-02-13 at 23 57 30](https://github.com/PraepechPrAe/RPS/assets/122012803/db69f14b-ebcb-4924-b3c6-c2ac6039c8dd)

![Screenshot 2567-02-13 at 23 57 39](https://github.com/PraepechPrAe/RPS/assets/122012803/04cdd399-d5f5-409d-aff9-c663e81518ad)
