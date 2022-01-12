import RichEntitledFuck from 0xf8d6e0586b0a20c7

transaction(metadata: {String : String}) {
    let receiverRef: &{RichEntitledFuck.NFTReceiver}
    let minterRef: &RichEntitledFuck.NFTMinter

    // Take the account info of the user trying to execute the transaction and validate.
    // Here we try to "borrow" the capabilities available on `NFTMinter` and `NFTReceiver`
    // resources, and will fail if the user executing this transaction does not have access
    // to these resources.
    prepare(acct: AuthAccount) {
        self.receiverRef = acct.getCapability<&{RichEntitledFuck.NFTReceiver}>(/public/NFTReceiver)
            .borrow()
            ?? panic("Could not borrow receiver reference")
        self.minterRef = acct.borrow<&RichEntitledFuck.NFTMinter>(from: /storage/NFTMinter)
            ?? panic("Could not borrow minter reference")
    }

    execute {

        // Mint the token by calling `mint()` on `@NFTMinter` resource, which returns
        // an `@NFT` resource, and move it to a variable `newNFT`.
        let newNFT <- self.minterRef.mint()

        // Call `deposit(..)` on the `@NFTReceiver` resource to deposit the token.
        // Note that this is where the metadata can be changed before transferring.
        self.receiverRef.deposit(token: <-newNFT, metadata: metadata)
        log("NFT Minted and deposited to Collection")
    }
}