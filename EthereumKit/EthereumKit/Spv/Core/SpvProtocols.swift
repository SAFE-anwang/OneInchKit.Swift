import RxSwift
import HSCryptoKit

protocol ISpvStorage: IStorage {
    var lastBlockHeader: BlockHeader? { get }
    func blockHeader(height: Int) -> BlockHeader?
    func reversedLastBlockHeaders(from height: Int, limit: Int) -> [BlockHeader]
    func save(blockHeaders: [BlockHeader])

    var accountState: AccountState? { get }
    func save(accountState: AccountState)
}

protocol IRandomHelper: class {
    var randomInt: Int { get }
    func randomKey() -> ECKey
    func randomBytes(length: Int) -> Data
    func randomBytes(length: Range<Int>) -> Data
}

protocol IFactory: class {
    func authMessage(signature: Data, publicKeyPoint: ECPoint, nonce: Data) -> AuthMessage
    func authAckMessage(data: Data) throws -> AuthAckMessage
    func keccakDigest() -> KeccakDigest
    func frameCodec(secrets: Secrets) -> FrameCodec
    func encryptionHandshake(myKey: ECKey, publicKey: Data) -> EncryptionHandshake
}

protocol IFrameCodecHelper {
    func updateMac(mac: KeccakDigest, macKey: Data, data: Data) -> Data
    func toThreeBytes(int: Int) -> Data
    func fromThreeBytes(data: Data) -> Int
}

protocol IAESCipher {
    func process(_ data: Data) -> Data
}

protocol IECIESCryptoUtils {
    func ecdhAgree(myKey: ECKey, remotePublicKeyPoint: ECPoint) -> Data
    func ecdhAgree(myPrivateKey: Data, remotePublicKeyPoint: Data) -> Data
    func concatKDF(_ data: Data) -> Data
    func sha256(_ data: Data) -> Data
    func aesEncrypt(_ data: Data, withKey: Data, keySize: Int, iv: Data) -> Data
    func hmacSha256(_ data: Data, key: Data, iv: Data, macData: Data) -> Data
}

protocol ICryptoUtils: class {
    func ecdhAgree(myKey: ECKey, remotePublicKeyPoint: ECPoint) -> Data
    func ellipticSign(_ messageToSign: Data, key: ECKey) throws -> Data
    func eciesDecrypt(privateKey: Data, message: ECIESEncryptedMessage) throws -> Data
    func eciesEncrypt(remotePublicKey: ECPoint, message: Data) -> ECIESEncryptedMessage
    func sha3(_ data: Data) -> Data
    func aesEncrypt(_ data: Data, withKey: Data, keySize: Int) -> Data
}

protocol IPeerDelegate: class {
    func didConnect()
    func didDisconnect(error: Error?)

    func didReceive(blockHeaders: [BlockHeader], blockHeader: BlockHeader, reverse: Bool)
    func didReceive(accountState: AccountState, address: Data, blockHeader: BlockHeader)
    func didAnnounce(blockHash: Data, blockHeight: Int)
}

protocol IDevP2PPeerDelegate: class {
    func didConnect()
    func didDisconnect(error: Error?)
    func didReceive(message: IInMessage)
}

protocol IConnectionDelegate: class {
    func didConnect()
    func didDisconnect(error: Error?)
    func didReceive(frame: Frame)
}

protocol IPeer: class {
    var delegate: IPeerDelegate? { get set }

    func connect()
    func disconnect(error: Error?)

    func requestBlockHeaders(blockHeader: BlockHeader, limit: Int, reverse: Bool)
    func requestAccountState(address: Data, blockHeader: BlockHeader)

    func send(rawTransaction: RawTransaction, nonce: Int, signature: Signature)
}

protocol IConnection: class {
    var delegate: IConnectionDelegate? { get set }

    func connect()
    func disconnect(error: Error?)
    func send(frame: Frame)
}

protocol IFrameConnection: class {
    var delegate: IFrameConnectionDelegate? { get set }

    func connect()
    func disconnect(error: Error?)
    func send(packetType: Int, payload: Data)
}

protocol IFrameConnectionDelegate: class {
    func didConnect()
    func didDisconnect(error: Error?)
    func didReceive(packetType: Int, payload: Data)
}

protocol IDevP2PConnection: class {
    var delegate: IDevP2PConnectionDelegate? { get set }

    func register(sharedCapabilities: [Capability])

    func connect()
    func disconnect(error: Error?)
    func send(message: IOutMessage)
}

protocol IDevP2PConnectionDelegate: class {
    func didConnect()
    func didDisconnect(error: Error?)
    func didReceive(message: IInMessage)
}

protocol INetwork {
    var chainId: Int { get }
    var genesisBlockHash: Data { get }
    var checkpointBlock: BlockHeader { get }
}

protocol IPeerGroupDelegate: class {
    func onUpdate(syncState: EthereumKit.SyncState)
    func onUpdate(accountState: AccountState)
}

protocol IPeerGroup {
    var delegate: IPeerGroupDelegate? { get set }

    var syncState: EthereumKit.SyncState { get }

    func start()

    func send(rawTransaction: RawTransaction, nonce: Int, signature: Signature)
}

protocol IDevP2PPeer {
    func connect()
    func disconnect(error: Error?)
    func send(message: IOutMessage)
}

protocol IMessage {
    func toString() -> String
}

protocol IInMessage: IMessage {
    init(data: Data) throws
}

protocol IOutMessage: IMessage {
    func encoded() -> Data
}

protocol ICapabilityHelper {
    func sharedCapabilities(myCapabilities: [Capability], nodeCapabilities: [Capability]) -> [Capability]
}

protocol IPeerProvider {
    func peer() -> IPeer
}

protocol IBlockHelper {
    var lastBlockHeader: BlockHeader { get }
}