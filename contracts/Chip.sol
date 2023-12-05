// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./token/ERC721/ERC721.sol";
import "./token/ERC721/ERC721Enumerable.sol";
import "./access/AccessControlEnumerable.sol";
import "./utils/Counters.sol";
import "./access/Ownable.sol";
import "./token/common/ERC2981.sol";
import "./token/ERC721/ERC721URIStorage.sol";

contract ChipToken is ERC2981, ERC721Enumerable, Ownable, ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping (uint => uint) public tokenLockedFromTimestamp;
    mapping (uint => bytes32) public tokenUnlockCodeHashes;
    mapping (uint => bool) public tokenUnlocked;

    string private _baseTokenURI;


    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    /**
    * This one is the mint function that sets the unlock code, then calls the parent mint
    */
    function mint(address to, address royaltyReceiver, uint96 royaltyAmount, string memory uri) public {
        
         require(msg.sender == owner(), "LockableToken: must have minter role to mint");

        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        _mint(to, _tokenIds.current());
        _setTokenURI(_tokenIds.current(), uri);


        if (royaltyReceiver != address(0) && royaltyAmount > 0) {
            _setTokenRoyalty(_tokenIds.current(), royaltyReceiver, royaltyAmount);
        }
        _tokenIds.increment();
    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
       return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC2981, ERC721Enumerable, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) virtual {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}