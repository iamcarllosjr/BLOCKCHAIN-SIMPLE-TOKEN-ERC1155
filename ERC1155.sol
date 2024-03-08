// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

//ERC1155, permite a criação e mint de multi tokens 
contract MyToken is ERC1155, Ownable, ERC1155Pausable, ERC1155Supply {
    //Erros customizados
    error MaxSupplyExceeded(uint);
    error ValueIsNotEnough(uint);
    error IdDoenstExist(uint);
    error MaxPerWalletReached(uint);
    error FailedTranfer();
    error URIQueryForNonExistentToken();

    uint256 public maxSuply = 50;
    uint8 public Id = 0;
    uint256 public currentSupply = 0;
    string public name;

    mapping(address => uint8) public walletMinted;

    constructor(address initialOwner)
        ERC1155(
            "https://ipfs.io/ipfs/QmRm5aRGSD15RVjjj3yp7Ud5AsgaJvpabDhw4jPwd4awUk/{id}.json"
        )
        Ownable(initialOwner)
    {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    //Função para adicionar e retornar o .json na URL do metadados IPFS.
    function uri(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        if (!exists(_tokenId)) revert URIQueryForNonExistentToken();
        return string(abi.encodePacked("https://ipfs.io/ipfs/QmRm5aRGSD15RVjjj3yp7Ud5AsgaJvpabDhw4jPwd4awUk/", Strings.toString(_tokenId), ".json"));
    }


    //contractURI - Função para passar os metadados da coleção para o Opensea/Rarible
    //Deve conter o link para o arquivo json  igual a baixo, e o arquivo deve apontar para a imagem da coleção
    /* 
    {
      "name": "Name Of Colletion",
      "description": "Description", 
      "image": "https://ipfs.io/ipfs/HASH_HERE/name.json", 
      "external_url": "Website"
    }
    */
    function contractURI() public pure returns (string memory) {
        return
            "https://ipfs.io/ipfs/Qmawc6exH9rDDNCtVyNxkx8BWZHDCCwaGGXtKJCn1mBWwY?filename=colletions.json";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(uint256 amount)
        public onlyOwner
        whenNotPaused
    {

        if (currentSupply + amount > maxSuply) {
            revert MaxSupplyExceeded(amount);
        }

         for (uint256 i = 0; i < amount; i++){
            _mint(msg.sender, Id, 1, "");
            currentSupply += 1; // Incrementa apenas 1 a cada iteração
            walletMinted[msg.sender] += 1; // Incrementa apenas 1 a cada iteração
         }
    }


    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyOwner {
        _mintBatch(to, ids, amounts, data);
    }
    
    //Função para retornar atual supply de um token pelo ID (para usar no frontend)
    function getCurrentSupply() public view returns (uint256) {
        return currentSupply;
    }

    //Função para retornar total max de supply de um token pelo ID (para usar no frontend)
    function getMaxSupplies() public view returns (uint256) {
        return maxSuply;
    }

    //Função para editar o MaxSuplies e MaxPerWallet
    function editRestrictions(uint256 _newMaxSupplies) external onlyOwner {
        maxSuply = _newMaxSupplies;
       
    }


    // The following functions are overrides required by Solidity.

    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal override(ERC1155, ERC1155Pausable, ERC1155Supply) {
        super._update(from, to, ids, values);
    }
}