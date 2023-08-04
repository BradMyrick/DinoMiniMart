    // SPDX-License-Identifier: MIT
    pragma solidity ^0.8.17;

    import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
    import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
    import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
    import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; // Make sure to import ReentrancyGuard

    contract DinoMiniMart is IERC721Receiver, ReentrancyGuard {
        // Mapping from NFT Token ID to the owner's address
        mapping(uint256 => address) private _deposits;

        // Mapping from NFT Token ID to the amount of WETH tokens to sell it for
        mapping(uint256 => uint256) private _prices;

        // Mapping for withdrawal pattern (seller => balance)
        mapping(address => uint256) private _balances;

        // Reference to the ERC721 Token
        IERC721 private _nftToken;

        // Reference to the ERC20 Token (WETH) for the reward
        IERC20 private _wethToken;

        // Events
        event Deposit(address indexed owner, uint256 indexed tokenId, uint256 amount);
        event Withdrawal(address indexed owner, uint256 amount);
        event Purchase(address indexed buyer, uint256 indexed tokenId, uint256 amount);

        constructor(address nftAddress, address wethAddress) {
            _nftToken = IERC721(nftAddress);
            _wethToken = IERC20(wethAddress);
        }

        // sell function for sellers
        function sell(uint256 tokenId, uint256 amount) external nonReentrant {
            require(_deposits[tokenId] == address(0), "Deposit already exists");
            require(amount > 0, "Amount must be greater than 0");
            // safe transfer handles the ownership check
            _nftToken.safeTransferFrom(msg.sender, address(this), tokenId);
            _deposits[tokenId] = msg.sender;
            _prices[tokenId] = amount;

            emit Deposit(msg.sender, tokenId, amount);
        }

        function withdraw(uint256 tokenId) external nonReentrant {
            require(_deposits[tokenId] == msg.sender, "Not the owner of this deposit");

            _nftToken.safeTransferFrom(address(this), msg.sender, tokenId);
            delete _deposits[tokenId];
            delete _prices[tokenId];
        }

        function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
            return this.onERC721Received.selector;
        }

        function getDepositOwner(uint256 tokenId) external view returns (address) {
            return _deposits[tokenId];
        }

        function getPrice(uint256 tokenId) external view returns (uint256) {
            return _prices[tokenId];
        }

        function buy(uint256 tokenId) external nonReentrant {
            require(_deposits[tokenId] != address(0), "No deposit for this NFT");
            require(_prices[tokenId] != 0, "No price for this NFT");

            address seller = _deposits[tokenId];
            uint256 price = _prices[tokenId];

            delete _deposits[tokenId];
            delete _prices[tokenId];

            // Adding balance to the seller's account instead of transferring directly for safety
            uint256 balance = _balances[seller];
            uint256 newBalance = balance + price;
            // Overflow check
            require(newBalance >= balance, "Balance overflow");
            
            _wethToken.transferFrom(msg.sender, address(this), price);
            _nftToken.safeTransferFrom(address(this), msg.sender, tokenId);
            
            _balances[seller] = newBalance;

            emit Purchase(msg.sender, tokenId, price);
        }

        // Withdrawal function for sellers
        function withdrawBalance() external nonReentrant {
            uint256 amount = _balances[msg.sender];
            require(amount > 0, "No balance to withdraw");

            _balances[msg.sender] = 0;

            _wethToken.transfer(msg.sender, amount);
            emit Withdrawal(msg.sender, amount);
        }

        // Function to check balance of a seller
        function getBalance(address seller) external view returns (uint256) {
            return _balances[seller];
        }

        // Function to display the nft contract address and weth contract address
        function showContractAddresses() external view returns (address, address) {
            return (address(_nftToken), address(_wethToken));
        }
    }
