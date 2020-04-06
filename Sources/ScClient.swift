import Starscream
import Foundation

public class ScClient: Listener {
    // MARK: - property
    var authToken: String?
    var url: String?
    var socket: WebSocket!
    var counter: AtomicInteger
    private(set)var socketId: String?
    
    var onConnect: ((ScClient) -> Void)?
    var onConnectError: ((ScClient, Error?) -> Void)?
    var onDisconnect: ((ScClient, Error?) -> Void)?
    var onSetAuthentication: ((ScClient, String?) -> Void)?
    var onAuthentication: ((ScClient, Bool?) -> Void)?
    
    // MARK: - init
    public init(url: URL, authToken: String? = nil) {
        self.counter = AtomicInteger()
        self.authToken = authToken
        self.socket = WebSocket(url: url)
        super.init()
        socket.delegate = self
    }
    
    public init(urlRequest: URLRequest, authToken: String? = nil, protocols: [String]? = nil) {
        self.counter = AtomicInteger()
        self.authToken = authToken
        self.socket = WebSocket(request: urlRequest, protocols: protocols)
        super.init()
        socket.delegate = self
    }
    
    // MARK: - methods
    public func setBasicListener(onConnect: ((ScClient) -> Void)?, onConnectError: ((ScClient, Error?) -> Void)?, onDisconnect: ((ScClient, Error?) -> Void)?) {
        self.onConnect = onConnect
        self.onDisconnect = onDisconnect
        self.onConnectError = onConnectError
    }
    
    public func setAuthenticationListener (onSetAuthentication: ((ScClient, String?) -> Void)?, onAuthentication: ((ScClient, Bool?) -> Void)?) {
        self.onSetAuthentication = onSetAuthentication
        self.onAuthentication = onAuthentication
    }
    
    public func setBackgroundQueue(queueName: String) {
        socket.callbackQueue = DispatchQueue(label: queueName)
    }
    
    public func setWebSocket(with url: URL) {
        self.socket = WebSocket(url: url)
        socket.delegate = self
    }
    
    public func connect() {
        socket.connect()
    }
    
    public func isConnected() -> Bool {
        return socket.isConnected
    }
    
    public func setAuthToken(token: String) {
        self.authToken = token
    }
    
    public func getAuthToken() -> String? {
        return self.authToken
    }
    
    private func sendHandShake() {
        let handshake = Model.getHandshakeObject(authToken: self.authToken, messageId: counter.incrementAndGet())
        socket.write(string: handshake.toJSONString()!)
    }
    
    private func ack(cid: Int) -> (AnyObject?, AnyObject?) -> Void {
        return {
            (error: AnyObject?, data: AnyObject?) in
            let ackObject = Model.getReceiveEventObject(data: data, error: error, messageId: cid)
            self.socket.write(string: ackObject.toJSONString()!)
        }
    }
    
    public func emit(eventName: String, data: AnyObject?) {
        let emitObject = Model.getEmitEventObject(eventName: eventName, data: data, messageId: counter.incrementAndGet())
        self.socket.write(string: emitObject.toJSONString()!)
    }
    
    public func emitAck(eventName: String, data: AnyObject?, ack: @escaping (String, AnyObject?, AnyObject?) -> Void) {
        let id = counter.incrementAndGet()
        let emitObject = Model.getEmitEventObject(eventName: eventName, data: data, messageId: id)
        putEmitAck(id: id, eventName: eventName, ack: ack)
        self.socket.write(string: emitObject.toJSONString()!)
    }
    
    public func subscribe(channelName: String) {
        let subscribeObject = Model.getSubscribeEventObject(channelName: channelName, messageId: counter.incrementAndGet())
        self.socket.write(string: subscribeObject.toJSONString()!)
    }
    
    public func subscribeAck(channelName: String, ack: @escaping (String, AnyObject?, AnyObject?) -> Void) {
        let id = counter.incrementAndGet()
        let subscribeObject = Model.getSubscribeEventObject(channelName: channelName, messageId: id)
        putEmitAck(id: id, eventName: channelName, ack: ack)
        self.socket.write(string: subscribeObject.toJSONString()!)
    }
    
    public func unsubscribe(channelName: String) {
        let unsubscribeObject = Model.getUnsubscribeEventObject(channelName: channelName, messageId: counter.incrementAndGet())
        self.socket.write(string: unsubscribeObject.toJSONString()!)
    }
    
    public func unsubscribeAck(channelName: String, ack: @escaping (String, AnyObject?, AnyObject?) -> Void) {
        let id = counter.incrementAndGet()
        let unsubscribeObject = Model.getUnsubscribeEventObject(channelName: channelName, messageId: id)
        putEmitAck(id: id, eventName: channelName, ack: ack)
        self.socket.write(string: unsubscribeObject.toJSONString()!)
    }
    
    public func publish(channelName: String, data: AnyObject?) {
        let publishObject = Model.getPublishEventObject(channelName: channelName, data: data, messageId: counter.incrementAndGet())
        self.socket.write(string: publishObject.toJSONString()!)
    }
    
    public func publishAck(channelName: String, data: AnyObject?, ack: @escaping (String, AnyObject?, AnyObject?) -> Void) {
        let id = counter.incrementAndGet()
        let publishObject = Model.getPublishEventObject(channelName: channelName, data: data, messageId: id)
        putEmitAck(id: id, eventName: channelName, ack: ack)
        self.socket.write(string: publishObject.toJSONString()!)
    }
    
    public func onChannel(channelName: String, ack: @escaping (String, AnyObject?) -> Void) {
        putOnListener(eventName: channelName, onListener: ack)
    }
    
    public func on(eventName: String, ack: @escaping (String, AnyObject?) -> Void) {
        putOnListener(eventName: eventName, onListener: ack)
    }
    
    public func onAck(eventName: String, ack: @escaping (String, AnyObject?, (AnyObject?, AnyObject?) -> Void) -> Void) {
        putOnAckListener(eventName: eventName, onAckListener: ack)
    }
    
    public func disconnect() {
        socket.disconnect()
    }
    
    public func disableSSLVerification(value : Bool) {
        socket.disableSSLCertValidation = value
    }
    
    public func useSSLCertificate() {
        socket.security = SSLSecurity()
    }
    
    public func loadSSLCertificateFromData(data: Data, usePublicKeys: Bool = false) {
        socket.security = SSLSecurity(certs: [SSLCert(data: data)], usePublicKeys: usePublicKeys)
    }
}

// MARK: - WebSocketDelegate
extension ScClient: WebSocketDelegate {
    public func websocketDidConnect(socket: WebSocketClient) {
        counter.value = 0
        self.sendHandShake()
        onConnect?(self)
    }
    
    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        onDisconnect?(self, error)
    }
    
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        if (text == "") {
            socket.write(string: "")
        } else {
            if let messageObject = JSONConverter.deserializeString(message: text) {
                if let (data, rid, cid, eventName, error) = Parser.getMessageDetails(myMessage: messageObject) {
                    
                    let parseResult = Parser.parse(rid: rid, cid: cid, event: eventName)
                    
                    switch parseResult {
                        
                    case .isAuthenticated:
                        let isAuthenticated = ClientUtils.getIsAuthenticated(message: messageObject)
                        if isAuthenticated != nil {
                            self.socketId = ClientUtils.getSocketId(message: messageObject)
                        }
                        onAuthentication?(self, isAuthenticated)
                    case .publish:
                        if let channel = Model.getChannelObject(data: data as AnyObject) {
                            handleOnListener(eventName: channel.channel, data: channel.data as AnyObject)
                        }
                    case .removeToken:
                        self.authToken = nil
                    case .setToken:
                        authToken = ClientUtils.getAuthToken(message: messageObject)
                        self.onSetAuthentication?(self, authToken)
                    case .ackReceive:
                        
                        handleEmitAck(id: rid!, error: error as AnyObject, data: data as AnyObject)
                    case .event:
                        if hasEventAck(eventName: eventName!) {
                            handleOnAckListener(eventName: eventName!, data: data as AnyObject, ack: self.ack(cid: cid!))
                        } else {
                            handleOnListener(eventName: eventName!, data: data as AnyObject)
                        }
                        
                    }
                    
                }
            }
        }
    }
    
    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Received data: \(data.count)")
    }
}

