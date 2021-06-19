// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract Lottery {
    
    uint256 public constant ticketPrice = 1 ether;
    uint256 public constant maxTickets = 100;       // maximum tickets available per lottery
    address public lotteryOperator;                 // the creator of the lottery
    
    mapping (address => uint256) winnings;          // maps the winners to their winnings
    address[] tickets;                              // the array of purchased tickets
    
    
    // modifier to check if caller is the lottery operator
    modifier isOperator() {
        require(msg.sender == lotteryOperator, "Caller is not the lottery operator");
        _;
    }
    
    // modifier to check if caller is a winner
    modifier isWinner() {
        require(IsWinner(), "Caller is not a winner");
        _;
    }
    
    constructor()
    {
        lotteryOperator = msg.sender;
    }
    
    function BuyTickets() public payable
    {
        require(msg.value % ticketPrice == 0, "the value must be multiple of 1 Ether");
        uint256 numOfTicketsToBuy = msg.value / ticketPrice;
        
        require(numOfTicketsToBuy < RemainingTickets(), "Not enough tickets available.");
        
        for (uint i = 0; i < numOfTicketsToBuy; i++)
        {
            tickets.push(msg.sender);
        }
        
    }
    
    function DrawWinnerTicket() public isOperator
    {
        require(tickets.length > 0, "No tickets were purchased");
        uint256 randomNum = uint(blockhash(block.number-1)) % tickets.length;
        
        address winner = tickets[randomNum];
        winnings[winner] += tickets.length;
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
    
    function IsWinner() public view returns(bool)
    {
        return winnings[msg.sender] > 0;
    }
    
    function CurrentWinningReward() public view returns(uint256)
    {
        return tickets.length * ticketPrice;
    }
    
    function RemainingTickets() public view returns(uint256)
    {
        return maxTickets - tickets.length;
    }    
}