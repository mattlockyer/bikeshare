

//jshint ignore: start

pragma solidity ^0.4.17;

import './Ownable.sol';

contract BikeShare is Ownable {
  
  /**************************************
  * State
  **************************************/
  Bike[] public bikes;
  struct Bike {
    address owner;
    bool isRented;
    uint32 kms;
  }

  struct User {
    uint32 bikeRented;
    uint256 credits;
  }
  //credits
	mapping(address => User) public userProfile;
  //prices and rates
  uint256 creditPrice = 1 finney;
	uint32 cpkm = 5; //cost per km riding
  uint256 donateCredits = 500;
  uint256 repairCredits = 250;
  
  /**************************************
  * Events
  **************************************/
  event Donation(address _from, uint256 _amount);
  event CreditsPurchased(address _to, uint256 _ethAmount, uint256 _creditAmount);
  event BikeRented(address _renter, uint32 _bikeNumber);
  event BikeRidden(address _renter, uint32 _bikeNumber, uint32 _kms);
  event BikeReturned(address _renter, uint32 _bikeNumber);
  event Transfer(address indexed from, address indexed to, uint256 value);

	/**************************************
  * constructor
  **************************************/
	function BikeShare() public {
	  //init with 5 bikes from the bikeshare owner
	  //we never rent bike 0, so we'll initialize 6 bikes
	  for (uint8 i = 0; i < 6; i++) {
	    bikes.push(Bike({ owner: msg.sender, isRented: false, kms: 0 }));
	  }
	}
	
	/**************************************
  * setters for bikeshare owner
  **************************************/
	function setCreditPrice(uint256 _creditPrice) onlyOwner public { creditPrice = _creditPrice; }
	function setCPKM(uint32 _cpkm) onlyOwner public { cpkm = _cpkm; }
	function setDonateCredits(uint256 _donateCredits) onlyOwner public { donateCredits = _donateCredits; }
	function setRepairCredits(uint256 _repairCredits) onlyOwner public { repairCredits = _repairCredits; }
	
	/**************************************
  * getters not provided by compiler
  **************************************/
	function getAvailable() public view returns (bool[]) {
	  bool[] memory available = new bool[](bikes.length);
	  //loop begins at index 1, never rent bike 0
	  for (uint8 i = 1; i < bikes.length; i++) {
	    if (bikes[i].isRented) {
	      available[i] = true;
	    }
	  }
	  return available;
	}
	
	/**************************************
  * default payable function to purchase credits
  **************************************/
  function() payable public {
    purchaseCredits();
  }
  //buying credits using ETH
  // Note the "internal"
  function purchaseCredits() internal {
    uint256 amount = msg.value / creditPrice; // flooring division
    userProfile[msg.sender].credits += amount;
    CreditsPurchased(msg.sender, msg.value, amount);
  }
  
  /**************************************
  * donating bicycles
  **************************************/
	function donateBike() public {
    bikes.push(Bike({ owner: msg.sender, isRented: false, kms: 0 }));
	  userProfile[msg.sender].credits += donateCredits;
	  Donation(msg.sender, donateCredits);
	}
	
  /**************************************
  * Modifiers
  **************************************/
  modifier onlyBikeOwner(uint32 _bikeNumber) {
    require(bikes[_bikeNumber].owner == msg.sender);
    _;
  }
  modifier canRent(uint32 _bikeNumber) {
    require(userProfile[msg.sender].bikeRented == 0 && !bikes[_bikeNumber].isRented);
    _;
  }
  modifier hasRental() {
    require(userProfile[msg.sender].bikeRented != 0);
    _;
  }
	modifier hasCredits(uint256 _kms) {
	  require(userProfile[msg.sender].credits - _kms * cpkm > 0);
    _;
  }
  
	/**************************************
  * bike functions
  **************************************/
	function rentBike(uint32 _bikeNumber) public canRent(_bikeNumber) {
	  userProfile[msg.sender].bikeRented = _bikeNumber;
	  bikes[_bikeNumber].isRented = true;
	  BikeRented(msg.sender, _bikeNumber);
	}
	
	function rideBike(uint32 _kms) public hasRental hasCredits(_kms) {
	  bikes[userProfile[msg.sender].bikeRented].kms += _kms;
	  userProfile[msg.sender].credits -= _kms * cpkm;
	  BikeRidden(msg.sender, userProfile[msg.sender].bikeRented, _kms);
	}
	
	function returnBike() public hasRental {
	  bikes[userProfile[msg.sender].bikeRented].isRented = false;
	  userProfile[msg.sender].bikeRented = 0;
	  BikeReturned(msg.sender, userProfile[msg.sender].bikeRented);
	}

    function transferCredits(address _to, uint256 _value) public returns(bool) {
        require(_to != address(0));
        require(_value <= userProfile[msg.sender].credits);

        userProfile[msg.sender].credits = userProfile[msg.sender].credits -_value;
        // Not prossible to reach, but showing what assert is used for
        assert(userProfile[msg.sender].credits > 0);
        userProfile[_to].credits = userProfile[_to].credits += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }
}

  // Challenge 1: Refactor the code so we only use 1 mapping
  // Challenge 2: Bikers should be able to transfer credits to a friend
  // Challenge 3: As of right now, the Ether is locked in the contract and cannot move,
  // make the Ether transferrable to your address immediately upon receipt

  // Advanced challenge 1: Decouple the "database" aka mapping into another contract.
  // Advanced challenge 2: Include an overflow protection library (or inherit from a contract)
  // Advanced challenge 3: Develop an efficient way to track and store kms per rental, per user
  // Advanced challenge 4: Add a repair bike bounty where the work can be claimed by a user and verified by another user
  // Advanced challenge 5: Allow all users to vote on how many credits should be given for a donated bike within a time frame

