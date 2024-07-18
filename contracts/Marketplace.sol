// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./library/VeryfiSignature.sol";

contract Rolable is OwnableUpgradeable {
    mapping(address => bytes32) hasAdminRole;

    function addAdmin(address to, bytes32 role) external onlyOwner {
        hasAdminRole[to] = role;
    }

    modifier onlyAdmin(bytes32 role) {
        require(hasAdminRole[msg.sender] == role, "Permission denied");
        _;
    }
}

contract Treasury is Rolable {
    bytes32 constant treasuryRole =
        0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

    function multiSend(
        address[] memory tos,
        uint[] memory amounts
    ) external onlyAdmin(treasuryRole) {
        require(tos.length == amounts.length, "Invalid request");
        for (uint i = 0; i < tos.length; i++) {
            (bool success, ) = tos[i].call{value: amounts[i]}("");
            require(success, "transfer failed");
        }
    }

    function multiSendFromAdmin(
        address[] memory tos,
        uint[] memory amounts
    ) external payable onlyAdmin(treasuryRole) {
        require(tos.length == amounts.length, "Invalid request");
        uint totalAmount;
        for (uint i = 0; i < tos.length; i++) {
            totalAmount += amounts[i];
        }
        require(msg.value >= totalAmount, "Invvalid amount");
        for (uint i = 0; i < tos.length; i++) {
            (bool success, ) = tos[i].call{value: amounts[i]}("");
            require(success, "transfer failed");
        }
    }

    function multiSendToken(
        address tokenAddress,
        address[] memory tos,
        uint[] memory amounts
    ) external onlyAdmin(treasuryRole) {
        require(tos.length == amounts.length, "Invalid request");
        for (uint i = 0; i < tos.length; i++) {
            IERC20(tokenAddress).transfer(tos[i], amounts[i]);
        }
    }

    function multiSendTokenFromAdmin(
        address tokenAddress,
        address[] memory tos,
        uint[] memory amounts
    ) external onlyAdmin(treasuryRole) {
        require(tos.length == amounts.length, "Invalid request");
        for (uint i = 0; i < tos.length; i++) {
            IERC20(tokenAddress).transferFrom(msg.sender, tos[i], amounts[i]);
        }
    }

    receive() external payable {}

    fallback() external {}
}

contract Marketplace is Treasury {
    /**
     * @dev trading engine
     * This is contract for metamask to import NFT with essential infos. EX, sell,auction
     * createSell
     * cancelSell
     * createAuction
     * cancelAuction
     * importNFT
     * payment: buy, bid
     */

    bytes32 constant marketAdminRole =
        0xc5d24673b7bfad8045d85a4707233c927e7db2dca703c0e0186f500b623ca824;

    modifier hasMarketAdminRole(address signer) {
        require(hasAdminRole[signer] == marketAdminRole, "Permission denied");
        _;
    }

    // events
    event SellCreated(
        address collection,
        uint NFTId,
        address paymentTokenAddress,
        uint price,
        uint startTime,
        uint endTime
    );
    event SellCancelled(address collection, uint NFTId, address owner);
    event AuctionCreated(
        address collection,
        uint NFTId,
        address paymentTokenAddress,
        uint price,
        uint startTime,
        uint endTime
    );
    event NFTImported(address collection, uint NFTId, address owner);
    event PaymentCreated(
        bytes32 orderId,
        address paymentTokenAddress,
        uint amount
    );
    event NFTExported(address collection, uint nftId, address to);
    event NFTTransfered(address collection, uint nftId, address to);

    // signature security
    mapping(bytes => bool) usedSignature;

    function initialize() public initializer {
        __Ownable_init();
    }

    // createSell
    function createSell(
        address collection,
        uint NFTId,
        address paymentTokenAddress,
        uint price,
        uint startTime,
        uint endTime
    ) external {
        ERC721(collection).transferFrom(msg.sender, address(this), NFTId);
        emit SellCreated(
            collection,
            NFTId,
            paymentTokenAddress,
            price,
            startTime,
            endTime
        );
    }

    // cancelSell
    function cancelSell(
        address collection,
        uint NFTId,
        address owner,
        address signer, // sign
        uint deadline,
        bytes memory signature // sign
    ) external {
        require(usedSignature[signature] != true, "signature is already used");
        bytes32 messageHash = keccak256(
            abi.encodePacked("cancelSell", collection, NFTId, owner, deadline)
        );
        require(
            verify(messageHash, signature, signer, deadline),
            "Permission denied"
        );
        usedSignature[signature] = true;
        ERC721(collection).transferFrom(address(this), owner, NFTId);
        emit SellCancelled(collection, NFTId, owner);
    }

    // createAuction
    function createAuction(
        address collection,
        uint NFTId,
        address paymentTokenAddress,
        uint price,
        uint startTime,
        uint endTime
    ) external {
        ERC721(collection).transferFrom(msg.sender, address(this), NFTId);
        emit AuctionCreated(
            collection,
            NFTId,
            paymentTokenAddress,
            price,
            startTime,
            endTime
        );
    }

    // importNFT
    function importNFT(address collection, uint NFTId, address owner) external {
        ERC721(collection).transferFrom(msg.sender, address(this), NFTId);
        emit NFTImported(collection, NFTId, owner);
    }

    // transfer
    function transferNFT(
        address collection,
        uint nftId,
        address to
    ) external payable {
        ERC721(collection).transferFrom(msg.sender, address(this), nftId);
        emit NFTTransfered(collection, nftId, to);
    }

    // export
    function exportNFT(
        address collection,
        uint nftId,
        address to
    ) public onlyAdmin(marketAdminRole) {
        ERC721(collection).transferFrom(address(this), to, nftId);
        emit NFTExported(collection, nftId, to);
    }

    // export
    function exportNFTs(
        address[] memory collections,
        uint[] memory nftIds,
        address[] memory tos
    ) external payable onlyAdmin(marketAdminRole) {
        uint count = collections.length;
        require(
            nftIds.length == count && tos.length == count,
            "Invalid paramters"
        );
        for (uint i = 0; i < count; i++) {
            exportNFT(collections[i], nftIds[i], tos[i]);
        }
    }

    // payment
    function payment(
        bytes32 orderID,
        address paymentTokenAddress,
        uint amount,
        address signer, // sign
        uint deadline, // sign
        bytes memory signature // sign
    ) external payable {
        bytes32 messageHash = keccak256(
            abi.encodePacked(
                "payment",
                orderID,
                paymentTokenAddress,
                amount,
                deadline
            )
        );
        require(
            verify(messageHash, signature, signer, deadline),
            "Permission denied"
        );
        if (paymentTokenAddress == address(0)) {
            require(msg.value >= amount);
        } else {
            IERC20(paymentTokenAddress).transferFrom(
                msg.sender,
                address(this),
                amount
            );
        }

        emit PaymentCreated(orderID, paymentTokenAddress, amount);
    }

    function verify(
        bytes32 messageHash,
        bytes memory signature,
        address signer,
        uint deadline
    ) internal view hasMarketAdminRole(signer) returns (bool) {
        require(deadline >= block.number, "signature has expired");
        require(signer != address(0), "zero address signer");
        bytes32 ethSignedMessageHash = VerifySignature.getEthSignedMessageHash(
            messageHash
        );
        return
            VerifySignature.recoverSigner(ethSignedMessageHash, signature) ==
            signer;
    }
}
