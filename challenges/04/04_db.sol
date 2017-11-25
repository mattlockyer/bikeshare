pragma solidity 0.4.17;

contract BikeshareDB {
    address owner;
    address bikeShareContract;

    struct User {
        uint32 bikeRented;
        uint256 credits;
    }

    mapping(address => User) public userProfile;

    function BikeshareDB(address _bikeShareContract) {
        bikeShareContract = _bikeShareContract;
        owner = msg.sender;
    }

    modifier onlyBikeShareContract() {
        require(msg.sender == bikeShareContract);
        _;
    }

    function set(address _msgSender, uint256 _credits, uint32 _bikeRented) external onlyBikeShareContract returns(bool) {
        userProfile[_msgSender].credits = _credits;
        userProfile[_msgSender].bikeRented = _bikeRented;
        return true;
    }

    function get(address _msgSender) public constant onlyBikeShareContract returns(uint256, uint32) {
        return (userProfile[_msgSender].credits, userProfile[_msgSender].bikeRented);
    }

    // simple and easy, but no validation
    function increaseCredit(address _msgSender, uint256 _amount) external onlyBikeShareContract returns(bool) {
        userProfile[_msgSender].credits += _amount;
        return true;
    }

    function changeBikeRented(address _msgSender, uint32 _bikeNumber) external onlyBikeShareContract  returns(bool) {
        userProfile[_msgSender].bikeRented = _bikeNumber;
        return true;
    }

    function getRented(address _msgSender) external onlyBikeShareContract  returns(uint32) {
        return userProfile[_msgSender].bikeRented;
    }

    function getCredits(address _msgSender) external onlyBikeShareContract  returns(uint256) {
        return userProfile[_msgSender].credits;
    }
    
}