# B9Lab_Splitter
Project 1: B9lab Ethereum Community Blockstar

# What
You will create a smart contract named Splitter whereby:

there are 3 people: Alice, Bob and Carol.
we can see the balance of the Splitter contract on the Web page.
whenever Alice sends ether to the contract for it to be split, half of it goes to Bob and the other half to Carol.
we can see the balances of Alice, Bob and Carol on the Web page.
Alice can use the Web page to split her ether.
We purposely left a lot to be decided. Such description approximates how your human project sponsors would describe the rules. As the Ethereum Smart Contract specialist, you have to think things through.

That's it! This is where you put hand to keyboard.

It would be even better if you could team up with different people impersonating Alice, Bob and Carol, all cooperating on a test net.

# Low Difficulty
Did you check proper msg.value or did you read from a cheaply misleading amount parameter?
Did you check the bool return value of address.send()?
Did you revert() when something fails?
Did you create redundant methods to get balance, when the facility is already there with web3?
Did you wrongly assume that preventing other contracts from interacting was a good idea?

# Medium Difficulty
Did you pass proper beneficiary addresses as part of the constructor? Instead of using a setter afterwards.
Did you check for empty addresses? Which may happen on badly formatted transactions.
Did you split msg.value and forgot that odd values may leave 1 wei in the contract balance?
Did you close the fallback function? You only leave it open if necessary. Usually you do not need it.
Did you provide a kill / pause switch?
Do your events make it possible to reconstruct the whole contract state?
Did you mark functions as payable strictly when necessary?
Did you write any test? Do they cover illegal actions?
Would your tests fail if your Solidity code was incorrect?

# High Difficulty
Did you send (a.k.a. push) the funds instead of letting the beneficiaries withdraw (a.k.a. pull) the funds?
If you pushed the funds, did you cover a potential reentrance? I.e. did you update all your state before making the transfer?

# Before moving on
In the next module, you will work on your next project. But because we do not want you to repeat the same mistakes in it as you would in the Splitter, we would like you to take your Splitter to a satisfactory level. And this level is:
Pull pattern implemented.
Proper events.
Good coverage of your units tests, including rejected situations.
At least 1 unit test that tests the withdraw feature with exact balance checking.
Inheritance with Owned and Pausable.
