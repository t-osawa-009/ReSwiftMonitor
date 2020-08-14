import Foundation
import ReSwift
import MultipeerConnectivity

public struct BrowserMiddleware {
    public static func make() -> Middleware<StateType> {
        return { dispatch, fetchState in
            return { next in
                return { action in
                    next(action)
                    ActionSender.send(state: fetchState()!, action: action)
                }
            }
        }
    }
}

private enum ActionSender {
    static func send(state: StateType, action: Action) {
        let serializedState = MonitorSerialization.convertValueToDictionary(state)
        var serializedAction = MonitorSerialization.convertValueToDictionary(action)
        
        if var _serializedAction = serializedAction as? [String: Any] {
            // add type to nicely show the action name in the UI
            _serializedAction["type"] = typeString(action: action)
            serializedAction = _serializedAction
        }
        
        let data: [String: Any] = [
            "action": serializedAction ?? "No_action",
            "timestamp": Date().timeIntervalSinceReferenceDate,
            "state": serializedState ?? "No_state"
        ]
        
        guard JSONSerialization.isValidJSONObject(data),
            let json = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted) else {
            return
        }
        MultipeerConnectivityWrapper.shared.send(data: json)
    }
    
    private static func typeString(action: Action) -> String {
        let mirror = Mirror(reflecting: action)
        if mirror.displayStyle == .enum {
            let str = String(reflecting: action)
            if let firstSegment = str.split(separator: ":").first {
                return String(firstSegment) + "..."
            }
            return str
        }
        
        return String(reflecting: type(of: action))
    }
}



private struct Constants {
    static let serviceType = "rebrowser"
}

private enum SessionState: String {
    case notConnected
    case connecting
    case connected
}

private final class MultipeerConnectivityWrapper: NSObject {
    // MARK: - internal
    static let shared = MultipeerConnectivityWrapper()
    
    func start() {
        advertiserAssistant.delegate = self
        advertiserAssistant.start()
        
        nearbyServiceBrowser.delegate = self
        nearbyServiceBrowser.startBrowsingForPeers()
        
        session.delegate = self
        restartAdvertising()
    }
    
    func reset() {
        restartAdvertising()
        stop()
        start()
    }
    
    func stop() {
        advertiserAssistant.delegate = nil
        advertiserAssistant.stop()
        
        nearbyServiceBrowser.delegate = nil
        nearbyServiceBrowser.startBrowsingForPeers()
        
        disconnect()
    }
    
    func disconnect() {
        session.delegate = nil
        session.disconnect()
    }
    
    func stopAdvertising() {
        nearbyServiceAdvertiser.delegate = nil
        nearbyServiceAdvertiser.stopAdvertisingPeer()
    }
    
    func restartAdvertising() {
        stopAdvertising()
        nearbyServiceAdvertiser.delegate = self
        nearbyServiceAdvertiser.startAdvertisingPeer()
    }
    
    func send(data: Data) {
        if session.connectedPeers.isEmpty {
            pendingData.append(data)
            return
        }
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            pendingData = pendingData.filter({ $0 != data })
        } catch {
            
        }
    }
    
    // MARK: - initializer
    private override init() {
        peerID = .init(displayName: UIDevice.current.name)
        nearbyServiceBrowser = .init(peer: peerID,
                                     serviceType: Constants.serviceType)
        session = .init(peer: peerID)
        advertiserAssistant = .init(serviceType: Constants.serviceType,
                                    discoveryInfo: nil,
                                    session: session)
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID,
                                                            discoveryInfo: nil,
                                                            serviceType: Constants.serviceType)
        super.init()
        session.delegate = self
        start()
    }
    
    // MARK: - private
    private var peerID: MCPeerID
    private var nearbyServiceBrowser: MCNearbyServiceBrowser
    private var session: MCSession
    private var advertiserAssistant: MCAdvertiserAssistant
    private var nearbyServiceAdvertiser: MCNearbyServiceAdvertiser
    private(set) var state: SessionState = .notConnected
    private var pendingData: [Data] = []
}

extension MultipeerConnectivityWrapper: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            if state == .connected {
                restartAdvertising()
            }
            self.state = .notConnected
        case .connecting:
            self.state = .connecting
        case .connected:
            if state != .connected {
                stopAdvertising()
            }
            if !session.connectedPeers.isEmpty {
                pendingData.forEach({ send(data: $0) })
            }
            self.state = .connected
        @unknown default:
            fatalError("no support")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
}

extension MultipeerConnectivityWrapper: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        let session = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 0)
        self.session = session
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
    }
}

extension MultipeerConnectivityWrapper: MCAdvertiserAssistantDelegate {
    
}

extension MultipeerConnectivityWrapper: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}
