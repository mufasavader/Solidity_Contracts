//coded by mufasavader

pragma solidity >=0.7.0 <0.9.0;

contract Escrow {
    // Variables

    enum State {NOT_INTIATED, AWAITING_PAYMENT, AWAITING_CONFIRMATION, COMPLETE}

    State public currState;

    bool public isBuyerIn;
    bool public isSellerIn;

    uint256 public price;

    address public buyer;
    address payable public seller;
    address public abitrator;

    // Modifiers

    //Buyer
    modifier onlyBuyer() {
        require(msg.sender == buyer, "only buyer can call this function");
        _;
    }

    //Abitrator
    modifier onlyAbitrator() {
        require(
            msg.sender == abitrator,
            "only abitrator can call this function"
        );
        _;
    }

    //escrow Not started
    modifier escrowNotStarted() {
        require(currState == State.NOT_INTIATED);
        _;
    }

    //Functions
    constructor(
        address _buyer,
        address payable _seller,
        address _abbitrator,
        uint256 _price
    ) {
        buyer = _buyer;
        seller = _seller;
        price = _price;
        abitrator = _abbitrator;
    }

    //intializes the contract
    function initContract() public escrowNotStarted {
        if (msg.sender == buyer) {
            isBuyerIn = true;
        }
        if (msg.sender == seller) {
            isSellerIn = true;
        }
        if (isBuyerIn && isSellerIn) {
            currState = State.AWAITING_PAYMENT;
        }
    }

    //The Onchain Peer deposits the funds
    function deposit() public payable onlyBuyer {
        require(currState == State.AWAITING_PAYMENT, "Already Paid");
        require(msg.value == price, "Wrong Deposit Amount");
        currState = State.AWAITING_PAYMENT;
    }

    //confirmation from our end
    function confirmation() public payable onlyAbitrator {
        require(
            currState == State.AWAITING_CONFIRMATION,
            "Cannot confirm from abitrator"
        );
        seller.transfer(price);
        currState = State.COMPLETE;
    }

    function withdraw() public payable onlyBuyer {
        require(
            currState == State.AWAITING_CONFIRMATION,
            "Cannot withdraw at this stage"
        );
        payable(msg.sender).transfer(price);
        currState = State.COMPLETE;
    }
}
