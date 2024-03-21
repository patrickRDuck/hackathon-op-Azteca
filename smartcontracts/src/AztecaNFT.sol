// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
contract AztecaNFT is ERC721, Ownable {
    using Strings for uint256;
    
    uint256 tokensId;
    uint256 maxSupply = 2;
    uint256 price = 0.07 ether;
    string internal baseUri = "https://harlequin-famous-heron-61.mypinata.cloud/ipfs/QmXPazcSy69GV2G1XKi88bwUP33YenmvQsQgpsYw3whXLa/";
   
    mapping(uint256 _tokenId => string _tokeURI) private _tokensURI;
    mapping(uint256 _tokenId => uint256 _value) public NftsForSale; 

    error MaxSupplyExcessed(uint256 _quantity);
    error ValueNotEnough(uint256 _value);
    error FailedTransfer();
    error NftDoesntExist(uint256 _tokenId);
    error IncorrectNftOwner();
    error ValueBellowTheAllowed(string _menssage);
    error NftNotForSale();
    
    event WithDrawn(address _owner, uint256 _balance);
    event NftPutUpForSale(address _owner, uint256 _value);
    event NftPurchased(address _oldOwner, address _newOwner, uint256 _value);
    
    constructor() ERC721("Azteca", "AZT") Ownable( 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266) {
    }
    
    function _setTokenURI(uint256 _tokenId) internal {
        require(_owners[_tokenId] != address(0), "TOKEN DOES NOT EXIST");
        _tokensURI[_tokenId] = tokenURI(_tokenId);
    }

    function _baseURI() internal view override returns(string memory) {
        return baseUri;
    }

    function verifyNftExist(uint256 _tokenId) internal view {
        if(_owners[_tokenId] == address(0)) {
            revert  NftDoesntExist(_tokenId);
        } 
    }

    function verifyNftOwner(uint256 _tokenId, address _from) private view {
        if(_owners[_tokenId] != _from) {
            revert IncorrectNftOwner();
        }
    }   

    //APESAR DA FUNÇÃO UTILIZAR UMA ESTRUTURA DE LOOPING ELA NÃO É RECOMENDADA POIS CONSOME MUITA GAS
    function makeMint(address _to, uint256 _amount) public payable {
        if(totalSupply() + _amount > maxSupply) {
            revert MaxSupplyExcessed(_amount);
        }

        uint256 calcValue = price * _amount;
        if(calcValue > msg.value){
            revert ValueNotEnough(calcValue);
        }

        for(uint256 i = 0; i < _amount; i++) {
            tokensId += 1;
            _safeMint(_to, tokensId);
            _setTokenURI(tokensId);
        }
    }

    function putNftForSale(uint256 _tokenId, uint256 _value) public {
        verifyNftExist(_tokenId);
        verifyNftOwner(_tokenId, msg.sender);

        if(_value <= 0) {
            revert  ValueBellowTheAllowed("The sales value must be greater than 0");
        }

        NftsForSale[_tokenId] = _value;

        emit NftPutUpForSale(msg.sender, _value);
    }

    function buyNft(uint256 _tokenId) public payable {
        uint256 memory purchasePrice = NftsForSale[_tokenId];
        address memory ownerBeforeSale = _owners[_tokenId];

        if(purchasePrice == 0) {
            revert NftNotForSale();
        }

        if(purchasePrice > msg.value) {
            revert ValueNotEnough(purchasePrice);
        }

        (bool success,) = ownerBeforeSale.call{value: msg.value}("");
        if(!success) {
            revert FailedTransfer();
        }

        _owners[_tokenId] = msg.sender;

        delete NftsForSale[_tokenId];

        emit NftPurchased(ownerBeforeSale, msg.sender, purchasePrice);
    }

    //FUNÇÃO CRIADA POR NOS PARA FORNECER A URI VINCULADA A AQUELE TOKEN
    function getTokenURI(uint256 _tokenId) public view returns(string memory) {
        return _tokensURI[_tokenId];
    }
    
    //ESTA FUNÇÃO RETORNA UMA URI A QUAL É RESULTADO DA JUNÇÃO DA BASEURI, O ID DO TOKE E A EXTENSÃO .JSON 
    function tokenURI(uint256 _tokenId) public view override returns(string memory) {
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

    //ESTA FUNÇÃO PASSA AS CRIPTOS RECEBIDAS NO CONTRATO PARA OUTRA CARTEIRA, A FUNÇÃO SO PODE SER CHAMADA PELO DONO, QUEM IRÁ FAZER ESSA VERIFICAÇÃO É O ONLYOWNER. O PRIMEIRO DONO É AQUELE QUE FAZ O DEPLOY DO CONTRATO, POSTERIORMENTE É POSSÍVEL TRANSFERIRI A TITULARIDADE DO CONTRATO
    function withDraw() external onlyOwner {
        uint256 _balance = address(this).balance;
        (bool success,) = msg.sender.call{value: _balance}("");
        if(!success) {
            revert FailedTransfer();
        }
        emit WithDrawn(msg.sender, _balance);
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

