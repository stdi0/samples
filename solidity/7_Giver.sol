pragma solidity >=0.5.0;

import "7_CrashContract.sol";

abstract contract AbstractContract {
	function receiveTransfer(uint64 number) public virtual;
}


//This contract allows to perform different kinds of currency transactions and control the result using the fallback function.
contract Giver {

	// Modifier that allows public function to accept all external calls.
	modifier alwaysAccept {
		// Runtime function that allows contract to process inbound messages spending
		// its own resources (it's necessary if contract should process all inbound messages,
		// not only those that carry value with them).
		tvm.accept();
		_;
	}

	// State variable storing the number of times fallback function was called.
	uint Counter = 0;

	// Fallback function that is executed on a call to the contract if none of the other
	// functions match the given function identifier. This function is also executed if
	// the caller meant to call a function that is not available.
	fallback() external {
		Counter += 1;
	}

	receive() external {
		Counter += 1;
	}

	onBounce(TvmSlice /*slice*/) external {
		Counter += 1;
	}

	// Function to obtain fallback counter
	function getCounter() public view alwaysAccept returns (uint) {
		return Counter;
	}


	// This function can transfer currency to an existing contract with fallback
	// function.
	function transferToAddress(address destination, uint128 amount) public pure alwaysAccept {
		destination.transfer(amount);
	}

	// This function calls an AbstractContract which would case a crash and call of onBounce function.
	function transferToAbstractContract(address destination, uint amount) public alwaysAccept {
		AbstractContract(destination).receiveTransfer.value(amount)(123);
	}

	// This function call a CrashContract's function which would cause a crash during transaction
	// and call of onBounce function.
	function transferToCrashContract(address destination, uint amount) public alwaysAccept {
		CrashContract(destination).doCrash.value(amount)();
	}

	// Function which allows to make a transfer to an arbitrary address.
	function do_tvm_transfer(address remote_addr, uint128 grams_value, bool bounce, uint16 sendrawmsg_flag) pure public alwaysAccept {
		// Runtime function that allows to make a transfer with arbitrary settings
		// and can be used to send grams to non-existing address.
		remote_addr.transfer(grams_value, bounce, sendrawmsg_flag);
	}

}
