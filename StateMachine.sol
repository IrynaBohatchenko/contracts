pragma solidity ^0.4.11;

import "./StandartToken.sol";

contract ICOStages {
    
    enum Stages {
        ICO,
        PostICO
    }
    
    Stages public stage = Stages.ICO;
    
    StandartToken public myToken = StandartToken (1000);
    
    uint public creationTime = now;
    uint constant public CROWDFUNDING_PERIOD = 12 days;
    
    address public multisig;
    uint public startDate = 0;
    
    mapping (address => uint) public investments;
    
    modifier atStage(Stages _stage) {
        require(stage == _stage);
        _;
    }

    function nextStage() internal {
        stage = Stages(uint(stage) + 1);
    }
    
    modifier timedTransitions() {
        if (stage == Stages.ICO && now >= creationTime + 1 minutes)
            nextStage();
        if (stage == Stages.PostICO && now >= creationTime + 5 minutes)
            nextStage();
        // The other stages transition by transaction
        _;
    }
    
    modifier transitionNext()
    {
        _;
        nextStage();
    }
    
    function calculateToken()
        payable
        timedTransitions
        atStage(Stages.ICO)
    {
        uint buyPrice = myToken.buyPrice();
        uint amount = msg.value / buyPrice;
        investments[msg.sender] = amount;
    }
    
    function fund()
        payable
        timedTransitions
        atStage(Stages.PostICO)
    {
        myToken.mintToken(msg.sender, investments[msg.sender]);
        myToken.balanceOf[msg.sender] += investments;
    }

}
