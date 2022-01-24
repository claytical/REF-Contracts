import RichEntitledFuck from "../contracts/RichEntitledFuck.cdc"
import MetadataViews from "../contracts/MetadataViews.cdc"

pub struct NFT {
    pub let name: String
    pub let description: String
    pub let thumbnail: String
    pub let uri: String
    pub let owner: Address
    pub let type: String

    init(
        name: String,
        description: String,
        thumbnail: String,
        uri: String,
        owner: Address,
        nftType: String,
    ) {
        self.name = name
        self.description = description
        self.thumbnail = thumbnail
        self.uri = uri
        self.owner = owner
        self.type = nftType
    }
}

pub fun main(address: Address, id: UInt64): NFT {
    let account = getAccount(address)

    let collection = account
        .getCapability(RichEntitledFuck.CollectionPublicPath)
        .borrow<&{RichEntitledFuck.RichEntitledFuckCollectionPublic}>()
        ?? panic("Could not borrow a reference to the collection")

    let nft = collection.borrowRichEntitledFuck(id: id)!

    // Get the basic display information for this NFT
    let view = nft.resolveView(Type<MetadataViews.Display>())!

    let display = view as! MetadataViews.Display
    
    let owner: Address = nft.owner!.address!
    let nftType = nft.getType()

    return NFT(
        name: display.name,
        description: display.description,
        thumbnail: display.thumbnail.uri(),
        uri: display.uri,
        owner: owner,
        nftType: nftType.identifier,
    )
}