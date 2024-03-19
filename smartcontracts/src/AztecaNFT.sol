// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract AztecaNFT is ERC721 {
    using Strings for uint256;
    uint256 tokensId;
    uint256 maxSupply = 2; //ESTA ENTIDADE DEFINE O MÁXIMO DE TOKENS QUE PODEM EXISTIR NESSE CONTRATO
    uint256 price = 0.07 ether;
    string internal baseUri = "https://harlequin-famous-heron-61.mypinata.cloud/ipfs/QmXPazcSy69GV2G1XKi88bwUP33YenmvQsQgpsYw3whXLa/";

    mapping(uint256 _tokenId => string _tokeURI) private _tokensURI;

    constructor() ERC721("Azteca", "AZT") {
    }

    //ESTE CONTRATO DE EXEMPLO NÃO TEVE A CRIAÇÃO DO WITHDRAW, ESTA É UMA FUNÇÃO QUE TRANSFERE O DINHEIRO DA COMPRA DAS NFT PARA UMA CARTEIRA

    //ESTA FUNÇÃO FOI CRIADA POR NÓS PARA FAZER UMA RELAÇÃO COM O TOKEN E A URI
    function _setTokenURI(uint256 _tokenId) internal {
        require(_owners[_tokenId] != address(0), "TOKEN DOES NOT EXIST");
        _tokensURI[_tokenId] = tokenURI(_tokenId);
    }

    //ESTA FUNÇÃO IRÁ TRATAR A FORMAÇÃO DE UM NFT, APÓS TRATAR OS DADOS ELA IRÁ CHAMA A _SAFEMINT DA BIBLIOTECA A QUAL É UMA FUNÇÃO PRIVA, OU SEJA É NECESSÁRIO A CONSTRUÇÃO DE UMA FUNÇÃO PÚBLICA EM ALGUM MOMENTO PARA QUE POSSA SER CHAMADO DE FORMA EXTERNA A CRIAÇÃO DE NOVOS NFT
    //APESAR DA FUNÇÃO UTILIZAR UMA ESTRUTURA DE LOOPING ELA NÃO É RECOMENDADA POIS CONSOME MUITA GAS
    function makeMint(address _to, uint256 _amount) public payable {
        uint256 calcValue = price * _amount;
        require(msg.value == calcValue, "CHN: Value is not enough");

        for(uint256 i = 0; i < _amount; i++) {
            tokensId += 1;
            _safeMint(_to, tokensId);
            _setTokenURI(tokensId);
        }
    }

    //FUNÇÃO CRIADA POR NOS PARA FORNECER A URI VINCULADA A AQUELE TOKEN
    function getTokenURI(uint256 _tokenId) public view returns(string memory) {
        return _tokensURI[_tokenId];
    }

    //ESSA FUNÇÃO É OVERRIDE, ISSO QUER DIZER QUE SOBRESCREVE A JÁ EXISTENTE IMPORTADA NA OPENZEPPIL, POIS A URI É ALGO INDIVIDUAL DA APLICAÇÃO, NA FUNÇÃO ORIGINAL ERA RETORNADO NADA.
    function _baseURI() internal view virtual override returns(string memory) {
        return baseUri;
    }

    //ESTA FUNÇÃO RETORNA UMA URI A QUAL É RESULTADO DA JUNÇÃO DA BASEURI, O ID DO TOKE E A EXTENSÃO .JSON 
    function tokenURI(uint256 _tokenId) private view virtual override returns(string memory) {
        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        _tokenId.toString(),
                        ".json"
                    )
                ) //O MÉTODO ENCODEPACKED( ) É UTILIZADO PARA REUNIR AQUELAS 3 INFOMRAÇÕES, ELE FAZ ISSO CONSUMINDO MENOS GAS QUE UMA CONCATENAÇÃO COMUM CONSUMIRIA
                : ""
        ;
    }

    //ESTA FUNÇÃO RETORNA O VALOR TOTAL DAS TRANSAÇÕES FEITAS NESSE CONTRATO, ISSO QUER DIZER A SOMA DE COMPRA DE TODOS OS NFTs
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    //ESTA FUNÇÃO ASSUME O PAPEL DE RETORNAR A QUANTIDADE DE TOKENS ATIVOS, É RETORNADO O ID POIS ELE SEGUE A CONTAGEM DE TOKENS EXISTENTES
    function totalSupply() public view returns(uint256) {
        return tokensId; 
    }
}

// FUNÇÕES ERC-721
// constructor(name_, symbol_)

// supportsInterface(interfaceId)

// balanceOf(owner)

// ownerOf(tokenId)

// name()

// symbol()

// tokenURI(tokenId) : Esta função recebe o id do token e retorna a URI a qual será a concatenação da baseURI + o id do token caso não haja uma função _baseURI que retorne algo será retornado ""
//_setTokenURI(uint256 tokenId, string _tokenURI) : Sendo de uso interno essa função associa um URI a um token
// _baseURI(): Esta função deve retornar em formato de string a base da URI de onde esta armazenado os metadados dos NFT, essa função precisa ser escrita de forma override e ela será utilizada em outras funções como tokenURI(). É IMPORTANTE VERIFICAR SE A BASE URI TERMINA COM / 

// approve(to, tokenId) : Permite que um endereço gaste NFT em seu nome

// getApproved(tokenId) : Retorna o endereço de quem estar aprovado para gastar o NFT em nome de outro endereço 

// setApprovalForAll(operator, approved) : Permite que um endereço gaste todos os seus NFTs em seu nome

// isApprovedForAll(owner, operator) : Retorna se um endereço estar aprovado para gastar todos os NFTs daquele proprietário

// transferFrom(from, to, tokenId)

// safeTransferFrom(from, to, tokenId)

// safeTransferFrom(from, to, tokenId, data)

// _safeTransfer(from, to, tokenId, data)

// _ownerOf(tokenId)

// _exists(tokenId)

// _isApprovedOrOwner(spender, tokenId)

// _safeMint(to, tokenId)

// _safeMint(to, tokenId, data)

// _mint(to, tokenId)

// _burn(tokenId)

// _transfer(from, to, tokenId)

// _approve(to, tokenId)

// _setApprovalForAll(owner, operator, approved)

// _requireMinted(tokenId)

// _beforeTokenTransfer(from, to, firstTokenId, batchSize)

// _afterTokenTransfer(from, to, firstTokenId, batchSize)

// __unsafe_increaseBalance(account, amount)

// EVENTOS 
// Transfer(from, to, tokenId)

// Approval(owner, approved, tokenId)

// ApprovalForAll(owner, operator, approved)