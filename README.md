# Dino Mini Mart
## A simple NFT marketplace for ERC721 tokens by KODR.eth
How to Use

Here's a guide to using my DinoMiniMart contract, including all the approvals needed:
1. Setup Approvals:

    For Sellers (NFT Owners):
        Before calling the deposit function to list an NFT for sale, the seller must first approve the DinoMiniMart contract to transfer their NFT. This can be done by calling the approve function on the ERC721 contract with the DinoMiniMart contract's address and the tokenId they want to sell.
    For Buyers (WETH Owners):
        Before calling the buy function to purchase an NFT, the buyer must approve the DinoMiniMart contract to transfer the WETH amount equivalent to the NFT's price. This can be done by calling the approve function on the ERC20 WETH contract with the DinoMiniMart contract's address and the amount they want to allow.

2. Deposit NFT:

    Call the deposit(uint256 tokenId, uint256 amount) function, specifying the tokenId you wish to sell and the price (in WETH) you wish to sell it for. remember to add the appropriate 0's

3. Withdraw NFT:

    If you want to withdraw the NFT without selling it, call the withdraw(uint256 tokenId) function. Only the depositor can withdraw the NFT.

4. Buy NFT:

    Call the buy(uint256 tokenId) function to purchase an NFT that's for sale. Ensure that the amount of WETH required is approved for transfer by the DinoMiniMart contract.

5. Withdraw Balance:

    Sellers can withdraw their balance (WETH) after a sale by calling the withdrawBalance() function.

6. Check Information:

    Use getDepositOwner, getPrice, and getBalance to retrieve information about the deposits, prices, and seller balances.

Is this safe? Yes I made it, but incase you need reassurance, here's a list of the security measures I took:

    Non-Reentrant:
        By using the ReentrancyGuard, the contract prevents reentrant calls, which can be used to exploit certain functions and manipulate contract state.

    Ownership Checks:
        The contract ensures that only the deposit owner can withdraw the NFT by using safeTransfer from the underlying erc721, and proper checks are in place for buying and selling, reducing the chance of unauthorized actions.

    Use of Standard Interfaces:
        The contract is built to interact with standard ERC721 and ERC20 tokens, ensuring compatibility with well-established token contracts.

    Withdrawal Pattern:
        Using the withdrawal pattern instead of direct transfers for seller balances reduces the attack surface related to reentrancy and control over external contract calls.

Even though I do this for a living daily, you're always welcome to audit and please DYOR. 
I'm not responsible for any losses you incur from using this contract and I have no control after deployment.
Dencentralized Finance is risky, and you should be aware of the risks before using this contract.

#KODR
```
