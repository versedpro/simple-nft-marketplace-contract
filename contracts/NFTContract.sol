// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

library Base58 {
    bytes constant prefix1 = hex"0a";
    bytes constant prefix2 = hex"080212";
    bytes constant postfix = hex"18";
    bytes constant sha256MultiHash = hex"1220";
    bytes constant ALPHABET =
        "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";

    /// @dev Converts hex string to base 58
    function toBase58(
        bytes memory source
    ) internal pure returns (bytes memory) {
        //   function toBytes(uint256 x) returns (bytes b) {

        if (source.length == 0) return new bytes(0);
        uint8[] memory digits = new uint8[](64); //TODO: figure out exactly how much is needed
        digits[0] = 0;
        uint8 digitlength = 1;
        for (uint256 i = 0; i < source.length; ++i) {
            uint carry = uint8(source[i]);
            for (uint256 j = 0; j < digitlength; ++j) {
                carry += uint(digits[j]) * 256;
                digits[j] = uint8(carry % 58);
                carry = carry / 58;
            }

            while (carry > 0) {
                digits[digitlength] = uint8(carry % 58);
                digitlength++;
                carry = carry / 58;
            }
        }
        //return digits;
        return toAlphabet(reverse(truncate(digits, digitlength)));
    }

    function truncate(
        uint8[] memory array,
        uint8 length
    ) internal pure returns (uint8[] memory) {
        uint8[] memory output = new uint8[](length);
        for (uint256 i = 0; i < length; i++) {
            output[i] = array[i];
        }
        return output;
    }

    function reverse(
        uint8[] memory input
    ) internal pure returns (uint8[] memory) {
        uint8[] memory output = new uint8[](input.length);
        for (uint256 i = 0; i < input.length; i++) {
            output[i] = input[input.length - 1 - i];
        }
        return output;
    }

    function toAlphabet(
        uint8[] memory indices
    ) internal pure returns (bytes memory) {
        bytes memory output = new bytes(indices.length);
        for (uint256 i = 0; i < indices.length; i++) {
            output[i] = ALPHABET[indices[i]];
        }

        return output;
    }
}

contract NFT is ERC721Enumerable, Ownable {
    using Address for address;
    using Strings for uint;
    using Base58 for bytes;
    mapping(uint => address) creators;

    string private baseUri;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        baseUri = "https://ipfs.idealbridgex.com/ipfs";
    }

    function setBaseUri(string memory uri) public onlyOwner {
        baseUri = uri;
    }

    function creatorOf(uint tokenId) public view virtual returns (address) {
        address creator = creators[tokenId];
        require(
            creator != address(0),
            "ERC721: owner query for nonexistent token"
        );
        return creator;
    }

    // public
    function mint(uint tokenId) public payable onlyOwner {
        _safeMint(msg.sender, tokenId);
        creators[tokenId] = msg.sender;
    }

    function tokenIdsOfOwner(
        address _owner
    ) public view returns (uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function tokenURI(
        uint tokenId
    ) public view override returns (string memory) {
        bytes memory src = new bytes(32);
        assembly {
            mstore(add(src, 32), tokenId)
        }
        bytes memory dst = new bytes(34);
        dst[0] = 0x12;
        dst[1] = 0x20;
        for (uint i = 0; i < 32; i++) {
            dst[i + 2] = src[i];
        }
        return string(abi.encodePacked(baseUri, "/", dst.toBase58()));
    }
}
