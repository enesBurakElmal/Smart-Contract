// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.1;

// We need some util functions for strings.
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import { Base64 } from "./libraries/Base64.sol";


contract MyEpicNFT is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

    

  string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";
  
  //  BASED NFT ITEMS HERE
  string[] firstWords = ["DARIUS-", "RENEKTON-", "VOLIBEAR-", "GANGPLANK-", "WUKONG-", "RENGAR-" , "TEEMO-"];
  string[] secondWords = ["SHACO-", "VI-", "RAMMUS-", "HECARIM-", "AMUMU-", "WARWICK-", "SEJUANI-"];
  string[] thirdWords = ["AHRI-", "VEIGAR-", "YASUO-", "SYNDRA-", "MALZAHAR-", "AKALI-", "ZIGGS-"];
  string[] fourthWords =  ["TRISTANA-", "CAITLYN-", "JHIN-", "JINX-", "ASHE-", "LUCIAN-", "VAYNE-"];
  string[] fifthWords =  ["JANNA", "ALISTAR", "LEONA", "BLITZCRANK", "MORGANA", "SONA", "SORAKA"];

  constructor() ERC721 ("LoLNFT", "ForFun") {
    console.log("League of Legends Your Comp. NFT Compiler");
  }

  mapping(uint256 => uint256) public tokenPrice;

  // Functions supporting erc standards

    function safeSell (uint256 _tokenId, uint256 _price) public payable {  // using "payable" for token transfer standarts. e.g.: there was a bug and the product crashed to 0 tokens. the request is denied. - token transfer standartlari icin "payable" kullaniyorum. ornek: herhangi bi bug olusur ve coin 0 token'a duserse islem oto reddedilir.
    require(msg.value == tokenPrice[_tokenId]); // check if the price and price is correct - fiyati ve fiyatin dogrulugunu kontrol ediyoruz
    require(ownerOf(_tokenId) == msg.sender); // Only the owner can sell - satan kisinin owner(bizim) oldugunu kontrol ediyoruz
    tokenPrice[_tokenId] = _price; // set a token price - tokenin fiyatini belirliyoruz
    approve(address(this), _tokenId); // approve the token to be sold - tokeni satis icin onayliyoruz
  }

  uint256 public tokensPerEth = 100;
  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

    function buyTokens() public payable returns (uint256 tokenAmount) {
    uint256 amountToBuy = msg.value * tokensPerEth;  // tokenin fiyatini belirliyoruz
    uint256 userBalance =  balanceOf(address(this)); // sozlesme cuzdaninda yeterli bakiye yoksa islem reddedilir.
    require(userBalance >= amountToBuy, "The contract owner does not have enough balance");
    transferFrom(address(this), msg.sender, amountToBuy); // tokeni kontrat sahibine cekiyoruz
    emit BuyTokens(msg.sender, msg.value, amountToBuy); //  event emiteri ile tokeni sozlesme sahibine cekiyoruz
    return amountToBuy;
  }
 

  // function safeBuy (uint256 _tokenId) public payable { // using "payable" for token transfer standarts. e.g.: there was a bug and the product crashed to 0 tokens. the request is denied. - token transfer standartlari icin "payable" kullaniyorum. ornek: herhangi bi bug olusur ve coin 0 token'a duserse islem oto reddedilir.
  //   require(tokenPrice[_tokenId] >= msg.value); // check if the price and price is correct - fiyati ve fiyatin dogrulugunu kontrol ediyoruz
  //   address from = msg.sender; // set the sender of the token - tokenin gonderenini belirliyoruz
  //   address to = address(this) // set the owner of the token - tokenin owner(bizim) oldugunu kontrol ediyoruz
  //   transferFrom(from, to, tokenId);
  // }

 

  function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
    rand = rand % firstWords.length;
    return firstWords[rand]; 
  }

  function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
    rand = rand % secondWords.length;
    return secondWords[rand];
  }

  function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
    rand = rand % thirdWords.length;
    return thirdWords[rand];
  }

    function pickRandomFourthWords(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("FOURTH_WORD", Strings.toString(tokenId))));
    rand = rand % fourthWords.length;
    return fourthWords[rand];
  }

    function pickRandomFifthWords(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("FIFTH_WORD", Strings.toString(tokenId))));
    rand = rand % fifthWords.length;
    return fifthWords[rand];
  }

      event NewEpicNFTMinted(address sender, uint256 tokenId);

  function random(string memory input) internal pure returns (uint256) {
      return uint256(keccak256(abi.encodePacked(input)));
  }
 
  function makeAnEpicNFT() public {
    uint256 newItemId = _tokenIds.current();

    // We go and randomly grab one word from each of the three arrays.
    string memory first = pickRandomFirstWord(newItemId);
    string memory second = pickRandomSecondWord(newItemId);
    string memory third = pickRandomThirdWord(newItemId);
    string memory fourth = pickRandomFourthWords(newItemId);
    string memory fifth = pickRandomFifthWords(newItemId);

    string memory combinedWord = string(abi.encodePacked(first, second, third, fourth, fifth));

    string memory finalSvg = string(abi.encodePacked(baseSvg, combinedWord, "</text></svg>"));

    // Get all the JSON metadata in place and base64 encode it.
    string memory json = Base64.encode(
        bytes(
            string(
                abi.encodePacked(
                    '{"name": "',
                    combinedWord,
                    '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                    Base64.encode(bytes(finalSvg)),
                    '"}'
                )
            )
        )
    );



    // Just like before, we prepend data:application/json;base64, to our data.
    string memory finalTokenUri = string(
        abi.encodePacked("data:application/json;base64,", json)
    );

    console.log("\n--------------------");
    console.log(  "https://nftpreview.0xdev.codes/?code=", finalTokenUri);
    console.log("--------------------\n");

    _safeMint(msg.sender, newItemId);
    
    _setTokenURI(newItemId, finalTokenUri);

    _tokenIds.increment();
    console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
    emit NewEpicNFTMinted(msg.sender, newItemId);
  }


}