// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract Lottery {
    
    uint256 public ticketPrice = 1000000000000000000; // Wei (1 Ether)
    uint256 public maxTickets = 100;
    uint256 public remainingTickets = 0;
    
    mapping (address => uint256) public winnings;
    
    address[] tickets;
    
    uint ticktCount = 0;
    
    address public lotteryOperator;
    address public latestWinner;
    
    // modifier to check if caller is the lottery operator
    modifier isOperator() {
        require(msg.sender == lotteryOperator, "Caller is not the lottery operator");
        _;
    }
    
    // modifier to check if caller is a winner
    modifier isWinner() {
        require(winnings[msg.sender] > 0, "Caller is not a winner");
        _;
    }
    
    constructor()
    {
        lotteryOperator = msg.sender; 
        remainingTickets = maxTickets;
    }
    
    function BuyTickets() public payable
    {
        require(msg.value % ticketPrice == 0, "the value must be multiple of 1 Ether");
        uint256 numOfTicketsToBuy = msg.value / ticketPrice;
        
        require(numOfTicketsToBuy <= remainingTickets, "Not enough tickets available.");
        remainingTickets -= numOfTicketsToBuy;
        
        for (uint i = 0; i < numOfTicketsToBuy; i++)
        {
            tickets.push(msg.sender);
            ticktCount++;
        }
        
    }
    
    function DrawWinnerTicket() public //isOperator
    {
        require(ticktCount > 0, "no tickets");
        uint256 randomNum = uint(blockhash(block.number-1)) % ticktCount;
        
        latestWinner = tickets[randomNum];
        winnings[latestWinner] += ticktCount;
        ticktCount = 0;
        remainingTickets = maxTickets;
        
        delete tickets;
    }
    
    function Withdraw() public isWinner
    {
        address payable winner = payable(msg.sender);
        uint256 winningTickets = winnings[winner];
        require(winningTickets > 0);
        
        winnings[winner] = 0;
        
        winner.transfer(winningTickets * ticketPrice);
    }  
        
    
}